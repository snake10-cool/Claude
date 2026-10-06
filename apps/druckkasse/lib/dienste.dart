import 'package:app_basis/app_basis.dart';
import 'package:app_kauf/app_kauf.dart';
import 'package:flutter/material.dart';

/// Hauptfarbe der App: Filament-Orange.
const appFarbe = Color(0xFFE8622A);

const appInfo = AppInfo(
  name: 'Druckkasse',
  paketId: 'com.snake10.druckkasse',
  farbe: appFarbe,
  kontaktEmail: 'snakejoni10@yahoo.com',
  datenschutzText: datenschutzText,
);

/// Pro-Abo (2,99 €/Monat) und Jahres-Abo, wie in der Play Console angelegt.
/// Bis zum Play-Store-Start ist [kaufPflicht] aus → alles frei.
final kauf = KaufDienst(
  proIds: const {'pro_monat', 'pro_jahr'},
  kaufPflicht: false,
);

final designModus = DesignModus();

const datenschutzText = '''
Datenschutzerklärung für Druckkasse

Kurz gesagt: Deine Daten bleiben auf deinem Gerät.

1. Welche Daten?
Drucker, Filamente, Produkte, Verkäufe, Aufträge (inkl. Kundennamen und Kontakt, die du selbst einträgst) und Sparziele werden ausschließlich lokal auf deinem Gerät gespeichert. Es gibt kein Konto und keinen Server.

2. Weitergabe
Die App sendet keine dieser Daten an mich oder Dritte. Es gibt keine Werbung und kein Tracking.

3. Käufe
Käufe und Abos laufen über Google Play. Dabei gelten die Datenschutzbestimmungen von Google. Ich erhalte keine Zahlungsdaten.

4. Sicherung und Export
Wenn du eine Sicherung oder einen CSV-Export erstellst, entscheidest du selbst, wo die Datei gespeichert oder mit wem sie geteilt wird.

5. Löschen
Du kannst alle Daten in den Einstellungen löschen. Beim Deinstallieren der App werden alle Daten entfernt.

6. Kontakt
Fragen zum Datenschutz: snakejoni10@yahoo.com
''';
