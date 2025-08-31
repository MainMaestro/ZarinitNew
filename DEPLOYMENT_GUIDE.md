# 🚀 Руководство по развертыванию на другом компьютере

## 📋 Предварительные требования

### Системные требования:
- **Docker** версии 20.10+
- **Docker Compose** версии 2.0+
- **Git** для клонирования репозитория
- **Минимум 2GB RAM** и **5GB свободного места**

### Установка Docker (если не установлен):

#### Ubuntu/Debian:
```bash
# Обновляем пакеты
sudo apt update

# Устанавливаем Docker
sudo apt install docker.io docker-compose-plugin

# Добавляем пользователя в группу docker
sudo usermod -aG docker $USER

# Перезагружаемся или выполняем
newgrp docker
```

#### CentOS/RHEL:
```bash
sudo yum install docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

#### Windows:
- Скачайте и установите [Docker Desktop](https://www.docker.com/products/docker-desktop/)

#### macOS:
- Скачайте и установите [Docker Desktop](https://www.docker.com/products/docker-desktop/)

## 📁 Структура проекта

Проект состоит из двух частей:
1. **ZarinitNew** - основное приложение (Vue.js + Flask)
2. **cloud-auth** - система аутентификации (Flask)

## 🔧 Пошаговое развертывание

### Шаг 1: Клонирование репозиториев

```bash
# Создаем рабочую директорию
mkdir zarinit-deployment
cd zarinit-deployment

# Клонируем основной проект
git clone <URL_ОСНОВНОГО_РЕПОЗИТОРИЯ> ZarinitNew

# Клонируем проект аутентификации
git clone <URL_CLOUD_AUTH_РЕПОЗИТОРИЯ> cloud-auth
```

### Шаг 2: Настройка путей

Убедитесь, что структура папок выглядит так:
```
zarinit-deployment/
├── ZarinitNew/          # Основное приложение
└── cloud-auth/          # Система аутентификации
```

### Шаг 3: Исправление docker-compose.yml

Перейдите в папку ZarinitNew и отредактируйте `docker-compose.yml`:

```bash
cd ZarinitNew
```

Найдите строку 43 и измените абсолютный путь на относительный:

**Было:**
```yaml
volumes:
  - /home/armen/Документы/cloud-auth:/cloud-auth
```

**Должно быть:**
```yaml
volumes:
  - ../cloud-auth:/cloud-auth
```

### Шаг 4: Настройка переменных окружения (опционально)

Создайте файл `.env` для кастомизации настроек:

```bash
# Создаем .env файл
cat > .env << 'EOF'
# База данных
POSTGRES_DB=adminka
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password_here

# Аутентификация
ROOT_USER_EMAIL=admin@yourcompany.com
ROOT_USER_PASSWORD=your_admin_password_here
SECRET_KEY=your-very-secure-secret-key-change-this-in-production

# Порты (если нужно изменить)
NGINX_PORT=80
EOF
```

### Шаг 5: Сборка и запуск

```bash
# Сборка всех контейнеров
docker compose build

# Запуск в фоновом режиме
docker compose up -d

# Проверка статуса
docker compose ps
```

### Шаг 6: Проверка работоспособности

```bash
# Проверяем основное приложение
curl http://localhost/

# Проверяем систему аутентификации
curl http://localhost/auth/login

# Проверяем статические файлы
curl -I http://localhost/static/bundle.js
```

## 🔍 Проверка логов

```bash
# Все логи
docker compose logs

# Логи конкретного сервиса
docker compose logs nginx
docker compose logs auth-backend
docker compose logs auth-db

# Следить за логами в реальном времени
docker compose logs -f
```

## 🛠️ Управление контейнерами

```bash
# Остановка
docker compose down

# Перезапуск
docker compose restart

# Пересборка после изменений
docker compose down
docker compose build --no-cache
docker compose up -d

# Очистка (ВНИМАНИЕ: удалит данные БД!)
docker compose down -v
docker system prune -a
```

## 🌐 Доступ к приложению

После успешного запуска:

- **Основное приложение**: http://localhost/
- **Система аутентификации**: http://localhost/auth/login
- **Админ-панель**: http://localhost/auth/dashboard

### Данные для входа по умолчанию:
- **Email**: root@admin.com
- **Пароль**: admin123

## 🔧 Настройка для продакшена

### 1. Изменение портов
Если порт 80 занят, измените в `docker-compose.yml`:
```yaml
ports:
  - "8080:80"  # Теперь доступно на http://localhost:8080
```

### 2. Безопасность
Обязательно измените:
- Пароли базы данных
- SECRET_KEY
- Данные администратора

### 3. SSL/HTTPS
Для продакшена рекомендуется настроить SSL через:
- Nginx с Let's Encrypt
- Cloudflare
- Обратный прокси (Traefik, HAProxy)

## 🐛 Решение проблем

### Проблема: Порт 80 занят
```bash
# Найти процесс, использующий порт
sudo lsof -i :80

# Или изменить порт в docker-compose.yml
ports:
  - "8080:80"
```

### Проблема: Недостаточно места
```bash
# Очистка неиспользуемых образов
docker system prune -a

# Проверка использования места
docker system df
```

### Проблема: Контейнер не запускается
```bash
# Проверяем логи
docker compose logs [service-name]

# Проверяем статус
docker compose ps

# Перезапуск конкретного сервиса
docker compose restart [service-name]
```

### Проблема: База данных не подключается
```bash
# Проверяем здоровье БД
docker compose exec auth-db pg_isready -U postgres

# Подключаемся к БД для диагностики
docker compose exec auth-db psql -U postgres -d adminka
```

## 📊 Мониторинг

### Проверка ресурсов:
```bash
# Использование ресурсов контейнерами
docker stats

# Информация о контейнерах
docker compose ps -a
```

### Бэкап базы данных:
```bash
# Создание бэкапа
docker compose exec auth-db pg_dump -U postgres adminka > backup.sql

# Восстановление из бэкапа
docker compose exec -T auth-db psql -U postgres adminka < backup.sql
```

## 🎯 Быстрый старт (TL;DR)

```bash
# 1. Клонируем проекты
mkdir zarinit-deployment && cd zarinit-deployment
git clone <MAIN_REPO> ZarinitNew
git clone <AUTH_REPO> cloud-auth

# 2. Исправляем путь в docker-compose.yml
cd ZarinitNew
sed -i 's|/home/armen/Документы/cloud-auth|../cloud-auth|g' docker-compose.yml

# 3. Запускаем
docker compose up -d

# 4. Проверяем
curl http://localhost/
```

## 📞 Поддержка

При возникновении проблем:
1. Проверьте логи: `docker compose logs`
2. Убедитесь, что все порты свободны
3. Проверьте наличие всех файлов проекта
4. Убедитесь, что Docker работает корректно

---

**Готово!** 🎉 Ваше приложение должно быть доступно по адресу http://localhost/