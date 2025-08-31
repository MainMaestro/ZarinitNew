# ✅ Чеклист развертывания Zarinit

## 🎯 Быстрый старт (5 минут)

### ☐ Подготовка
- [ ] Docker установлен и запущен
- [ ] Git установлен
- [ ] Порт 80 свободен (или готов использовать другой)

### ☐ Получение кода
```bash
mkdir zarinit-deployment && cd zarinit-deployment
git clone <MAIN_REPO> ZarinitNew
git clone <AUTH_REPO> cloud-auth  # опционально
cd ZarinitNew
```

### ☐ Запуск
```bash
# Полная система (если есть cloud-auth)
./deploy.sh

# Или только фронтенд
docker compose -f docker-compose.frontend-only.yml up -d
```

### ☐ Проверка
- [ ] http://localhost/ открывается
- [ ] http://localhost/auth/login работает (для полной системы)
- [ ] `docker compose ps` показывает все контейнеры как "Up"

---

## 🔧 Настройка (опционально)

### ☐ Переменные окружения
- [ ] Скопировать `.env.example` в `.env`
- [ ] Изменить пароли по умолчанию
- [ ] Установить сильный SECRET_KEY

### ☐ Порты
- [ ] Изменить порт в docker-compose.yml если нужно
- [ ] Обновить firewall правила

### ☐ Безопасность (для продакшена)
- [ ] Изменить все пароли по умолчанию
- [ ] Настроить SSL/HTTPS
- [ ] Ограничить доступ к админ-панели
- [ ] Настроить регулярные бэкапы БД

---

## 🐛 Диагностика проблем

### ☐ Docker
- [ ] `docker --version` работает
- [ ] `docker compose --version` работает
- [ ] `docker info` не показывает ошибок

### ☐ Контейнеры
- [ ] `docker compose ps` - все контейнеры "Up"
- [ ] `docker compose logs` - нет критических ошибок
- [ ] Порты не конфликтуют с другими сервисами

### ☐ Сеть
- [ ] `curl http://localhost/` возвращает HTML
- [ ] Браузер открывает приложение
- [ ] Нет блокировки firewall

---

## 📋 Файлы проекта

### ☐ Обязательные файлы
- [ ] `docker-compose.yml` - основная конфигурация
- [ ] `nginx.conf` - конфигурация веб-сервера
- [ ] `dist/` - собранный фронтенд
- [ ] `Dockerfile.auth` - образ для auth-backend

### ☐ Вспомогательные файлы
- [ ] `deploy.sh` - скрипт автоматического развертывания
- [ ] `.env.example` - пример переменных окружения
- [ ] `docker-compose.frontend-only.yml` - только фронтенд
- [ ] `nginx-frontend-only.conf` - nginx для фронтенда

### ☐ Документация
- [ ] `README_DEPLOYMENT.md` - основная документация
- [ ] `HOW_TO_DEPLOY_ON_NEW_COMPUTER.md` - инструкции
- [ ] `DEPLOYMENT_GUIDE.md` - подробное руководство

---

## 🎯 Результат

После успешного развертывания:

### ✅ Полная система
- Приложение: http://localhost/
- Логин: http://localhost/auth/login (root@admin.com / admin123)
- Админка: http://localhost/auth/dashboard
- База данных: PostgreSQL с автоматическими миграциями

### ✅ Только фронтенд
- Приложение: http://localhost/
- Статические файлы обслуживаются Nginx
- SPA роутинг работает корректно

---

## 🚀 Команды управления

```bash
# Статус
docker compose ps

# Логи
docker compose logs -f

# Перезапуск
docker compose restart

# Остановка
docker compose down

# Обновление
docker compose pull && docker compose up -d

# Полная очистка
docker compose down -v && docker system prune -a
```

---

## 📞 Быстрая помощь

| Проблема | Решение |
|----------|---------|
| Порт 80 занят | `sudo lsof -i :80` и остановить процесс |
| Docker не запущен | `sudo systemctl start docker` |
| Контейнер падает | `docker compose logs [service]` |
| 404 ошибки | Проверить nginx конфигурацию |
| БД недоступна | `docker compose restart auth-db` |

**Готово!** ✅ Используйте этот чеклист для быстрого развертывания.