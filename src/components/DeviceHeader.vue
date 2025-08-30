<script setup lang="ts">
import { useRoute } from "vue-router";
import { computed } from "vue";
import { useDevicesStore } from "@/entities/device/model/deviceStore";

const route = useRoute();
const devicesStore = useDevicesStore();

// Получаем текущее устройство по id из route
const device = computed(() =>
  devicesStore.devices.find((d) => d.id === route.params.id)
);
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

   
    </div>
  </header>
</template>
