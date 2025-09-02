<script setup lang="ts">
import { useRoute } from "vue-router";
import { computed, onMounted } from "vue";
import { useDevicesStore } from "@/entities/device/model/deviceStore";
import { useAuth } from '@/composables/useAuth.js'

const route = useRoute();
const devicesStore = useDevicesStore();

// Получаем текущее устройство по id из route
const device = computed(() =>
  devicesStore.devices.find((d) => d.id === route.params.id)
);

const { 
  isAuthenticated, 
  userInfo, 
  loading,
  isAdmin,
  checkAuth
} = useAuth()

// Проверяем авторизацию при загрузке компонента
onMounted(() => {
  checkAuth()
})

// Функция выхода из системы
const handleLogout = () => {
  // Перенаправляем на страницу выхода cloud-auth
  window.location.href = '/auth/logout'
}
</script>

<template>
  <header class="bg-linear-to-r from-[#452587] to-[#470ABF] h-20 content-center text-white shadow-md sticky top-0 z-50">
    <div class="mx-auto flex items-center justify-between p-4">
      <div class="flex flex-col">
         <router-link
          to="/device"
          class="text-sm flex justify-center hover:underline">
          <img src="/src/assets/icon.svg" class="" alt="" />
          <span>Назад к устройствам</span>
        </router-link>
        <div class="flex items-center space-x-2 mb-2">
          <img src="/src/assets/Logo.svg" alt="Logo" class="h-8 w-8" />
          <span class="font-bold text-lg">
            {{ device ? device.name : "Устройство" }}
          </span>
        </div>
       
      </div>

      <div class="flex items-center space-x-4">
        <div class="text-right">
          <div class="text-sm">
            <span class="font-semibold">{{ userInfo?.username || 'Пользователь' }}</span>
          </div>
          <div v-if="userInfo?.role" class="text-xs opacity-75">
            {{ userInfo.role === 'admin' ? 'Администратор' : 'Пользователь' }}
          </div>
        </div>
        <div class="flex items-center space-x-2">
          <button 
            v-if="isAdmin"
            @click="() => window.location.href = '/auth/admin/users'"
            class="px-3 py-1 text-xs bg-white/20 hover:bg-white/30 rounded-md transition-colors duration-200"
            title="Админ панель"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
            </svg>
          </button>
          <button 
            @click="handleLogout"
            class="px-3 py-1 text-xs bg-red-500/80 hover:bg-red-500 rounded-md transition-colors duration-200 flex items-center space-x-1"
            title="Выйти"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
            </svg>
            <span>Выйти</span>
          </button>
        </div>
      </div>
    </div>
  </header>
</template>
