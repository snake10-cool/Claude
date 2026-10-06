import 'package:app_basis/app_basis.dart';
import 'package:app_kauf/app_kauf.dart';
import 'package:buddelmo/dienste.dart';
import 'package:buddelmo/l10n/app_localizations.dart';
import 'package:buddelmo/screens/shop_screen.dart';
import 'package:buddelmo/screens/spiel_screen.dart';
import 'package:buddelmo/screens/wurmregen_screen.dart';
import 'package:buddelmo/widgets/mo_maler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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
    testWidgets('Spielen: $name', (tester) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = Size(breite * 3, hoehe * 3);
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      await tester.runAsync(spiel.zuruecksetzen);
      await tester.runAsync(spiel.laden);

      await tester.pumpWidget(app(const SpielScreen(), dunkel: dunkel));
      await tester.pump();
      ohneFehler(tester, 'Start');

      // 30 Mal auf Mo tippen → 30 Gold.
      final mo = find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is MoMaler,
      );
      for (var i = 0; i < 30; i++) {
        await tester.tap(mo, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(spiel.stand.tipps, 30);
      expect(spiel.stand.gold, greaterThanOrEqualTo(30));

      // Regenwurm kaufen.
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.widgetWithText(FilledButton, 'Kaufen').first);
      await tester.pump(const Duration(milliseconds: 200));
      expect(spiel.stand.helfer['wurm'], 1);
      ohneFehler(tester, 'Helfer');

      for (final reiter in ['Verbesserungen', 'Hügel', 'Helfer']) {
        await tester.tap(find.text(reiter));
        await tester.pump(const Duration(milliseconds: 400));
        ohneFehler(tester, reiter);
      }

      // Tagesbonus abholen.
      await tester.tap(find.text('Tagesbonus'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Abholen'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(spiel.stand.bonusSerie, 1);
      ohneFehler(tester, 'Tagesbonus');

      // Boost-Dialog öffnen und schließen.
      await tester.tap(find.text('Boost'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Später'));
      await tester.pump(const Duration(milliseconds: 400));

      // Wurmregen: eine ganze Runde.
      await tester.pumpWidget(app(const WurmregenScreen(), dunkel: dunkel));
      await tester.tap(find.text('Los!'));
      for (var i = 0; i < 220; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        final wurm = find.text('🪱').hitTestable();
        if (i % 5 == 0 && wurm.evaluate().isNotEmpty) {
          await tester.tap(wurm.first, warnIfMissed: false);
        }
      }
      expect(find.text('Zurück zu Mo'), findsOneWidget);
      ohneFehler(tester, 'Wurmregen');

      await tester.pumpWidget(app(const ShopScreen(), dunkel: dunkel));
      await tester.pump(const Duration(milliseconds: 300));
      ohneFehler(tester, 'Shop');

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  }
}
