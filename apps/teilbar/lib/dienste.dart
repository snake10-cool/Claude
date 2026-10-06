import 'package:app_basis/app_basis.dart';
import 'package:app_kauf/app_kauf.dart';
import 'package:app_werbung/app_werbung.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sync/sync_motor.dart';

const appFarbe = Color(0xFF1F9D6B);

const appInfo = AppInfo(
  name: 'Teilbar',
  paketId: 'com.snake10.teilbar',
  farbe: appFarbe,
  kontaktEmail: 'snakejoni10@yahoo.com',
  datenschutzText: datenschutzText,
);

/// Plus-Abo (unbegrenzt Gruppen, Statistik, werbefrei) und Einmalkauf
/// „Werbefrei“. Bis zum Start: [KaufDienst.kaufPflicht] aus → alles frei.
final kauf = KaufDienst(
  proIds: const {'plus_monat', 'plus_jahr'},
  einzelIds: const {'werbefrei'},
  kaufPflicht: false,
);

/// Gratis: so viele Gruppen.
const gratisGruppen = 2;

final werbung = WerbeDienst(ids: const WerbeIds());
final designModus = DesignModus();

/// Gesetzt, wenn Firebase eingerichtet ist (siehe firebase_options.dart).
SyncMotor? sync;

/// Mein Name (Vorschlag beim Anlegen von Gruppen) und meine Zutaten.
class Profil extends ChangeNotifier {
  String name = '';
  List<String> zutaten = [];

  Future<void> laden() async {
    final p = await SharedPreferences.getInstance();
    name = p.getString('profil_name') ?? '';
    zutaten = p.getStringList('meine_zutaten') ?? [];
    notifyListeners();
  }

  Future<void> nameSetzen(String n) async {
    name = n.trim();
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString('profil_name', name);
  }

  Future<void> zutatenSetzen(List<String> z) async {
    zutaten = z;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setStringList('meine_zutaten', z);
  }
}

final profil = Profil();

const datenschutzText = '''
Datenschutzerklärung für Teilbar

1. Daten auf deinem Gerät
Listen, Gruppen, Ausgaben, Packlisten und deine Zutaten werden auf deinem Gerät gespeichert.

2. Geteilte Gruppen (Google Firebase)
Wenn du eine Gruppe online teilst oder einer beitrittst, werden die Daten dieser Gruppe (Gruppenname, Namen der Mitglieder, Listen, Artikel, Ausgaben) in Google Firebase (Cloud Firestore, Rechenzentrum in der EU) gespeichert, damit alle Mitglieder sie sehen. Dazu meldet sich die App anonym an (ohne E-Mail oder Namen). Nur Mitglieder der Gruppe können die Daten lesen. Wenn du die Gruppe löschst, werden die Einträge als gelöscht markiert.

3. Werbung (Google AdMob)
In der kostenlosen Version zeigt die App Banner-Werbung über Google AdMob. Dabei kann Google die Werbe-ID, ungefähre Standortdaten und Interaktionen verarbeiten. In der EU wirst du vorher um Einwilligung gebeten. Mehr: https://policies.google.com/technologies/ads

4. Kamera
Die Kamera wird nur zum Scannen von Einladungs-QR-Codes verwendet. Es werden keine Bilder gespeichert.

5. Käufe
Laufen über Google Play. Ich erhalte keine Zahlungsdaten.

6. Kontakt
snakejoni10@yahoo.com
''';
