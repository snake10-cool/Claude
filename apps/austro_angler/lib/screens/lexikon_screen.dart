import 'package:flutter/material.dart';

import '../data/bilder.dart';
import '../data/fische.dart';
import '../data/gewaesser.dart';
import '../data/koeder.dart';
import '../services/wecker.dart';
import '../main.dart';
import '../models/fisch.dart';
import '../models/gewaesser.dart';
import 'gewaesser_screen.dart';
import 'widgets.dart';

/// Teilt den Merkmal-Text in einzelne Punkte (an Kommas und Satzenden).
List<String> merkmalPunkte(String text) {
  final punkte = <String>[];
  for (final satz in text.split(RegExp(r'(?<=[.!])\s+'))) {
    final teile = satz.replaceAll(RegExp(r'[.!]$'), '').split(RegExp(r',\s+'));
    // Kurze Sätze ohne Aufzählung bleiben zusammen.
    punkte.addAll(teile.where((t) => t.trim().isNotEmpty).map((t) {
      final s = t.trim();
      return s[0].toUpperCase() + s.substring(1);
    }));
  }
  return punkte;
}

/// Gewässer, in denen es diesen Fisch gibt – das nächste zu Braunau zuerst.
List<Gewaesser> gewaesserMit(Fisch fisch) =>
    gewaesserListe.where((g) => g.fischarten.contains(fisch.id)).toList()
      ..sort((a, b) => kmVonBraunau(a).compareTo(kmVonBraunau(b)));

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
          const BundeslandWahl(),
          const SizedBox(height: 8),
          for (final f in fische)
            Card(
              child: ListTile(
                leading: fischBilder[f.id] == null
                    ? const CircleAvatar(child: Icon(Icons.set_meal))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          fischBilder[f.id]!.pfad,
                          width: 56,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                title: Text(f.name),
                subtitle: Text(
                  'Schonzeit: ${f.regel(land).schonzeitText}\n'
                  'Brittelmaß: ${f.regel(land).mindestmassText} · '
                  'in ${gewaesserMit(f).length} Gewässern',
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
          if (fischBilder[fisch.id] case final bild?) ...[
            QuellenBild(bild, hoehe: 220),
            const SizedBox(height: 16),
          ],
          Text('Erkennungsmerkmale', style: text.titleMedium),
          const SizedBox(height: 4),
          for (final m in merkmalPunkte(fisch.merkmale))
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✔  '),
                  Expanded(child: Text(m)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          _Abschnitt('Lebensraum', fisch.lebensraum),
          _Abschnitt('Köder', fisch.koeder),
          if (koederTipps[fisch.id] case final tipps?) ...[
            Text('Köder-Ratgeber nach Jahreszeit', style: text.titleMedium),
            const SizedBox(height: 4),
            for (var i = 0; i < 4; i++)
              Card(
                color: i == jahreszeit(DateTime.now())
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: ListTile(
                  dense: true,
                  title: Text(jahreszeitNamen[i] +
                      (i == jahreszeit(DateTime.now()) ? '  (jetzt)' : '')),
                  subtitle: Text(tipps[i]),
                ),
              ),
            const SizedBox(height: 12),
          ],
          if (Wecker.unterstuetzt) _WeckerKnopf(fisch),
          Text('Wo gibt es ihn?', style: text.titleMedium),
          const SizedBox(height: 4),
          if (gewaesserMit(fisch).isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text('In keinem geprüften Gewässer eingetragen.'),
            )
          else ...[
            for (final g in gewaesserMit(fisch))
              Card(
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    g.typ == GewaesserTyp.fluss || g.typ == GewaesserTyp.bach
                        ? Icons.waves
                        : Icons.water,
                  ),
                  title: Text(g.name),
                  subtitle: Text('${g.typ.name} · ${g.ort} · '
                      '${kmVonBraunau(g)} km'),
                  trailing: Text(
                    g.preise.isEmpty ? '?' : g.preise.first.euroText,
                    style: text.titleSmall,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => GewaesserDetail(g)),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
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

class _WeckerKnopf extends StatefulWidget {
  const _WeckerKnopf(this.fisch);

  final Fisch fisch;

  @override
  State<_WeckerKnopf> createState() => _WeckerKnopfState();
}

class _WeckerKnopfState extends State<_WeckerKnopf> {
  bool? _an;

  @override
  void initState() {
    super.initState();
    Wecker.instanz.fische().then((f) {
      if (mounted) setState(() => _an = f.contains(widget.fisch.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final land = SpeicherScope.of(context).bundesland;
    final regel = widget.fisch.regel(land);
    if (regel.von == null || regel.bis == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: const Icon(Icons.alarm),
        title: const Row(children: [
          Flexible(child: Text('Schonzeit-Wecker')),
          SizedBox(width: 8),
          PremiumMarke(),
        ]),
        subtitle: Text('Erinnerung um 8 Uhr am Tag nach dem ${regel.bis}, wenn die '
            'Schonzeit in ${land.name} endet'),
        value: _an ?? false,
        onChanged: _an == null
            ? null
            : (_) async {
                final an =
                    await Wecker.instanz.umschalten(widget.fisch.id, land);
                if (mounted) setState(() => _an = an);
              },
      ),
    );
  }
}
