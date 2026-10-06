# app_basis

Gemeinsame Bausteine für alle Apps im Repo:

- `AppDesign.hell(farbe)` / `AppDesign.dunkel(farbe)`: einheitlicher Stil, jede App mit eigener Farbe.
- `DesignModus`: Hell / Dunkel / System, wird gespeichert.
- `MehrAppsScreen`: verlinkt auf die anderen Apps (Liste in `lib/src/meine_apps.dart`).
- `BewertungsBitte`: fragt dezent nach einer Bewertung, wenn jemand die App ein paar Tage benutzt.
- `AppInfoKacheln`: Design, Bewerten, Kontakt, Datenschutz, Mehr Apps, Version für den Einstellungs-Bildschirm.

Texte liegen in `lib/src/l10n/basis_*.arb`. Nach Änderungen: `flutter gen-l10n` in diesem Ordner.
