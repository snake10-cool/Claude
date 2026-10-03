import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/gewaesser.dart';
import '../main.dart';
import '../services/fang_dienst.dart';
import 'gewaesser_screen.dart';
import 'widgets.dart';

class Verein {
  const Verein(this.id, this.name, this.ort, this.beschreibung, this.website,
      this.gewaesserIds);

  final String id;
  final String name;
  final String ort;
  final String beschreibung;
  final String website;
  final List<String> gewaesserIds;
}

/// Vereine und Verbände der Region (öffentliche Infos – keine offiziellen
/// Vereinsseiten).
const vereine = <Verein>[
  Verein(
    'sac-mattig',
    'SAC Mattig Braunau',
    'Braunau am Inn',
    'Sportanglerclub mit Revieren an Inn, Mattig und Enknach sowie den '
        'Enknach-Teichen. Tageskarten bei Fa. Hauser und online über hejfish.',
    'https://sac-mattig.at/',
    ['inn-braunau', 'mattig', 'enknach', 'enknach-teiche'],
  ),
  Verein(
    'sac-schalchen',
    'Schalchner Angler Club (SAC)',
    'Schalchen / Mattighofen',
    'Verein mit Baggersee Pfaffstätt, Kühbach und Moserweiher sowie '
        'Strecken an der Mattig. Karten am Baggersee, bei Fotostudio Fesl '
        'oder online.',
    'https://www.sac-schalchen.com/',
    ['baggersee-pfaffstaett', 'kuehbach-moserweiher', 'mattig-schalchen',
      'schwemmbach'],
  ),
  Verein(
    'fischerinnung-mattsee',
    'Fischerinnung Mattsee',
    'Mattsee',
    'Bewirtschaftet den Mattsee im Salzburger Seenland.',
    'https://www.fischerinnung-mattsee.at/',
    ['mattsee'],
  ),
  Verein(
    'lfv-ooe',
    'Oö. Landesfischereiverband',
    'Linz (ganz OÖ)',
    'Dachverband für OÖ: Fischerprüfung, Jahresfischerkarte, '
        'Gastfischerkarte und eigene Reviere wie Inn-Braunau und Höllerersee.',
    'https://www.lfvooe.at/',
    ['inn-braunau', 'hoellerersee', 'antiesen', 'schwemmbach'],
  ),
  Verein(
    'sfv-salzburg',
    'Salzburger Fischereiverband',
    'Salzburg (ganzes Land)',
    'Landesverband für Salzburg mit Infos zu Fischerkarte, Gastkarte und '
        'Gewässern im Flachgau.',
    'http://www.fischereiverband.at/',
    ['obertrumer-see', 'fuschlsee'],
  ),
];

class VereineScreen extends StatelessWidget {
  const VereineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vereine & Verbände')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final v in vereine)
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.groups_2)),
                title: Text(v.name),
                subtitle: Text(v.ort),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => VereinDetail(v))),
              ),
            ),
          const SizedBox(height: 8),
          const HinweisKarte(
            'Infos aus öffentlichen Quellen – keine offiziellen Vereinsseiten. '
            'Bist du im Vorstand eines Vereins und willst eure Seite selbst '
            'pflegen? Schreib uns im Tab "Wünsche"!',
          ),
        ],
      ),
    );
  }
}

class VereinDetail extends StatefulWidget {
  const VereinDetail(this.verein, {super.key});

  final Verein verein;

  @override
  State<VereinDetail> createState() => _VereinDetailState();
}

class _VereinDetailState extends State<VereinDetail> {
  late final _termine = fangDienst.vereinsTermine(widget.verein.id);

  Future<void> _terminAnlegen() async {
    final text = TextEditingController();
    final datum = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Termin eintragen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: datum,
                decoration: const InputDecoration(
                    labelText: 'Datum, z. B. Sa, 12.4. 8:00')),
            TextField(
                controller: text,
                decoration: const InputDecoration(
                    labelText: 'Was? z. B. Arbeitseinsatz Enknach')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Speichern')),
        ],
      ),
    );
    if (ok != true || text.text.trim().isEmpty) return;
    await fangDienst.vereinsTerminAnlegen(
        widget.verein.id, text.text.trim(), datum.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.verein;
    final admin = KontoScope.of(context)?.istAdmin ?? false;
    final text = Theme.of(context).textTheme;
    final gewaesser =
        gewaesserListe.where((g) => v.gewaesserIds.contains(g.id)).toList();
    return Scaffold(
      appBar: AppBar(title: Text(v.name)),
      floatingActionButton: admin
          ? FloatingActionButton.extended(
              onPressed: _terminAnlegen,
              icon: const Icon(Icons.event),
              label: const Text('Termin'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(v.ort, style: text.labelLarge),
          const SizedBox(height: 8),
          Text(v.beschreibung),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: () => launchUrl(Uri.parse(v.website),
                mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Website'),
          ),
          const SizedBox(height: 16),
          Text('Gewässer', style: text.titleMedium),
          for (final g in gewaesser)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.water),
              title: Text(g.name),
              subtitle: Text(g.ort),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => GewaesserDetail(g))),
            ),
          const SizedBox(height: 16),
          Text('Termine', style: text.titleMedium),
          if (KontoScope.of(context) != null)
            StreamBuilder<List<Eintrag>>(
              stream: _termine,
              builder: (context, snap) {
                final liste = snap.data ?? const <Eintrag>[];
                if (liste.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Keine Termine eingetragen.'),
                  );
                }
                return Column(
                  children: [
                    for (final t in liste)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.event_note),
                        title: Text(t.text),
                        subtitle: t.bezug.isEmpty ? null : Text(t.bezug),
                        trailing: admin
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => fangDienst
                                    .vereinsTerminLoeschen(v.id, t.id),
                              )
                            : null,
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
