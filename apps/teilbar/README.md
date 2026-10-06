# 🧺 Teilbar

Einkaufslisten für WG & Familie, Ausgaben teilen, Rechnungsrechner, Packlisten, Resteküche.

| Ordner | Inhalt |
|---|---|
| `lib/logik/` | Geld (Aufteilen, Salden, Ausgleich, Rechner), Artikel-Erkennung, Resteküche, Packvorlagen |
| `lib/daten/` | Datenbank (Drift). Jede Zeile hat UUID, Zeitstempel und Lösch-Markierung für den Sync |
| `lib/sync/` | Sync-Motor (offline zuerst, „neueste Änderung gewinnt“) und Firestore-Anbindung |
| `assets/rezepte/` | Eigene Rezepte. Ändern in `tools/rezepte_bauen.py`, dann ausführen |
| `firestore.rules` | Sicherheitsregeln für Firestore |

- Online-Gruppen einrichten: [`docs/firebase.md`](docs/firebase.md)
- Play Store: [`docs/play-store.md`](docs/play-store.md)
- Tests: `flutter test` (inkl. Sync-Test mit zwei simulierten Handys)
