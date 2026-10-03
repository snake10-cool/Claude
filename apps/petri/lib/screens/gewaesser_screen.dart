import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/fische.dart';
import '../data/gewaesser.dart';
import '../main.dart';
import '../models/gewaesser.dart';
import 'widgets.dart';

class GewaesserScreen extends StatelessWidget {
  const GewaesserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final land = SpeicherScope.of(context).bundesland;
    final liste = gewaesserListe.where((g) => g.land == land).toList();
    final karte = fischerkarten.firstWhere((k) => k.land == land);

    return Scaffold(
      appBar: AppBar(title: const Text('Wo darf ich fischen?')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Center(child: BundeslandWahl()),
          const SizedBox(height: 12),
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Was brauche ich zum Fischen?'),
              subtitle: Text(land.name),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              children: [
                for (final p in karte.punkte)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  '),
                        Expanded(child: Text(p)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          for (final g in liste) _GewaesserKachel(g),
          const SizedBox(height: 8),
          const HinweisKarte(
            'Alle Preise und Regeln ohne Gewähr. Vor dem Fischen immer die '
            'Lizenzbedingungen des Reviers lesen.',
          ),
        ],
      ),
    );
  }
}

class _GewaesserKachel extends StatelessWidget {
  const _GewaesserKachel(this.g);

  final Gewaesser g;

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: farben.primaryContainer,
          child: Icon(
            g.typ == GewaesserTyp.fluss ? Icons.waves : Icons.water,
            color: farben.onPrimaryContainer,
          ),
        ),
        title: Text(g.name),
        subtitle: Text('${g.typ.name} · ${g.ort}'),
        trailing: Text(
          g.preise.isEmpty ? '?' : g.preisKurz.split(' ').skip(1).join(' '),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GewaesserDetail(g)),
        ),
      ),
    );
  }
}

class GewaesserDetail extends StatelessWidget {
  const GewaesserDetail(this.g, {super.key});

  final Gewaesser g;

  Future<void> _navigation() async {
    final p = g.position;
    final uri = Uri.parse('geo:${p.latitude},${p.longitude}?q='
        '${p.latitude},${p.longitude}(${Uri.encodeComponent(g.name)})');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final land = SpeicherScope.of(context).bundesland;
    final heute = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text(g.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${g.typ.name} · ${g.ort} · ${g.land.name}',
              style: text.labelLarge),
          const SizedBox(height: 8),
          Text(g.beschreibung),
          if (g.hinweis != null) ...[
            const SizedBox(height: 12),
            HinweisKarte(g.hinweis!, icon: Icons.warning_amber),
          ],
          const SizedBox(height: 16),
          Text('Preise', style: text.titleMedium),
          if (g.preise.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Noch nicht bekannt – bitte beim Revier erfragen.'),
            )
          else
            for (final p in g.preise)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(p.art),
                trailing: Text(p.euroText, style: text.titleMedium),
              ),
          const SizedBox(height: 8),
          Text('Karten bekommst du hier', style: text.titleMedium),
          const SizedBox(height: 4),
          Text(g.kartenverkauf),
          const SizedBox(height: 16),
          Text('Fischarten', style: text.titleMedium),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final id in g.fischarten)
                if (fischById(id) case final f?)
                  Chip(
                    avatar: f.regel(land).istGeschont(heute) == true
                        ? const Icon(Icons.block, size: 18)
                        : null,
                    label: Text(f.name),
                  ),
            ],
          ),
          const SizedBox(height: 4),
          Text('🚫 = heute Schonzeit (${land.name})', style: text.bodySmall),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _navigation,
            icon: const Icon(Icons.directions),
            label: const Text('Hinfahren'),
          ),
          const SizedBox(height: 16),
          Text('Quelle: ${g.quelle} · Stand: ${g.stand}', style: text.bodySmall),
        ],
      ),
    );
  }
}
