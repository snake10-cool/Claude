import 'package:app_basis/app_basis.dart';
import 'package:app_kauf/app_kauf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:raetseltag/dienste.dart';
import 'package:raetseltag/l10n/app_localizations.dart';
import 'package:raetseltag/logik/sudoku.dart';
import 'package:raetseltag/logik/wortraetsel.dart';
import 'package:raetseltag/screens/archiv_screen.dart';
import 'package:raetseltag/screens/heute_screen.dart';
import 'package:raetseltag/screens/mehr_screen.dart';
import 'package:raetseltag/screens/schiebe_screen.dart';
import 'package:raetseltag/screens/statistik_screen.dart';
import 'package:raetseltag/screens/sudoku_screen.dart';
import 'package:raetseltag/screens/wort_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() => initializeDateFormatting('de'));

  Widget app(Widget start, {bool dunkel = false}) => MaterialApp(
        theme: dunkel ? AppDesign.dunkel(appFarbe) : AppDesign.hell(appFarbe),
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
    testWidgets('Rätsel lösen: $name', (tester) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = Size(breite * 3, hoehe * 3);
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      await tester.runAsync(Woerter.laden);
      await tester.runAsync(fortschritt.laden);
      final n = fortschritt.heute;

      await tester.pumpWidget(app(const HeuteScreen(), dunkel: dunkel));
      await tester.pump();
      ohneFehler(tester, 'Heute');

      // Worträtsel: erst ein falsches Wort, dann die Lösung tippen.
      final loesung = wortDesTages(Woerter.loesungen, n);
      final falsch = Woerter.loesungen.firstWhere((w) => w != loesung);
      await tester.pumpWidget(app(WortScreen(nummer: n), dunkel: dunkel));
      await tester.pump();
      Future<void> tippe(String wort) async {
        for (final b in wort.split('')) {
          await tester.tap(find.text(b.toUpperCase()).last);
          await tester.pump();
        }
        await tester.tap(find.byIcon(Icons.keyboard_return));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tippe(falsch);
      await tippe(loesung);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Super!'), findsOneWidget);
      ohneFehler(tester, 'Worträtsel');
      await tester.tap(find.text('Weiter'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(fortschritt.geloest('wort:$n'), isTrue);

      // Sudoku leicht komplett über das Zahlenfeld lösen.
      await tester.pumpWidget(app(SudokuScreen(nummer: n, stufe: Stufe.leicht), dunkel: dunkel));
      await tester.pump();
      final (raetsel, loesungSudoku) = sudokuErzeugen(sudokuSeed(n, Stufe.leicht), Stufe.leicht);
      final zellen = find.descendant(of: find.byType(GridView).first, matching: find.byType(GestureDetector));
      for (var i = 0; i < 81; i++) {
        if (raetsel[i] != 0) continue;
        await tester.tap(zellen.at(i));
        await tester.pump();
        await tester.tap(find.widgetWithText(FilledButton, '${loesungSudoku[i]}'));
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Super!'), findsOneWidget);
      ohneFehler(tester, 'Sudoku');
      await tester.tap(find.text('Weiter'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(fortschritt.geloest('sudoku:leicht:$n'), isTrue);

      // Schiebepuzzle: ein Zug.
      await tester.pumpWidget(app(SchiebeScreen(nummer: n), dunkel: dunkel));
      await tester.pump();
      ohneFehler(tester, 'Schiebepuzzle');

      for (final seite in <Widget>[
        const HeuteScreen(),
        const StatistikScreen(),
        const ArchivScreen(),
        const MehrScreen(),
        SudokuScreen(nummer: n, stufe: Stufe.schwer),
      ]) {
        await tester.pumpWidget(app(seite, dunkel: dunkel));
        await tester.pump(const Duration(milliseconds: 300));
        ohneFehler(tester, '${seite.runtimeType}');
      }
      expect(fortschritt.aktuelleSerie, 1);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });
  }
}
