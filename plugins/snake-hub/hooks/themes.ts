// Die fünf Themes des Snake-Hub. Jedes hat einen hellen und einen dunklen Modus.
type Anchors = { "surface-0": string; "text-primary": string } & Partial<Record<"surface-1" | "surface-2" | "surface-3" | "text-secondary" | "text-muted", string>>
type Seed = { name: string; emoji: string; roles: Record<"accent" | "danger" | "success" | "warning" | "pro", string>; light: Anchors; dark: Anchors }
export const THEME_SEEDS: Record<string, Seed> = {
  herbst: {
    name: 'Herbstlaub', emoji: '🍂',
    roles: { accent: '#c8641e', danger: '#b33a2a', success: '#5b7d2e', warning: '#b07a12', pro: '#8a4f7a' },
    light: { 'surface-0': '#f1e6d4', 'surface-1': '#f6ecdd', 'surface-2': '#fbf4e8', 'text-primary': '#2b2018', 'text-secondary': '#55432f', 'text-muted': '#6b5843' },
    dark: { 'surface-0': '#1e1712', 'surface-1': '#271e17', 'surface-2': '#30251c', 'surface-3': '#382b20', 'text-primary': '#f3e6d4', 'text-secondary': '#d6c3aa', 'text-muted': '#b09a80' },
  },
  sakura: {
    name: 'Sakura', emoji: '🌸',
    roles: { accent: '#c2406e', danger: '#b3352f', success: '#4f7d4a', warning: '#a8701a', pro: '#7a52a0' },
    light: { 'surface-0': '#f6e9ec', 'surface-1': '#f9eff1', 'surface-2': '#fcf6f7', 'text-primary': '#2c1d22', 'text-secondary': '#57404a', 'text-muted': '#6e5660' },
    dark: { 'surface-0': '#1d1519', 'surface-1': '#261b20', 'surface-2': '#2f2228', 'surface-3': '#36272e', 'text-primary': '#f5e6eb', 'text-secondary': '#dbc3cc', 'text-muted': '#b79ba6' },
  },
  mitternacht: {
    name: 'Mitternacht', emoji: '🌙',
    roles: { accent: '#5468d4', danger: '#c0392b', success: '#3f8a5a', warning: '#b07d12', pro: '#8b5cc4' },
    light: { 'surface-0': '#e7e9f2', 'surface-1': '#eef0f7', 'surface-2': '#f5f6fb', 'text-primary': '#191c2b', 'text-secondary': '#3d4258', 'text-muted': '#555b72' },
    dark: { 'surface-0': '#11131d', 'surface-1': '#181b27', 'surface-2': '#1f2331', 'surface-3': '#262a39', 'text-primary': '#e6e8f4', 'text-secondary': '#c1c5da', 'text-muted': '#999fb8' },
  },
  ozean: {
    name: 'Ozean', emoji: '🌊',
    roles: { accent: '#1f7fa3', danger: '#b8402f', success: '#2f8566', warning: '#a87612', pro: '#6058b0' },
    light: { 'surface-0': '#e2eef1', 'surface-1': '#eaf3f5', 'surface-2': '#f3f9fa', 'text-primary': '#12242b', 'text-secondary': '#36505a', 'text-muted': '#4d6772' },
    dark: { 'surface-0': '#0f1a1e', 'surface-1': '#152328', 'surface-2': '#1b2c32', 'surface-3': '#21333a', 'text-primary': '#e2f0f3', 'text-secondary': '#bcd3d9', 'text-muted': '#93afb7' },
  },
  wald: {
    name: 'Wald', emoji: '🌲',
    roles: { accent: '#3f7a3a', danger: '#b33a2a', success: '#2f7a46', warning: '#a87a12', pro: '#7a5a94' },
    light: { 'surface-0': '#e6ecdf', 'surface-1': '#edf2e7', 'surface-2': '#f5f8f1', 'text-primary': '#1b2417', 'text-secondary': '#3f4c38', 'text-muted': '#56634d' },
    dark: { 'surface-0': '#131a12', 'surface-1': '#1a2318', 'surface-2': '#212b1e', 'surface-3': '#273224', 'text-primary': '#e7eee2', 'text-secondary': '#c4d1bb', 'text-muted': '#9eae93' },
  },
}
