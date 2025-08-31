<template>
  <div class="auth-integration p-6 bg-white rounded-lg shadow-lg">
    <h2 class="text-2xl font-bold mb-6 text-gray-800">
      Интеграция с Cloud-Auth
    </h2>

    <!-- Статус аутентификации -->
    <div class="mb-6">
      <div class="flex items-center gap-3 mb-3">
        <div 
          :class="[
            'w-3 h-3 rounded-full',
            isAuthenticated ? 'bg-green-500' : 'bg-red-500'
          ]"
        ></div>
        <span class="font-medium">
          {{ isAuthenticated ? 'Аутентифицирован' : 'Не аутентифицирован' }}
        </span>
      </div>
      
      <div class="flex gap-2">
        <button
          v-if="!isAuthenticated"
          @click="redirectToLogin"
          class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors"
        >
          Войти в систему
        </button>
        
        <button
          v-if="isAuthenticated"
          @click="logout"
          class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 transition-colors"
        >
          Выйти
        </button>
        
        <button
          @click="redirectToAdmin"
          class="px-4 py-2 bg-purple-500 text-white rounded hover:bg-purple-600 transition-colors"
        >
          Админ панель
        </button>
      </div>
    </div>

    <!-- Проверка группы -->
    <div class="mb-6 p-4 border border-gray-200 rounded">
      <h3 class="text-lg font-semibold mb-3">Проверка принадлежности к группе</h3>
      
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">
            Название группы
          </label>
          <input
            v-model="groupName"
            type="text"
            placeholder="Введите название группы"
            class="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
        </div>
        
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">
            Пароль группы (опционально)
          </label>
          <input
            v-model="groupPassword"
            type="password"
            placeholder="Пароль группы"
            class="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
        </div>
      </div>
      
      <button
        @click="handleCheckGroup"
        :disabled="!groupName || isLoading"
        class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
      >
        {{ isLoading ? 'Проверка...' : 'Проверить группу' }}
      </button>
      
      <!-- Результат проверки группы -->
      <div v-if="groupCheckResult" class="mt-4 p-3 rounded" :class="[
        groupCheckResult.exists ? 'bg-green-100 border border-green-300' : 'bg-red-100 border border-red-300'
      ]">
        <div class="font-medium">
          {{ groupCheckResult.exists ? '✅ Группа найдена' : '❌ Группа не найдена' }}
        </div>
        <div v-if="groupCheckResult.exists" class="text-sm mt-1">
          <div>Описание: {{ groupCheckResult.group_description || 'Не указано' }}</div>
          <div>Пароль корректен: {{ groupCheckResult.valid_password ? 'Да' : 'Нет' }}</div>
        </div>
        <div v-if="groupCheckResult.message" class="text-sm mt-1">
          {{ groupCheckResult.message }}
        </div>
      </div>
    </div>

    <!-- Генерация пароля (только для админов) -->
    <div class="mb-6 p-4 border border-gray-200 rounded">
      <h3 class="text-lg font-semibold mb-3">Генерация пароля группы</h3>
      <p class="text-sm text-gray-600 mb-3">
        Доступно только администраторам
      </p>
      
      <div class="flex gap-2 mb-4">
        <input
          v-model="passwordGroupName"
          type="text"
          placeholder="Название группы для генерации пароля"
          class="flex-1 px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
        <button
          @click="handleGeneratePassword"
          :disabled="!passwordGroupName || isLoading"
          class="px-4 py-2 bg-orange-500 text-white rounded hover:bg-orange-600 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
        >
          {{ isLoading ? 'Генерация...' : 'Генерировать' }}
        </button>
      </div>
      
      <!-- Результат генерации пароля -->
      <div v-if="generatedPassword" class="p-3 bg-blue-100 border border-blue-300 rounded">
        <div class="font-medium">🔑 Сгенерированный пароль:</div>
        <div class="font-mono text-lg mt-1 p-2 bg-white rounded border">
          {{ generatedPassword }}
        </div>
        <button
          @click="copyToClipboard(generatedPassword)"
          class="mt-2 px-3 py-1 text-sm bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors"
        >
          Копировать
        </button>
      </div>
    </div>

    <!-- Ошибки -->
    <div v-if="hasError" class="p-3 bg-red-100 border border-red-300 rounded text-red-700">
      <div class="font-medium">❌ Ошибка:</div>
      <div>{{ errorMessage }}</div>
      <button
        @click="clearError"
        class="mt-2 px-3 py-1 text-sm bg-red-500 text-white rounded hover:bg-red-600 transition-colors"
      >
        Закрыть
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useCloudAuth } from '@/composables/useCloudAuth'

// Используем composable для работы с аутентификацией
const {
  isAuthenticated,
  isLoading,
  hasError,
  errorMessage,
  checkGroup,
  generateGroupPassword,
  checkAuthStatus,
  redirectToLogin,
  logout,
  redirectToAdmin,
  clearError
} = useCloudAuth()

// Локальное состояние компонента
const groupName = ref('')
const groupPassword = ref('')
const groupCheckResult = ref(null)
const passwordGroupName = ref('')
const generatedPassword = ref('')

// Обработчик проверки группы
const handleCheckGroup = async () => {
  try {
    groupCheckResult.value = null
    const result = await checkGroup(groupName.value, groupPassword.value)
    groupCheckResult.value = result
  } catch (error) {
    console.error('Ошибка при проверке группы:', error)
  }
}

// Обработчик генерации пароля
const handleGeneratePassword = async () => {
  try {
    generatedPassword.value = ''
    const result = await generateGroupPassword(passwordGroupName.value)
    if (result.success) {
      generatedPassword.value = result.password
    }
  } catch (error) {
    console.error('Ошибка при генерации пароля:', error)
  }
}

// Копирование в буфер обмена
const copyToClipboard = async (text) => {
  try {
    await navigator.clipboard.writeText(text)
    alert('Пароль скопирован в буфер обмена!')
  } catch (error) {
    console.error('Ошибка при копировании:', error)
    // Fallback для старых браузеров
    const textArea = document.createElement('textarea')
    textArea.value = text
    document.body.appendChild(textArea)
    textArea.select()
    document.execCommand('copy')
    document.body.removeChild(textArea)
    alert('Пароль скопирован в буфер обмена!')
  }
}

// Проверяем статус аутентификации при загрузке компонента
onMounted(() => {
  checkAuthStatus()
})
</script>

<style scoped>
.auth-integration {
  max-width: 800px;
  margin: 0 auto;
}
</style>