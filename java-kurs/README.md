# ☕ Java-Kurs – animierte Lektionen mit benoteten Aufgaben

Jede Lektion ist eine eigene Artefakt-Seite mit einem animierten „Video“ (ohne Stimme), Kurz-Checks
und Aufgaben. Erreicht das Video eine Aufgabe, wird es **für den Account gesperrt**, bis die Lösung
abgegeben ist (auch nach Neuladen und auf anderen Geräten). Danach gibt es eine **Note (1–5)** mit Feedback
von Claude; ohne Claude-Zugriff benotet die Seite automatisch über Tests.

| Lektion | Thema | Aufgaben | Link |
|---|---|---|---|
| 1 | Hallo Java! – erstes Programm, print/println, Fehler, Kommentare | Steckbrief · ASCII-Kunst | https://claude.ai/artifact/W2WCM2NQbB1BqAATpmkpW8 |
| 2 | Variablen & Datentypen – rechnen, Ganzzahl-Falle, Konstanten | Taschengeld-Rechner · Angel-Statistik | https://claude.ai/artifact/HNMkZnpAWhwydTEG6tX7Ew |
| 3 | Eingaben & Entscheidungen – Scanner, if/else, &&/‖, equals, printf | Ticket-Automat · Notenrechner | https://claude.ai/artifact/QT4NxYuTccwUZsURVGEa1n |
| 4 | Schleifen – while, for, do-while, Zufall | Einmaleins · Zahlenraten | https://claude.ai/artifact/WZbgDospMFYMGRxt4aqPuZ |

## Aufbau

| Datei | Inhalt |
|---|---|
| `src/minijava.js` | Mini-Java: ein Java-Interpreter im Browser (Klassen, Schleifen, Arrays, Scanner, printf …) mit deutschen Fehlermeldungen |
| `src/player.js`, `src/player.css`, `src/page.html` | Lektions-Player: Video, Quiz, Sperre, Code-Editor, Konsole, Benotung, Speicherung |
| `lessons/lNN.mjs` | Inhalt jeder Lektion (Schritte, Code, Quiz, Aufgaben mit Tests und Bewertungskriterien) |
| `build.mjs` | baut `dist/lektion-NN.html` und prüft alle Beispiele und Musterlösungen (`--java` zusätzlich mit echtem javac) |
| `test/differential.mjs` | vergleicht Mini-Java mit echtem Java 21 (50 Programme, alle identisch) |
| `test/ui.mjs` | Browser-Test: Quiz, Sperre, Neuladen, Ausführen, Abgabe, Handy-Ansicht |

```bash
node build.mjs --java          # Lektionen bauen und prüfen
node test/differential.mjs     # Interpreter gegen echtes Java testen
node test/ui.mjs dist/lektion-01.html
```
