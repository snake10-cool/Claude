import 'package:flutter/material.dart';

import '../main.dart';
import '../services/empfehlung.dart';
import '../widgets/buch_kachel.dart';
import 'abhaken_screen.dart';
import 'fragebogen_screen.dart';
import 'vergleich_screen.dart';
import 'start_screen.dart';

class FuerDichTab extends StatelessWidget {
  const FuerDichTab({super.key});

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final liste = speicher.empfehlungen;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Hallo ${speicher.name}! 👋', style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Diese Bücher passen zu deinem Fragebogen und deinen Bewertungen. '
          'Je mehr du bewertest, desto besser werden sie.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const FragebogenScreen(pflicht: false),
              )),
              icon: const Icon(Icons.tune),
              label: Text(speicher.fragebogenEntwurf == null ? 'Fragebogen neu machen' : 'Fragebogen fortsetzen'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AbhakenScreen())),
              icon: const Icon(Icons.checklist),
              label: const Text('Bücher abhaken'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VergleichScreen())),
              icon: const Icon(Icons.compare_arrows),
              label: const Text('Bücher gegeneinander'),
            ),
          ],
        ),
        if (liste.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Text('Du kennst schon alle Bücher im Katalog! 🎉', textAlign: TextAlign.center),
          ),
        for (final (i, e) in liste.indexed) _EmpfehlungKarte(e, platz: i + 1),
      ],
    );
  }
}

class _EmpfehlungKarte extends StatelessWidget {
  const _EmpfehlungKarte(this.empfehlung, {required this.platz});

  final Empfehlung empfehlung;
  final int platz;

  @override
  Widget build(BuildContext context) {
    final buch = empfehlung.buch;
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => buchOeffnen(context, buch.id),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BuchCover(buch, breite: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#$platz  ${buch.titel}', style: theme.textTheme.titleMedium),
                    Text('${buch.autor} · ${buch.seiten} Seiten', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Text(buch.beschreibung, maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (empfehlung.gruende.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final g in empfehlung.gruende)
                            Chip(
                              label: Text(g),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
