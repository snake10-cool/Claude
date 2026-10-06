import 'package:app_basis/app_basis.dart';
import 'package:app_kauf/app_kauf.dart';
import 'package:app_werbung/app_werbung.dart';
import 'package:flutter/material.dart';

import 'spiel_dienst.dart';

const appFarbe = Color(0xFFE0A030);

const appInfo = AppInfo(
  name: 'Buddel Mo',
  paketId: 'com.snake10.buddelmo',
  farbe: appFarbe,
  kontaktEmail: 'snakejoni10@yahoo.com',
  datenschutzText: datenschutzText,
);

/// Werbefrei (Einmalkauf) und Booster-Pakete (verbrauchbar).
final kauf = KaufDienst(
  proIds: const {},
  einzelIds: const {'werbefrei'},
  verbrauchbarIds: const {'goldsack', 'glitzerpaket'},
  verbrauchbarGekauft: (id) async => spiel.paketGutschreiben(id),
  kaufPflicht: false,
);

final werbung = WerbeDienst(ids: const WerbeIds());
final designModus = DesignModus();
final spiel = SpielDienst();

const datenschutzText = '''
Datenschutzerklärung für Buddel Mo

1. Spielstand
Dein Spielstand wird nur auf deinem Gerät gespeichert. Es gibt kein Konto.

2. Werbung (Google AdMob)
Das Spiel zeigt Banner-Werbung und freiwillige Belohnungs-Videos über Google AdMob. Dabei kann Google die Werbe-ID, ungefähre Standortdaten und Interaktionen verarbeiten. In der EU wirst du vorher um Einwilligung gebeten. Mehr: https://policies.google.com/technologies/ads

3. Käufe
Laufen über Google Play. Ich erhalte keine Zahlungsdaten.

4. Kontakt
snakejoni10@yahoo.com
''';
