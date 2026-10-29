import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/start_screen.dart';
import 'screens/willkommen_screen.dart';
import 'services/erinnerung.dart';
import 'services/konto.dart';
import 'services/speicher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final speicher = await Speicher.laden();
  // Sanfte Lese-Erinnerung: nach jedem Lese-Tag und beim Start neu planen.
  speicher.nachLeseTag = () => Erinnerung.instanz.planen(speicher).catchError((_) {});
  Erinnerung.instanz.planen(speicher).catchError((_) {});
  Konto? konto;
  if (firebaseKonfiguriert) {
    try {
      await Firebase.initializeApp(options: firebaseOptionen);
      konto = Konto(speicher);
    } catch (e) {
      debugPrint('Firebase nicht verfügbar: $e');
    }
  }
  runApp(BuecherwurmApp(speicher: speicher, konto: konto));
}

/// Macht den [Speicher] überall in der App verfügbar.
class SpeicherScope extends InheritedNotifier<Speicher> {
  const SpeicherScope({super.key, required Speicher speicher, required super.child})
    : super(notifier: speicher);

  static Speicher of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SpeicherScope>()!.notifier!;
}

/// Macht das [Konto] verfügbar – `null`, wenn Firebase nicht eingerichtet ist.
class KontoScope extends InheritedNotifier<Konto> {
  const KontoScope({super.key, required Konto? konto, required super.child})
    : super(notifier: konto);

  static Konto? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<KontoScope>()?.notifier;
}

class BuecherwurmApp extends StatelessWidget {
  const BuecherwurmApp({super.key, required this.speicher, this.konto});

  final Speicher speicher;
  final Konto? konto;

  @override
  Widget build(BuildContext context) {
    const farbe = Color(0xFF2E7D6B);
    return SpeicherScope(
      speicher: speicher,
      child: KontoScope(
        konto: konto,
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
