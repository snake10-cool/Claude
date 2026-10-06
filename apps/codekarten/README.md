# 🃏 Codekarten

Programmieren lernen mit Karteikarten (Spaced Repetition) und eigener Snippet-Sammlung.

## Aufbau

| Ordner | Inhalt |
|---|---|
| `assets/stapel/` | Die fertigen Stapel als JSON (werden beim Start eingespielt, Lernstand bleibt bei Updates erhalten) |
| `tools/stapel_quellen/` | Quellen der Stapel (Python). Hier Karten ändern, dann `python3 <datei>.py` |
| `tools/stapel_pruefen.py` | Führt jede Code-Karte mit echtem Java/Python/Dart/Node aus und prüft die Antworten |
| `lib/logik/` | SM-2 (`srs.dart`), Streak, Lernrunde, Syntax-Hervorhebung, Suche, Freischaltung |
| `lib/daten/` | Datenbank (Drift) |
| `lib/screens/` | Bildschirme |

## Neue Karten

1. In `tools/stapel_quellen/<sprache>.py` eine Zeile ergänzen:
   - `b(key, frage, antwort)` – Begriff
   - `a(key, code, antwort, optionen, erklärung)` – „Was gibt das aus?“
   - `l(key, frage, code_mit___, antwort, optionen, erwartete_ausgabe, erklärung)` – Lücke
2. `python3 tools/stapel_quellen/<sprache>.py`
3. `python3 tools/stapel_pruefen.py` – muss überall ✓ zeigen
4. Keys nie ändern (daran hängt der Lernstand)

Neuer Stapel: JSON erzeugen und die ID in `lib/main.dart` → `eingebauteStapel` eintragen.

Play-Store-Unterlagen: [`docs/play-store.md`](docs/play-store.md)
