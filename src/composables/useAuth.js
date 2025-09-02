import { ref, computed } from 'vue'

// Глобальное состояние авторизации
const isAuthenticated = ref(false)
const userInfo = ref(null)
const loading = ref(false)

export function useAuth() {
  // Проверка авторизации
  const checkAuth = async () => {
    loading.value = true
    try {
      const response = await fetch('/auth/api/check-auth', {
        credentials: 'include'
      })
      
      if (response.ok) {
        const data = await response.json()
        
        if (data.authenticated) {
          isAuthenticated.value = true
          userInfo.value = data.user
          return data.user
        } else {
          isAuthenticated.value = false
          userInfo.value = null
          return null
        }
      } else {
        isAuthenticated.value = false
        userInfo.value = null
        return null
      }
    } catch (error) {
      console.error('Ошибка проверки авторизации:', error)
      isAuthenticated.value = false
      userInfo.value = null
      return null
    } finally {
      loading.value = false
    }
  }

  // Авторизация
  const login = async (email, password) => {
    loading.value = true
    try {
      const response = await fetch('/api/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        credentials: 'include',
        body: JSON.stringify({
          email,
          password
        })
      })
      
      const data = await response.json()
      
      if (data.success) {
        isAuthenticated.value = true
        userInfo.value = data.user
        return {
          success: true,
          user: data.user
        }
      } else {
        isAuthenticated.value = false
        userInfo.value = null
        return {
          success: false,
          error: data.error
        }
      }
    } catch (error) {
      console.error('Ошибка авторизации:', error)
      isAuthenticated.value = false
      userInfo.value = null
      return {
        success: false,
        error: 'Ошибка сети'
      }
    } finally {
      loading.value = false
    }
  }

  // Выход из системы
  const logout = async () => {
    loading.value = true
    try {
      const response = await fetch('/api/logout', {
        method: 'POST',
        credentials: 'include'
      })
      
      const data = await response.json()
      
      if (data.success) {
        isAuthenticated.value = false
        userInfo.value = null
        return {
          success: true
        }
      } else {
        return {
          success: false,
          error: data.error
        }
      }
    } catch (error) {
      console.error('Ошибка выхода:', error)
      // Даже если запрос не удался, очищаем локальное состояние
      isAuthenticated.value = false
      userInfo.value = null
      return {
        success: false,
        error: 'Ошибка сети'
      }
    } finally {
      loading.value = false
    }
  }

  // Проверка, является ли пользователь администратором
  const isAdmin = computed(() => {
    return userInfo.value?.role === 'admin'
  })

  // Проверка группы с паролем
  const checkGroupPassword = async (groupName, password) => {
    try {
      const response = await fetch('/auth/api/check-group', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        credentials: 'include',
        body: JSON.stringify({
          group_name: groupName,
          password_phrase: password
        })
      })
      
      const data = await response.json()
      return {
        success: response.ok,
        message: data.message || (response.ok ? 'Доступ разрешен' : 'Доступ запрещен')
      }
    } catch (error) {
      console.error('Ошибка проверки группы:', error)
      return {
        success: false,
        message: 'Ошибка сети'
      }
    }
  }

  // Генерация пароля для группы (только для админов)
  const generateGroupPassword = async (groupName) => {
    try {
      const response = await fetch('/auth/api/generate-password', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        credentials: 'include',
        body: JSON.stringify({
          group_name: groupName
        })
      })
      
      const data = await response.json()
      return {
        success: response.ok,
        password: data.password,
        message: data.message
      }
    } catch (error) {
      console.error('Ошибка генерации пароля:', error)
      return {
        success: false,
        message: 'Ошибка сети'
      }
    }
  }

  // Проверка роли пользователя
  const hasRole = (role) => {
    return userInfo.value?.role === role
  }

  // Проверка принадлежности к группе
  const hasGroup = (groupName) => {
    if (!userInfo.value || !userInfo.value.groups) return false
    return userInfo.value.groups.some(group => group.name === groupName)
  }

  // Требовать авторизацию (для защиты маршрутов)
  const requireAuth = () => {
    if (!isAuthenticated.value) {
      window.location.href = '/auth/login'
      return false
    }
    return true
  }

  // Требовать права администратора
  const requireAdmin = () => {
    if (!isAuthenticated.value) {
      window.location.href = '/auth/login'
      return false
    }
    if (!isAdmin.value) {
      alert('Недостаточно прав доступа')
      return false
    }
    return true
  }

  return {
    // Состояние
    isAuthenticated,
    userInfo,
    loading,
    isAdmin,
    
    // Методы
    checkAuth,
    login,
    logout,
    hasRole,
    hasGroup,
    checkGroupPassword,
    generateGroupPassword,
    requireAuth,
    requireAdmin
  }
}