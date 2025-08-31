# 🚀 Как запустить Zarinit на новом компьютере

## ⚡ Самый быстрый способ (1 команда)

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/setup-new-machine.sh | bash
```

*Замените `YOUR_USERNAME/YOUR_REPO` на реальные данные вашего репозитория*

---

## 🛠️ Пошаговая инструкция

### Шаг 1: Подготовка системы

#### Установка Docker:

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install docker.io docker-compose-plugin
sudo usermod -aG docker $USER
newgrp docker
```

**CentOS/RHEL:**
```bash
sudo yum install docker docker-compose
sudo systemctl start docker
sudo usermod -aG docker $USER
```

**Windows/macOS:**
- Скачайте [Docker Desktop](https://www.docker.com/products/docker-desktop/)

### Шаг 2: Получение проекта

#### Вариант A: Полная система (с аутентификацией)
```bash
# Создаем папку
mkdir zarinit-deployment
cd zarinit-deployment

# Клонируем проекты
git clone <URL_ОСНОВНОГО_РЕПОЗИТОРИЯ> ZarinitNew
git clone <URL_CLOUD_AUTH_РЕПОЗИТОРИЯ> cloud-auth

# Переходим в основной проект
cd ZarinitNew
```

#### Вариант B: Только фронтенд
```bash
# Клонируем только основной проект
git clone <URL_ОСНОВНОГО_РЕПОЗИТОРИЯ> zarinit
cd zarinit
```

### Шаг 3: Запуск

#### Для полной системы:
```bash
# Автоматический запуск
./deploy.sh

# Или ручной запуск
docker compose up -d
```

#### Для только фронтенда:
```bash
docker compose -f docker-compose.frontend-only.yml up -d
```

### Шаг 4: Проверка

Откройте в браузере:
- **Полная система**: http://localhost/ (логин: root@admin.com / admin123)
- **Только фронтенд**: http://localhost/

---

## 🔧 Настройка

### Изменение порта (если 80 занят):
```bash
# Найти процесс на порту 80
sudo lsof -i :80

# Или изменить порт в docker-compose.yml
sed -i 's/"80:80"/"8080:80"/g' docker-compose.yml
```

### Настройка переменных окружения:
```bash
# Создать файл настроек
cp .env.example .env
nano .env
```

### Изменение паролей:
```env
POSTGRES_PASSWORD=your_secure_password
ROOT_USER_PASSWORD=your_admin_password
SECRET_KEY=your-very-secure-secret-key
```

---

## 🐛 Решение проблем

### Docker не запускается:
```bash
# Linux
sudo systemctl start docker

# Проверка статуса
docker --version
docker compose --version
```

### Порт занят:
```bash
# Остановить конфликтующие сервисы
sudo systemctl stop apache2
sudo systemctl stop nginx

# Или использовать другой порт
```

### Контейнер не запускается:
```bash
# Проверить логи
docker compose logs

# Пересобрать образы
docker compose build --no-cache
docker compose up -d
```

### Очистка при проблемах:
```bash
docker compose down -v
docker system prune -a
```

---

## 📋 Что получится в результате

### Полная система:
- ✅ Vue.js приложение на http://localhost/
- ✅ Система аутентификации на http://localhost/auth/login
- ✅ База данных PostgreSQL
- ✅ Админ-панель на http://localhost/auth/dashboard

### Только фронтенд:
- ✅ Vue.js приложение на http://localhost/
- ❌ Аутентификация недоступна (заглушка)

---

## 🛠️ Управление системой

```bash
# Статус контейнеров
docker compose ps

# Просмотр логов
docker compose logs -f

# Перезапуск
docker compose restart

# Остановка
docker compose down

# Обновление после изменений
docker compose down
docker compose pull
docker compose up -d
```

---

## 🔒 Безопасность для продакшена

1. **Измените пароли по умолчанию**
2. **Используйте сильный SECRET_KEY**
3. **Настройте SSL/HTTPS**
4. **Ограничьте доступ к портам**
5. **Регулярно обновляйте образы**

---

## 📞 Поддержка

При проблемах:
1. Проверьте логи: `docker compose logs`
2. Убедитесь, что Docker запущен
3. Проверьте доступность портов
4. Смотрите документацию в репозитории

---

## 🎯 Краткая справка

| Команда | Описание |
|---------|----------|
| `./setup-new-machine.sh` | Автоматическая настройка |
| `./deploy.sh` | Запуск полной системы |
| `docker compose up -d` | Ручной запуск |
| `docker compose ps` | Статус контейнеров |
| `docker compose logs` | Просмотр логов |
| `docker compose down` | Остановка системы |

**Готово!** 🎉 Теперь Zarinit можно легко развернуть на любом компьютере.