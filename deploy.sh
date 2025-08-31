#!/bin/bash

# 🚀 Скрипт автоматического развертывания Zarinit
# Версия: 1.0

set -e  # Остановка при ошибке

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для вывода сообщений
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Проверка зависимостей
check_dependencies() {
    log "Проверка зависимостей..."
    
    if ! command -v docker &> /dev/null; then
        error "Docker не установлен. Установите Docker и повторите попытку."
    fi
    
    if ! command -v docker compose &> /dev/null; then
        error "Docker Compose не установлен. Установите Docker Compose и повторите попытку."
    fi
    
    # Проверка, что Docker запущен
    if ! docker info &> /dev/null; then
        error "Docker не запущен. Запустите Docker и повторите попытку."
    fi
    
    log "Все зависимости установлены ✓"
}

# Проверка структуры проекта
check_project_structure() {
    log "Проверка структуры проекта..."
    
    if [ ! -f "docker-compose.yml" ]; then
        error "Файл docker-compose.yml не найден. Убедитесь, что вы находитесь в корневой папке проекта."
    fi
    
    if [ ! -f "nginx.conf" ]; then
        error "Файл nginx.conf не найден."
    fi
    
    if [ ! -d "dist" ]; then
        error "Папка dist не найдена. Выполните сборку фронтенда: npm run build"
    fi
    
    if [ ! -d "../cloud-auth" ]; then
        error "Папка cloud-auth не найдена в родительской директории."
        error "Убедитесь, что структура проекта выглядит так:"
        error "  parent-folder/"
        error "  ├── ZarinitNew/"
        error "  └── cloud-auth/"
        error ""
        error "Для исправления:"
        error "1. Клонируйте репозиторий cloud-auth в родительскую папку"
        error "2. Или измените путь в docker-compose.yml на абсолютный"
    fi
    
    log "Структура проекта проверена ✓"
}

# Проверка портов
check_ports() {
    log "Проверка доступности портов..."
    
    if lsof -Pi :80 -sTCP:LISTEN -t >/dev/null 2>&1; then
        warn "Порт 80 уже используется. Возможные решения:"
        warn "1. Остановите процесс, использующий порт 80"
        warn "2. Измените порт в docker-compose.yml (например, на 8080:80)"
        read -p "Продолжить? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    log "Порты проверены ✓"
}

# Остановка существующих контейнеров
stop_existing() {
    log "Остановка существующих контейнеров..."
    docker compose down 2>/dev/null || true
    log "Существующие контейнеры остановлены ✓"
}

# Сборка образов
build_images() {
    log "Сборка Docker образов..."
    docker compose build --no-cache
    log "Образы собраны ✓"
}

# Запуск контейнеров
start_containers() {
    log "Запуск контейнеров..."
    docker compose up -d
    log "Контейнеры запущены ✓"
}

# Ожидание готовности сервисов
wait_for_services() {
    log "Ожидание готовности сервисов..."
    
    # Ждем базу данных
    info "Ожидание готовности базы данных..."
    timeout=60
    while [ $timeout -gt 0 ]; do
        if docker compose exec -T auth-db pg_isready -U postgres >/dev/null 2>&1; then
            break
        fi
        sleep 2
        timeout=$((timeout-2))
    done
    
    if [ $timeout -le 0 ]; then
        error "База данных не готова через 60 секунд"
    fi
    
    # Ждем auth-backend
    info "Ожидание готовности auth-backend..."
    timeout=30
    while [ $timeout -gt 0 ]; do
        if curl -s http://localhost/auth/login >/dev/null 2>&1; then
            break
        fi
        sleep 2
        timeout=$((timeout-2))
    done
    
    if [ $timeout -le 0 ]; then
        error "Auth-backend не готов через 30 секунд"
    fi
    
    log "Все сервисы готовы ✓"
}

# Проверка работоспособности
health_check() {
    log "Проверка работоспособности..."
    
    # Проверяем главную страницу
    if curl -s http://localhost/ | grep -q "<!DOCTYPE html>"; then
        log "Главная страница: ✓"
    else
        error "Главная страница недоступна"
    fi
    
    # Проверяем страницу логина
    if curl -s http://localhost/auth/login | grep -q "Система управления"; then
        log "Страница логина: ✓"
    else
        error "Страница логина недоступна"
    fi
    
    # Проверяем статические файлы
    if curl -s -I http://localhost/static/bundle.js | grep -q "200 OK"; then
        log "Статические файлы: ✓"
    else
        error "Статические файлы недоступны"
    fi
    
    log "Все проверки пройдены ✓"
}

# Показать информацию о развертывании
show_deployment_info() {
    echo
    echo "🎉 Развертывание завершено успешно!"
    echo
    echo "📋 Информация о доступе:"
    echo "  🌐 Основное приложение: http://localhost/"
    echo "  🔐 Система аутентификации: http://localhost/auth/login"
    echo "  👤 Админ-панель: http://localhost/auth/dashboard"
    echo
    echo "🔑 Данные для входа по умолчанию:"
    echo "  📧 Email: root@admin.com"
    echo "  🔒 Пароль: admin123"
    echo
    echo "🛠️ Полезные команды:"
    echo "  📊 Статус контейнеров: docker compose ps"
    echo "  📝 Логи: docker compose logs"
    echo "  🔄 Перезапуск: docker compose restart"
    echo "  ⏹️  Остановка: docker compose down"
    echo
}

# Основная функция
main() {
    echo "🚀 Zarinit Deployment Script v1.0"
    echo "=================================="
    echo
    
    check_dependencies
    check_project_structure
    check_ports
    stop_existing
    build_images
    start_containers
    wait_for_services
    health_check
    show_deployment_info
}

# Обработка сигналов
trap 'error "Развертывание прервано пользователем"' INT TERM

# Запуск
main "$@"