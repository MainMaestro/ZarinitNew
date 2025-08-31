# 🚀 Zarinit - Инструкции по развертыванию

## 📋 Обзор проекта

**Zarinit** - это веб-приложение, состоящее из:
- 🎨 **Vue.js фронтенд** - интерфейс пользователя
- 🔐 **Flask backend** - система аутентификации (cloud-auth)
- 🗄️ **PostgreSQL** - база данных
- 🌐 **Nginx** - веб-сервер и прокси

## 🎯 Варианты развертывания

### 🔥 Вариант 1: Полная система (рекомендуется)

Включает все компоненты с аутентификацией.

#### Требования:
- Docker & Docker Compose
- Доступ к репозиторию `cloud-auth`

#### Быстрый старт:
```bash
# 1. Создаем рабочую папку
mkdir zarinit-deployment
cd zarinit-deployment

# 2. Клонируем проекты
git clone <URL_ОСНОВНОГО_РЕПОЗИТОРИЯ> ZarinitNew
git clone <URL_CLOUD_AUTH_РЕПОЗИТОРИЯ> cloud-auth

# 3. Запускаем
cd ZarinitNew
./deploy.sh
```

#### Доступ:
- **Приложение**: http://localhost/
- **Логин**: http://localhost/auth/login (root@admin.com / admin123)
- **Админка**: http://localhost/auth/dashboard

---

### ⚡ Вариант 2: Только фронтенд

Если нет доступа к `cloud-auth` или нужен только интерфейс.

#### Быстрый старт:
```bash
# 1. Клонируем проект
git clone <URL_РЕПОЗИТОРИЯ> zarinit
cd zarinit

# 2. Запускаем только фронтенд
docker compose -f docker-compose.frontend-only.yml up -d
```

#### Доступ:
- **Приложение**: http://localhost/

---

## 🛠️ Подробные инструкции

### Установка Docker

#### Ubuntu/Debian:
```bash
sudo apt update
sudo apt install docker.io docker-compose-plugin
sudo usermod -aG docker $USER
newgrp docker
```

#### CentOS/RHEL:
```bash
sudo yum install docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

#### Windows/macOS:
Установите [Docker Desktop](https://www.docker.com/products/docker-desktop/)

### Настройка проекта

#### 1. Структура файлов (для полной системы):
```
deployment-folder/
├── ZarinitNew/
│   ├── docker-compose.yml
│   ├── nginx.conf
│   ├── dist/
│   └── deploy.sh
└── cloud-auth/
    ├── app.py
    ├── requirements.txt
    └── ...
```

#### 2. Настройка переменных окружения:
```bash
# Создаем .env файл
cp .env.example .env
nano .env
```

Пример `.env`:
```env
POSTGRES_PASSWORD=your_secure_password
ROOT_USER_EMAIL=admin@yourcompany.com
ROOT_USER_PASSWORD=your_admin_password
SECRET_KEY=your-very-secure-secret-key
NGINX_PORT=80
```

#### 3. Настройка портов (если 80 занят):
```yaml
# В docker-compose.yml
ports:
  - "8080:80"  # Теперь доступно на http://localhost:8080
```

## 🔧 Управление системой

### Основные команды:
```bash
# Запуск
docker compose up -d

# Остановка
docker compose down

# Перезапуск
docker compose restart

# Просмотр логов
docker compose logs -f

# Статус контейнеров
docker compose ps

# Обновление после изменений
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Мониторинг:
```bash
# Использование ресурсов
docker stats

# Проверка здоровья
curl http://localhost/
curl http://localhost/auth/login
```

### Бэкап базы данных:
```bash
# Создание бэкапа
docker compose exec auth-db pg_dump -U postgres adminka > backup.sql

# Восстановление
docker compose exec -T auth-db psql -U postgres adminka < backup.sql
```

## 🐛 Решение проблем

### Частые проблемы:

#### 1. Порт 80 занят
```bash
# Найти процесс
sudo lsof -i :80

# Остановить Apache/Nginx
sudo systemctl stop apache2
sudo systemctl stop nginx

# Или изменить порт в docker-compose.yml
```

#### 2. Контейнер не запускается
```bash
# Проверить логи
docker compose logs [service-name]

# Проверить образы
docker images

# Пересобрать
docker compose build --no-cache
```

#### 3. База данных недоступна
```bash
# Проверить здоровье БД
docker compose exec auth-db pg_isready -U postgres

# Подключиться к БД
docker compose exec auth-db psql -U postgres -d adminka
```

#### 4. Ошибка "cloud-auth not found"
```bash
# Проверить структуру
ls -la ../cloud-auth

# Или изменить путь в docker-compose.yml на абсолютный
volumes:
  - /absolute/path/to/cloud-auth:/cloud-auth
```

### Очистка системы:
```bash
# Полная очистка (ВНИМАНИЕ: удалит данные!)
docker compose down -v
docker system prune -a
docker volume prune
```

## 🔒 Безопасность для продакшена

### Обязательные изменения:
1. **Пароли**: Измените все пароли по умолчанию
2. **SECRET_KEY**: Используйте криптографически стойкий ключ
3. **SSL**: Настройте HTTPS через Let's Encrypt или Cloudflare
4. **Firewall**: Ограничьте доступ к портам
5. **Обновления**: Регулярно обновляйте образы Docker

### Пример SSL с Let's Encrypt:
```bash
# Установка Certbot
sudo apt install certbot python3-certbot-nginx

# Получение сертификата
sudo certbot --nginx -d yourdomain.com

# Автообновление
sudo crontab -e
# Добавить: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 📊 Производительность

### Рекомендуемые ресурсы:
- **RAM**: минимум 2GB, рекомендуется 4GB+
- **CPU**: 2+ ядра
- **Диск**: 10GB+ свободного места
- **Сеть**: стабильное подключение для Docker образов

### Оптимизация:
```yaml
# В docker-compose.yml добавить ограничения ресурсов
services:
  auth-backend:
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
```

## 📞 Поддержка

### Полезные ссылки:
- 📖 [Полная документация](DEPLOYMENT_GUIDE.md)
- ⚡ [Быстрый старт](QUICK_DEPLOY.md)
- 🔧 [Финальные инструкции](FINAL_DEPLOYMENT_INSTRUCTIONS.md)

### При проблемах:
1. Проверьте логи: `docker compose logs`
2. Убедитесь в правильности структуры проекта
3. Проверьте доступность портов
4. Убедитесь, что Docker работает корректно

---

## 🎉 Готово!

После успешного развертывания у вас будет:
- ✅ Рабочее веб-приложение
- ✅ Система аутентификации
- ✅ База данных с автоматическими бэкапами
- ✅ Масштабируемая архитектура

**Наслаждайтесь использованием Zarinit!** 🚀