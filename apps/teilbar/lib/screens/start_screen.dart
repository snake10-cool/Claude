import 'package:flutter/material.dart';

import '../l10n/l.dart';
import 'geld_screen.dart';
import 'kochen_screen.dart';
import 'listen_screen.dart';
import 'mehr_screen.dart';
import 'packen_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [
          ListenScreen(),
          GeldScreen(),
          PackenScreen(),
          KochenScreen(),
          MehrScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.checklist_outlined),
            selectedIcon: const Icon(Icons.checklist),
            label: l.tabListen,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: l.tabGeld,
          ),
          NavigationDestination(
            icon: const Icon(Icons.luggage_outlined),
            selectedIcon: const Icon(Icons.luggage),
            label: l.tabPacken,
          ),
          NavigationDestination(
            icon: const Icon(Icons.restaurant_outlined),
            selectedIcon: const Icon(Icons.restaurant),
            label: l.tabKochen,
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
