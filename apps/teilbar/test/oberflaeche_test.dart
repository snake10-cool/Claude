import 'package:app_basis/app_basis.dart';
import 'package:app_kauf/app_kauf.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teilbar/daten/datenbank.dart';
import 'package:teilbar/l10n/app_localizations.dart';
import 'package:teilbar/logik/packvorlagen.dart';
import 'package:teilbar/screens/ausgabe_screen.dart';
import 'package:teilbar/screens/beitreten_screen.dart';
import 'package:teilbar/screens/gruppe_screen.dart';
import 'package:teilbar/screens/kochen_screen.dart';
import 'package:teilbar/screens/liste_screen.dart';
import 'package:teilbar/screens/mehr_screen.dart';
import 'package:teilbar/screens/rechner_screen.dart';
import 'package:teilbar/screens/rezept_screen.dart';
import 'package:teilbar/screens/start_screen.dart';

void main() {
  setUpAll(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    await initializeDateFormatting('de');
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatenbank(NativeDatabase.memory());
  });

  Widget app(Widget start, {bool dunkel = false}) => MaterialApp(
        theme: dunkel
            ? AppDesign.dunkel(const Color(0xFF1F9D6B))
            : AppDesign.hell(const Color(0xFF1F9D6B)),
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
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 100));
      if (i >= 4 && find.byType(CircularProgressIndicator).evaluate().isEmpty) {
        return;
      }
    }
  }

  Finder tab(String name) => find.widgetWithText(NavigationDestination, name);

  void ohneFehler(WidgetTester tester, String wo) {
    final f = tester.takeException();
    if (f != null) {
      for (final r in tester.allRenderObjects) {
        if (r.toStringShort().contains('OVERFLOWING')) {
          // ignore: avoid_print
          print('ÜBERLAUF in $wo: ${r.debugCreator}');
        }
      }
    }
    expect(f, isNull, reason: wo);
  }

  for (final (name, breite, hoehe, dunkel) in [
    ('großes Handy, hell', 393.0, 851.0, false),
    ('kleines Handy, dunkel', 360.0, 640.0, true),
  ]) {
    testWidgets('Durchklicken: $name', (tester) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = Size(breite * 3, hoehe * 3);
      addTearDown(tester.view.reset);

      // Daten: WG mit Liste, Ausgabe und Packliste.
      late String gid, lid, packId;
      await tester.runAsync(() async {
        gid = await db.gruppeAnlegen(
            name: 'WG Linz', art: 'wg', meinName: 'Anna', weitere: ['Ben', 'Cem']);
        lid = await db.listeAnlegen(name: 'Einkauf WG', gruppeId: gid);
        final liste = (await db.listenLaden()).single.liste;
        await db.artikelHinzufuegen(liste, name: 'Milch', menge: '2');
        await db.artikelHinzufuegen(liste, name: 'Klopapier');
        final ben = (await db.personenLaden(gid)).firstWhere((p) => p.name == 'Ben');
        await db.ausgabeAnlegen(
          gruppeId: gid,
          titel: 'Pizza',
          betragCent: 3600,
          zahlerId: ben.id,
          anteile: {for (final p in await db.personenLaden(gid)) p.id: 1},
        );
        packId = await db.packlisteAnlegen('Strand', '🏖️', packVorlagen.first.artikel);
      });

      await tester.pumpWidget(app(const StartScreen(), dunkel: dunkel));
      await warten(tester);
      expect(find.text('Einkauf WG'), findsOneWidget);
      for (final t in ['Geld', 'Packen', 'Kochen', 'Mehr', 'Listen']) {
        await tester.tap(tab(t));
        await warten(tester);
        ohneFehler(tester, 'Tab $t');
      }

      // Liste: Artikel eintippen, Milch mit Betrag abhaken.
      await tester.pumpWidget(app(ListeScreen(listeId: lid), dunkel: dunkel));
      await warten(tester);
      await tester.enterText(find.byType(TextField).first, '500g Mehl');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await warten(tester);
      expect(find.text('Mehl'), findsOneWidget);
      expect(find.text('500 g'), findsOneWidget);
      await tester.tap(find.text('Milch'));
      await warten(tester);
      expect(find.text('Milch gekauft'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).last, '2,40');
      await tester.tap(find.text('Abhaken'));
      await warten(tester);
      ohneFehler(tester, 'Liste');
      final salden = await tester.runAsync(() => db.saldenBeobachten(gid).first);
      // Pizza 36 € von Ben, Milch 2,40 € von Anna, je durch 3.
      expect(salden!.values.fold(0, (a, b) => a + b), 0);
      final anna = (await tester.runAsync(() => db.personenLaden(gid)))!
          .firstWhere((p) => p.name == 'Anna');
      expect(salden[anna.id], 240 - 80 - 1200);

      // Packliste mit Kategorien.
      await tester.pumpWidget(app(ListeScreen(listeId: packId), dunkel: dunkel));
      await warten(tester);
      expect(find.text('Dokumente'), findsOneWidget);
      ohneFehler(tester, 'Packliste');

      // Gruppe: alle drei Reiter.
      await tester.pumpWidget(app(GruppeScreen(gruppeId: gid), dunkel: dunkel));
      await warten(tester);
      for (final reiter in ['Wer schuldet wem', 'Mitglieder', 'Ausgaben']) {
        await tester.tap(find.text(reiter));
        await warten(tester);
        ohneFehler(tester, 'Gruppe/$reiter');
      }

      // Rezept aus der Resteküche.
      final rezepte = await tester.runAsync(rezepteLaden);
      final gruppe = await tester.runAsync(() => db.gruppeLaden(gid));
      final personen = await tester.runAsync(() => db.personenLaden(gid));
      for (final seite in <Widget>[
        RezeptScreen(rezept: rezepte!.first),
        const KochenScreen(),
        const RechnerScreen(),
        const BeitretenScreen(),
        AusgabeScreen(gruppe: gruppe!, personen: personen!),
        const MehrScreen(),
      ]) {
        await tester.pumpWidget(app(seite, dunkel: dunkel));
        await warten(tester);
        ohneFehler(tester, '${seite.runtimeType}');
      }

      await tester.pumpWidget(const SizedBox());
      await warten(tester);
    });
  }
}
