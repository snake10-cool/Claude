# 🎬 Claude Pro – lange Version (≈ 6 Minuten)

**Video:** [`claude-pro-lang.mp4`](claude-pro-lang.mp4) (1920×1080, 30 fps, mit Musik, Soundeffekten und Untertiteln)

Wie die kurze Version komplett aus Code, aber mit 7 Kapiteln und Live-Demos:

| Kapitel | Inhalt |
|---|---|
| Intro + Überblick | Logo, „Hallo, ich bin Claude.“, Inhaltsverzeichnis |
| 1 Wer bin ich? | Texte/Code/Bilder/Dokumente, Sprachen-Laufband, Hinweis „Ich kann mich irren“ |
| 2 Schreiben | E-Mail an den Chef wird geschrieben, dann auf „Bitte kürzer!“ umgeschrieben |
| 3 Programmieren | Fisch-Spiel wird programmiert und gespielt, danach ein Bug gefunden und repariert |
| 4 Dateien & Recherche | PDF wird gescannt und zusammengefasst, Websuche mit Quellen |
| 5 Lernen | Photosynthese als animiertes Schaubild, Quiz mit Konfetti |
| 6 Daten | Tabelle → Balkendiagramm, Erkenntnisse werden markiert |
| 7 Warum Claude Pro? | Nutzung, Claude Code (Terminal-Demo), weitere Vorteile, Free vs. Pro, Preis |

## Dateien

| Datei | Was sie macht |
|---|---|
| `index.html` | Alle Szenen. Die Länge jeder Szene richtet sich nach ihrem Sprechertext |
| `synth.py` | Musik (je Kapitel ein Stil: chill, groove, big …), Soundeffekte, Stimme einmischen und Musik darunter leiser machen |
| `render.mjs` | Baut Zeitplan + Ton und rendert die Bilder parallel auf allen CPU-Kernen |
| `sprechertext.md` | Alle Sprechersätze, nummeriert, zum Vertonen mit einer Stimm-KI |
| `tts.py` | Optional: offline-Stimme „Thorsten“ (Piper). Klingt ziemlich nach Roboter, daher nicht im Video |

## Stimme nachträglich einbauen

1. Jeden Satz aus `sprechertext.md` mit einer Stimm-KI vertonen (z. B. ElevenLabs).
2. Die Dateien als `sprecher/01.mp3`, `sprecher/02.mp3` … speichern.
3. `node render.mjs` ausführen. Das Timing passt sich automatisch an, die Musik wird unter der Stimme leiser.

## Neu rendern

```bash
cd video/claude-pro-lang
node render.mjs                          # komplettes Video
node render.mjs --stills 10,60,120       # nur Standbilder (stills/)
```

Braucht Node mit Playwright, Python 3 mit numpy und ffmpeg.
