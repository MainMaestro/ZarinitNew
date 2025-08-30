<template>
  <div class="auth-status">
    <!-- Загрузка -->
    <div v-if="loading" class="auth-loading">
      <div class="spinner"></div>
      <span>Проверка авторизации...</span>
    </div>

    <!-- Пользователь авторизован -->
    <div v-else-if="isAuthenticated" class="auth-authenticated">
      <div class="user-info">
        <div class="user-details">
          <h3>👋 Добро пожаловать, {{ userInfo.username }}!</h3>
          <p class="user-email">📧 {{ userInfo.email }}</p>
          <p class="user-role">🔑 Роль: {{ userInfo.role }}</p>
        </div>
        
        <div class="auth-actions">
          <a href="/auth/profile" class="btn btn-secondary">👤 Профиль</a>
          <a v-if="isAdmin" href="/auth/admin/users" class="btn btn-secondary">⚙️ Админка</a>
          <button @click="handleLogout" class="btn btn-danger" :disabled="loading">
            🚪 Выйти
          </button>
        </div>
      </div>
    </div>

    <!-- Пользователь НЕ авторизован - показываем сообщение о перенаправлении -->
    <div v-else class="auth-not-authenticated">
      <div class="redirect-message">
        <p>🔒 Требуется авторизация</p>
        <p>Перенаправление на страницу входа...</p>
        <div class="spinner"></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAuth } from '@/composables/useAuth'

const { 
  isAuthenticated, 
  userInfo, 
  loading,
  isAdmin,
  checkAuth,
  logout
} = useAuth()

// Проверяем авторизацию при загрузке компонента
onMounted(async () => {
  const user = await checkAuth()
  
  // Если пользователь не авторизован, перенаправляем на страницу входа
  if (!user && !isAuthenticated.value) {
    // Небольшая задержка для показа сообщения
    setTimeout(() => {
      window.location.href = '/auth/login'
    }, 1000)
  }
})

// Обработка выхода
const handleLogout = async () => {
  const result = await logout()
  if (result.success) {
    // После выхода перенаправляем на страницу входа
    window.location.href = '/auth/login'
  } else {
    console.error('Ошибка при выходе:', result.error)
  }
}
</script>

<style scoped>
.auth-status {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 20px;
  border-radius: 12px;
  margin: 10px 0;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.auth-loading, .redirect-message {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  justify-content: center;
  text-align: center;
}

.spinner {
  width: 20px;
  height: 20px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top: 2px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.auth-authenticated {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.user-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 15px;
}

.user-details h3 {
  margin: 0 0 8px 0;
  font-size: 1.2em;
}

.user-details p {
  margin: 4px 0;
  opacity: 0.9;
  font-size: 0.9em;
}

.auth-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.auth-not-authenticated {
  text-align: center;
}

.redirect-message p {
  margin: 5px 0;
  font-size: 1.1em;
}

.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  text-decoration: none;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 5px;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-primary {
  background: #4CAF50;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: #45a049;
  transform: translateY(-1px);
}

.btn-secondary {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.btn-secondary:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-1px);
}

.btn-danger {
  background: #f44336;
  color: white;
}

.btn-danger:hover:not(:disabled) {
  background: #da190b;
  transform: translateY(-1px);
}

/* Адаптивность */
@media (max-width: 768px) {
  .user-info {
    flex-direction: column;
    align-items: stretch;
  }
  
  .auth-actions {
    justify-content: center;
  }
}
</style>