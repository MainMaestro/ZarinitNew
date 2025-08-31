# 🚀 Финальные инструкции по развертыванию Zarinit

## 📋 Что у нас есть

✅ **Рабочие компоненты:**
- Vue.js фронтенд (собран в `dist/`)
- Nginx конфигурация
- PostgreSQL база данных
- Docker конфигурация

❌ **Что нужно для полного запуска:**
- Репозиторий `cloud-auth` с Flask приложением

## 🎯 Варианты развертывания

### Вариант 1: С системой аутентификации (полная функциональность)

#### Структура проекта:
```
deployment-folder/
├── ZarinitNew/          # Этот репозиторий
└── cloud-auth/          # Репозиторий системы аутентификации
```

#### Шаги:
1. **Клонирование проектов:**
   ```bash
   mkdir zarinit-deployment
   cd zarinit-deployment
   
   # Клонируем основной проект
   git clone <URL_ЭТОГО_РЕПОЗИТОРИЯ> ZarinitNew
   
   # Клонируем систему аутентификации
   git clone <URL_CLOUD_AUTH_РЕПОЗИТОРИЯ> cloud-auth
   ```

2. **Настройка путей:**
   ```bash
   cd ZarinitNew
   
   # Изменяем путь в docker-compose.yml на относительный
   sed -i 's|/home/armen/Документы/cloud-auth|../cloud-auth|g' docker-compose.yml
   ```

3. **Запуск:**
   ```bash
   # Автоматический запуск
   ./deploy.sh
   
   # Или ручной запуск
   docker compose up -d
   ```

### Вариант 2: Только фронтенд (без аутентификации)

Если у вас нет доступа к репозиторию `cloud-auth`, можно запустить только фронтенд:

#### Создайте упрощенный docker-compose.yml:
```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx-simple.conf:/etc/nginx/nginx.conf:ro
      - ./dist:/usr/share/nginx/html
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

#### Создайте упрощенный nginx-simple.conf:
```nginx
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        listen 80;
        server_name localhost;
        root /usr/share/nginx/html;
        index index.html;

        # SPA роутинг
        location / {
            try_files $uri $uri/ /index.html;
        }

        # Статические файлы
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
```

#### Запуск:
```bash
docker compose -f docker-compose-simple.yml up -d
```

## 🔧 Настройка для продакшена

### 1. Переменные окружения
Создайте `.env` файл:
```bash
# База данных
POSTGRES_DB=adminka
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password

# Аутентификация
ROOT_USER_EMAIL=admin@yourcompany.com
ROOT_USER_PASSWORD=your_admin_password
SECRET_KEY=your-very-secure-secret-key

# Порты
NGINX_PORT=80
```

### 2. Безопасность
- Измените все пароли по умолчанию
- Используйте сильные SECRET_KEY
- Настройте SSL/HTTPS для продакшена
- Ограничьте доступ к базе данных

### 3. Мониторинг
```bash
# Проверка статуса
docker compose ps

# Логи
docker compose logs -f

# Использование ресурсов
docker stats
```

## 🐛 Решение проблем

### Проблема: "ModuleNotFoundError: No module named 'app'"
**Причина:** Отсутствует репозиторий cloud-auth или неправильный путь

**Решение:**
1. Убедитесь, что cloud-auth клонирован в правильное место
2. Проверьте путь в docker-compose.yml
3. Или используйте вариант только с фронтендом

### Проблема: Порт 80 занят
**Решение:**
```bash
# Найти процесс
sudo lsof -i :80

# Или изменить порт
ports:
  - "8080:80"
```

### Проблема: Контейнер не запускается
**Решение:**
```bash
# Проверить логи
docker compose logs [service-name]

# Пересобрать образы
docker compose build --no-cache

# Очистить все
docker compose down -v
docker system prune -a
```

## 📦 Готовые файлы для развертывания

В этом репозитории есть:
- ✅ `docker-compose.yml` - основная конфигурация
- ✅ `nginx.conf` - конфигурация веб-сервера
- ✅ `dist/` - собранный фронтенд
- ✅ `deploy.sh` - скрипт автоматического развертывания
- ✅ `DEPLOYMENT_GUIDE.md` - подробная документация

## 🎯 Быстрый старт для нового компьютера

```bash
# 1. Установите Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# 2. Клонируйте проект
git clone <URL_ЭТОГО_РЕПОЗИТОРИЯ> zarinit
cd zarinit

# 3. Запустите (если есть cloud-auth)
./deploy.sh

# 4. Или только фронтенд (если нет cloud-auth)
# Создайте упрощенную конфигурацию и запустите
```

## 📞 Поддержка

При возникновении проблем:
1. Проверьте логи: `docker compose logs`
2. Убедитесь в правильности структуры проекта
3. Проверьте доступность портов
4. Убедитесь, что Docker работает

---

**Готово!** 🎉 Теперь у вас есть полная инструкция для развертывания на любом компьютере.