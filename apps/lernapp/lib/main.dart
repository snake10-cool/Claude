import 'package:flutter/material.dart';

import 'screens/klasse_screen.dart';
import 'screens/start_screen.dart';
import 'services/fortschritt.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final fortschritt = await Fortschritt.laden();
  runApp(LernApp(fortschritt: fortschritt));
}

/// Macht den [Fortschritt] überall in der App verfügbar.
class FortschrittScope extends InheritedNotifier<Fortschritt> {
  const FortschrittScope({
    super.key,
    required Fortschritt fortschritt,
    required super.child,
  }) : super(notifier: fortschritt);

  static Fortschritt of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<FortschrittScope>()!
      .notifier!;
}

class LernApp extends StatelessWidget {
  const LernApp({super.key, required this.fortschritt});

  final Fortschritt fortschritt;

  @override
  Widget build(BuildContext context) {
    const farbe = Color(0xFFF57C00);
    return FortschrittScope(
      fortschritt: fortschritt,
      child: MaterialApp(
        title: 'Lernfuchs',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: farbe, useMaterial3: true),
        darkTheme: ThemeData(
          colorSchemeSeed: farbe,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const _Weiche(),
      ),
    );
  }
}

/// Beim ersten Start die Klasse wählen, danach direkt zur Startseite.
class _Weiche extends StatelessWidget {
  const _Weiche();

  @override
  Widget build(BuildContext context) {
    return FortschrittScope.of(context).stufe == null
        ? const KlasseScreen()
        : const StartScreen();
  }
}
