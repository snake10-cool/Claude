import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/community_screen.dart';
import 'screens/fangbuch_screen.dart';
import 'screens/gewaesser_screen.dart';
import 'screens/karte_screen.dart';
import 'screens/mehr_screen.dart';
import 'services/konto.dart';
import 'services/speicher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final speicher = await Speicher.oeffnen();
  Konto? konto;
  if (firebaseKonfiguriert) {
    try {
      await Firebase.initializeApp(options: firebaseOptionen);
      konto = Konto();
    } catch (e) {
      debugPrint('Firebase nicht verfügbar: $e');
    }
  }
  runApp(AustroAnglerApp(speicher: speicher, konto: konto));
}

/// Macht den lokalen [Speicher] überall verfügbar.
class SpeicherScope extends InheritedNotifier<Speicher> {
  const SpeicherScope({
    super.key,
    required Speicher speicher,
    required super.child,
  }) : super(notifier: speicher);

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

class AustroAnglerApp extends StatelessWidget {
  const AustroAnglerApp({super.key, required this.speicher, this.konto});

  final Speicher speicher;
  final Konto? konto;

  @override
  Widget build(BuildContext context) {
    const farbe = Color(0xFF1E6F5C);
    return SpeicherScope(
      speicher: speicher,
      child: KontoScope(
        konto: konto,
        child: MaterialApp(
          title: 'Austro Angler',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorSchemeSeed: farbe, useMaterial3: true),
          darkTheme: ThemeData(
            colorSchemeSeed: farbe,
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          home: const Startseite(),
        ),
      ),
    );
  }
}

class Startseite extends StatefulWidget {
  const Startseite({super.key});

  @override
  State<Startseite> createState() => _StartseiteState();
}

class _StartseiteState extends State<Startseite> {
  int _index = 0;

  static const _seiten = [
    GewaesserScreen(),
    KarteScreen(),
    FangbuchScreen(),
    CommunityScreen(),
    MehrScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _seiten),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.water), label: 'Gewässer'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Karte'),
          NavigationDestination(icon: Icon(Icons.book), label: 'Fangbuch'),
          NavigationDestination(icon: Icon(Icons.groups), label: 'Community'),
          NavigationDestination(icon: Icon(Icons.menu), label: 'Mehr'),
        ],
      ),
    );
  }
}
