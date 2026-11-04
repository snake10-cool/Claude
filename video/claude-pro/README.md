# 🎬 Claude Pro – Video aus reinem Code

**Video:** [`claude-pro.mp4`](claude-pro.mp4) (1920×1080, 30 fps, 51 s, mit Ton)

Alles ist Code: kein Videoschnittprogramm, keine fertigen Bilder, keine Sound-Dateien.

| Datei | Was sie macht |
|---|---|
| `index.html` | Die komplette Animation im Canvas. `draw(t)` zeichnet das Bild zu jeder Sekunde `t`; hier steht auch der Zeitplan aller Soundeffekte |
| `synth.py` | Baut den Ton mit numpy: Beat (Kick, Clap, Hi-Hats), Bass, Pad, Arpeggio, Tipp-Geräusche, Pops, Whooshes, Riser, Impacts, Glocken, Hall |
| `render.mjs` | Öffnet die Seite in Chromium, macht 1530 Einzelbilder und fügt sie mit ffmpeg und dem Ton zu einer MP4 zusammen |

## Ablauf (51 s)

1. **Intro**: Strahlen-Logo baut sich auf, Impact, „Hallo, ich bin Claude.“ wird getippt
2. **Was ich kann**: 6 Karten (Schreiben, Programmieren, Recherche, Dateien, Erklären, Analysieren)
3. **Live-Demo**: Chat-Fenster, „Bau mir eine Angel-App für ganz Österreich!“ → Claude schreibt Flutter-Code
4. **Warum Claude Pro?**: Riser + großer Impact, Nutzungs-Balken Free vs. Pro, 5 Vorteile
5. **Preis**: zählt auf 20 $ / Monat hoch (17 $ im Jahresabo, ≈ 67 Cent pro Tag)
6. **Outro**: „Claude Pro. Mehr Claude. Mehr Möglichkeiten.“, claude.ai

## Selbst neu rendern

```bash
cd video/claude-pro
node render.mjs                     # erzeugt audio.wav + claude-pro.mp4
node render.mjs --stills 4,11,26    # nur Standbilder zum Prüfen (Ordner stills/)
```

Braucht Node mit Playwright, Python 3 mit numpy und ffmpeg.
Vorschau im Browser: `index.html` öffnen (nach einem Render liegt `audio.wav` daneben, dann läuft der Ton mit).

> Preise und Funktionen: Stand November 2026, laut öffentlichen Angaben. Sie können je nach Land abweichen.
> Aktuelle Infos unter claude.com/pricing.
