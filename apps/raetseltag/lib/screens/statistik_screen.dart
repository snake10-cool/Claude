import 'package:app_basis/app_basis.dart';
import 'package:flutter/material.dart';

import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/sudoku.dart';
import '../logik/wortraetsel.dart';
import 'heute_screen.dart';

class StatistikScreen extends StatelessWidget {
  const StatistikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.statistik)),
      body: ListenableBuilder(
        listenable: fortschritt,
        builder: (context, _) {
          final e = fortschritt.ergebnisse;
          final wort = e.entries
              .where((x) => x.key.startsWith('wort:'))
              .map((x) => x.value)
              .toList();
          final wortGewonnen = wort.where((x) => x['geloest'] == true).toList();
          final verteilung = List.filled(maxVersuche, 0);
          for (final w in wortGewonnen) {
            verteilung[(w['versuche'] as int) - 1]++;
          }
          final maxV = verteilung.fold(1, (a, b) => b > a ? b : a);
          final schiebe = e.entries
              .where((x) => x.key.startsWith('schiebe:'))
              .map((x) => x.value)
              .toList();
          int? bestesSudoku(Stufe s) {
            final zeiten = e.entries
                .where((x) => x.key.startsWith('sudoku:${s.name}:'))
                .map((x) => x.value['sekunden'] as int? ?? 0)
                .toList();
            return zeiten.isEmpty
                ? null
                : zeiten.reduce((a, b) => a < b ? a : b);
          }

          Widget kachel(String wert, String titel) => Expanded(
            child: Column(
              children: [
                Text(
                  wert,
                  style: t.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  titel,
                  style: t.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      kachel(
                        '🔥 ${fortschritt.aktuelleSerie}',
                        l.aktuelleSerie,
                      ),
                      kachel('${fortschritt.laengste}', l.laengsteSerie),
                      kachel(
                        '${fortschritt.geloesteTage.length}',
                        l.tageGespielt,
                      ),
                    ],
                  ),
                ),
              ),
              Abschnitt('🔤 ${l.wortraetsel}'),
              Row(
                children: [
                  kachel('${wort.length}', l.gespielt),
                  kachel(
                    wort.isEmpty
                        ? '–'
                        : '${(wortGewonnen.length * 100 / wort.length).round()} %',
                    l.gewonnen,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(l.versucheVerteilung, style: t.textTheme.titleSmall),
              const SizedBox(height: 6),
              for (var i = 0; i < maxVersuche; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(width: 20, child: Text('${i + 1}')),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: (verteilung[i] / maxV).clamp(
                              0.06,
                              1.0,
                            ),
                            child: Container(
                              height: 22,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: verteilung[i] > 0
                                    ? t.colorScheme.primary
                                    : t.colorScheme.surfaceContainerHighest,
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(4),
                                ),
                              ),
                              child: Text(
                                '${verteilung[i]}',
                                style: TextStyle(
                                  color: verteilung[i] > 0
                                      ? t.colorScheme.onPrimary
                                      : t.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Abschnitt('🔢 ${l.sudoku}'),
              for (final s in Stufe.values)
                ListTile(
                  dense: true,
                  title: Text(stufeName(l, s)),
                  trailing: Text(
                    bestesSudoku(s) == null
                        ? '–'
                        : l.bestzeit(zeitText(bestesSudoku(s)!)),
                  ),
                ),
              Abschnitt('🧩 ${l.schiebepuzzle}'),
              Row(
                children: [
                  kachel('${schiebe.length}', l.geloestAnzahl),
                  kachel(
                    schiebe.isEmpty
                        ? '–'
                        : '${schiebe.map((x) => x['zuege'] as int).reduce((a, b) => a < b ? a : b)}',
                    l.wenigsteZuege,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
