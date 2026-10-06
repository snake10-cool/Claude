import 'package:app_basis/app_basis.dart';
import 'package:app_kauf/app_kauf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'dienste.dart';
import 'l10n/app_localizations.dart';
import 'screens/heute_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('de');
  await designModus.laden();
  await BewertungsBitte.appGestartet();
  await Woerter.laden();
  await fortschritt.laden();
  kauf.starten();
  void werbungAnpassen() => werbung.aus = kauf.gekauft;
  kauf.addListener(werbungAnpassen);
  werbungAnpassen();
  runApp(const RaetseltagApp());
  werbung.starten();
}

class RaetseltagApp extends StatelessWidget {
  const RaetseltagApp({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: designModus,
    builder: (context, _) => MaterialApp(
      title: appInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppDesign.hell(appFarbe),
      darkTheme: AppDesign.dunkel(appFarbe),
      themeMode: designModus.modus,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        BasisLocalizations.delegate,
        KaufLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HeuteScreen(),
    ),
  );
}
