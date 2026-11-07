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
import 'package:austro_angler/screens/fangbuch_screen.dart';
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
import 'package:austro_angler/services/fern_konfig.dart';
import 'package:austro_angler/services/ki.dart';
import 'package:austro_angler/screens/petri_screen.dart';
import 'package:austro_angler/screens/karriere_screen.dart';
import 'package:austro_angler/screens/angelplaner_screen.dart';
import 'package:austro_angler/services/angelplaner.dart';
import 'package:austro_angler/data/gewaesser.dart';
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
  // Echte Schatten statt schwarzer Test-Ränder (am Testende in _foto zurück).
  debugDisableShadows = false;
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
  debugDisableShadows = true;
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
    Map<String, Object> e(int min, String art, String text) => {
          'zeit': start.add(Duration(minutes: min)).toIso8601String(),
          'art': art,
          'text': text,
          if (art == 'fang') 'mit': true,
        };
    await _starten(tester, extra: {
      ...neuDunkel,
      'live_sitzung': jsonEncode({
        'start': start.toIso8601String(),
        'gewaesser': 'Inn bei Braunau',
        'koeder': 'Gummifisch 10 cm',
        'limit': 2,
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

  void kiAn() {
    fernKonfig.uebernehmen(FernDaten(ein: const {'ki'}));
    PetriKi.testServer = (_) async => (200, <String, dynamic>{});
    petriKi.neuerChat();
  }

  void kiAus() {
    petriKi.neuerChat();
    petriKi.rest = null;
    PetriKi.testServer = null;
    fernKonfig.uebernehmen(FernDaten());
  }

  testWidgets('18 Petri-KI Chat', (tester) async {
    kiAn();
    // Beispieltexte für das Store-Bild – keine echte KI-Antwort.
    petriKi.verlauf.addAll([
      (vonMir: true, text: 'Was beißt heute bei mir?'),
      (
        vonMir: false,
        text: 'Heute Abend schaut’s am Inn gut aus: Der Luftdruck fällt leicht '
            'und es ist bewölkt – typisches Raubfischwetter im November.\n\n'
            '• **Zander**: ab der Dämmerung (ca. 16:30–19 Uhr) an Buhnenköpfen '
            'und Strömungskanten, Gummifisch 10–12 cm langsam am Grund.\n'
            '• **Hecht**: tagsüber in ruhigen Buchten und Altarmen, großer '
            'Gummifisch oder toter Köderfisch.\n\n'
            'Beide sind in Oberösterreich gerade offen (Brittelmaß Hecht 60 cm, '
            'Zander 50 cm). Die Revierordnung kann strenger sein.',
      ),
      (vonMir: true, text: 'Welcher Gummifisch genau?'),
      (
        vonMir: false,
        text: 'Bei kaltem Wasser am Inn: **schlanke Shads** mit 10–12 cm in '
            'Weiß, Perlmutt oder Barsch-Dekor. Jigkopf 14–21 g, je nach '
            'Strömung – der Köder soll den Grund spüren. Kurze Sprünge, lange '
            'Pausen: Die meisten Bisse kommen beim Absinken.',
      ),
    ]);
    petriKi.rest = 18;
    await _starten(tester, extra: neuDunkel);
    await _oeffnen(tester, const PetriScreen());
    await _foto(tester, '18_petri_ki');
    kiAus();
  });

  testWidgets('19 Petri-KI Foto', (tester) async {
    kiAn();
    PetriKi.testServer = (_) async => (200, <String, dynamic>{
          'rest': 17,
          'ergebnis': {
            'erkannt': true,
            'fisch_id': 'zander',
            'sicherheit': 'hoch',
            'merkmale': [
              'Große, glasige Augen',
              'Zwei getrennte Rückenflossen, die vordere stachelig',
              'Langgestreckter Körper mit dunklen Querbinden',
            ],
            'alternativen': [
              {
                'fisch_id': 'flussbarsch',
                'grund': 'Auch stachelige Rückenflosse, aber hochrückiger',
              },
            ],
            'hinweis': 'Ganz sicher bist du mit den Glasaugen und den '
                'spitzen Fangzähnen.',
          },
        });
    await _starten(tester, extra: neuDunkel);
    final bild = File('assets/bilder/fische/zander.jpg').readAsBytesSync();
    await _oeffnen(tester, PetriFotoScreen(testBild: bild));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 600)));
    await _warten(tester);
    await _foto(tester, '19_petri_foto');
    kiAus();
  });

  testWidgets('20 Heute mit Petri', (tester) async {
    kiAn();
    liveAngeln.sitzung = null;
    await _starten(tester, extra: neuDunkel);
    await _foto(tester, '20_heute_ki');
    kiAus();
  });

  testWidgets('21 Angel-Karriere', (tester) async {
    liveAngeln.tage = 4;
    await _starten(tester, extra: {
      ...neuDunkel,
      'besteQuizPunkte': 9,
      'pruefungBestanden': true,
      'live_tage': 4,
    });
    await _oeffnen(tester, const KarriereScreen());
    await _foto(tester, '21_karriere');
    liveAngeln.tage = 0;
  });

  testWidgets('22 Angelplaner', (tester) async {
    // Beispielwetter: jeder Tag anders, je Ort leicht verschieden.
    const trend = [0.0, -0.2, 0.3, -0.5, 0.1, -0.3, 0.25, 0.0];
    const wolken = [20.0, 60.0, 10.0, 85.0, 40.0, 70.0, 30.0, 50.0];
    const wind = [10.0, 22.0, 30.0, 8.0, 15.0, 12.0, 26.0, 18.0];
    planerTestWetter = (ort) async {
      final heute = DateTime.now();
      final versatz = ((ort.latitude * 10) % 3).round() * 8.0;
      return [
        for (var d = -1; d < 8; d++)
          for (var h = 0; h < 24; h++)
            Stunde(
                DateTime(heute.year, heute.month, heute.day + d, h),
                1016 - (d < 0 ? 0.0 : trend[d]) * h,
                7 + h / 4,
                ((d < 0 ? 40 : wolken[d]) + versatz).clamp(0, 100).toDouble(),
                d < 0 ? 15.0 : wind[d]),
      ];
    };
    final ids = [
      for (final name in ['Inn bei Braunau', 'Mattig (SAC Mattig, Braunau)', 'Ibmer See'])
        ...gewaesserListe.where((g) => g.name == name).map((g) => g.id),
    ];
    await _starten(tester, extra: {...neuDunkel, 'favoriten': ids});
    await _oeffnen(tester, const AngelplanerScreen());
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await _warten(tester);
    await _foto(tester, '22_angelplaner');
    planerTestWetter = null;
  });

  // Design-Prüfung: jeder Bildschirm im neuen Design, hell und dunkel.
  // Aufruf: QA=<Ordner> flutter test screenshots/store_test.dart --plain-name QA --update-goldens
  final qaOrdner = Platform.environment['QA'];
  if (qaOrdner != null) {
    for (final hell in ['dunkel', 'hell']) {
      testWidgets('QA $hell', (tester) async {
        liveAngeln.sitzung = null;
        await _starten(tester, extra: {'design': 'neu', 'darstellung': hell});
        var n = 0;
        Future<void> knips(String name) async {
          await _warten(tester);
          await expectLater(find.byType(MaterialApp).first,
              matchesGoldenFile('$qaOrdner/${hell}_${(n++).toString().padLeft(2, '0')}_$name.png'));
        }
        Future<void> zurueck() async {
          tester.state<NavigatorState>(find.byType(Navigator).first).pop();
          await _warten(tester);
        }
        for (final tab in ['Heute', 'Gewässer', 'Karte', 'Fangbuch', 'Feed', 'Mehr']) {
          await tester.tap(find.text(tab).last);
          await knips('tab_$tab');
        }
        await tester.tap(find.text('Gewässer').last);
        await _warten(tester);
        await tester.scrollUntilVisible(find.text('✅ Inn bei Braunau'), 200,
            scrollable: find.byType(Scrollable).first);
        await tester.tap(find.text('✅ Inn bei Braunau'));
        await knips('gewaesser_detail');
        await tester.drag(find.byType(Scrollable).last, const Offset(0, -1400));
        await knips('gewaesser_detail_unten');
        await zurueck();
        await _oeffnen(tester, const FangFormular());
        await knips('fang_formular');
        await zurueck();
        await _oeffnen(tester, FischDetail(fische.firstWhere((f) => f.id == 'hecht')));
        await knips('fisch_detail');
        await zurueck();
        await tester.tap(find.text('Mehr').last);
        await _warten(tester);
        for (final titel in _qaMehr) {
          final ziel = find.text(titel);
          await tester.scrollUntilVisible(ziel, 300,
              scrollable: find.byType(Scrollable).first);
          await tester.tap(ziel);
          await knips(titel.replaceAll(RegExp(r'[^A-Za-zÄÖÜäöüß]+'), '_'));
          await zurueck();
        }
        debugDisableShadows = true;
      });
    }
  }
}

const _qaMehr = [
  '⭐ Premium', 'Einstellungen', 'Darf ich …? ⭐', 'Live-Angeln', 'Regeln heute',
  'Zielfisch', 'Wünsche & Ideen', 'Was ist neu?', 'Einführung ansehen',
  'FAQ – Fragen & Antworten', 'Statistik & Abzeichen', 'Arten-Sammelalbum',
  'Eigene Wettfischen', 'Meine Angeltage ⭐', 'Köder-Box', 'Meine Ausrüstung',
  'Fischerkarte', 'Meine Lizenzen', 'Mein Heimatort', 'Angelgeschäfte',
  'Vereine & Verbände', 'Fisch-Quiz', 'Ausrüstungs-Checkliste',
  'Welcher Fisch ist das?', 'Fischlexikon', 'Schonzeit-Kalender',
  'Angel-Wörterbuch', 'Fischerprüfung üben', 'Knoten',
];
