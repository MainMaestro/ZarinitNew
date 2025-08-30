<script setup lang="ts">
import DeviceSearch from './DeviceSearch.vue'
import DeviceTagFilter from './DeviceTagFilter.vue'
</script>

<template>
  <div class="space-y-4 bg-[#222228] p-5 rounded-3xl">
    <h2 class="text-lg font-semibold text-white">Фильтры</h2>
    <DeviceSearch />
    <div class="text-sm text-zinc-400">Теги устройств:</div>
    <DeviceTagFilter />
  </div>
</template>