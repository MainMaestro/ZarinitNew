<script setup lang="ts">
import type { Device } from '../model/device.types'

defineProps<{
  device: Device
}>()
</script>

<template>


  <div class="rounded-xl bg-[#222228] p-4 shadow-md border border-zinc-700">
    <div class="flex justify-between items-center mb-2">
       <RouterLink :to="{ name: 'DevicePage', params: { id: device.id } }">
      <h3 class="text-white font-semibold text-lg">{{ device.name }}</h3>
  
</RouterLink>
      
      <span
        class="w-3 h-3 rounded-full"
        :class="device.online ? 'bg-green-400' : 'bg-red-500'"
      />
    </div>

    <ul class="text-sm text-zinc-300 space-y-3">
      <li class="flex justify-between w-full border-b border-zinc-400 border-dotted">
        <span class="text-zinc-400">IP адрес:</span>
        {{ device.ip }}
      </li>
      <li class="flex justify-between w-full border-b border-zinc-400 border-dotted">
        <span class="text-zinc-400">MAC:</span>
        {{ device.mac }}
      </li>
      <li class="flex justify-between w-full border-b border-zinc-400 border-dotted">
        <span class="text-zinc-400">Скорость:</span>
        {{ device.speed }}
      </li>
      <li class="flex justify-between w-full border-b border-zinc-400 border-dotted">
        <span class="text-zinc-400">Активность:</span>
        {{ device.lastSeen }}
      </li>
    </ul>

    <div class="flex flex-wrap gap-2 mt-3">
      <span
        v-for="tag in device.tags"
        :key="tag"
        class="px-3 py-1 rounded-full text-xs border border-violet-500 text-violet-300 bg-zinc-800"
      >
        {{ tag }}
      </span>
    </div>
  </div>
</template>

<style scoped>

</style>