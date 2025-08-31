# Интеграция ZarinitNew + Cloud-Auth

## 🎯 Что было создано

Успешно настроена интеграция двух проектов:
- **ZarinitNew** (Vue.js фронтенд)
- **Cloud-Auth** (Flask бэкенд аутентификации)

Оба приложения работают на **одном домене** через nginx reverse proxy, что обеспечивает корректную работу с куками.

## 📁 Созданные файлы

### Docker конфигурация
- `docker-compose.yml` - Production конфигурация
- `docker-compose.dev.yml` - Development конфигурация
- `Dockerfile.auth` - Dockerfile для Cloud-Auth
- `nginx-proxy.conf` - Конфигурация Nginx reverse proxy

### Скрипты управления
- `docker-manage.sh` - Скрипт управления Docker Compose
- `start-auth.py` - Скрипт запуска Cloud-Auth с поддержкой env переменных
- `test-integration.sh` - Скрипт тестирования интеграции

### Frontend интеграция
- `src/composables/useCloudAuth.js` - Composable для работы с Cloud-Auth API
- `src/components/AuthIntegration.vue` - Компонент демонстрации интеграции
- `src/pages/AuthDemo.vue` - Демонстрационная страница

### Конфигурация
- `.env` - Переменные окружения
- `DOCKER_README.md` - Подробная документация

## 🚀 Быстрый старт

```bash
# Запуск в режиме разработки
./docker-manage.sh dev

# Или в production режиме
./docker-manage.sh prod

# Тестирование
./test-integration.sh
```

## 🌐 Доступ к приложениям

После запуска все доступно на `http://localhost`:

- `/` - Основное приложение ZarinitNew
- `/auth-demo` - Демонстрация интеграции
- `/auth/login` - Вход в систему
- `/auth/admin/users` - Админ панель

**Учетные данные:** root@admin.com / admin123

## 🏗️ Архитектура

```
┌─────────────────┐
│   Nginx Proxy   │  ← localhost:80
│   (localhost)   │
└─────────┬───────┘
          │
    ┌─────┴─────┐
    │           │
┌───▼───┐   ┌───▼────┐
│Frontend│   │Auth    │
│:8080   │   │Backend │
│(Vue.js)│   │:5001   │
│        │   │(Flask) │
└────────┘   └───┬────┘
                 │
            ┌────▼────┐
            │PostgreSQL│
            │:5432     │
            └─────────┘
```

## 🔧 Маршрутизация

Nginx перенаправляет запросы:
- `localhost/` → Frontend (ZarinitNew)
- `localhost/auth/` → Auth Backend (Cloud-Auth)
- `localhost/auth/api/` → API аутентификации

## ✨ Особенности

1. **Единый домен** - все сервисы доступны через localhost
2. **Корректные куки** - куки работают между всеми сервисами
3. **API интеграция** - Frontend может обращаться к API аутентификации
4. **Простое управление** - один скрипт для всех операций
5. **Режимы разработки и production** - разные конфигурации

## 🛠️ Команды управления

```bash
# Запуск
./docker-manage.sh dev          # Development режим
./docker-manage.sh prod         # Production режим

# Управление
./docker-manage.sh stop         # Остановка
./docker-manage.sh restart      # Перезапуск
./docker-manage.sh clean        # Полная очистка

# Мониторинг
./docker-manage.sh status       # Статус контейнеров
./docker-manage.sh logs         # Просмотр логов

# Отладка
./docker-manage.sh shell frontend      # Подключение к frontend
./docker-manage.sh shell auth-backend  # Подключение к auth backend
```

## 🧪 Тестирование

Скрипт `test-integration.sh` проверяет:
- Доступность основного приложения
- Работу системы аутентификации
- Функционирование API
- Корректность установки куков

## 📝 Примеры использования

### Проверка группы из Frontend

```javascript
import { useCloudAuth } from '@/composables/useCloudAuth'

const { checkGroup } = useCloudAuth()

// Проверка принадлежности к группе
const result = await checkGroup('admin', 'password123')
console.log(result.exists) // true/false
```

### API запросы

```bash
# Проверка группы
curl -X POST http://localhost/auth/api/check-group \
  -H "Content-Type: application/json" \
  -d '{"group_name":"admin","password_phrase":"password123"}'

# Генерация пароля (требует аутентификации)
curl -X POST http://localhost/auth/api/generate-password \
  -H "Content-Type: application/json" \
  -d '{"group_name":"admin"}'
```

## 🔒 Безопасность

- Все сервисы работают в изолированной Docker сети
- PostgreSQL недоступна извне в production режиме
- Используются переменные окружения для конфиденциальных данных
- Nginx настроен с базовыми заголовками безопасности

## 📚 Дополнительная документация

Подробная документация доступна в `DOCKER_README.md`