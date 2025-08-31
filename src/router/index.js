import { createRouter, createWebHistory } from "vue-router";
import SuperUserPage from "@/pages/superuser/ui/SuperUserPage.vue";
import DevicePage from "@/pages/device/ui/DevicePage.vue";
import AuthDemo from "@/pages/AuthDemo.vue";

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

export default router;
