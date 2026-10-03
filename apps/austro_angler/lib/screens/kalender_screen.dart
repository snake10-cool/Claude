import 'package:flutter/material.dart';

import '../data/fische.dart';
import '../main.dart';
import '../models/fisch.dart';
import 'widgets.dart';

enum MonatStatus { offen, teilweise, geschont, unbekannt }

/// Wie viel eines Monats in der Schonzeit liegt.
MonatStatus monatStatus(Regel regel, int monat) {
  final tage = DateUtils.getDaysInMonth(2026, monat);
  var geschont = 0;
  for (var t = 1; t <= tage; t++) {
    final g = regel.istGeschont(DateTime(2026, monat, t));
    if (g == null) return MonatStatus.unbekannt;
    if (g) geschont++;
  }
  if (geschont == 0) return MonatStatus.offen;
  if (geschont == tage) return MonatStatus.geschont;
  return MonatStatus.teilweise;
}

class KalenderScreen extends StatelessWidget {
  const KalenderScreen({super.key});

  static const _monate = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O',
    'N', 'D'];

  Color _farbe(MonatStatus s) => switch (s) {
        MonatStatus.offen => Colors.green.shade500,
        MonatStatus.teilweise => Colors.orange.shade400,
        MonatStatus.geschont => Colors.red.shade500,
        MonatStatus.unbekannt => Colors.grey.shade400,
      };

  @override
  Widget build(BuildContext context) {
    final land = SpeicherScope.of(context).bundesland;
    final aktuell = DateTime.now().month;
    final text = Theme.of(context).textTheme;

    Widget legende(MonatStatus s, String t) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 14, height: 14, color: _farbe(s)),
            const SizedBox(width: 4),
            Text(t, style: text.bodySmall),
          ],
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Schonzeit-Kalender')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const BundeslandWahl(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              legende(MonatStatus.offen, 'offen'),
              legende(MonatStatus.teilweise, 'teilweise geschont'),
              legende(MonatStatus.geschont, 'geschont'),
              legende(MonatStatus.unbekannt, 'unbekannt'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 110),
              for (var m = 1; m <= 12; m++)
                Expanded(
                  child: Text(
                    _monate[m - 1],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: m == aktuell ? FontWeight.bold : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (final f in fische)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(f.name.split(' (').first,
                        overflow: TextOverflow.ellipsis),
                  ),
                  for (var m = 1; m <= 12; m++)
                    Expanded(
                      child: Container(
                        height: 22,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: _farbe(monatStatus(f.regel(land), m)),
                          borderRadius: BorderRadius.circular(3),
                          border: m == aktuell
                              ? Border.all(width: 2,
                                  color: Theme.of(context).colorScheme.onSurface)
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Text('$schonzeitenStand. Genaue Daten im Fischlexikon.',
              style: text.bodySmall),
        ],
      ),
    );
  }
}
