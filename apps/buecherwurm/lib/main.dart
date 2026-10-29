import 'package:flutter/material.dart';

import 'screens/start_screen.dart';
import 'screens/willkommen_screen.dart';
import 'services/speicher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final speicher = await Speicher.laden();
  runApp(BuecherwurmApp(speicher: speicher));
}

/// Macht den [Speicher] überall in der App verfügbar.
class SpeicherScope extends InheritedNotifier<Speicher> {
  const SpeicherScope({
    super.key,
    required Speicher speicher,
    required super.child,
  }) : super(notifier: speicher);

  static Speicher of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SpeicherScope>()!.notifier!;
}

class BuecherwurmApp extends StatelessWidget {
  const BuecherwurmApp({super.key, required this.speicher});

  final Speicher speicher;

  @override
  Widget build(BuildContext context) {
    const farbe = Color(0xFF2E7D6B);
    return SpeicherScope(
      speicher: speicher,
      child: MaterialApp(
        title: 'Bücherwurm',
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

/// Beim ersten Start sind Fragebogen und Auswahl der gelesenen Bücher Pflicht.
class _Weiche extends StatelessWidget {
  const _Weiche();

  @override
  Widget build(BuildContext context) {
    return SpeicherScope.of(context).einrichtungFertig
        ? const StartScreen()
        : const WillkommenScreen();
  }
}
