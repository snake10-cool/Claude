import 'package:flutter/material.dart';

import '../main.dart';
import '../services/challenges.dart';

/// Monats-Challenges: drei Aufgaben pro Monat, für alle gleich.
class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Neu geschaffte Challenges gleich gutschreiben.
    SpeicherScope.of(context).challengesPruefen().then((neu) {
      if (!mounted || neu.isEmpty) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('🎉 Geschafft: ${neu.map((c) => c.text).join(', ')}'),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final theme = Theme.of(context);
    final jetzt = DateTime.now();
    final erledigt = speicher.erledigteChallenges;
    const monate = ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September',
      'Oktober', 'November', 'Dezember'];
    final punkte = challengePunkte(jetzt.month);

    return Scaffold(
      appBar: AppBar(title: const Text('Monats-Challenges')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (istLesesommer(jetzt.month))
            Card(
              color: theme.colorScheme.tertiaryContainer,
              child: const ListTile(
                leading: Text('☀️', style: TextStyle(fontSize: 28)),
                title: Text('Lesesommer!'),
                subtitle: Text('Im Juli und August zählt jede Challenge doppelt.'),
              ),
            ),
          Text('${monate[jetzt.month - 1]} ${jetzt.year}', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Jede geschaffte Challenge bringt $punkte Bonuspunkte für die Rangliste. '
              'Alle bekommen dieselben drei Aufgaben – ihr könnt euch also vergleichen.'),
          const SizedBox(height: 12),
          for (final c in challengesFuer(jetzt.year, jetzt.month))
            Builder(builder: (context) {
              final geschafft = erledigt.containsKey('${jetzt.year}-${jetzt.month}:${c.id}');
              return Card(
                child: ListTile(
                  leading: Text(c.emoji, style: const TextStyle(fontSize: 30)),
                  title: Text(c.text),
                  subtitle: Text(geschafft ? 'Geschafft! +$punkte Punkte' : 'Noch offen'),
                  trailing: Icon(geschafft ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: geschafft ? Colors.green : theme.colorScheme.outline),
                ),
              );
            }),
          const SizedBox(height: 12),
          Text('Bisher insgesamt ${speicher.bonusPunkte} Bonuspunkte aus Challenges.',
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text('Bücher zählen für den Monat, in dem du sie als gelesen einträgst.', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
