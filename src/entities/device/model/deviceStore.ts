import { defineStore } from "pinia";
import { ref, computed } from "vue";
import type { Device } from "@/entities/device/model/device.types";
import rawItems from '@/mock/superuser/devices.json'

const items: Partial<Device>[] = rawItems.items

export const useDevicesStore = defineStore("devices", () => {
  const devices = ref<Device[]>(
    items.map((d, i) => ({
      id: d.id || String(i + 1),
      name: d.name || "Unknown",
      ip: d.ip || "0.0.0.0",
      mac: d.mac || "00:00:00:00:00:00",
      speed: d.speed || "0 Мбит/с",
      lastSeen: d.lastSeen || "—",
      online: d.online ?? false, // если undefined → false
      tags: d.tags || [],

      // опциональные поля с дефолтами
      firmware: d.firmware || "—",
      uptime: d.uptime || "—",
      cpuLoad: d.cpuLoad || 0,
      memoryUsage: d.memoryUsage || 0,
      downloadSpeed: d.downloadSpeed || "—",
      uploadSpeed: d.uploadSpeed || "—",
      simCards: d.simCards || [],
      availableTags: d.availableTags || [],
    }))
  );

  const selectedTags = ref<string[]>([]);
  const searchQuery = ref("");

  const setSearchQuery = (query: string) => {
    searchQuery.value = query;
  };

  const filteredDevices = computed(() => {
    const matchesTags = (device: Device) =>
      selectedTags.value.every((tag) => device.tags.includes(tag));

    const matchesSearch = (device: Device) =>
      device.name.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      device.ip.includes(searchQuery.value);

    return devices.value.filter(
      (device) => matchesTags(device) && matchesSearch(device)
    );
  });

  const toggleTag = (tag: string) => {
    if (selectedTags.value.includes(tag)) {
      selectedTags.value = selectedTags.value.filter((t) => t !== tag);
    } else {
      selectedTags.value.push(tag);
    }
  };

  const allTags = computed(() => {
    const tags = new Set<string>();
    devices.value.forEach((d) => d.tags.forEach((t) => tags.add(t)));
    return [...tags];
  });

  return {
    devices,
    selectedTags,
    toggleTag,
    filteredDevices,
    allTags,
    setSearchQuery,
    searchQuery,
  };
});
