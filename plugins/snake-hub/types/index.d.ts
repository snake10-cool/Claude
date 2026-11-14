export type Fortschritt = { prozent: number; aufgabe: string; schritt: string }
export type HubSettings = { theme: string; mods: Record<string, boolean>; skills: Record<string, boolean> }

declare module 'claude-code' {
  interface PluginState {
    'snake-hub': { fortschritt: Shaped<Fortschritt>; settings: Shaped<HubSettings> }
  }
}
