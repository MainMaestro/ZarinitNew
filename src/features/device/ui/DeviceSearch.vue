<script setup lang="ts">
import { ref, watch } from 'vue'
import { useDevicesStore } from '@/entities/device/model/deviceStore'

const search = ref('')
const { devices, filteredDevices, setSearchQuery } = useDevicesStore()

watch(search, (newVal) => {
  setSearchQuery(newVal)
})
</script>

<template>
  <input
    v-model="search"
    type="text"
    placeholder="Поиск по устройствам..."
    class="w-full rounded-md bg-zinc-900 text-zinc-200 px-4 py-2 outline-none border border-zinc-700"
  />
</template>