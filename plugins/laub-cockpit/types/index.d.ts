export type Fortschritt = { prozent: number; aufgabe: string; schritt: string }

declare module 'claude-code' {
  interface PluginState {
    'laub-cockpit': { fortschritt: Shaped<Fortschritt> }
  }
}
