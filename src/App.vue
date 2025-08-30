<script setup>
import { RouterView } from "vue-router";
import SuperUserPage from "./pages/superuser/ui/SuperUserPage.vue";
import AuthStatus from "./components/AuthStatus.vue"; // ← Добавить эту строку
</script>

<template>
  <main>
    <AuthStatus />
    <RouterView />
  </main>
</template>

<style scoped></style>
