<script setup lang="ts">
import DeviceCard from "@/entities/device/ui/DeviceCard.vue";
import { useDevicesStore } from "@/entities/device/model/deviceStore";
import DeviceFilters from "@/features/device/ui/DeviceFilters.vue";

const devicesStore = useDevicesStore();
</script>

<template>
  <section class="p-6 bg-zinc-900 rounded-xl">
    <DeviceFilters />
    <div class="grid grid-cols-4 gap-4 mt-6">
      <DeviceCard
        v-for="device in devicesStore.devices"
        :key="JSON.stringify(device)"
        :device="device"
      />
      
    </div>
  </section>
</template>

<style scoped></style>
