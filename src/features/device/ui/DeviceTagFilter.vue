<script setup lang="ts">
import { useDevicesStore } from "@/entities/device/model/deviceStore"

const { allTags, selectedTags, toggleTag } = useDevicesStore()
</script>

<template>
  <div class="flex flex-wrap gap-2">
    <button
      v-for="tag in allTags"
      :key="tag"
      @click="toggleTag(tag)"
      class="px-3 py-1 rounded border"
      :class="{
        'bg-[#37343D] stroke-1 stroke-[#7A46D3] text-white': selectedTags.includes(tag),
        'bg-[#1A2333] text-zinc-300': !selectedTags.includes(tag)
      }"
    >
      {{ tag }}
    </button>
  </div>
</template>

<style scoped>

</style>