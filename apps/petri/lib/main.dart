import 'package:flutter/material.dart';

import 'screens/fangbuch_screen.dart';
import 'screens/gewaesser_screen.dart';
import 'screens/karte_screen.dart';
import 'screens/lexikon_screen.dart';
import 'screens/pruefung_screen.dart';
import 'services/speicher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final speicher = await Speicher.oeffnen();
  runApp(PetriApp(speicher: speicher));
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

class PetriApp extends StatelessWidget {
  const PetriApp({super.key, required this.speicher});

  final Speicher speicher;

  @override
  Widget build(BuildContext context) {
    const farbe = Color(0xFF1E6F5C);
    return SpeicherScope(
      speicher: speicher,
      child: MaterialApp(
        title: 'Petri',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: farbe, useMaterial3: true),
        darkTheme: ThemeData(
          colorSchemeSeed: farbe,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const Startseite(),
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
    LexikonScreen(),
    PruefungScreen(),
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
          NavigationDestination(icon: Icon(Icons.set_meal), label: 'Fische'),
          NavigationDestination(icon: Icon(Icons.school), label: 'Prüfung'),
        ],
      ),
    );
  }
}
