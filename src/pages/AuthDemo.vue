<template>
  <div class="auth-demo-page min-h-screen bg-gray-50 py-8">
    <div class="container mx-auto px-4">
      <div class="text-center mb-8">
        <h1 class="text-4xl font-bold text-gray-800 mb-4">
          Демонстрация интеграции с Cloud-Auth
        </h1>
        <p class="text-lg text-gray-600 max-w-2xl mx-auto">
          Эта страница демонстрирует интеграцию между ZarinitNew и системой аутентификации Cloud-Auth.
          Оба приложения работают на одном домене, что обеспечивает корректную работу с куками.
        </p>
      </div>

      <!-- Компонент интеграции -->
      <AuthIntegration />

      <!-- Дополнительная информация -->
      <div class="mt-12 max-w-4xl mx-auto">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Архитектура -->
          <div class="bg-white p-6 rounded-lg shadow-lg">
            <h3 class="text-xl font-semibold mb-4 text-gray-800">
              🏗️ Архитектура
            </h3>
            <ul class="space-y-2 text-gray-600">
              <li>• <strong>Frontend:</strong> ZarinitNew (Vue.js) на порту 8080</li>
              <li>• <strong>Auth Backend:</strong> Cloud-Auth (Flask) на порту 5001</li>
              <li>• <strong>Database:</strong> PostgreSQL на порту 5432</li>
              <li>• <strong>Proxy:</strong> Nginx на порту 80</li>
            </ul>
          </div>

          <!-- Маршрутизация -->
          <div class="bg-white p-6 rounded-lg shadow-lg">
            <h3 class="text-xl font-semibold mb-4 text-gray-800">
              🛣️ Маршрутизация
            </h3>
            <ul class="space-y-2 text-gray-600">
              <li>• <code>/</code> → Основное приложение</li>
              <li>• <code>/auth/</code> → Система аутентификации</li>
              <li>• <code>/auth/api/</code> → API аутентификации</li>
              <li>• <code>/auth/admin/</code> → Админ панель</li>
            </ul>
          </div>

          <!-- Возможности -->
          <div class="bg-white p-6 rounded-lg shadow-lg">
            <h3 class="text-xl font-semibold mb-4 text-gray-800">
              ⚡ Возможности
            </h3>
            <ul class="space-y-2 text-gray-600">
              <li>• Единый домен для всех сервисов</li>
              <li>• Корректная работа с куками</li>
              <li>• API для проверки групп</li>
              <li>• Генерация паролей для групп</li>
              <li>• Админ панель управления</li>
            </ul>
          </div>

          <!-- Полезные ссылки -->
          <div class="bg-white p-6 rounded-lg shadow-lg">
            <h3 class="text-xl font-semibold mb-4 text-gray-800">
              🔗 Полезные ссылки
            </h3>
            <div class="space-y-2">
              <a 
                href="/auth/login" 
                class="block text-blue-600 hover:text-blue-800 transition-colors"
              >
                → Страница входа
              </a>
              <a 
                href="/auth/admin/users" 
                class="block text-blue-600 hover:text-blue-800 transition-colors"
              >
                → Управление пользователями
              </a>
              <a 
                href="/auth/admin/groups" 
                class="block text-blue-600 hover:text-blue-800 transition-colors"
              >
                → Управление группами
              </a>
              <a 
                href="/auth/profile" 
                class="block text-blue-600 hover:text-blue-800 transition-colors"
              >
                → Профиль пользователя
              </a>
            </div>
          </div>
        </div>

        <!-- Инструкции по запуску -->
        <div class="mt-8 bg-white p-6 rounded-lg shadow-lg">
          <h3 class="text-xl font-semibold mb-4 text-gray-800">
            🚀 Инструкции по запуску
          </h3>
          <div class="bg-gray-100 p-4 rounded font-mono text-sm">
            <div class="mb-2"># Запуск в режиме разработки</div>
            <div class="mb-4">./docker-manage.sh dev</div>
            
            <div class="mb-2"># Запуск в production режиме</div>
            <div class="mb-4">./docker-manage.sh prod</div>
            
            <div class="mb-2"># Просмотр логов</div>
            <div class="mb-4">./docker-manage.sh logs</div>
            
            <div class="mb-2"># Остановка</div>
            <div>./docker-manage.sh stop</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import AuthIntegration from '@/components/AuthIntegration.vue'
</script>

<style scoped>
code {
  background-color: #f3f4f6;
  padding: 0.125rem 0.25rem;
  border-radius: 0.25rem;
  font-size: 0.875rem;
}
</style>