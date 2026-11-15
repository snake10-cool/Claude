import 'package:flutter/material.dart';

import '../main.dart';
import '../models/buch.dart';
import '../services/abzeichen.dart';

/// Lese-Statistik und Abzeichen.
class StatistikScreen extends StatelessWidget {
  const StatistikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final theme = Theme.of(context);
    final gelesen = speicher.eintraege.entries.where((e) => e.value.status == Status.gelesen).toList();
    final jahr = DateTime.now().year;

    final genres = <String, int>{};
    for (final e in gelesen) {
      for (final t in speicher.buch(e.key)?.tags ?? const <String>{}) {
        if (t == 'serie' || t == 'jungeHelden') continue;
        genres[t] = (genres[t] ?? 0) + 1;
      }
    }
    final topGenres = genres.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final maxGenre = topGenres.isEmpty ? 1 : topGenres.first.value;

    final proJahr = {for (var j = jahr - 4; j <= jahr; j++) j: speicher.gelesenImJahr(j)};
    final maxJahr = proJahr.values.fold(1, (a, b) => a > b ? a : b);

    Widget balken(String text, int wert, int max) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              SizedBox(width: 110, child: Text(text, overflow: TextOverflow.ellipsis)),
              Expanded(
                child: LinearProgressIndicator(
                  value: max == 0 ? 0 : wert / max,
                  minHeight: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: 36, child: Text('$wert', textAlign: TextAlign.end)),
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik & Abzeichen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _Kachel('${gelesen.length}', 'Bücher gelesen'),
              _Kachel('${gesamtSeiten(speicher)}', 'Seiten'),
              _Kachel('${leseSerie(speicher)} 🔥', 'Tage Lese-Serie'),
              _Kachel('${speicher.bewiesen}', 'Quizze bestanden'),
            ],
          ),
          const SizedBox(height: 24),
          Text('Lieblingsgenres', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (topGenres.isEmpty) const Text('Noch keine gelesenen Bücher.'),
          for (final g in topGenres.take(8)) balken(Tags.namen[g.key] ?? g.key, g.value, maxGenre),
          const SizedBox(height: 24),
          Text('Bücher pro Jahr', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final MapEntry(:key, :value) in proJahr.entries) balken('$key', value, maxJahr),
          const SizedBox(height: 24),
          Text('Abzeichen', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.9,
            children: [
              for (final a in alleAbzeichen)
                Tooltip(
                  message: a.beschreibung,
                  child: Opacity(
                    opacity: a.erreicht(speicher) ? 1 : 0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(a.emoji, style: const TextStyle(fontSize: 34)),
                        const SizedBox(height: 4),
                        Text(a.name, textAlign: TextAlign.center, style: theme.textTheme.labelMedium),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${alleAbzeichen.where((a) => a.erreicht(speicher)).length} von ${alleAbzeichen.length} '
            'Abzeichen – tippe lange auf eines, um zu sehen, wie man es bekommt.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Kachel extends StatelessWidget {
  const _Kachel(this.wert, this.text);

  final String wert;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(wert, style: theme.textTheme.headlineSmall),
          Text(text, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
