import 'package:flutter/material.dart';

import '../main.dart';
import '../models/buch.dart';
import '../widgets/buch_kachel.dart';
import 'quiz_screen.dart';

/// Alle Bücher mit Quiz. Gelesene stehen oben.
class QuizTab extends StatelessWidget {
  const QuizTab({super.key});

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final theme = Theme.of(context);
    int rang(Buch b) {
      if (speicher.quiz.containsKey(b.id)) return 2;
      final s = speicher.eintraege[b.id]?.status;
      return s == Status.gelesen || s == Status.lese ? 0 : 1;
    }

    final buecher = speicher.alleBuecher.where((b) => b.hatQuiz).toList()
      ..sort((a, b) => rang(a).compareTo(rang(b)));

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Card(
            color: theme.colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('🏅', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${speicher.punkte} Punkte · ${speicher.bewiesen} Bücher bewiesen\n'
                      'Beweise, dass du ein Buch gelesen oder gehört hast!',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        for (final buch in buecher)
          Builder(builder: (context) {
            final ergebnis = speicher.quiz[buch.id];
            final status = speicher.eintraege[buch.id]?.status;
            return ListTile(
              leading: BuchCover(buch, breite: 36),
              title: Text(buch.titel),
              subtitle: Text(ergebnis != null
                  ? '${ergebnis.richtig}/${ergebnis.gesamt} richtig · ${ergebnis.punkte} Punkte'
                  : status == Status.gelesen
                      ? 'Gelesen – jetzt beweisen!'
                      : '${buch.quiz.length} Fragen'),
              trailing: ergebnis == null
                  ? const Icon(Icons.play_circle_outline)
                  : Icon(
                      ergebnis.bestanden ? Icons.verified : Icons.cancel_outlined,
                      color: ergebnis.bestanden ? Colors.green : theme.colorScheme.error,
                    ),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => QuizScreen(buch: buch))),
            );
          }),
      ],
    );
  }
}
