import 'package:app_basis/app_basis.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/typen.dart';
import '../widgets/sprach_abzeichen.dart';
import 'stapel_detail_screen.dart';

class StapelScreen extends StatelessWidget {
  const StapelScreen({super.key});

  Future<void> _neu(BuildContext context) async {
    final ergebnis = await stapelDialog(context);
    if (ergebnis == null) return;
    final (name, sprache) = ergebnis;
    final id = await db.stapelSpeichern(
      StapelTabelleCompanion.insert(
        name: name,
        sprache: sprache,
        eigen: const Value(true),
      ),
    );
    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => StapelDetailScreen(stapelId: id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.tabStapel)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _neu(context),
        icon: const Icon(Icons.add),
        label: Text(l.eigenerStapel),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([lernen, kauf]),
        builder: (context, _) => StreamBuilder<List<StapelInfo>>(
          stream: db.stapelBeobachten(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final eingebaut = snap.data!.where((s) => !s.stapel.eigen);
            final eigene = snap.data!.where((s) => s.stapel.eigen).toList();
            return ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: [
                Abschnitt(l.fertigeStapel),
                for (final s in eingebaut) _StapelKachel(s),
                Abschnitt(l.eigeneStapel),
                if (eigene.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(l.eigeneStapelLeer),
                  ),
                for (final s in eigene) _StapelKachel(s),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StapelKachel extends StatelessWidget {
  const _StapelKachel(this.info);
  final StapelInfo info;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    final s = info.stapel;
    final offen = lernen.offen(s.produkt);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Card(
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => StapelDetailScreen(stapelId: s.id),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SprachAbzeichen(s.sprache),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.name,
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!offen)
                      Icon(Icons.lock_outline, color: t.colorScheme.primary)
                    else if (info.faellig > 0)
                      Badge(label: Text('${info.faellig}')),
                  ],
                ),
                if (s.beschreibung.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    s.beschreibung,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: info.fortschritt,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Text(
                  l.stapelZahlen(info.anzahl, info.gelernt, info.gefestigt),
                  style: t.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog für Name und Sprache eines eigenen Stapels.
Future<(String, String)?> stapelDialog(
  BuildContext context, {
  String? name,
  String sprache = 'java',
}) async {
  final l = context.l;
  final c = TextEditingController(text: name);
  var gewaehlt = sprache;
  final form = GlobalKey<FormState>();
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(name == null ? l.eigenerStapel : l.stapelBearbeiten),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: c,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l.name,
                  hintText: l.stapelBeispiel,
                ),
                validator: (t) =>
                    (t ?? '').trim().isEmpty ? l.pflichtfeld : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: gewaehlt,
                decoration: InputDecoration(labelText: l.sprache),
                items: [
                  for (final s in sprachen)
                    DropdownMenuItem(value: s, child: Text(spracheName(s))),
                ],
                onChanged: (v) => setState(() => gewaehlt = v ?? gewaehlt),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.abbrechen),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(context, true);
            },
            child: Text(l.speichern),
          ),
        ],
      ),
    ),
  );
  if (ok != true) return null;
  return (c.text.trim(), gewaehlt);
}
