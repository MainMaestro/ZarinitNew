<script setup lang="ts">
import DeviceCard from "@/entities/device/ui/DeviceCard.vue";
import DeviceFilters from "@/features/device/ui/DeviceFilters.vue";
import { ref, onMounted } from "vue"
import axios from "axios"


const clients = ref<any[]>([])

onMounted(() => {
  axios.get(`localhost/api/clients/`, {
    headers: {
      Authorization:
        "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwidXNlcklkIjoiNzNhMmU0MmUtZDc2OS00ODZlLTlkYzEtOTcyZmRhMDNhOGI2IiwiZ3JvdXBJZCI6IjczYTJlNDJlLWQ3NjktNDg2ZS05ZGMxLTk3MmZkYTAzYThiNiIsInJvbGVzIjpbImFkbWluIl0sImlhdCI6MTc1NzE4Mjg3MywiZXhwIjoxNzU3MjY5MjY5fQ.fZOd-eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwidXNlcklkIjoiNzNhMmU0MmUtZDc2OS00ODZlLTlkYzEtOTcyZmRhMDNhOGI2IiwiZ3JvdXBJZCI6IjczYTJlNDJlLWQ3NjktNDg2ZS05ZGMxLTk3MmZkYTAzYThiNiIsInJvbGVzIjpbImFkbWluIl0sImlhdCI6MTc1NzE4Mjg3MywiZXhwIjoxNzU3MjY5MjY5fQ.fZOd-5f_S9UDrn4eFlNjjpchZ5IHNmFKoDggAA6eFnJEHZKVfAKrtNyP2M05ofm1a9GtRaUUSkS9dUbbB2x8kg", // сократил для примера
    },
  })
    .then((res) => {
      clients.value = res.data.nodes
    })
    .catch((err) => console.error(err))
})
</script>

<template>
  <section class="p-6 bg-zinc-900 rounded-xl">
    <DeviceFilters />
    <div class="grid grid-cols-4 gap-4 mt-6">
      <DeviceCard
        v-for="device in clients"
        :key="JSON.stringify(device)"
        :device="device"
      />
    </div>
  </section>
</template>

<style scoped></style>
