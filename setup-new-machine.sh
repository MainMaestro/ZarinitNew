#!/bin/bash

# 🚀 Скрипт настройки Zarinit на новом компьютере
# Автоматически устанавливает зависимости и настраивает проект

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARNING] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; exit 1; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }

# Определение ОС
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt &> /dev/null; then
            OS="ubuntu"
        elif command -v yum &> /dev/null; then
            OS="centos"
        else
            OS="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        OS="unknown"
    fi
    log "Обнаружена ОС: $OS"
}

# Установка Docker
install_docker() {
    log "Проверка Docker..."
    
    if command -v docker &> /dev/null; then
        log "Docker уже установлен ✓"
        return
    fi
    
    log "Установка Docker..."
    
    case $OS in
        "ubuntu")
            sudo apt update
            sudo apt install -y docker.io docker-compose-plugin
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker $USER
            ;;
        "centos")
            sudo yum install -y docker docker-compose
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker $USER
            ;;
        "macos")
            warn "Для macOS установите Docker Desktop вручную:"
            warn "https://www.docker.com/products/docker-desktop/"
            read -p "Нажмите Enter после установки Docker Desktop..."
            ;;
        *)
            error "Неподдерживаемая ОС. Установите Docker вручную."
            ;;
    esac
    
    log "Docker установлен ✓"
}

# Проверка Git
check_git() {
    if ! command -v git &> /dev/null; then
        log "Установка Git..."
        case $OS in
            "ubuntu") sudo apt install -y git ;;
            "centos") sudo yum install -y git ;;
            "macos") 
                if command -v brew &> /dev/null; then
                    brew install git
                else
                    error "Установите Git вручную или установите Homebrew"
                fi
                ;;
        esac
    fi
    log "Git доступен ✓"
}

# Клонирование проектов
clone_projects() {
    log "Настройка проектов..."
    
    # Запрашиваем URL репозиториев
    echo
    info "Введите URL репозиториев:"
    read -p "URL основного проекта (ZarinitNew): " MAIN_REPO
    read -p "URL системы аутентификации (cloud-auth) [Enter для пропуска]: " AUTH_REPO
    
    # Создаем рабочую папку
    WORK_DIR="$HOME/zarinit-deployment"
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"
    
    # Клонируем основной проект
    if [ ! -d "ZarinitNew" ]; then
        log "Клонирование основного проекта..."
        git clone "$MAIN_REPO" ZarinitNew
    fi
    
    # Клонируем систему аутентификации (если указана)
    if [ -n "$AUTH_REPO" ] && [ ! -d "cloud-auth" ]; then
        log "Клонирование системы аутентификации..."
        git clone "$AUTH_REPO" cloud-auth
    fi
    
    cd ZarinitNew
    log "Проекты настроены в: $WORK_DIR"
}

# Настройка конфигурации
setup_config() {
    log "Настройка конфигурации..."
    
    # Исправляем путь к cloud-auth
    if [ -d "../cloud-auth" ]; then
        log "Настройка полной системы с аутентификацией..."
        sed -i.bak 's|/home/armen/Документы/cloud-auth|../cloud-auth|g' docker-compose.yml
        DEPLOYMENT_MODE="full"
    else
        warn "cloud-auth не найден. Будет использован режим только фронтенда."
        DEPLOYMENT_MODE="frontend-only"
    fi
    
    # Создаем .env файл
    if [ ! -f ".env" ]; then
        log "Создание файла переменных окружения..."
        cp .env.example .env 2>/dev/null || cat > .env << 'EOF'
POSTGRES_DB=adminka
POSTGRES_USER=postgres
POSTGRES_PASSWORD=secure_password_$(date +%s)
ROOT_USER_EMAIL=admin@localhost
ROOT_USER_PASSWORD=admin123
SECRET_KEY=secret_key_$(openssl rand -hex 32)
NGINX_PORT=80
EOF
    fi
    
    log "Конфигурация настроена ✓"
}

# Проверка портов
check_ports() {
    log "Проверка портов..."
    
    if lsof -Pi :80 -sTCP:LISTEN -t >/dev/null 2>&1; then
        warn "Порт 80 занят. Изменяем на 8080..."
        sed -i.bak 's/"80:80"/"8080:80"/g' docker-compose*.yml
        PORT=8080
    else
        PORT=80
    fi
    
    log "Будет использован порт: $PORT"
}

# Запуск системы
deploy_system() {
    log "Запуск системы..."
    
    # Проверяем, что Docker работает
    if ! docker info &> /dev/null; then
        warn "Docker не запущен. Попытка запуска..."
        case $OS in
            "ubuntu"|"centos") sudo systemctl start docker ;;
            "macos") open -a Docker ;;
        esac
        
        # Ждем запуска Docker
        timeout=30
        while [ $timeout -gt 0 ] && ! docker info &> /dev/null; do
            sleep 2
            timeout=$((timeout-2))
        done
        
        if ! docker info &> /dev/null; then
            error "Не удалось запустить Docker. Запустите его вручную и повторите."
        fi
    fi
    
    # Запускаем соответствующую конфигурацию
    if [ "$DEPLOYMENT_MODE" = "full" ]; then
        log "Запуск полной системы..."
        if [ -f "deploy.sh" ]; then
            chmod +x deploy.sh
            ./deploy.sh
        else
            docker compose up -d
        fi
    else
        log "Запуск только фронтенда..."
        docker compose -f docker-compose.frontend-only.yml up -d
    fi
    
    log "Система запущена ✓"
}

# Показать результат
show_result() {
    echo
    echo "🎉 Развертывание завершено!"
    echo "=========================="
    echo
    
    if [ "$DEPLOYMENT_MODE" = "full" ]; then
        echo "🌐 Основное приложение: http://localhost:$PORT/"
        echo "🔐 Система входа: http://localhost:$PORT/auth/login"
        echo "👤 Админ-панель: http://localhost:$PORT/auth/dashboard"
        echo
        echo "🔑 Данные для входа:"
        echo "  📧 Email: root@admin.com"
        echo "  🔒 Пароль: admin123"
    else
        echo "🌐 Приложение (только фронтенд): http://localhost:$PORT/"
        echo "ℹ️  Система аутентификации недоступна"
    fi
    
    echo
    echo "🛠️ Управление:"
    echo "  📊 Статус: docker compose ps"
    echo "  📝 Логи: docker compose logs -f"
    echo "  🔄 Перезапуск: docker compose restart"
    echo "  ⏹️  Остановка: docker compose down"
    echo
    echo "📁 Проект находится в: $(pwd)"
    echo
}

# Основная функция
main() {
    echo "🚀 Zarinit - Автоматическая настройка на новом компьютере"
    echo "=========================================================="
    echo
    
    detect_os
    check_git
    install_docker
    clone_projects
    setup_config
    check_ports
    deploy_system
    show_result
    
    echo "✅ Готово! Система настроена и запущена."
}

# Обработка прерывания
trap 'error "Настройка прервана пользователем"' INT TERM

# Запуск
main "$@"