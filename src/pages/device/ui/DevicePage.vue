<script setup lang="ts">
import { useRoute } from "vue-router";
import { computed, ref } from "vue";
import { useDevicesStore } from "@/entities/device/model/deviceStore";
import DeviceHeader from "@/components/DeviceHeader.vue";

const route = useRoute();
const devicesStore = useDevicesStore();

// Находим устройство по id
const device = computed(() =>
  devicesStore.devices.find((d) => d.id === route.params.id)
);

// Для добавления нового тега
const newTag = ref("");
const addTag = () => {
  if (device.value && newTag.value.trim() !== "") {
    if (!device.value.tags.includes(newTag.value)) {
      device.value.tags.push(newTag.value);
    }
    newTag.value = "";
  }
};

// Массив для основной информации
const deviceInfo = computed(() =>
  device.value
    ? [
        { label: "IP", value: device.value.ip },
        { label: "MAC", value: device.value.mac },
        { label: "Прошивка", value: device.value.firmware },
        { label: "Время работы", value: device.value.uptime },
      ]
    : []
);

// Массив для информации о скорости сети
const networkInfo = computed(() =>
  device.value
    ? [
        { label: "Загрузка", value: device.value.downloadSpeed + " Mbps" },
        { label: "Отдача", value: device.value.uploadSpeed + " Mbps" },
        { label: "Память", value: device.value.memoryUsage + "%" },
        { label: "CPU", value: device.value.cpuLoad + "%" },
      ]
    : []
);

// Массив для SIM-карт
const simCards = computed(() => device.value?.simCards ?? []);
</script>

<template>
  <DeviceHeader />
  <div v-if="device" class="p-6 space-y-6 text-white grid grid-cols-2 gap-4">
    <!-- Основная информация -->
    <section
      class="rounded-xl bg-[#222228] p-4 shadow-md border border-[#363E4B] text-white"
    >
      <h2 class="text-lg font-semibold mb-2">Основная информация</h2>
      <div class="grid grid-cols-2 gap-4">
        <div
          v-for="(item, index) in deviceInfo"
          :key="index"
          class="bg-[#303046] p-4 rounded-xl"
        >
          <span>
            <b class="text-[#979797]">{{ item.label }}:</b><br />
            {{ item.value }}
          </span>
        </div>
      </div>
    </section>

   

    <!-- SIM карты -->
    <section class="bg-[#222228] p-4 rounded shadow border border-[#363E4B]">
      <h2 class="text-lg font-semibold mb-2">
        SIM карты (активно {{ simCards.filter((s) => s.active).length }}/{{
          simCards.length
        }})
      </h2>
      <div class="grid grid-cols-2 gap-4">
        <div
          v-for="sim in simCards"
          :key="sim.operator"
          class="p-2 border rounded flex justify-between"
        >
          <span>{{ sim.operator }} ({{ sim.connection }})</span>
          <span :class="sim.active ? 'text-green-500' : 'text-red-500'">
            {{ sim.speed }}
          </span>
        </div>
      </div>
    </section>
     <!-- Скорость сети -->
    <section class="bg-[#222228] p-4 rounded shadow border border-[#363E4B]">
      <h2 class="text-lg font-semibold mb-2">Скорость сети</h2>
      <div class="grid grid-cols-2 gap-4">
        <div
          v-for="(item, index) in networkInfo"
          :key="index"
          class="bg-[#303046] p-4 rounded-xl"
        >
          <span>
            <b class="text-[#979797]">{{ item.label }}:</b><br />
            {{ item.value }}
          </span>
        </div>
      </div>
    </section>

    <!-- Управление тегами -->
    <section class="bg-[#222228] p-4 rounded shadow border border-[#363E4B]">
      <h2 class="text-lg font-semibold mb-2">Управление тегами</h2>
      <div class="mb-2"><b>Текущие:</b> {{ device.tags.join(", ") }}</div>
      <div class="mb-2">
        <b>Возможные:</b> {{ device.availableTags?.join(", ") ?? "" }}
      </div>
      <div class="flex gap-2">
        <input
          v-model="newTag"
          type="text"
          placeholder="Новый тег"
          class="border rounded px-2 py-1 flex-1"
        />
        <button
          @click="addTag"
          class="bg-blue-500 text-white px-3 py-1 rounded"
        >
          Добавить
        </button>
      </div>
    </section>

    <!-- Быстрые действия -->
    <section
      class="bg-[#222228] p-4 rounded shadow space-x-2 border border-[#363E4B]"
    >
      <h2 class="text-lg font-semibold mb-2">Быстрые действия</h2>
      <div class="flex gap-3">
        <button class="bg-[#303046] text-red-500 p-4 rounded-xl flex ">
          Перезагрузить роутер
          <img class="ml-3" src="/src//assets/Refresh.svg" alt="" />
        </button>
        <button class="bg-[#303046] text-white p-4 rounded-xl flex">
          Обновить прошивку <img class="ml-3" src="/src/assets/Download.svg" alt="">
        </button>
        <button class="bg-[#303046] text-white p-4 rounded-xl flex">
          Системные логи <img class="ml-3" src="/src/assets/Message.svg" alt="">
        </button>
      </div>
    </section>
  </div>

  <p v-else class="p-6">Устройство не найдено</p>
</template>
