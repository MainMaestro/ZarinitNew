#!/bin/bash

# Скрипт для управления Docker Compose проектом

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для вывода сообщений
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка наличия Docker и Docker Compose
check_dependencies() {
    if ! command -v docker &> /dev/null; then
        error "Docker не установлен"
        exit 1
    fi

    # Проверяем наличие docker compose (v2) или docker-compose (v1)
    if command -v docker-compose &> /dev/null; then
        DOCKER_COMPOSE="docker-compose"
    elif docker compose version &> /dev/null; then
        DOCKER_COMPOSE="docker compose"
    else
        error "Docker Compose не установлен"
        exit 1
    fi
}

# Функция для запуска в production режиме
start_production() {
    log "Запуск в production режиме..."
    $DOCKER_COMPOSE up -d --build
    log "Приложение запущено на http://localhost"
    log "Аутентификация доступна на http://localhost/auth/"
}

# Функция для запуска в development режиме
start_development() {
    log "Запуск в development режиме..."
    $DOCKER_COMPOSE -f docker-compose.dev.yml up -d --build
    log "Приложение запущено на http://localhost"
    log "Аутентификация доступна на http://localhost/auth/"
}

# Функция для остановки
stop() {
    log "Остановка контейнеров..."
    $DOCKER_COMPOSE down
    $DOCKER_COMPOSE -f docker-compose.dev.yml down 2>/dev/null || true
}

# Функция для полной очистки
clean() {
    log "Остановка и удаление контейнеров, сетей и volumes..."
    $DOCKER_COMPOSE down -v --remove-orphans
    $DOCKER_COMPOSE -f docker-compose.dev.yml down -v --remove-orphans 2>/dev/null || true
    docker system prune -f
}

# Функция для просмотра логов
logs() {
    if [ -f docker-compose.dev.yml ] && $DOCKER_COMPOSE -f docker-compose.dev.yml ps -q &>/dev/null; then
        $DOCKER_COMPOSE -f docker-compose.dev.yml logs -f
    else
        $DOCKER_COMPOSE logs -f
    fi
}

# Функция для показа статуса
status() {
    log "Статус контейнеров:"
    $DOCKER_COMPOSE ps
    echo
    if [ -f docker-compose.dev.yml ]; then
        log "Статус dev контейнеров:"
        $DOCKER_COMPOSE -f docker-compose.dev.yml ps 2>/dev/null || echo "Dev контейнеры не запущены"
    fi
}

# Функция для входа в контейнер
shell() {
    local service=${1:-frontend}
    log "Подключение к контейнеру $service..."
    
    if $DOCKER_COMPOSE ps -q $service &>/dev/null; then
        $DOCKER_COMPOSE exec $service /bin/sh
    elif $DOCKER_COMPOSE -f docker-compose.dev.yml ps -q $service &>/dev/null 2>/dev/null; then
        $DOCKER_COMPOSE -f docker-compose.dev.yml exec $service /bin/sh
    else
        error "Контейнер $service не найден или не запущен"
        exit 1
    fi
}

# Функция для показа помощи
show_help() {
    echo "Использование: $0 [КОМАНДА]"
    echo
    echo "Команды:"
    echo "  start-prod, prod    Запуск в production режиме"
    echo "  start-dev, dev      Запуск в development режиме"
    echo "  stop                Остановка всех контейнеров"
    echo "  restart             Перезапуск (остановка + запуск prod)"
    echo "  clean               Полная очистка (контейнеры, volumes, сети)"
    echo "  logs                Просмотр логов"
    echo "  status              Показать статус контейнеров"
    echo "  shell [SERVICE]     Подключиться к контейнеру (по умолчанию frontend)"
    echo "  help                Показать эту справку"
    echo
    echo "Примеры:"
    echo "  $0 dev              # Запуск в режиме разработки"
    echo "  $0 prod             # Запуск в production режиме"
    echo "  $0 shell auth-backend  # Подключиться к контейнеру аутентификации"
    echo "  $0 logs             # Просмотр логов всех сервисов"
}

# Основная логика
main() {
    check_dependencies

    case "${1:-help}" in
        "start-prod"|"prod")
            start_production
            ;;
        "start-dev"|"dev")
            start_development
            ;;
        "stop")
            stop
            ;;
        "restart")
            stop
            start_production
            ;;
        "clean")
            clean
            ;;
        "logs")
            logs
            ;;
        "status")
            status
            ;;
        "shell")
            shell $2
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

main "$@"