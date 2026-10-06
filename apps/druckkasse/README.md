# 🖨️ Druckkasse

Kosten, Preise und Verkäufe für 3D-Drucke. Offline, ohne Konto.

## Aufbau

| Ordner | Inhalt |
|---|---|
| `lib/logik/` | Reine Rechenlogik ohne Flutter (Kalkulation, Statistik, Sparziel, CSV). Voll getestet. |
| `lib/daten/` | Datenbank (Drift/SQLite): Tabellen, Abfragen, Sicherung, Beispieldaten, Vorlagen |
| `lib/screens/` | Bildschirme |
| `lib/widgets/` | Wiederverwendbare Teile (Formatierung, Sparziel-Karte, Diagramm) |
| `lib/l10n/` | Texte (`app_de.arb`). Englisch: `app_en.arb` anlegen. |

## Nach Änderungen an Tabellen

```
dart run build_runner build --delete-conflicting-outputs
```

Die erzeugte Datei `lib/daten/datenbank.g.dart` wird mit eingecheckt. Bei einer
neuen Spalte `schemaVersion` erhöhen und eine Migration in `datenbank.dart` ergänzen.

## Tests

```
flutter test
```

- `kalkulation_test`, `statistik_test`: Preise, Gewinn, Sparziel, CSV
- `datenbank_test`: Verkäufe, Aufträge, Snapshots von Preis und Kosten
- `sicherung_test`: Sicherung erstellen und zurückspielen
- `oberflaeche_test`: klickt sich auf großem und kleinem Handy durch alle Bildschirme

Play-Store-Unterlagen: [`docs/play-store.md`](docs/play-store.md)
