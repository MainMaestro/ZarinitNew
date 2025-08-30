export interface SimCard {
  operator: string;
  active: boolean;
  connection: string;
  speed: string;
}

export interface Device {
  id: string;
  name: string;
  ip: string;
  mac: string;
  speed: string;
  lastSeen: string;
  online: boolean;
  tags: string[];

  firmware?: string;
  uptime?: string;
  cpuLoad?: number;
  memoryUsage?: number;
  downloadSpeed?: string;
  uploadSpeed?: string;
  simCards?: SimCard[];
  availableTags?: string[];
}
