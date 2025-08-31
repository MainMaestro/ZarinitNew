# 🚀 Быстрый старт - Интеграция ZarinitNew + Cloud-Auth

## Что это?

Интеграция двух проектов на одном домене:
- **ZarinitNew** (Vue.js) - основное приложение
- **Cloud-Auth** (Flask) - система аутентификации

## Запуск за 30 секунд

```bash
# 1. Перейти в директорию проекта
cd /home/armen/Документы/ZarinitNew/ZarinitNew

# 2. Запустить в режиме разработки
./docker-manage.sh dev

# 3. Дождаться сборки (2-3 минуты)
# 4. Открыть http://localhost
```

## Доступные адреса

После запуска:
- **http://localhost** - Основное приложение
- **http://localhost/auth-demo** - Демо интеграции
- **http://localhost/auth/login** - Вход в систему
- **http://localhost/auth/admin/users** - Админ панель

## Учетные данные

- **Email:** root@admin.com
- **Пароль:** admin123

## Основные команды

```bash
./docker-manage.sh dev      # Запуск development
./docker-manage.sh prod     # Запуск production
./docker-manage.sh stop     # Остановка
./docker-manage.sh logs     # Просмотр логов
./docker-manage.sh status   # Статус контейнеров
```

## Тестирование

```bash
./test-integration.sh       # Автоматическое тестирование
```

## Что дальше?

1. Откройте **http://localhost/auth-demo** для демонстрации возможностей
2. Изучите `src/composables/useCloudAuth.js` для API интеграции
3. Посмотрите `DOCKER_README.md` для подробной документации

## Архитектура

```
localhost:80 (Nginx)
├── / → Frontend (Vue.js)
└── /auth/ → Backend (Flask)
    ├── /auth/login
    ├── /auth/admin/
    └── /auth/api/
```

## Проблемы?

1. Проверьте статус: `./docker-manage.sh status`
2. Посмотрите логи: `./docker-manage.sh logs`
3. Перезапустите: `./docker-manage.sh restart`
4. Полная очистка: `./docker-manage.sh clean`