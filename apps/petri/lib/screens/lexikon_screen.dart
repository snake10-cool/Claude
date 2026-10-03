import 'package:flutter/material.dart';

import '../data/fische.dart';
import '../main.dart';
import '../models/fisch.dart';
import 'widgets.dart';

class LexikonScreen extends StatelessWidget {
  const LexikonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final land = SpeicherScope.of(context).bundesland;
    final heute = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Fischlexikon')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Center(child: BundeslandWahl()),
          const SizedBox(height: 8),
          for (final f in fische)
            Card(
              child: ListTile(
                title: Text(f.name),
                subtitle: Text(
                  'Schonzeit: ${f.regel(land).schonzeitText}\n'
                  'Brittelmaß: ${f.regel(land).mindestmassText}',
                ),
                isThreeLine: true,
                trailing: _StatusPunkt(f.regel(land).istGeschont(heute)),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => FischDetail(f)),
                ),
              ),
            ),
          const SizedBox(height: 8),
          const HinweisKarte(
            '$schonzeitenStand. Einzelne Reviere haben oft strengere Regeln – '
            'die Lizenz gilt immer vor.',
          ),
        ],
      ),
    );
  }
}

class _StatusPunkt extends StatelessWidget {
  const _StatusPunkt(this.geschont);

  final bool? geschont;

  @override
  Widget build(BuildContext context) {
    final (farbe, text) = switch (geschont) {
      true => (Colors.red.shade600, 'Schonzeit'),
      false => (Colors.green.shade600, 'Offen'),
      null => (Colors.grey, '?'),
    };
    return Chip(
      label: Text(text, style: const TextStyle(color: Colors.white)),
      backgroundColor: farbe,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

class FischDetail extends StatelessWidget {
  const FischDetail(this.fisch, {super.key});

  final Fisch fisch;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(fisch.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${fisch.familie} · ${fisch.raubfisch ? 'Raubfisch' : 'Friedfisch'}',
            style: text.labelLarge,
          ),
          const SizedBox(height: 16),
          _Abschnitt('Erkennungsmerkmale', fisch.merkmale),
          _Abschnitt('Lebensraum', fisch.lebensraum),
          _Abschnitt('Köder', fisch.koeder),
          const SizedBox(height: 8),
          Text('Schonzeit & Brittelmaß', style: text.titleMedium),
          const SizedBox(height: 8),
          Table(
            border: TableBorder.all(color: Theme.of(context).dividerColor),
            columnWidths: const {0: IntrinsicColumnWidth()},
            children: [
              const TableRow(children: [
                _Zelle('', fett: true),
                _Zelle('Schonzeit', fett: true),
                _Zelle('Brittelmaß', fett: true),
              ]),
              for (final e in fisch.regeln.entries)
                TableRow(children: [
                  _Zelle(e.key.kurz, fett: true),
                  _Zelle(e.value.schonzeitText),
                  _Zelle(e.value.mindestmassText),
                ]),
            ],
          ),
          for (final e in fisch.regeln.entries)
            if (e.value.hinweis != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('${e.key.kurz}: ${e.value.hinweis}'),
              ),
          const SizedBox(height: 16),
          Text(schonzeitenStand, style: text.bodySmall),
        ],
      ),
    );
  }
}

class _Abschnitt extends StatelessWidget {
  const _Abschnitt(this.titel, this.inhalt);

  final String titel;
  final String inhalt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titel, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(inhalt),
        ],
      ),
    );
  }
}

class _Zelle extends StatelessWidget {
  const _Zelle(this.text, {this.fett = false});

  final String text;
  final bool fett;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: fett ? const TextStyle(fontWeight: FontWeight.bold) : null,
      ),
    );
  }
}
