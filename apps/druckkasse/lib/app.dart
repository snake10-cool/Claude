import 'package:app_basis/app_basis.dart';
import 'package:app_kauf/app_kauf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dienste.dart';
import 'l10n/app_localizations.dart';
import 'screens/einfuehrung_screen.dart';
import 'screens/start_screen.dart';

class DruckkasseApp extends StatelessWidget {
  const DruckkasseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
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
        home: const _Einstieg(),
      ),
    );
  }
}

/// Beim allerersten Start die Einführung, danach direkt die App.
class _Einstieg extends StatefulWidget {
  const _Einstieg();

  @override
  State<_Einstieg> createState() => _EinstiegState();
}

class _EinstiegState extends State<_Einstieg> {
  static const _schluessel = 'einfuehrung_gesehen';
  bool? _gesehen;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) {
        setState(() => _gesehen = prefs.getBool(_schluessel) ?? false);
      }
    });
  }

  Future<void> _fertig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_schluessel, true);
    if (mounted) setState(() => _gesehen = true);
  }

  @override
  Widget build(BuildContext context) => switch (_gesehen) {
    null => const Scaffold(),
    false => EinfuehrungScreen(fertig: _fertig),
    true => const StartScreen(),
  };
}
