// Erzeugt die Screenshots für den Play Store (nicht Teil der normalen Tests).
//
// Aufruf: flutter test screenshots/store_test.dart --update-goldens
// Ergebnis: docs/store/screenshots/*.png (1080 × 1920)
import 'dart:convert';
import 'dart:io';

import 'package:austro_angler/data/fische.dart';
import 'package:austro_angler/main.dart';
import 'package:austro_angler/screens/einfuehrung_screen.dart';
import 'package:austro_angler/screens/kalender_screen.dart';
import 'package:austro_angler/screens/lexikon_screen.dart';
import 'package:austro_angler/screens/statistik_screen.dart';
import 'package:austro_angler/services/alle_gewaesser.dart';
import 'package:austro_angler/services/speicher.dart';
import 'package:austro_angler/services/wochen_challenges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _schriften = '/opt/tools/flutter/bin/cache/artifacts/material_fonts';

Future<void> _schrift(String familie, List<String> dateien) async {
  final loader = FontLoader(familie);
  for (final d in dateien) {
    final bytes = File(d).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

/// Beispiel-Fänge für Fangbuch und Statistik (klar erkennbar als Beispiele).
List<Map<String, dynamic>> _beispielFaenge() {
  final heute = DateTime.now();
  Map<String, dynamic> f(int tageZurueck, String fisch, double cm, int? g,
          String gewaesser, String koeder,
          {bool zurueck = false, int stunde = 7}) =>
      {
        'id': 'b$tageZurueck$fisch',
        'fischId': fisch,
        'datum': DateTime(heute.year, heute.month, heute.day, stunde)
            .subtract(Duration(days: tageZurueck))
            .toIso8601String(),
        'laengeCm': cm,
        'gewichtG': g,
        'gewaesser': gewaesser,
        'bundesland': 'Oberösterreich',
        'koeder': koeder,
        'notiz': '',
        'zurueckgesetzt': zurueck,
        'wetter': {'temp': 14.0, 'druck': 1016.0, 'wind': 8.0},
      };
  return [
    f(1, 'hecht', 78, 3900, 'Inn bei Braunau', 'Gummifisch', stunde: 18),
    f(3, 'bachforelle', 34, 420, 'Mattig', 'Spinner', stunde: 6),
    f(6, 'aitel', 41, 900, 'Enknach (Bach)', 'Brotflocke', zurueck: true),
    f(9, 'zander', 56, 1700, 'Inn bei Braunau', 'Gummifisch', stunde: 20),
    f(14, 'karpfen', 62, 5200, 'Ibmer See / Heratinger See', 'Boilie',
        stunde: 5),
    f(20, 'flussbarsch', 28, 310, 'Inn bei Braunau', 'Dropshot', zurueck: true),
    f(27, 'aesche', 36, 450, 'Mattig', 'Nymphe', zurueck: true),
    f(33, 'schleie', 38, 900, 'Ibmer See / Heratinger See', 'Mais'),
  ];
}

Future<void> _starten(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({
    'einfuehrung': true,
    'bundesland': 'Oberösterreich',
    'bezirk': 'Braunau',
    'heimat': 'Oberösterreich|Braunau|Braunau am Inn',
    'heimatLat': 48.2565,
    'heimatLon': 13.0435,
    'faenge': jsonEncode(_beispielFaenge()),
    // Keine „Challenge geschafft“-Hinweise im Bild.
    'challenges': [
      for (final c in challengesDerWoche(DateTime.now()))
        challengeSchluessel(DateTime.now(), c),
    ],
  });
  final speicher = await Speicher.oeffnen();
  await tester.runAsync(alleGewaesser.laden);
  await tester.pumpWidget(AustroAnglerApp(speicher: speicher));
  await _warten(tester);
}

Future<void> _warten(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  // Bilder aus den Assets werden echt (asynchron) dekodiert.
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 600)));
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _oeffnen(WidgetTester tester, Widget seite) async {
  tester
      .state<NavigatorState>(find.byType(Navigator).first)
      .push(MaterialPageRoute(builder: (_) => seite));
  await _warten(tester);
}

Future<void> _foto(WidgetTester tester, String name) async {
  // Hinweise wie „Challenge geschafft“ gehören nicht ins Store-Bild.
  for (final m in tester.stateList<ScaffoldMessengerState>(
      find.byType(ScaffoldMessenger))) {
    m.clearSnackBars();
  }
  await tester.pump(const Duration(seconds: 1));
  await expectLater(find.byType(MaterialApp).first,
      matchesGoldenFile('../docs/store/screenshots/$name.png'));
}

void main() {
  setUp(() {
    final bote =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    bote.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/connectivity'),
        (_) async => ['wifi']);
    bote.setMockStreamHandler(
        const EventChannel('dev.fluttercommunity.plus/connectivity_status'),
        MockStreamHandler.inline(
            onListen: (_, sink) => sink.success(['wifi'])));
  });

  setUpAll(() async {
    await _schrift('Roboto', [
      '$_schriften/Roboto-Regular.ttf',
      '$_schriften/Roboto-Medium.ttf',
      '$_schriften/Roboto-Bold.ttf',
    ]);
    await _schrift('MaterialIcons', ['$_schriften/MaterialIcons-Regular.otf']);
    await _schrift(
        'NotoColorEmoji', ['/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf']);
  });

  testWidgets('1 Gewässerliste', (tester) async {
    await _starten(tester);
    await _foto(tester, '1_gewaesser');
  });

  testWidgets('2 Gewässer-Detail', (tester) async {
    await _starten(tester);
    await tester.scrollUntilVisible(find.text('✅ Inn bei Braunau'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('✅ Inn bei Braunau'));
    await _warten(tester);
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -520));
    await _warten(tester);
    await _foto(tester, '2_gewaesser_detail');
  });

  testWidgets('3 Fangbuch', (tester) async {
    await _starten(tester);
    await tester.tap(find.text('Fangbuch').last);
    await _warten(tester);
    await _foto(tester, '3_fangbuch');
  });

  testWidgets('4 Statistik', (tester) async {
    await _starten(tester);
    await _oeffnen(tester, const StatistikScreen());
    await _foto(tester, '4_statistik');
  });

  testWidgets('5 Fischlexikon', (tester) async {
    await _starten(tester);
    await _oeffnen(tester, const LexikonScreen());
    await _foto(tester, '5_lexikon');
  });

  testWidgets('6 Hecht', (tester) async {
    await _starten(tester);
    await _oeffnen(tester, FischDetail(fische.firstWhere((f) => f.id == 'hecht')));
    await _foto(tester, '6_hecht');
  });

  testWidgets('7 Schonzeit-Kalender', (tester) async {
    await _starten(tester);
    await _oeffnen(tester, const KalenderScreen());
    await _foto(tester, '7_kalender');
  });

  testWidgets('8 Einführung', (tester) async {
    await _starten(tester);
    await _oeffnen(tester, const EinfuehrungScreen());
    await _foto(tester, '8_einfuehrung');
  });
}
