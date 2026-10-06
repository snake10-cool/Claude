import 'package:flutter/material.dart';

import '../l10n/l.dart';
import 'heute_screen.dart';
import 'mehr_screen.dart';
import 'snippets_screen.dart';
import 'stapel_screen.dart';

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
        children: [
          HeuteScreen(zuStapeln: () => setState(() => _tab = 1)),
          const StapelScreen(),
          const SnippetsScreen(),
          const MehrScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.school_outlined),
            selectedIcon: const Icon(Icons.school),
            label: l.tabLernen,
          ),
          NavigationDestination(
            icon: const Icon(Icons.style_outlined),
            selectedIcon: const Icon(Icons.style),
            label: l.tabStapel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.code),
            label: l.tabSnippets,
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
