import { atom, read, update } from 'claude-code'
import type { Register, ThemeSetArgs } from 'claude-code'

import type { Fortschritt } from '../types'
import { makeColors } from './make-colors.js'

// Herbstlaub bei Tag, Lagerfeuer bei Nacht.
const { theme, problems } = makeColors({
  label: 'Laub-Herbst',
  roles: { accent: '#c8641e', danger: '#b33a2a', success: '#5b7d2e', warning: '#b07a12', pro: '#8a4f7a' },
  light: {
    gray: {
      anchors: {
        'surface-0': '#f1e6d4',
        'surface-1': '#f6ecdd',
        'surface-2': '#fbf4e8',
        'text-primary': '#2b2018',
        'text-secondary': '#55432f',
        'text-muted': '#6b5843',
      },
    },
  },
  dark: {
    gray: {
      anchors: {
        'surface-0': '#1e1712',
        'surface-1': '#271e17',
        'surface-2': '#30251c',
        'surface-3': '#382b20',
        'text-primary': '#f3e6d4',
        'text-secondary': '#d6c3aa',
        'text-muted': '#b09a80',
      },
    },
  },
})

const LOOK: ThemeSetArgs = { colors: theme }
const PANE = 'laub-cockpit'
const TITEL = '🍂 Laub-Cockpit'
const TOOL = 'fortschritt'

const fortschritt = atom(
  { plugin: 'laub-cockpit', key: 'fortschritt' } as const,
  { prozent: 0, aufgabe: '', schritt: '' } as Fortschritt,
  { shape: 'fortschritt-1' },
)

const KNOEPFE: { label: string; prompt: string }[] = [
  { label: '✨ Mehr Details', prompt: 'Füge dem aktuellen Projekt mehr Details hinzu, die gut dazu passen (Grafik, Effekte, Inhalte). Melde den Fortschritt mit dem fortschritt-Werkzeug.' },
  { label: '🎮 Neues Level', prompt: 'Füge dem aktuellen Spiel ein neues, passendes Level oder einen neuen Abschnitt hinzu. Melde den Fortschritt mit dem fortschritt-Werkzeug.' },
  { label: '🐞 Bugs suchen', prompt: 'Suche im aktuellen Projekt nach Fehlern und behebe sie. Melde den Fortschritt mit dem fortschritt-Werkzeug.' },
  { label: '💡 Ideen', prompt: 'Schlage mir 5 kurze Ideen vor, was ich am aktuellen Projekt als Nächstes verbessern könnte.' },
]

function balken(prozent: number, breite = 20): string {
  const voll = Math.round((prozent / 100) * breite)
  return '█'.repeat(voll) + '░'.repeat(breite - voll)
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const unpainted = problems.find(line => line.startsWith("Desktop won't paint"))
    if (unpainted !== undefined) {
      $.ui.toast(unpainted)
    }
    await $.theme.set(LOOK)

    await $.command.register({ name: 'cockpit', description: 'Öffnet das Laub-Cockpit mit Fortschrittsbalken' })
    await $.command.register({ name: 'mehr-details', description: 'Claude fügt dem Projekt mehr passende Details hinzu' })
    await $.tool.register({
      name: TOOL,
      description:
        'Zeigt dem Nutzer den Fortschritt einer mehrstufigen Aufgabe als Ladebalken im Laub-Cockpit. ' +
        'Bei Projekten mit mehreren Schritten (z. B. ein Spiel bauen) am Anfang mit 0 aufrufen, nach jedem größeren Schritt aktualisieren und am Ende mit 100.',
      inputSchema: {
        type: 'object',
        properties: {
          prozent: { type: 'number', minimum: 0, maximum: 100, description: 'Fortschritt in Prozent' },
          aufgabe: { type: 'string', description: 'Kurzer Name des Projekts, z. B. "Laub-Spiel"' },
          schritt: { type: 'string', description: 'Was gerade passiert, z. B. "Grafik wird gebaut"' },
        },
        required: ['prozent', 'aufgabe'],
      },
    })
    void $.ui.open({ id: PANE, title: TITEL })

    return next(e)
  })

  on('command.run', { command: 'cockpit' }, async $ => {
    await $.ui.open({ id: PANE, title: TITEL })
    return { text: 'Laub-Cockpit geöffnet 🍂' }
  })

  on('command.run', { command: 'mehr-details' }, async $ => {
    void $.prompt.submit({ text: KNOEPFE[0]?.prompt ?? "Füge dem aktuellen Projekt mehr passende Details hinzu." })
    return { text: 'Okay, ich füge mehr Details hinzu ✨' }
  })

  on('tool.call', { tool: `mcp__laub-cockpit__${TOOL}` }, async ($, e) => {
    const input = (e as unknown as { input?: Record<string, unknown> }).input ?? (e as unknown as Record<string, unknown>)
    const prozent = Math.max(0, Math.min(100, Number(input.prozent) || 0))
    const aufgabe = String(input.aufgabe ?? '')
    const schritt = String(input.schritt ?? '')
    await update($, fortschritt, () => ({ prozent, aufgabe, schritt }))
    $.ui.status(`🍂 ${aufgabe}: ${Math.round(prozent)} %`)
    if (prozent >= 100) {
      $.ui.toast(`🎉 ${aufgabe} ist fertig – du kannst es abholen!`)
    }
    return { result: `Fortschritt angezeigt: ${Math.round(prozent)} %` }
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Text, Button } = $.ui.resolve(e)
    const f = await read($, fortschritt)
    const fertig = f.prozent >= 100

    return (
      <Box flexDirection="column" gap={1}>
        {f.aufgabe === '' ? (
          <Text dimColor>Noch kein Projekt läuft. Gib mir eine Aufgabe, dann siehst du hier den Ladebalken.</Text>
        ) : (
          <Box flexDirection="column">
            <Text bold>{f.aufgabe}</Text>
            <Text>
              {balken(f.prozent)} {Math.round(f.prozent)} %
            </Text>
            {f.schritt !== '' && <Text dimColor>{f.schritt}</Text>}
            {fertig && <Text bold>🎉 Fertig – dein Projekt kann abgeholt werden!</Text>}
          </Box>
        )}
        <Box flexDirection="column">
          <Text dimColor>Schnellknöpfe</Text>
          {KNOEPFE.map(k => (
            <Button key={k.label} label={k.label} onPress={() => void $.prompt.submit({ text: k.prompt })} />
          ))}
        </Box>
      </Box>
    )
  })
}
