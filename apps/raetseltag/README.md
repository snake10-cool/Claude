# 🧩 Rätseltag

Jeden Tag ein Worträtsel, ein Sudoku (3 Stufen) und ein Schiebepuzzle, mit gemeinsamer Serie.

| Datei | Inhalt |
|---|---|
| `lib/logik/wortraetsel.dart` | Bewertung wie Wordle (korrekt bei doppelten Buchstaben), Emoji-Raster |
| `lib/logik/sudoku.dart` | Generator mit Eindeutigkeitsprüfung, Löser, Konflikte |
| `lib/logik/schiebe.dart` | 4×4-Schiebepuzzle, immer lösbar gemischt |
| `lib/logik/tag.dart`, `serie.dart` | Rätselnummer pro Tag, Serie |
| `assets/woerter/` | Lösungswörter (eigene Auswahl) und erlaubte Wörter (wordfreq, CC BY-SA 4.0) |
| `tools/woerter_bauen.py` | Erzeugt die Wortlisten; Lösungen hier pflegen |

Alle Rätsel werden aus der Rätselnummer erzeugt – jeder Spieler hat am selben Tag dieselben Rätsel.
