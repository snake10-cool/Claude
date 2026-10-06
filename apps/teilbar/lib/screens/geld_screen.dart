import 'package:app_basis/app_basis.dart';
import 'package:app_werbung/app_werbung.dart';
import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../dienste.dart';
import '../l10n/l.dart';
import '../widgets/format.dart';
import 'beitreten_screen.dart';
import 'gruppe_screen.dart';
import 'rechner_screen.dart';

/// Gruppen mit Ausgaben und der Rechnungsrechner.
class GeldScreen extends StatelessWidget {
  const GeldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.tabGeld),
        actions: [
          IconButton(
            tooltip: l.beitreten,
            icon: const Icon(Icons.group_add_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const BeitretenScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => gruppeAnlegen(context),
        icon: const Icon(Icons.add),
        label: Text(l.neueGruppe),
      ),
      bottomNavigationBar: WerbeBanner(dienst: werbung),
      body: StreamBuilder<List<Gruppe>>(
        stream: db.gruppenBeobachten(),
        builder: (context, snap) {
          final gruppen = snap.data ?? const <Gruppe>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            children: [
              Card(
                color: t.colorScheme.secondaryContainer,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const Icon(Icons.calculate_outlined, size: 32),
                  title: Text(
                    l.rechner,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(l.rechnerText),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RechnerScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (snap.hasData && gruppen.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: LeerHinweis(
                    symbol: Icons.groups_outlined,
                    titel: l.keineGruppen,
                    text: l.keineGruppenText,
                  ),
                ),
              for (final g in gruppen) _GruppenKarte(g),
            ],
          );
        },
      ),
    );
  }
}

class _GruppenKarte extends StatelessWidget {
  const _GruppenKarte(this.g);
  final Gruppe g;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: StreamBuilder<Map<String, int>>(
          stream: db.saldenBeobachten(g.id),
          builder: (context, s) {
            final mein = g.ichPersonId == null ? null : s.data?[g.ichPersonId];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: Text(
                gruppenSymbol(g.art),
                style: const TextStyle(fontSize: 30),
              ),
              title: Text(
                g.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                mein == null
                    ? (g.online ? l.geteilt : l.nurAufDiesemGeraet)
                    : mein == 0
                    ? l.duBistQuitt
                    : mein > 0
                    ? l.duBekommst(euro(mein))
                    : l.duSchuldest(euro(-mein)),
              ),
              trailing: Icon(
                g.online ? Icons.cloud_done_outlined : Icons.chevron_right,
                color: g.online ? t.colorScheme.primary : null,
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => GruppeScreen(gruppeId: g.id),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

String gruppenSymbol(String art) => switch (art) {
  'wg' => '🏠',
  'familie' => '👨‍👩‍👧',
  'urlaub' => '✈️',
  'essen' => '🍽️',
  _ => '👥',
};

/// Neue Gruppe: Name, Art, mein Name, weitere Personen.
Future<String?> gruppeAnlegen(BuildContext context) async {
  final l = context.l;
  final anzahl = (await db.gruppenLaden()).length;
  if (!context.mounted) return null;
  if (!kauf.istPro && anzahl >= gratisGruppen) {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.workspace_premium),
        title: Text(l.grenzeErreicht),
        content: Text(l.grenzeGruppen(gratisGruppen)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.ok),
          ),
        ],
      ),
    );
    return null;
  }
  final name = TextEditingController();
  final ich = TextEditingController(text: profil.name);
  final weitere = TextEditingController();
  var art = 'wg';
  final form = GlobalKey<FormState>();
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.neueGruppe,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (a, text) in [
                      ('wg', l.artWg),
                      ('familie', l.artFamilie),
                      ('urlaub', l.artUrlaub),
                      ('essen', l.artEssen),
                      ('sonst', l.artSonst),
                    ])
                      ChoiceChip(
                        label: Text('${gruppenSymbol(a)} $text'),
                        selected: art == a,
                        onSelected: (_) => setState(() => art = a),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: l.gruppenName,
                    hintText: l.gruppenNameBeispiel,
                  ),
                  validator: (t) =>
                      (t ?? '').trim().isEmpty ? l.pflichtfeld : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ich,
                  decoration: InputDecoration(labelText: l.deinName),
                  validator: (t) =>
                      (t ?? '').trim().isEmpty ? l.pflichtfeld : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: weitere,
                  decoration: InputDecoration(
                    labelText: l.weiterePersonen,
                    helperText: l.weiterePersonenHilfe,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (form.currentState!.validate()) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text(l.anlegen),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  if (ok != true) return null;
  if (profil.name.isEmpty) await profil.nameSetzen(ich.text);
  final id = await db.gruppeAnlegen(
    name: name.text.trim(),
    art: art,
    meinName: ich.text.trim(),
    weitere: [
      for (final n in weitere.text.split(','))
        if (n.trim().isNotEmpty) n.trim(),
    ],
  );
  if (context.mounted) {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => GruppeScreen(gruppeId: id)));
  }
  return id;
}
