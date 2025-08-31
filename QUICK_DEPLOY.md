# ⚡ Быстрое развертывание Zarinit

## 🚀 Быстрый старт (5 минут)

### 1️⃣ Подготовка
```bash
# Создайте папку для проектов
mkdir zarinit-deployment
cd zarinit-deployment

# Клонируйте репозитории
git clone <URL_ОСНОВНОГО_РЕПОЗИТОРИЯ> ZarinitNew
git clone <URL_CLOUD_AUTH_РЕПОЗИТОРИЯ> cloud-auth
```

### 2️⃣ Автоматическое развертывание
```bash
cd ZarinitNew
./deploy.sh
```

### 3️⃣ Готово! 🎉
- **Приложение**: http://localhost/
- **Логин**: http://localhost/auth/login
- **Админка**: http://localhost/auth/dashboard

**Данные для входа:**
- Email: `root@admin.com`
- Пароль: `admin123`

---

## 🛠️ Ручное развертывание

Если автоматический скрипт не работает:

```bash
# 1. Проверьте структуру
ls -la  # Должны быть: docker-compose.yml, nginx.conf, dist/

# 2. Убедитесь, что cloud-auth в родительской папке
ls ../cloud-auth  # Должна существовать

# 3. Запустите контейнеры
docker compose up -d

# 4. Проверьте статус
docker compose ps
```

---

## 🔧 Настройка

### Изменение порта (если 80 занят):
```yaml
# В docker-compose.yml измените:
ports:
  - "8080:80"  # Теперь http://localhost:8080
```

### Изменение паролей:
```bash
# Скопируйте пример настроек
cp .env.example .env

# Отредактируйте .env файл
nano .env
```

---

## 🐛 Решение проблем

### Порт занят:
```bash
sudo lsof -i :80  # Найти процесс
# Или измените порт в docker-compose.yml
```

### Контейнер не запускается:
```bash
docker compose logs [service-name]
```

### Очистка и перезапуск:
```bash
docker compose down -v
docker system prune -a
./deploy.sh
```

---

## 📞 Поддержка

1. Проверьте логи: `docker compose logs`
2. Убедитесь в наличии всех файлов
3. Проверьте, что Docker запущен
4. Смотрите полную документацию в `DEPLOYMENT_GUIDE.md`