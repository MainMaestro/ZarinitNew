# Docker Compose интеграция ZarinitNew + Cloud-Auth

Этот проект объединяет два приложения:
- **ZarinitNew** - фронтенд приложение (Vue.js)
- **Cloud-Auth** - бэкенд аутентификации (Flask)

Оба приложения работают на одном домене через nginx reverse proxy, что обеспечивает корректную работу с куками.

## Архитектура

```
┌─────────────────┐
│   Nginx Proxy   │  ← Порт 80
│   (localhost)   │
└─────────┬───────┘
          │
    ┌─────┴─────┐
    │           │
┌───▼───┐   ┌───▼────┐
│Frontend│   │Auth    │
│:8080   │   │Backend │
│        │   │:5001   │
└────────┘   └───┬────┘
                 │
            ┌────▼────┐
            │PostgreSQL│
            │:5432     │
            └─────────┘
```

## Маршрутизация

- `http://localhost/` - Основное приложение (ZarinitNew)
- `http://localhost/auth/` - Система аутентификации (Cloud-Auth)
- `http://localhost/auth/api/` - API аутентификации

## Быстрый старт

### 1. Запуск в режиме разработки

```bash
./docker-manage.sh dev
```

### 2. Запуск в production режиме

```bash
./docker-manage.sh prod
```

### 3. Остановка

```bash
./docker-manage.sh stop
```

## Подробные команды

### Управление через скрипт

```bash
# Запуск в development режиме
./docker-manage.sh dev

# Запуск в production режиме  
./docker-manage.sh prod

# Остановка всех контейнеров
./docker-manage.sh stop

# Перезапуск
./docker-manage.sh restart

# Просмотр логов
./docker-manage.sh logs

# Статус контейнеров
./docker-manage.sh status

# Подключение к контейнеру
./docker-manage.sh shell frontend
./docker-manage.sh shell auth-backend

# Полная очистка
./docker-manage.sh clean
```

### Прямые команды Docker Compose

```bash
# Production
docker-compose up -d --build
docker-compose down

# Development
docker-compose -f docker-compose.dev.yml up -d --build
docker-compose -f docker-compose.dev.yml down
```

## Конфигурация

### Переменные окружения

Основные переменные настраиваются в файле `.env`:

```env
# База данных
POSTGRES_DB=adminka
POSTGRES_USER=postgres
POSTGRES_PASSWORD=1

# Аутентификация
ROOT_USER_EMAIL=root@admin.com
ROOT_USER_PASSWORD=admin123
SECRET_KEY=your-secret-key

# Режим работы
FLASK_ENV=development
```

### Порты

- **80** - Nginx proxy (основной вход)
- **5432** - PostgreSQL (доступен извне только в dev режиме)

## Доступ к приложениям

После запуска:

1. **Основное приложение**: http://localhost
2. **Демо интеграции**: http://localhost/auth-demo
3. **Аутентификация**: http://localhost/auth/login
4. **Админ панель**: http://localhost/auth/admin/users

### Учетные данные по умолчанию

- **Email**: root@admin.com
- **Пароль**: admin123

### Тестирование интеграции

Запустите тестовый скрипт для проверки работоспособности:

```bash
./test-integration.sh
```

## Разработка

### Режим разработки

В dev режиме:
- Включены volume mounts для hot reload
- База данных доступна на localhost:5432
- Логи более подробные
- Автоматическая перезагрузка при изменении файлов

### Структура файлов

```
ZarinitNew/
├── docker-compose.yml          # Production конфигурация
├── docker-compose.dev.yml      # Development конфигурация
├── nginx-proxy.conf            # Конфигурация Nginx proxy
├── Dockerfile                  # Frontend Dockerfile
├── Dockerfile.auth             # Auth backend Dockerfile
├── start-auth.py              # Скрипт запуска auth с env переменными
├── docker-manage.sh           # Скрипт управления
├── .env                       # Переменные окружения
└── DOCKER_README.md           # Эта документация
```

## Отладка

### Просмотр логов

```bash
# Все сервисы
./docker-manage.sh logs

# Конкретный сервис
docker-compose logs -f frontend
docker-compose logs -f auth-backend
docker-compose logs -f nginx
```

### Подключение к контейнерам

```bash
# Frontend
./docker-manage.sh shell frontend

# Auth backend
./docker-manage.sh shell auth-backend

# База данных
docker-compose exec auth-db psql -U postgres -d adminka
```

### Проверка сети

```bash
# Статус контейнеров
./docker-manage.sh status

# Проверка сетевого подключения
docker-compose exec frontend ping auth-backend
docker-compose exec auth-backend ping auth-db
```

## Решение проблем

### Проблемы с куками

Если куки не работают между приложениями:
1. Убедитесь, что оба приложения доступны через один домен (localhost)
2. Проверьте настройки nginx proxy
3. Убедитесь, что приложения используют одинаковые настройки SameSite

### Проблемы с базой данных

```bash
# Пересоздание базы данных
./docker-manage.sh clean
./docker-manage.sh dev

# Проверка подключения к БД
docker-compose exec auth-backend python -c "
from app import db
print('Database connection:', db.engine.url)
"
```

### Проблемы с сетью

```bash
# Пересоздание сети
docker network prune
./docker-manage.sh restart
```

## Производственное развертывание

Для production:

1. Измените переменные в `.env`:
   - Установите сложный `SECRET_KEY`
   - Измените пароли базы данных
   - Установите `FLASK_ENV=production`

2. Настройте SSL (добавьте сертификаты в nginx)

3. Настройте мониторинг и логирование

4. Используйте внешнюю базу данных для высокой доступности