import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../daten/produkt_details.dart';
import '../l10n/l.dart';
import '../logik/sparziel_rechner.dart';
import '../logik/statistik.dart';
import '../logik/typen.dart';
import 'format.dart';

/// Sparziel mit Fortschrittsbalken und „Noch 14× Flexi Dragon“.
class SparzielKarte extends StatelessWidget {
  const SparzielKarte({
    super.key,
    required this.ziel,
    required this.produkte,
    this.onTap,
  });

  final Sparziel ziel;
  final List<ProduktDetails> produkte;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Verkauf>>(
      stream: db.verkaeufeBeobachten(ziel.startDatum, DateTime(9999)),
      builder: (context, snap) {
        final auswertung = auswerten(
          (snap.data ?? const []).map((v) => v.zeile),
        );
        final basis = SparBasis.values[ziel.basis];
        final stand = sparStand(basis, auswertung);
        return SparzielAnzeige(
          ziel: ziel,
          standCent: stand,
          produkte: produkte,
          onTap: onTap,
        );
      },
    );
  }
}

class SparzielAnzeige extends StatelessWidget {
  const SparzielAnzeige({
    super.key,
    required this.ziel,
    required this.standCent,
    required this.produkte,
    this.onTap,
  });

  final Sparziel ziel;
  final int standCent;
  final List<ProduktDetails> produkte;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    final basis = SparBasis.values[ziel.basis];
    final fortschritt = sparFortschritt(
      standCent: standCent,
      zielCent: ziel.zielCent,
    );
    final rest = ziel.zielCent - standCent;

    // Die zwei Produkte, mit denen das Ziel am schnellsten erreicht ist.
    int beitrag(ProduktDetails p) =>
        basis == SparBasis.gewinn ? p.gewinnCent : p.preisCent;
    final beste = [...produkte.where((p) => beitrag(p) > 0)]
      ..sort((a, b) => beitrag(b).compareTo(beitrag(a)));

    return Card(
      color: t.colorScheme.primaryContainer,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(ziel.symbol, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ziel.name,
                          style: t.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          l.sparStand(
                            euro(standCent),
                            euro(ziel.zielCent),
                            basis == SparBasis.gewinn ? l.gewinn : l.umsatz,
                          ),
                          style: t.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(fortschritt * 100).floor()} %',
                    style: t.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: fortschritt,
                  minHeight: 12,
                  backgroundColor: t.colorScheme.surface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 10),
              if (rest <= 0)
                Text(l.sparZielErreicht, style: t.textTheme.bodyMedium)
              else if (beste.isNotEmpty)
                Text(
                  l.sparNoch(
                    euro(rest),
                    beste
                        .take(2)
                        .map(
                          (p) =>
                              '${stueckFehlend(restCent: rest, proStueckCent: beitrag(p))}× ${p.produkt.name}',
                        )
                        .join(l.oder),
                  ),
                  style: t.textTheme.bodyMedium,
                )
              else
                Text(l.sparNochOhne(euro(rest)), style: t.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
