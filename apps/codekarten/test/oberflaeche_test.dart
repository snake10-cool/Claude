import 'dart:convert';
import 'dart:io';

import 'package:app_basis/app_basis.dart';
import 'package:app_kauf/app_kauf.dart';
import 'package:codekarten/daten/datenbank.dart';
import 'package:codekarten/l10n/app_localizations.dart';
import 'package:codekarten/main.dart' show eingebauteStapel;
import 'package:codekarten/screens/karten_screen.dart';
import 'package:codekarten/screens/lern_screen.dart';
import 'package:codekarten/screens/mehr_screen.dart';
import 'package:codekarten/screens/snippets_screen.dart';
import 'package:codekarten/screens/stapel_detail_screen.dart';
import 'package:codekarten/screens/start_screen.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    await initializeDateFormatting('de');
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatenbank(NativeDatabase.memory());
  });

  Future<void> einspielen() async {
    for (final (i, id) in eingebauteStapel.indexed) {
      await db.stapelEinspielen(
        jsonDecode(File('assets/stapel/$id.json').readAsStringSync())
            as Map<String, dynamic>,
        i,
      );
    }
  }

  Widget app(Widget start, {bool dunkel = false}) => MaterialApp(
    theme: dunkel
        ? AppDesign.dunkel(const Color(0xFF6C4DE6))
        : AppDesign.hell(const Color(0xFF6C4DE6)),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      BasisLocalizations.delegate,
      KaufLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('de'),
    home: start,
  );

  Future<void> warten(WidgetTester tester) async {
    for (var i = 0; i < 40; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (i >= 4 && find.byType(CircularProgressIndicator).evaluate().isEmpty) {
        return;
      }
    }
  }

  Finder tab(String name) => find.widgetWithText(NavigationDestination, name);

  for (final (name, breite, hoehe, dunkel) in [
    ('großes Handy, hell', 393.0, 851.0, false),
    ('kleines Handy, dunkel', 360.0, 640.0, true),
  ]) {
    testWidgets('Durchklicken und eine Lernrunde: $name', (tester) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = Size(breite * 3, hoehe * 3);
      addTearDown(tester.view.reset);
      await tester.runAsync(einspielen);

      await tester.pumpWidget(app(const StartScreen(), dunkel: dunkel));
      await warten(tester);
      expect(find.textContaining('Jetzt lernen'), findsOneWidget);

      for (final t in ['Stapel', 'Snippets', 'Mehr', 'Lernen']) {
        await tester.tap(tab(t));
        await warten(tester);
      }

      // Lernrunde bis zum Ende (10 neue Karten, falsche kommen nochmal).
      final stapel = await tester.runAsync(db.stapelLaden);
      await tester.pumpWidget(
        app(LernScreen(stapelIds: [stapel!.first.stapel.id]), dunkel: dunkel),
      );
      await warten(tester);
      var beantwortet = 0;
      for (var i = 0; i < 40; i++) {
        if (find.text('Runde geschafft!').evaluate().isNotEmpty) break;
        beantwortet++;
        if (find.text('Antwort zeigen').evaluate().isNotEmpty) {
          await tester.tap(find.text('Antwort zeigen'));
          await warten(tester);
          await tester.tap(find.text('Gut'));
        } else {
          // Auswahl-Karte: erste Option nehmen, dann weiter.
          await tester.tap(find.byType(OutlinedButton).first);
          await warten(tester);
          final weiter = find.textContaining('Weiter');
          await tester.ensureVisible(weiter.first);
          await tester.tap(weiter.first);
        }
        await warten(tester);
        expect(tester.takeException(), isNull, reason: 'Karte $i');
      }
      final tage = await tester.runAsync(db.lerntageLaden);
      expect(find.text('Runde geschafft!'), findsOneWidget);
      expect(tage!.values.single.karten, beantwortet);
      expect(tage.values.single.neu, 10);

      // Alle weiteren Bildschirme.
      final s = stapel.first.stapel;
      final karten = await tester.runAsync(
        () => db.kartenBeobachten(s.id).first,
      );
      for (final seite in <Widget>[
        StapelDetailScreen(stapelId: s.id),
        StapelDetailScreen(stapelId: stapel[1].stapel.id),
        KartenScreen(stapel: s),
        KarteAnsichtScreen(
          karte: karten!.firstWhere((k) => k.code != null),
          stapel: s,
        ),
        KarteBearbeitenScreen(stapel: s),
        const SnippetsScreen(),
        const SnippetBearbeitenScreen(),
        const StatistikScreen(),
        const EinstellungenScreen(),
      ]) {
        await tester.pumpWidget(app(seite, dunkel: dunkel));
        await warten(tester);
        final fehler = tester.takeException();
        if (fehler != null) {
          for (final r in tester.allRenderObjects) {
            if (r.toStringShort().contains('OVERFLOWING')) {
              // ignore: avoid_print
              print('ÜBERLAUF: ${r.debugCreator}');
            }
          }
        }
        expect(fehler, isNull, reason: '${seite.runtimeType}');
      }
      await tester.pumpWidget(const SizedBox());
      await warten(tester);
    });
  }
}
