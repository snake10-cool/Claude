import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register, ThemeSetArgs } from 'claude-code'

import type { Fortschritt, HubSettings } from '../types'
import { makeColors } from './make-colors.js'
import { THEME_SEEDS } from './themes'

// ---------- Kataloge: was es alles zum An- und Ausschalten gibt ----------

const MODS: { id: string; name: string; info: string }[] = [
  { id: 'fortschritt', name: '📊 Fortschrittsbalken', info: 'Ladebalken für laufende Projekte, Meldung bei 100 %' },
  { id: 'knoepfe', name: '🎛️ Schnellknöpfe', info: 'Mehr Details, Neues Level, Bugs suchen, Ideen' },
  { id: 'uhr', name: '🕒 Sitzungs-Uhr', info: 'Uhrzeit und Sitzungsdauer in der Statuszeile' },
  { id: 'pause', name: '☕ Pausen-Erinnerung', info: 'Alle 45 Minuten eine Erinnerung' },
  { id: 'schutz', name: '🛡️ Datei-Schutz', info: 'Schützt .env, Schlüssel und Signatur-Dateien vor Änderungen' },
  { id: 'fertig', name: '✅ Fertig-Meldung', info: 'Kurze Meldung, wenn Claude mit einer Antwort fertig ist' },
]

const SKILLS: { id: string; name: string; info: string; context: string }[] = [
  { id: 'spiel-bauen', name: '🎮 Spiel bauen', info: 'Browser-Spiele Schritt für Schritt bauen',
    context: 'Skill „snake-skills:spiel-bauen“ ist AN: Wenn der Nutzer ein Spiel bauen will, lade diesen Skill und folge ihm.' },
  { id: 'bug-jagd', name: '🐞 Bug-Jagd', info: 'Fehler systematisch finden und beheben',
    context: 'Skill „snake-skills:bug-jagd“ ist AN: Bei Fehlern, Abstürzen oder „geht nicht“ lade diesen Skill und folge ihm.' },
  { id: 'flutter-release', name: '📱 Flutter-Release', info: 'Android-App für Google Play fertig machen',
    context: 'Skill „snake-skills:flutter-release“ ist AN: Wenn es um eine Veröffentlichung im Play Store oder eine Release-Version geht, lade diesen Skill und folge ihm.' },
  { id: 'einfach-erklaert', name: '🧠 Einfach erklärt', info: 'Erklärungen ohne Fachchinesisch',
    context: 'Skill „snake-skills:einfach-erklaert“ ist AN: Wenn der Nutzer etwas verstehen will, lade diesen Skill und folge ihm.' },
  { id: 'game-guide', name: '🕹️ Game-Guide', info: 'Tipps und Achievements für Videospiele',
    context: 'Skill „snake-skills:game-guide“ ist AN: Bei Fragen zu Videospielen, Achievements oder Spieltipps lade diesen Skill und folge ihm.' },
  { id: 'kurz-knapp', name: '✂️ Kurz & knapp', info: 'Antworten so kurz wie möglich',
    context: 'Modus „Kurz & knapp“ ist AN: Antworte so kurz wie möglich, ohne Einleitung und Wiederholungen.' },
  { id: 'deutsch-immer', name: '🇩🇪 Immer Deutsch', info: 'Antworten und Code-Kommentare auf Deutsch',
    context: 'Modus „Immer Deutsch“ ist AN: Antworte immer auf Deutsch und schreibe Code-Kommentare auf Deutsch.' },
]

const KNOEPFE: { label: string; prompt: string }[] = [
  { label: '✨ Mehr Details', prompt: 'Füge dem aktuellen Projekt mehr Details hinzu, die gut dazu passen (Grafik, Effekte, Inhalte).' },
  { label: '🎮 Neues Level', prompt: 'Füge dem aktuellen Spiel ein neues, passendes Level oder einen neuen Abschnitt hinzu.' },
  { label: '🐞 Bugs suchen', prompt: 'Suche im aktuellen Projekt nach Fehlern und behebe sie.' },
  { label: '💡 Ideen', prompt: 'Schlage mir 5 kurze Ideen vor, was ich am aktuellen Projekt als Nächstes verbessern könnte.' },
]

const DEFAULTS: HubSettings = {
  theme: 'herbst',
  mods: { fortschritt: true, knoepfe: true, uhr: false, pause: false, schutz: true, fertig: false },
  skills: { 'spiel-bauen': true, 'bug-jagd': true, 'flutter-release': true, 'einfach-erklaert': true, 'game-guide': true, 'kurz-knapp': false, 'deutsch-immer': true },
}

// ---------- Themes ----------

const LOOKS: Record<string, ThemeSetArgs> = {}
for (const [id, s] of Object.entries(THEME_SEEDS)) {
  const { theme } = makeColors({ label: s.name, roles: s.roles, light: { gray: { anchors: s.light } }, dark: { gray: { anchors: s.dark } } })
  LOOKS[id] = { colors: theme }
}

// ---------- Zustand ----------

const PANE = 'snake-hub'
const TITEL = '🐍 Snake-Hub'
const TOOL = 'fortschritt'
const PAUSE_MS = 45 * 60 * 1000
const SCHUTZ = /(^|[\\/])(\.env(\..*)?|key\.properties|.*\.jks|.*\.keystore|.*\.pem|id_rsa.*)$/i

const fortschritt = atom({ plugin: 'snake-hub', key: 'fortschritt' } as const, { prozent: 0, aufgabe: '', schritt: '' } as Fortschritt, { shape: 'fortschritt-1' })
const settings = atom({ plugin: 'snake-hub', key: 'settings' } as const, DEFAULTS, { shape: 'settings-1' })

let startedAt = 0
let uhrTimer: { cancel: () => void } | undefined
let pauseTimer: { cancel: () => void } | undefined

function balken(prozent: number, breite = 20): string {
  const voll = Math.round((prozent / 100) * breite)
  return '█'.repeat(voll) + '░'.repeat(breite - voll)
}

function merge(saved: unknown): HubSettings {
  const s = (saved ?? {}) as Partial<HubSettings>
  return {
    theme: typeof s.theme === 'string' ? s.theme : DEFAULTS.theme,
    mods: { ...DEFAULTS.mods, ...(s.mods ?? {}) },
    skills: { ...DEFAULTS.skills, ...(s.skills ?? {}) },
  }
}

async function applyTheme($: EngineInterface, id: string): Promise<string> {
  const look = LOOKS[id]
  if (look === undefined) {
    await $.theme.clear()
    return 'Theme aus (Standard-Aussehen der App)'
  }
  const set = await $.theme.set(look)
  const name = `${THEME_SEEDS[id]?.emoji ?? ''} ${THEME_SEEDS[id]?.name ?? id}`
  return set.isDrawn ? `Theme: ${name}` : `Theme: ${name} (wird gezeichnet, sobald die Desktop- oder Handy-App angeschlossen ist)`
}

function applyTimers($: EngineInterface, s: HubSettings): void {
  uhrTimer?.cancel()
  pauseTimer?.cancel()
  uhrTimer = undefined
  pauseTimer = undefined
  if (s.mods.uhr) {
    const tick = async () => {
      const now = await $.clock.now()
      const min = Math.floor((now - startedAt) / 60000)
      const zeit = new Date(now).toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' })
      $.ui.status(`🕒 ${zeit} · Sitzung ${min} min`)
    }
    void tick()
    uhrTimer = $.clock.every(30000, tick)
  } else {
    $.ui.status(undefined)
  }
  if (s.mods.pause) {
    pauseTimer = $.clock.every(PAUSE_MS, () => $.ui.toast('☕ Du bist seit 45 Minuten dran. Zeit für eine kurze Pause!'))
  }
}

async function save($: EngineInterface, fn: (s: HubSettings) => HubSettings): Promise<HubSettings> {
  let next = DEFAULTS
  await update($, settings, s => (next = fn(s)))
  await $.store.set('settings', next)
  return next
}


export const register: Register = on => {
  // ---------- Start ----------

  on('session.start', async ($, e, next) => {
    startedAt = await $.clock.now()
    const s = merge(await $.store.get('settings'))
    await update($, settings, () => s)
    await applyTheme($, s.theme)
    applyTimers($, s)

    await $.command.register({ name: 'hub', description: 'Öffnet den Snake-Hub und zeigt, was an und aus ist' })
    await $.command.register({ name: 'look', description: 'Theme wechseln: herbst, sakura, mitternacht, ozean, wald oder aus' })
    await $.command.register({ name: 'mod', description: 'Mod an/aus: fortschritt, knoepfe, uhr, pause, schutz, fertig' })
    await $.command.register({ name: 'skill', description: 'Skill an/aus: spiel-bauen, bug-jagd, flutter-release, einfach-erklaert, game-guide, kurz-knapp, deutsch-immer' })
    await $.command.register({ name: 'mehr-details', description: 'Claude fügt dem Projekt mehr passende Details hinzu' })
    await $.tool.register({
      name: TOOL,
      description:
        'Zeigt dem Nutzer den Fortschritt einer mehrstufigen Aufgabe als Ladebalken im Snake-Hub. ' +
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

  // ---------- Slash-Befehle ----------

  on('command.run', { command: 'hub' }, async $ => {
    const pane = await $.ui.open({ id: PANE, title: TITEL })
    const s = await read($, settings)
    const an = (b: boolean | undefined) => (b ? '●' : '○')
    const lines = [
      '🐍 Snake-Hub',
      `Theme: ${THEME_SEEDS[s.theme]?.name ?? 'aus'}`,
      'Mods: ' + MODS.map(m => `${an(s.mods[m.id])} ${m.id}`).join('  '),
      'Skills: ' + SKILLS.map(k => `${an(s.skills[k.id])} ${k.id}`).join('  '),
      pane.isPlaced ? '' : 'Panel wird hier nicht angezeigt. Nutze /look, /mod und /skill.',
    ]
    return { text: lines.filter(Boolean).join('\n') }
  })

  on('command.run', { command: 'look' }, async ($, e) => {
    const wahl = (e.args ?? '').trim().toLowerCase()
    if (wahl !== 'aus' && LOOKS[wahl] === undefined) {
      return { text: `Unbekanntes Theme „${wahl}“. Möglich: ${Object.keys(LOOKS).join(', ')}, aus` }
    }
    await save($, s => ({ ...s, theme: wahl }))
    return { text: await applyTheme($, wahl) }
  })

  on('command.run', { command: 'mod' }, async ($, e) => {
    const id = (e.args ?? '').trim().toLowerCase()
    const mod = MODS.find(m => m.id === id)
    if (mod === undefined) {
      return { text: `Unbekannte Mod „${id}“. Möglich: ${MODS.map(m => m.id).join(', ')}` }
    }
    const s = await save($, s => ({ ...s, mods: { ...s.mods, [id]: !s.mods[id] } }))
    applyTimers($, s)
    return { text: `${mod.name}: ${s.mods[id] ? 'AN' : 'AUS'}` }
  })

  on('command.run', { command: 'skill' }, async ($, e) => {
    const id = (e.args ?? '').trim().toLowerCase()
    const skill = SKILLS.find(k => k.id === id)
    if (skill === undefined) {
      return { text: `Unbekannter Skill „${id}“. Möglich: ${SKILLS.map(k => k.id).join(', ')}` }
    }
    const s = await save($, s => ({ ...s, skills: { ...s.skills, [id]: !s.skills[id] } }))
    return { text: `${skill.name}: ${s.skills[id] ? 'AN' : 'AUS'} (gilt ab deiner nächsten Nachricht)` }
  })

  on('command.run', { command: 'mehr-details' }, async $ => {
    void $.prompt.submit({ text: KNOEPFE[0]?.prompt ?? 'Füge dem aktuellen Projekt mehr passende Details hinzu.' })
    return { text: 'Okay, ich füge mehr Details hinzu ✨' }
  })

  // ---------- Skills: pro Nachricht sagen, was an und aus ist ----------

  on('prompt.submit', async ($, e, next) => {
    if (e.command !== undefined) {
      return next(e)
    }
    const s = await read($, settings)
    const an = SKILLS.filter(k => s.skills[k.id]).map(k => k.context)
    const aus = SKILLS.filter(k => !s.skills[k.id]).map(k => k.id)
    const hinweis = [
      'Snake-Hub (vom Nutzer gewählte Einstellungen):',
      ...an,
      aus.length > 0 ? `Ausgeschaltet, also nicht verwenden: ${aus.join(', ')}.` : '',
      s.mods.fortschritt ? 'Bei mehrstufigen Aufgaben den Fortschritt mit dem fortschritt-Werkzeug melden.' : 'Das fortschritt-Werkzeug nicht verwenden.',
    ].filter(Boolean).join('\n')
    return next({ ...e, context: [...(e.context ?? []), hinweis] })
  }).catch(($, e, next) => next(e))

  // ---------- Mods ----------

  on('tool.call', { tool: 'mcp__snake-hub__fortschritt' }, async ($, e) => {
    const s = await read($, settings)
    if (!s.mods.fortschritt) {
      return { result: 'Der Fortschrittsbalken ist ausgeschaltet.' }
    }
    const input = (e as unknown as { input?: Record<string, unknown> }).input ?? (e as unknown as Record<string, unknown>)
    const prozent = Math.max(0, Math.min(100, Number(input.prozent) || 0))
    const aufgabe = String(input.aufgabe ?? '')
    const schritt = String(input.schritt ?? '')
    await update($, fortschritt, () => ({ prozent, aufgabe, schritt }))
    if (!s.mods.uhr) {
      $.ui.status(`📊 ${aufgabe}: ${Math.round(prozent)} %`)
    }
    if (prozent >= 100) {
      $.ui.toast(`🎉 ${aufgabe} ist fertig – du kannst es abholen!`)
    }
    return { result: `Fortschritt angezeigt: ${Math.round(prozent)} %` }
  })

  on('tool.call', { tool: 'Edit' }, async ($, e, next) => {
    const s = await read($, settings)
    return s.mods.schutz && SCHUTZ.test(e.file_path) ? { deny: `🛡️ Datei-Schutz: ${e.file_path} ist geschützt. Schalte die Mod „schutz“ aus, wenn du sie wirklich ändern willst.` } : next(e)
  }).catch(($, e, next) => (next.called ? next(e) : { deny: 'Datei-Schutz konnte nicht prüfen.' }))

  on('tool.call', { tool: 'Write' }, async ($, e, next) => {
    const s = await read($, settings)
    return s.mods.schutz && SCHUTZ.test(e.file_path) ? { deny: `🛡️ Datei-Schutz: ${e.file_path} ist geschützt. Schalte die Mod „schutz“ aus, wenn du sie wirklich ändern willst.` } : next(e)
  }).catch(($, e, next) => (next.called ? next(e) : { deny: 'Datei-Schutz konnte nicht prüfen.' }))

  on('turn.complete', async ($, e, next) => {
    const result = await next(e)
    const s = await read($, settings)
    if (s.mods.fertig) {
      $.ui.toast('✅ Claude ist fertig')
    }
    return result
  })

  // ---------- Panel ----------

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Text, Button } = $.ui.resolve(e)
    const s = await read($, settings)
    const f = await read($, fortschritt)

    const setTheme = (id: string) => async () => {
      await save($, x => ({ ...x, theme: id }))
      await applyTheme($, id)
    }
    const toggleMod = (id: string) => async () => {
      const x = await save($, y => ({ ...y, mods: { ...y.mods, [id]: !y.mods[id] } }))
      applyTimers($, x)
    }
    const toggleSkill = (id: string) => async () => {
      await save($, y => ({ ...y, skills: { ...y.skills, [id]: !y.skills[id] } }))
    }

    return (
      <Box flexDirection="column" gap={1}>
        {s.mods.fortschritt && (
          <Box flexDirection="column">
            <Text bold>Fortschritt</Text>
            {f.aufgabe === '' ? (
              <Text dimColor>Noch kein Projekt läuft.</Text>
            ) : (
              <Box flexDirection="column">
                <Text>{f.aufgabe}</Text>
                <Text>{balken(f.prozent)} {Math.round(f.prozent)} %</Text>
                {f.schritt !== '' && <Text dimColor>{f.schritt}</Text>}
                {f.prozent >= 100 && <Text bold>🎉 Fertig – kann abgeholt werden!</Text>}
              </Box>
            )}
          </Box>
        )}

        {s.mods.knoepfe && (
          <Box flexDirection="column">
            <Text bold>Schnellknöpfe</Text>
            {KNOEPFE.map(k => (
              <Button key={`k-${k.label}`} label={k.label} onPress={() => void $.prompt.submit({ text: k.prompt })} />
            ))}
          </Box>
        )}

        <Box flexDirection="column">
          <Text bold>Theme</Text>
          {Object.entries(THEME_SEEDS).map(([id, t]) => (
            <Button key={`t-${id}`} label={`${s.theme === id ? '●' : '○'} ${t.emoji} ${t.name}`} onPress={() => void setTheme(id)()} />
          ))}
          <Button key="t-aus" label={`${s.theme === 'aus' ? '●' : '○'} Aus`} onPress={() => void setTheme('aus')()} />
        </Box>

        <Box flexDirection="column">
          <Text bold>Mods</Text>
          {MODS.map(m => (
            <Button key={`m-${m.id}`} label={`${s.mods[m.id] ? '● AN ' : '○ AUS'}  ${m.name}`} onPress={() => void toggleMod(m.id)()} />
          ))}
        </Box>

        <Box flexDirection="column">
          <Text bold>Skills</Text>
          {SKILLS.map(k => (
            <Button key={`s-${k.id}`} label={`${s.skills[k.id] ? '● AN ' : '○ AUS'}  ${k.name}`} onPress={() => void toggleSkill(k.id)()} />
          ))}
          <Text dimColor>Skill-Änderungen gelten ab deiner nächsten Nachricht.</Text>
        </Box>
      </Box>
    )
  })
}
