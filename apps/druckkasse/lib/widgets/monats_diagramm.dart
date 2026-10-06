import 'package:flutter/material.dart';

import '../logik/statistik.dart';
import 'format.dart';

/// Säulen für den Gewinn der letzten Monate. Eine Datenreihe in der
/// App-Farbe, der gewählte Monat ist beschriftet und kräftiger.
/// Antippen wählt den Monat aus.
class MonatsDiagramm extends StatelessWidget {
  const MonatsDiagramm({
    super.key,
    required this.werte,
    required this.gewaehlt,
    required this.onWaehlen,
  });

  final List<MonatsWert> werte;
  final DateTime gewaehlt;
  final ValueChanged<DateTime> onWaehlen;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final farben = t.colorScheme;
    final maxWert = werte.fold<int>(
      1,
      (m, w) => w.gewinnCent > m ? w.gewinnCent : m,
    );
    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final w in werte)
            Expanded(
              child: Semantics(
                button: true,
                label: '${monatJahr(w.monat)}: ${euro(w.gewinnCent)}',
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onWaehlen(w.monat),
                  child: Padding(
                    // 2 px Abstand zwischen den Säulen (je 1 px links/rechts).
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Builder(
                      builder: (context) {
                        final aktiv = w.monat == gewaehlt;
                        final anteil = w.gewinnCent <= 0
                            ? 0.0
                            : w.gewinnCent / maxWert;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 18,
                              child: aktiv
                                  ? FittedBox(
                                      child: Text(
                                        euro(w.gewinnCent),
                                        style: t.textTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: anteil.clamp(0.01, 1.0),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: aktiv
                                          ? farben.primary
                                          : farben.primary.withValues(
                                              alpha: 0.35,
                                            ),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(height: 1, color: farben.outlineVariant),
                            const SizedBox(height: 4),
                            Text(
                              monatKurz(w.monat),
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: t.textTheme.labelSmall?.copyWith(
                                color: aktiv
                                    ? farben.onSurface
                                    : farben.onSurfaceVariant,
                                fontWeight: aktiv ? FontWeight.bold : null,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
