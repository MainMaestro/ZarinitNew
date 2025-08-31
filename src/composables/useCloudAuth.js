/**
 * Composable для работы с Cloud-Auth API
 * Обеспечивает интеграцию между ZarinitNew и системой аутентификации
 */

import { ref, computed } from 'vue'
import axios from 'axios'

// Базовый URL для API аутентификации
const AUTH_API_BASE = '/auth/api'

// Глобальное состояние аутентификации
const isAuthenticated = ref(false)
const currentUser = ref(null)
const userGroups = ref([])

export function useCloudAuth() {
  const loading = ref(false)
  const error = ref(null)

  /**
   * Проверка принадлежности к группе
   * @param {string} groupName - Название группы
   * @param {string} passwordPhrase - Пароль группы (опционально)
   * @returns {Promise<Object>} Результат проверки
   */
  const checkGroup = async (groupName, passwordPhrase = '') => {
    loading.value = true
    error.value = null

    try {
      const response = await axios.post(`${AUTH_API_BASE}/check-group`, {
        group_name: groupName,
        password_phrase: passwordPhrase
      })

      return response.data
    } catch (err) {
      error.value = err.response?.data?.error || 'Ошибка при проверке группы'
      throw err
    } finally {
      loading.value = false
    }
  }

  /**
   * Генерация пароля для группы (только для админов)
   * @param {string} groupName - Название группы
   * @returns {Promise<Object>} Результат генерации
   */
  const generateGroupPassword = async (groupName) => {
    loading.value = true
    error.value = null

    try {
      const response = await axios.post(`${AUTH_API_BASE}/generate-password`, {
        group_name: groupName
      })

      return response.data
    } catch (err) {
      error.value = err.response?.data?.error || 'Ошибка при генерации пароля'
      throw err
    } finally {
      loading.value = false
    }
  }

  /**
   * Проверка статуса аутентификации
   * @returns {Promise<boolean>} Статус аутентификации
   */
  const checkAuthStatus = async () => {
    try {
      const response = await axios.get('/auth/dashboard')
      isAuthenticated.value = response.status === 200
      return isAuthenticated.value
    } catch (err) {
      isAuthenticated.value = false
      return false
    }
  }

  /**
   * Получение информации о текущем пользователе
   * @returns {Promise<Object|null>} Информация о пользователе
   */
  const getCurrentUser = async () => {
    try {
      const response = await axios.get('/auth/profile')
      if (response.status === 200) {
        // Парсим HTML ответ для извлечения данных пользователя
        // В реальном проекте лучше создать отдельный API endpoint
        currentUser.value = {
          authenticated: true,
          // Здесь можно добавить парсинг HTML или создать отдельный API
        }
        return currentUser.value
      }
    } catch (err) {
      currentUser.value = null
      return null
    }
  }

  /**
   * Перенаправление на страницу входа
   */
  const redirectToLogin = () => {
    window.location.href = '/auth/login'
  }

  /**
   * Перенаправление на страницу выхода
   */
  const logout = () => {
    window.location.href = '/auth/logout'
  }

  /**
   * Перенаправление в админ панель
   */
  const redirectToAdmin = () => {
    window.location.href = '/auth/admin/users'
  }

  /**
   * Middleware для защищенных маршрутов
   * @param {Function} next - Функция продолжения
   * @param {string} requiredGroup - Требуемая группа (опционально)
   */
  const requireAuth = async (next, requiredGroup = null) => {
    const authenticated = await checkAuthStatus()
    
    if (!authenticated) {
      redirectToLogin()
      return false
    }

    if (requiredGroup) {
      try {
        const groupCheck = await checkGroup(requiredGroup)
        if (!groupCheck.exists || !groupCheck.valid_password) {
          error.value = `Требуется доступ к группе: ${requiredGroup}`
          return false
        }
      } catch (err) {
        error.value = 'Ошибка при проверке прав доступа'
        return false
      }
    }

    if (next) next()
    return true
  }

  // Computed свойства
  const isLoading = computed(() => loading.value)
  const hasError = computed(() => !!error.value)
  const errorMessage = computed(() => error.value)

  return {
    // Состояние
    isAuthenticated: computed(() => isAuthenticated.value),
    currentUser: computed(() => currentUser.value),
    userGroups: computed(() => userGroups.value),
    isLoading,
    hasError,
    errorMessage,

    // Методы
    checkGroup,
    generateGroupPassword,
    checkAuthStatus,
    getCurrentUser,
    requireAuth,
    redirectToLogin,
    logout,
    redirectToAdmin,

    // Утилиты
    clearError: () => { error.value = null }
  }
}

// Экспорт для глобального использования
export default useCloudAuth