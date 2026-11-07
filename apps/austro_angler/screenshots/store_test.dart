// ignore_for_file: invalid_use_of_visible_for_testing_member
// Erzeugt die Screenshots für den Play Store (nicht Teil der normalen Tests).
//
// Aufruf: flutter test screenshots/store_test.dart --update-goldens
// Ergebnis: docs/store/screenshots/*.png (1080 × 1920)
import 'dart:convert';
import 'dart:io';

import 'package:austro_angler/data/fische.dart';
import 'package:austro_angler/main.dart';
import 'package:austro_angler/screens/album_screen.dart';
import 'package:austro_angler/screens/beissindex_karte.dart';
import 'package:austro_angler/screens/darf_ich_screen.dart';
import 'package:austro_angler/services/wetter.dart';
import 'package:austro_angler/screens/neu_screen.dart';
import 'package:austro_angler/screens/regeln_screen.dart';
import 'package:austro_angler/screens/fischerkarte_screen.dart';
import 'package:austro_angler/screens/live_angeln_screen.dart';
import 'package:austro_angler/screens/einfuehrung_screen.dart';
import 'package:austro_angler/screens/zielfisch_screen.dart';
import 'package:austro_angler/screens/kalender_screen.dart';
import 'package:austro_angler/screens/lexikon_screen.dart';
import 'package:austro_angler/screens/statistik_screen.dart';
import 'package:austro_angler/services/abo.dart';
import 'package:austro_angler/services/live_angeln.dart';
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

Future<void> _starten(WidgetTester tester,
    {Map<String, Object> extra = const {}}) async {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({
    'einfuehrung': true, 'wasIstNeu': 99,
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
    ...extra,
  });
  final speicher = await Speicher.oeffnen();
  // Store-Bilder zeigen die App mit Premium.
  aboDienst.aktiv = true;
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
    // Feste Beispiel-Wetterdaten für den Beißindex (kein Internet im Test).
    BeissindexKarte.testWetter = (_) async {
      final heute = DateTime.now();
      return [
        for (var h = 0; h < 24; h++)
          Stunde(DateTime(heute.year, heute.month, heute.day, h),
              1018 - (h >= 6 ? (h - 6) * 0.3 : 0), 6 + h / 3, 75, 9),
      ];
    };
    await _schrift('Roboto', [
      '$_schriften/Roboto-Regular.ttf',
      '$_schriften/Roboto-Medium.ttf',
      '$_schriften/Roboto-Bold.ttf',
    ]);
    await _schrift('MaterialIcons', ['$_schriften/MaterialIcons-Regular.otf']);
    // Schriften des neuen Designs.
    await _schrift('BebasNeue', ['assets/schriften/BebasNeue-Regular.ttf']);
    await _schrift('BarlowCondensed', [
      'assets/schriften/BarlowCondensed-Medium.ttf',
      'assets/schriften/BarlowCondensed-SemiBold.ttf',
      'assets/schriften/BarlowCondensed-Bold.ttf',
    ]);
    await _schrift('Barlow', [
      'assets/schriften/Barlow-Regular.ttf',
      'assets/schriften/Barlow-Medium.ttf',
      'assets/schriften/Barlow-SemiBold.ttf',
      'assets/schriften/Barlow-Bold.ttf',
    ]);
    await _schrift(
        'NotoColorEmoji', ['/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf']);
  });

  testWidgets('1 Gewässerliste', (tester) async {
    await _starten(tester);
    await tester.tap(find.text('Gewässer').last);
    await _warten(tester);
    await _foto(tester, '1_gewaesser');
  });

  testWidgets('2 Gewässer-Detail', (tester) async {
    await _starten(tester);
    await tester.tap(find.text('Gewässer').last);
    await _warten(tester);
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

  testWidgets('9 Darf ich', (tester) async {
    await _starten(tester);
    await _oeffnen(tester,
        const DarfIchScreen(frage: 'Darf ich morgen am Inn einen 45 cm Hecht mitnehmen?'));
    await _foto(tester, '9_darf_ich');
  });

  testWidgets('10 Zielfisch', (tester) async {
    await _starten(tester);
    await _oeffnen(tester, const ZielfischScreen(fischId: 'zander'));
    await _foto(tester, '10_zielfisch');
  });

  testWidgets('11 Heute', (tester) async {
    await _starten(tester);
    await _foto(tester, '11_heute');
  });

  testWidgets('12 Sammelalbum', (tester) async {
    await _starten(tester);
    await _oeffnen(tester, const AlbumScreen());
    await _foto(tester, '12_album');
  });

  testWidgets('13 Was ist neu', (tester) async {
    await _starten(tester);
    await _oeffnen(tester, const NeuScreen());
    await _foto(tester, '13_neu');
  });

  for (final (design, hell) in [
    ('neu', 'dunkel'),
    ('neu', 'hell'),
    ('klassisch', 'dunkel'),
  ]) {
    testWidgets('Design $design $hell', (tester) async {
      await _starten(tester, extra: {'design': design, 'darstellung': hell});
      await _foto(tester, 'design_${design}_$hell');
    });
  }

  const neuDunkel = {'design': 'neu', 'darstellung': 'dunkel'};

  testWidgets('14 Regeln heute', (tester) async {
    await _starten(tester, extra: {...neuDunkel, 'lieblingsfische': ['hecht', 'zander']});
    await _oeffnen(tester, const RegelnScreen());
    await _foto(tester, '14_regeln');
  });

  testWidgets('15 Fischerkarte', (tester) async {
    await _starten(tester, extra: {
      ...neuDunkel,
      'fischerkarte': jsonEncode({
        'name': 'Jasmin Aigner',
        'art': 'Amtliche Fischerkarte Oberösterreich',
        'nummer': 'OÖ-2026-04711',
        'bis': DateTime(DateTime.now().year, 12, 31).toIso8601String(),
      }),
    });
    await _oeffnen(tester, const FischerkarteScreen());
    await _foto(tester, '15_fischerkarte');
  });

  testWidgets('16 Live-Angeln', (tester) async {
    final start = DateTime.now().subtract(const Duration(hours: 2, minutes: 14));
    Map<String, String> e(int min, String art, String text) => {
          'zeit': start.add(Duration(minutes: min)).toIso8601String(),
          'art': art,
          'text': text,
        };
    await _starten(tester, extra: {
      ...neuDunkel,
      'live_sitzung': jsonEncode({
        'start': start.toIso8601String(),
        'gewaesser': 'Inn bei Braunau',
        'koeder': 'Gummifisch 10 cm',
        'eintraege': [
          e(18, 'biss', 'Spinner Gr. 3'),
          e(41, 'koeder', 'Gummifisch 10 cm'),
          e(55, 'biss', 'Gummifisch 10 cm'),
          e(72, 'fang', 'Gummifisch 10 cm'),
          e(96, 'notiz', 'Wind dreht auf West'),
          e(118, 'biss', 'Gummifisch 10 cm'),
        ],
      }),
    });
    await _oeffnen(tester, const LiveAngelnScreen());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await _warten(tester);
    await _foto(tester, '16_live_angeln');
  });

  testWidgets('17 Heute neu', (tester) async {
    liveAngeln.sitzung = null;
    await _starten(tester, extra: neuDunkel);
    await _foto(tester, '17_heute_neu');
  });
}
