import 'package:flutter/material.dart';

import '../l10n/l.dart';
import 'auftraege_screen.dart';
import 'mehr_screen.dart';
import 'produkte_screen.dart';
import 'uebersicht_screen.dart';
import 'verkaufen_screen.dart';

/// Hauptbildschirm mit den fünf Tabs unten.
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _tab = 0;

  void _wechseln(int tab) => setState(() => _tab = tab);

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          VerkaufenScreen(zuProdukten: () => _wechseln(2)),
          const AuftraegeScreen(),
          const ProdukteScreen(),
          const UebersichtScreen(),
          const MehrScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _wechseln,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.point_of_sale_outlined),
            selectedIcon: const Icon(Icons.point_of_sale),
            label: l.tabVerkaufen,
          ),
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(Icons.assignment),
            label: l.tabAuftraege,
          ),
          NavigationDestination(
            icon: const Icon(Icons.category_outlined),
            selectedIcon: const Icon(Icons.category),
            label: l.tabProdukte,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: l.tabUebersicht,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            label: l.tabMehr,
          ),
        ],
      ),
    );
  }
}
