import 'dart:convert';

import 'package:app_basis/app_basis.dart';
import 'package:app_kauf/app_kauf.dart';
import 'package:app_werbung/app_werbung.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logik/serie.dart';
import 'logik/tag.dart';

const appFarbe = Color(0xFF2563EB);

const appInfo = AppInfo(
  name: 'Rätseltag',
  paketId: 'com.snake10.raetseltag',
  farbe: appFarbe,
  kontaktEmail: 'snakejoni10@yahoo.com',
  datenschutzText: datenschutzText,
);

const storeLink =
    'https://play.google.com/store/apps/details?id=com.snake10.raetseltag';

/// Pro: Archiv und Endlos-Modus, werbefrei. Einmalkauf oder Abo.
final kauf = KaufDienst(
  proIds: const {'pro_einmal', 'pro_monat'},
  kaufPflicht: false,
);

final werbung = WerbeDienst(ids: const WerbeIds());
final designModus = DesignModus();
final fortschritt = Fortschritt();

/// Wortlisten aus den Assets.
class Woerter {
  static List<String> loesungen = const [];
  static Set<String> erlaubt = const {};

  static Future<void> laden() async {
    List<String> lesen(String t) =>
        t.split('\n').map((w) => w.trim()).where((w) => w.isNotEmpty).toList();
    loesungen = lesen(
      await rootBundle.loadString('assets/woerter/loesungen.txt'),
    );
    erlaubt = lesen(await rootBundle.loadString('assets/woerter/erlaubt.txt'))
        .toSet();
  }
}

/// Ergebnisse und laufende Rätsel. Schlüssel z. B. „wort:12“,
/// „sudoku:mittel:12“, „schiebe:12“.
class Fortschritt extends ChangeNotifier {
  Map<String, Map<String, dynamic>> ergebnisse = {};
  Map<String, Map<String, dynamic>> laufend = {};

  Future<void> laden() async {
    final p = await SharedPreferences.getInstance();
    Map<String, Map<String, dynamic>> lesen(String k) {
      final t = p.getString(k);
      if (t == null) return {};
      return (jsonDecode(t) as Map).map(
        (k, v) => MapEntry(k as String, Map<String, dynamic>.from(v as Map)),
      );
    }

    ergebnisse = lesen('ergebnisse');
    laufend = lesen('laufend');
    notifyListeners();
  }

  Future<void> _speichern() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('ergebnisse', jsonEncode(ergebnisse));
    await p.setString('laufend', jsonEncode(laufend));
  }

  Future<void> zwischenstand(
    String schluessel,
    Map<String, dynamic> daten,
  ) async {
    laufend[schluessel] = daten;
    await _speichern();
  }

  /// Rätsel beendet (gelöst oder nicht).
  Future<void> beenden(String schluessel, Map<String, dynamic> ergebnis) async {
    ergebnisse[schluessel] = ergebnis;
    laufend.remove(schluessel);
    notifyListeners();
    await _speichern();
  }

  Map<String, dynamic>? ergebnis(String schluessel) => ergebnisse[schluessel];

  bool geloest(String schluessel) => ergebnisse[schluessel]?['geloest'] == true;

  /// Nummern der Tage mit mindestens einem gelösten Rätsel.
  Set<int> get geloesteTage => {
    for (final e in ergebnisse.entries)
      if (e.value['geloest'] == true) int.parse(e.key.split(':').last),
  };

  int get aktuelleSerie => serie(geloesteTage, DateTime.now());
  int get laengste => laengsteSerie(geloesteTage);

  /// Alle drei Rätsel eines Tages gelöst (Sudoku in irgendeiner Stufe).
  bool alleDrei(int nummer) =>
      geloest('wort:$nummer') &&
      geloest('schiebe:$nummer') &&
      ['leicht', 'mittel', 'schwer'].any((s) => geloest('sudoku:$s:$nummer'));

  int get heute => raetselNummer(DateTime.now());

  Future<void> allesLoeschen() async {
    ergebnisse = {};
    laufend = {};
    notifyListeners();
    await _speichern();
  }
}

const datenschutzText = '''
Datenschutzerklärung für Rätseltag

1. Spielstand
Ergebnisse und Statistiken werden nur auf deinem Gerät gespeichert. Es gibt kein Konto.

2. Werbung (Google AdMob)
Die kostenlose Version zeigt Banner, Werbung zwischen den Rätseln (nie während eines Rätsels) und freiwillige Videos für Tipps. Dabei kann Google die Werbe-ID, ungefähre Standortdaten und Interaktionen verarbeiten. In der EU wirst du vorher um Einwilligung gebeten. Mehr: https://policies.google.com/technologies/ads

3. Teilen
Wenn du ein Ergebnis teilst, entscheidest du selbst, wohin. Es enthält keine persönlichen Daten.

4. Käufe
Laufen über Google Play. Ich erhalte keine Zahlungsdaten.

5. Wortliste
Erlaubte Wörter stammen aus wordfreq (Robyn Speer), Daten unter CC BY-SA 4.0.

6. Kontakt
snakejoni10@yahoo.com
''';
