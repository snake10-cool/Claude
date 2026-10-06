# ⛏️ Buddel Mo

Ein-Finger-Idle-Spiel mit dem Maulwurf Mo.

| Datei | Inhalt |
|---|---|
| `lib/logik/katalog.dart` | Helfer, Verbesserungen, Erdschichten – hier wird balanciert |
| `lib/logik/spiel.dart` | Regeln: Produktion, Kosten, Offline-Ertrag, Prestige, Tagesbonus, Erfolge |
| `lib/spiel_dienst.dart` | Spielschleife (10×/s), Speichern, Glücksklumpen |
| `lib/widgets/mo_maler.dart` | Mo, Hintergrund und Goldklumpen (selbst gezeichnet) |
| `lib/screens/wurmregen_screen.dart` | Minispiel |
| `tools/icon_rendern_test.dart.txt` | Rendert das App-Icon aus dem Mo-Painter (nach `test/` kopieren und ausführen) |

Tests: `flutter test` (Spielregeln + Durchklicken inkl. Wurmregen-Runde).
