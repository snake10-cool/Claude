import 'package:app_basis/app_basis.dart';
import 'package:app_kauf/app_kauf.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:druckkasse/daten/beispieldaten.dart';
import 'package:druckkasse/daten/datenbank.dart';
import 'package:druckkasse/l10n/app_localizations.dart';
import 'package:druckkasse/screens/auftrag_bearbeiten_screen.dart';
import 'package:druckkasse/screens/drucker_screen.dart';
import 'package:druckkasse/screens/einfuehrung_screen.dart';
import 'package:druckkasse/screens/einstellungen_screen.dart';
import 'package:druckkasse/screens/extras_screen.dart';
import 'package:druckkasse/screens/filamente_screen.dart';
import 'package:druckkasse/screens/mehr_screen.dart';
import 'package:druckkasse/screens/produkt_bearbeiten_screen.dart';
import 'package:druckkasse/screens/sparziele_screen.dart';
import 'package:druckkasse/screens/start_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Klickt sich mit Beispieldaten durch alle Bildschirme. Findet Layout-
/// Fehler (Überläufe, Abstürze), die Unit-Tests nicht sehen.
void main() {
  setUpAll(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    await initializeDateFormatting('de');
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatenbank(NativeDatabase.memory());
  });

  Widget app(Widget start, {required bool dunkel}) => MaterialApp(
    theme: dunkel
        ? AppDesign.dunkel(const Color(0xFFE8622A))
        : AppDesign.hell(const Color(0xFFE8622A)),
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

  /// Echte Zeit vergehen lassen (die Datenbank arbeitet asynchron), bis
  /// nichts mehr lädt.
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

  Future<void> zurueck(WidgetTester tester) async {
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    // Übergangsanimation fertig laufen lassen.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  for (final (name, breite, hoehe, dunkel) in [
    ('großes Handy, hell', 393.0, 851.0, false),
    ('kleines Handy, dunkel', 360.0, 640.0, true),
  ]) {
    testWidgets('Durchklicken: $name', (tester) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = Size(breite * 3, hoehe * 3);
      addTearDown(tester.view.reset);

      await tester.runAsync(() => beispieldatenLaden(db));
      await tester.pumpWidget(app(const StartScreen(), dunkel: dunkel));
      await warten(tester);

      // Verkaufen: Sparziel und Produkt-Knöpfe.
      expect(find.text('Bambu Lab P1S'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Klicker'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await warten(tester);

      // Ein Verkauf per Tipp, mit Rückgängig.
      await tester.tap(find.text('Klicker').hitTestable().first);
      await warten(tester);
      expect(find.text('Rückgängig'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5)); // Snackbar weg

      // Lange drücken öffnet den Sonderverkauf.
      await tester.longPress(find.text('Klicker').hitTestable().first);
      await warten(tester);
      expect(find.text('Preis pro Stück'), findsOneWidget);
      await zurueck(tester);
      await warten(tester);

      for (final t in ['Aufträge', 'Produkte', 'Übersicht', 'Mehr']) {
        await tester.tap(tab(t));
        await warten(tester);
      }

      // Produkt-Editor bis ganz unten (Live-Kalkulation).
      await tester.tap(tab('Produkte'));
      await warten(tester);
      await tester.tap(find.text('Flexi Dragon').hitTestable().first);
      await warten(tester);
      await tester.scrollUntilVisible(
        find.text('Kosten pro Stück'),
        300,
        scrollable: find
            .descendant(
              of: find.byType(ProduktBearbeitenScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text('Kosten pro Stück'), findsWidgets);
      await zurueck(tester);
      await warten(tester);

      // Auftrag öffnen.
      await tester.tap(tab('Aufträge'));
      await warten(tester);
      await tester.tap(find.text('Lena (Nachbarin)'));
      await warten(tester);
      expect(find.text('Was wurde bestellt?'), findsOneWidget);
      await zurueck(tester);
      await warten(tester);

      // Alle übrigen Bildschirme einzeln.
      for (final seite in <Widget>[
        EinfuehrungScreen(fertig: () {}),
        const MehrScreen(),
        const EinstellungenScreen(),
        const DruckerScreen(),
        const DruckerBearbeitenScreen(),
        const FilamenteScreen(),
        const FilamentBearbeitenScreen(),
        const ExtrasScreen(),
        const SparzieleScreen(),
        const ProduktBearbeitenScreen(),
        const AuftragBearbeitenScreen(),
      ]) {
        await tester.pumpWidget(app(seite, dunkel: dunkel));
        await warten(tester);
        expect(find.byWidget(seite), findsOneWidget);
        expect(tester.takeException(), isNull, reason: '${seite.runtimeType}');
      }

      await tester.pumpWidget(const SizedBox());
      await warten(tester);
    });
  }

  testWidgets('leere App zeigt die ersten Schritte', (tester) async {
    await tester.pumpWidget(app(const StartScreen(), dunkel: false));
    await warten(tester);
    expect(find.text('Drucker anlegen'), findsOneWidget);
    expect(find.text('Erstes Produkt anlegen'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await warten(tester);
  });
}
