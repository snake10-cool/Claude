import 'package:flutter/material.dart';

import 'bibliothek_tab.dart';
import 'buch_screen.dart';
import 'fuer_dich_tab.dart';
import 'profil_screen.dart';
import 'quiz_tab.dart';
import 'rangliste_tab.dart';
import 'suche_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  var _tab = 0;

  static const _titel = ['Für dich', 'Meine Bücher', 'Quiz', 'Wettbewerb'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titel[_tab]),
        actions: [
          IconButton(
            tooltip: 'Bücher suchen',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SucheScreen())),
          ),
          IconButton(
            tooltip: 'Profil',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const ProfilScreen())),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: const [FuerDichTab(), BibliothekTab(), QuizTab(), RanglisteTab()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Für dich'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Bücher'),
          NavigationDestination(icon: Icon(Icons.quiz_outlined), selectedIcon: Icon(Icons.quiz), label: 'Quiz'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'Wettbewerb'),
        ],
      ),
    );
  }
}

/// Öffnet die Detailseite eines Buchs.
void buchOeffnen(BuildContext context, String buchId) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => BuchScreen(buchId)));
}
