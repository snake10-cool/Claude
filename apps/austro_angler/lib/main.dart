import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/community_screen.dart';
import 'screens/fangbuch_screen.dart';
import 'screens/gewaesser_screen.dart';
import 'screens/karte_screen.dart';
import 'screens/konto_screen.dart';
import 'screens/mehr_screen.dart';
import 'screens/wuensche_screen.dart';
import 'services/alle_gewaesser.dart';
import 'services/hintergrund.dart';
import 'services/konto.dart';
import 'services/speicher.dart';
import 'services/wecker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final speicher = await Speicher.oeffnen();
  // Schonzeit-Wecker für das nächste Jahr neu planen (im Hintergrund).
  Wecker.instanz.alleEinplanen(speicher.bundesland).catchError((_) {});
  // Alle Gewässer Österreichs im Hintergrund laden.
  alleGewaesser.laden();
  Konto? konto;
  if (firebaseKonfiguriert) {
    try {
      await Firebase.initializeApp(options: firebaseOptionen);
      // Offline-Modus: Daten bleiben am Gerät und werden später synchronisiert.
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
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

ThemeData _thema(Color farbe, Brightness helligkeit) => ThemeData(
  colorSchemeSeed: farbe,
  brightness: helligkeit,
  useMaterial3: true,
  // Kleinere Beschriftung, damit "Gewässer" & Co. nicht umbrechen.
  navigationBarTheme: const NavigationBarThemeData(
    labelTextStyle: WidgetStatePropertyAll(
      TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    ),
  ),
  tabBarTheme: const TabBarThemeData(
    labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontSize: 13),
  ),
);

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
          theme: _thema(farbe, Brightness.light),
          darkTheme: _thema(farbe, Brightness.dark),
          home: const _Weiche(),
          // Jungangler-Modus: etwas größere Schrift.
          builder: (context, kind) => ListenableBuilder(
            listenable: speicher,
            builder: (context, _) => speicher.jungangler
                ? MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: MediaQuery.textScalerOf(context)
                          .clamp(minScaleFactor: 1.15),
                    ),
                    child: kind!,
                  )
                : kind!,
          ),
        ),
      ),
    );
  }
}

/// Mit Online-Funktionen muss man angemeldet sein, um die App zu nutzen.
class _Weiche extends StatelessWidget {
  const _Weiche();

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context);
    if (konto == null) return const Startseite();
    if (!konto.bereit) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return konto.angemeldet ? const Startseite() : const AnmeldeSeite();
  }
}

class Startseite extends StatefulWidget {
  const Startseite({super.key});

  @override
  State<Startseite> createState() => _StartseiteState();
}

class _StartseiteState extends State<Startseite> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final konto = KontoScope.of(context);
      angeltageWarnen(konto);
      startbildschirmAktualisieren(SpeicherScope.of(context));
    });
  }

  static const _seiten = [
    GewaesserScreen(),
    KarteScreen(),
    FangbuchScreen(),
    CommunityScreen(),
    WuenscheScreen(),
    MehrScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _OfflineHinweis(),
          Expanded(child: IndexedStack(index: _index, children: _seiten)),
        ],
      ),
      // Große Systemschrift nur begrenzt übernehmen, sonst bricht die
      // Beschriftung bei sechs Tabs um.
      bottomNavigationBar: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.1,
        child: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.water), label: 'Gewässer'),
            NavigationDestination(icon: Icon(Icons.map), label: 'Karte'),
            NavigationDestination(icon: Icon(Icons.book), label: 'Fangbuch'),
            NavigationDestination(icon: Icon(Icons.groups), label: 'Feed'),
            NavigationDestination(
              icon: Icon(Icons.lightbulb_outline),
              label: 'Wünsche',
            ),
            NavigationDestination(icon: Icon(Icons.menu), label: 'Mehr'),
          ],
        ),
      ),
    );
  }
}

/// Zeigt oben einen Streifen, wenn kein Internet da ist.
class _OfflineHinweis extends StatelessWidget {
  const _OfflineHinweis();

  static final _stream = Connectivity().onConnectivityChanged;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: _stream,
      builder: (context, snap) {
        final offline = snap.data != null &&
            snap.data!.every((r) => r == ConnectivityResult.none);
        if (!offline) return const SizedBox.shrink();
        return Material(
          color: Colors.orange.shade700,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: const [
                  Icon(Icons.cloud_off, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Offline – Fänge werden gespeichert und später '
                      'hochgeladen.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
