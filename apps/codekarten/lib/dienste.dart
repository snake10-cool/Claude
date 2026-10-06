import 'package:app_basis/app_basis.dart';
import 'package:app_kauf/app_kauf.dart';
import 'package:app_werbung/app_werbung.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logik/freischaltung.dart';

/// Hauptfarbe der App: Violett.
const appFarbe = Color(0xFF6C4DE6);

const appInfo = AppInfo(
  name: 'Codekarten',
  paketId: 'com.snake10.codekarten',
  farbe: appFarbe,
  kontaktEmail: 'snakejoni10@yahoo.com',
  datenschutzText: datenschutzText,
);

/// Pakete (Einmalkauf) und das Abo „Alles“. Bis zum Play-Store-Start ist
/// [KaufDienst.kaufPflicht] aus → alle Stapel frei.
const paketIds = {
  'paket_java_profi',
  'paket_python',
  'paket_dart',
  'paket_javascript',
};

final kauf = KaufDienst(
  proIds: const {'alles_monat', 'alles_jahr'},
  einzelIds: paketIds,
  kaufPflicht: false,
);

/// Nur Test-Anzeigen, bis echte IDs eingetragen sind (siehe app_werbung).
final werbung = WerbeDienst(ids: const WerbeIds());

final designModus = DesignModus();

/// Lern-Einstellungen und Video-Freischaltungen.
class Lerneinstellungen extends ChangeNotifier {
  int tagesziel = 20;
  int neueProTag = 10;
  final Map<String, DateTime> _freiBis = {};

  Future<void> laden() async {
    final p = await SharedPreferences.getInstance();
    tagesziel = p.getInt('tagesziel') ?? 20;
    neueProTag = p.getInt('neue_pro_tag') ?? 10;
    for (final id in paketIds) {
      final ms = p.getInt('frei_$id');
      if (ms != null) _freiBis[id] = DateTime.fromMillisecondsSinceEpoch(ms);
    }
    notifyListeners();
  }

  Future<void> setzen({int? ziel, int? neue}) async {
    final p = await SharedPreferences.getInstance();
    if (ziel != null) {
      tagesziel = ziel;
      await p.setInt('tagesziel', ziel);
    }
    if (neue != null) {
      neueProTag = neue;
      await p.setInt('neue_pro_tag', neue);
    }
    notifyListeners();
  }

  DateTime? freiBis(String produkt) => _freiBis[produkt];

  Future<void> perVideoFreischalten(String produkt) async {
    final bis = DateTime.now().add(videoFreischaltung);
    _freiBis[produkt] = bis;
    final p = await SharedPreferences.getInstance();
    await p.setInt('frei_$produkt', bis.millisecondsSinceEpoch);
    notifyListeners();
  }

  bool offen(String? produkt) => stapelOffen(
    produkt: produkt,
    gekauft: produkt != null && kauf.hat(produkt),
    freiBis: produkt == null ? null : _freiBis[produkt],
    jetzt: DateTime.now(),
  );
}

final lernen = Lerneinstellungen();

const datenschutzText = '''
Datenschutzerklärung für Codekarten

1. Deine Lerndaten
Lernkarten, Lernfortschritt, eigene Stapel und Code-Snippets werden nur lokal auf deinem Gerät gespeichert. Es gibt kein Konto und keinen Server.

2. Werbung (Google AdMob)
In der kostenlosen Version zeigt die App Werbung über Google AdMob (Banner und freiwillige Belohnungs-Videos). Dabei kann Google die Werbe-ID deines Geräts, ungefähre Standortdaten (aus der IP-Adresse) und Informationen über Interaktionen mit Anzeigen verarbeiten. In der EU wirst du vorher um Einwilligung gebeten (Google UMP). Du kannst sie in den Einstellungen jederzeit ändern. Mehr: https://policies.google.com/technologies/ads

3. Käufe
Käufe und Abos laufen über Google Play. Ich erhalte keine Zahlungsdaten.

4. Löschen
Beim Deinstallieren werden alle Daten entfernt.

5. Kontakt
snakejoni10@yahoo.com
''';
