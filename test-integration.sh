#!/bin/bash

# Скрипт для тестирования интеграции

echo "🧪 Тестирование интеграции ZarinitNew + Cloud-Auth"
echo "=================================================="

# Проверка доступности сервисов
echo "📡 Проверка доступности сервисов..."

# Ждем запуска сервисов
sleep 10

# Тест основного приложения
echo "🔍 Тестирование основного приложения..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200"; then
    echo "✅ Основное приложение доступно"
else
    echo "❌ Основное приложение недоступно"
fi

# Тест аутентификации
echo "🔍 Тестирование системы аутентификации..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost/auth/login | grep -q "200"; then
    echo "✅ Система аутентификации доступна"
else
    echo "❌ Система аутентификации недоступна"
fi

# Тест API аутентификации
echo "🔍 Тестирование API аутентификации..."
response=$(curl -s -X POST http://localhost/auth/api/check-group \
  -H "Content-Type: application/json" \
  -d '{"group_name":"test"}' \
  -w "%{http_code}")

if echo "$response" | grep -q "200\|400\|404"; then
    echo "✅ API аутентификации отвечает"
else
    echo "❌ API аутентификации не отвечает"
fi

# Проверка работы с куками
echo "🔍 Тестирование работы с куками..."
cookie_jar=$(mktemp)
login_response=$(curl -s -c "$cookie_jar" -X POST http://localhost/auth/login \
  -d "email=root@admin.com&password=admin123" \
  -w "%{http_code}")

if [ -s "$cookie_jar" ]; then
    echo "✅ Куки устанавливаются корректно"
else
    echo "❌ Проблемы с установкой куков"
fi

rm -f "$cookie_jar"

echo ""
echo "🎯 Тестирование завершено!"
echo ""
echo "📋 Полезные ссылки:"
echo "   • Основное приложение: http://localhost"
echo "   • Вход в систему: http://localhost/auth/login"
echo "   • Админ панель: http://localhost/auth/admin/users"
echo "   • Учетные данные: root@admin.com / admin123"