import { createRouter, createWebHistory } from "vue-router";
import SuperUserPage from "@/pages/superuser/ui/SuperUserPage.vue";
import DevicePage from "@/pages/device/ui/DevicePage.vue";
import AuthDemo from "@/pages/AuthDemo.vue";
import { useAuth } from "@/composables/useAuth.js";

const routes = [
  {
    path: '/',
    component: SuperUserPage,
  },
  {
    path: "/device",
    name: "SuperUserPage",
    component: SuperUserPage,
  },
  {
    path: "/device/:id",
    name: "DevicePage",
    component: DevicePage,
    props: true,
  },
  {
    path: "/auth-demo",
    name: "AuthDemo",
    component: AuthDemo,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

// Глобальная проверка авторизации перед каждым переходом
router.beforeEach(async (to, from, next) => {
  const { checkAuth, isAuthenticated } = useAuth()
  
  try {
    // Проверяем авторизацию
    await checkAuth()
    
    // Если пользователь не авторизован, перенаправляем на страницу входа
    if (!isAuthenticated.value) {
      window.location.href = '/auth/login'
      return
    }
    
    // Если авторизован, продолжаем навигацию
    next()
  } catch (error) {
    console.error('Ошибка проверки авторизации:', error)
    // В случае ошибки тоже перенаправляем на вход
    window.location.href = '/auth/login'
  }
})

export default router;
