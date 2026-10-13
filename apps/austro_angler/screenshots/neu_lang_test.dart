// ignore_for_file: invalid_use_of_visible_for_testing_member
// Erzeugt „Was ist neu?“ in voller Länge für die Update-Seite.
// Aufruf: flutter test screenshots/neu_lang_test.dart --update-goldens
import 'dart:io';

import 'package:austro_angler/main.dart';
import 'package:austro_angler/screens/neu_screen.dart';
import 'package:austro_angler/services/alle_gewaesser.dart';
import 'package:austro_angler/services/speicher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _schriften = '/opt/tools/flutter/bin/cache/artifacts/material_fonts';

Future<void> _schrift(String familie, List<String> dateien) async {
  final loader = FontLoader(familie);
  for (final d in dateien) {
    loader.addFont(Future.value(ByteData.view(File(d).readAsBytesSync().buffer)));
  }
  await loader.load();
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

  for (final dunkel in [false, true]) {
    testWidgets('Was ist neu lang ${dunkel ? 'dunkel' : 'hell'}', (tester) async {
      tester.view.physicalSize = const Size(1080, 7400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.platformBrightnessTestValue =
          dunkel ? Brightness.dark : Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      SharedPreferences.setMockInitialValues({
        'einfuehrung': true,
        'wasIstNeu': 99,
        'bundesland': 'Oberösterreich',
      });
      final speicher = await Speicher.oeffnen();
      await tester.runAsync(alleGewaesser.laden);
      await tester.pumpWidget(AustroAnglerApp(speicher: speicher));
      await tester.pump(const Duration(milliseconds: 500));
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .push(MaterialPageRoute(builder: (_) => const NeuScreen()));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await expectLater(find.byType(MaterialApp).first,
          matchesGoldenFile('../docs/update/neu_${dunkel ? 'dunkel' : 'hell'}.png'));
    });
  }
}
