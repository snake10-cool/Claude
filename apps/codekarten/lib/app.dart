import 'package:app_basis/app_basis.dart';
import 'package:app_kauf/app_kauf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'dienste.dart';
import 'l10n/app_localizations.dart';
import 'screens/start_screen.dart';

class CodekartenApp extends StatelessWidget {
  const CodekartenApp({super.key});

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
      home: const StartScreen(),
    ),
  );
}
