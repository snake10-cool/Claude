# ☕ Code-Kurs – vom ersten Befehl zum Multiplayer-Jump'n'Run

**Kurs:** https://claude.ai/artifact/53GsWKWmffRpVzvoNmqmwo

Eine einzige Seite mit zwei Reitern: **Classics** (Grundlagen) und **Unser Game** (alles speziell fürs
Endprojekt, ein Multiplayer-Jump'n'Run im Browser). Fortschritt und Noten liegen in **einem** Speicher
(im Account, sonst im Browser). Ist irgendwo eine Aufgabe offen, sind **alle** Videos gesperrt.

| Teil | Inhalt | Aufgaben mit Note |
|---|---|---|
| Lektion 1 | Hallo Java! | Steckbrief · ASCII-Kunst |
| Lektion 2 | Variablen & Datentypen | Taschengeld-Rechner · Angel-Statistik |
| Lektion 3 | Eingaben & Entscheidungen | Ticket-Automat · Notenrechner |
| Lektion 4 | Schleifen | Einmaleins · Zahlenraten |
| ★ nach 4 | Zwischen-Challenges | FizzBuzz · Primzahl · Quersumme |
| Lektion 5 | Arrays | Fang-Auswertung · Highscore-Liste |
| ★ nach 5 | Zwischen-Challenges | Würfel-Statistik · Schere-Stein-Papier · Pyramide |
| Lektion 6 | Methoden | Mini-Rechner · Noten-Werkzeuge |
| Lektion 7 | Strings im Detail | Passwort-Checker · Caesar-Geheimschrift |
| ★ nach 7 | Zwischen-Challenges | Palindrom · Wort-Statistik |
| Lektion 8 | Klassen & Objekte | Held · Würfel |
| Lektion 9 | ArrayList & Kapselung | Inventar · Bestenliste |
| ★ nach 9 | Zwischen-Challenge | Einkaufszettel |
| Lektion 10 | Vererbung | Gegner-Welle · Power-ups |
| ★ nach 10 | Zwischen-Challenge | Rennstrecke |
| Lektion 11 | Spielfelder & Fehlerbehandlung | Labyrinth · Robuster Rundenzähler |
| ★ nach 11 | Zwischen-Challenges | Minesweeper · Lücken-Detektor |
| Lektion 12 | Abschlussprojekt: Pixel-Lauf | Physik · Das ganze Spiel |
| Finale | 20 Challenges, nur nacheinander (öffnet nach L12) | Temperatur-Tabelle … Endgegner: Rennen-Auswertung |

Geplant (im Kurs als Lernpfad sichtbar): JavaScript, HTML & CSS, Node.js (Classics) und 12 Game-Lektionen
(Canvas, Game-Loop, Physik, Kollision, Level & Kamera, Multiplayer …).

## Aufbau

| Datei | Inhalt |
|---|---|
| `src/minijava.js` | Mini-Java: Java-Interpreter im Browser mit deutschen Fehlermeldungen |
| `src/common.js` | Hervorhebung, Zeitplan, Ton, Editor, Konsole, Tests, Benotung, Aufgaben-Bereich |
| `src/player.js` | Lektions-Player (Video, Quiz, Sperre) als Baustein |
| `src/course.js` | Kursseite: Reiter Classics/Game, Speicher, Notenbuch, Challenges, Finale, Spielplatz |
| `src/player.css`, `src/course.css`, `src/course.html` | Aussehen und Seitenvorlage |
| `lessons/lNN.mjs`, `lessons/kurs.mjs`, `lessons/checkpoints.mjs`, `lessons/finale.mjs` | Lektionen; Ziel, Reiter-Plan und Challenges 1–6; Zwischen-Challenges 7–12; Finale f01–f20 |
| `build.mjs` | baut `dist/kurs.html` und prüft alle Beispiele und Musterlösungen (`--java`: zusätzlich mit echtem javac) |
| `test/differential.mjs` | vergleicht Mini-Java mit echtem Java 21 |
| `test/course-ui.mjs` | Browser-Test: Sperre kursweit, Neuladen, Abgabe, Challenge, Notenbuch, Handy |

`dist/lektion-0N.html` sind nur noch Hinweisseiten auf den neuen Kurs (die alten Links führen dorthin).
