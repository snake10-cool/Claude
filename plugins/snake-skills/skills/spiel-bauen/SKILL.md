---
name: spiel-bauen
description: Baut ein eigenes Browser-Spiel Schritt für Schritt als HTML-Datei mit Fortschrittsanzeige. Verwenden, wenn der Nutzer ein Spiel bauen, erweitern oder verbessern will.
---

# Spiel bauen

1. **Idee klären, aber kurz.** Frage höchstens eine Sache nach (Genre oder Steuerung), sonst triff sinnvolle Annahmen und nenne sie.
2. **Eigenes Spiel.** Baue eigene Ideen, Figuren und Grafiken, keine Kopie eines bestehenden Spiels.
3. **Fortschritt melden.** Wenn das Werkzeug `fortschritt` (Snake-Hub) da ist: 0 % am Anfang, dann nach jedem Schritt aktualisieren, 100 % am Ende.
4. **Reihenfolge:**
   - Spielfeld und Steuerung (Tastatur und Touch)
   - Spielregeln, Punkte, Gewinnen und Verlieren
   - Grafik, Animationen, Sound (erst nach Klick starten)
   - Startbildschirm, Pause, Neustart, Highscore (`localStorage` mit try/catch)
5. **Eine Datei.** Alles in einer HTML-Datei, ohne externe Bilder. Grafiken mit Canvas oder CSS zeichnen.
6. **Testen.** Mit Playwright einmal laden und auf Konsolenfehler prüfen, wenn möglich.
7. **Abschluss.** Kurz sagen, wie man spielt, und drei Ideen für die nächste Version nennen.
