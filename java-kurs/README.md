# ☕ Java-Kurs – ein Kurs, ein Notenbuch

**Kurs:** https://claude.ai/artifact/53GsWKWmffRpVzvoNmqmwo

Eine einzige Seite mit Startseite, 5 Lektionen (animierte Videos ohne Stimme), 6 Transfer-Challenges,
gemeinsamem Notenbuch und Spielplatz. Fortschritt und Noten liegen in **einem** Speicher (im Account,
sonst im Browser). Ist irgendwo eine Aufgabe offen, sind **alle** Videos gesperrt, bis sie abgegeben ist.

| Teil | Inhalt | Aufgaben mit Note |
|---|---|---|
| Lektion 1 | Hallo Java! | Steckbrief · ASCII-Kunst |
| Lektion 2 | Variablen & Datentypen | Taschengeld-Rechner · Angel-Statistik |
| Lektion 3 | Eingaben & Entscheidungen | Ticket-Automat · Notenrechner |
| Lektion 4 | Schleifen | Einmaleins · Zahlenraten |
| Lektion 5 | Arrays | Fang-Auswertung · Highscore-Liste |
| Challenges | Transfer-Aufgaben, so nie gezeigt | FizzBuzz · Primzahl · Quersumme · Würfel-Statistik · Schere-Stein-Papier · Pyramide |

Geplant sind 12 Lektionen (6 Methoden, 7 Strings, 8 Klassen & Objekte, 9 ArrayList & Kapselung,
10 Vererbung, 11 Spielfelder & Fehlerbehandlung, 12 Abschlussprojekt).

## Aufbau

| Datei | Inhalt |
|---|---|
| `src/minijava.js` | Mini-Java: Java-Interpreter im Browser mit deutschen Fehlermeldungen |
| `src/common.js` | Hervorhebung, Zeitplan, Ton, Editor, Konsole, Tests, Benotung, Aufgaben-Bereich |
| `src/player.js` | Lektions-Player (Video, Quiz, Sperre) als Baustein |
| `src/course.js` | Kursseite: Navigation, Speicher, Start, Notenbuch, Challenges, Spielplatz |
| `src/player.css`, `src/course.css`, `src/course.html` | Aussehen und Seitenvorlage |
| `lessons/lNN.mjs`, `lessons/kurs.mjs` | Inhalte der Lektionen; Kursplan, Ziel und Challenges |
| `build.mjs` | baut `dist/kurs.html` und prüft alle Beispiele und Musterlösungen (`--java`: zusätzlich mit echtem javac) |
| `test/differential.mjs` | vergleicht Mini-Java mit echtem Java 21 |
| `test/course-ui.mjs` | Browser-Test: Sperre kursweit, Neuladen, Abgabe, Challenge, Notenbuch, Handy |

`dist/lektion-0N.html` sind nur noch Hinweisseiten auf den neuen Kurs (die alten Links führen dorthin).
