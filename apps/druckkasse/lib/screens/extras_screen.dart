import 'package:app_basis/app_basis.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../l10n/l.dart';
import '../widgets/allgemein.dart';
import '../widgets/format.dart';

/// Extras wie Verpackung, Schlüsselringe, Magnete.
class ExtrasScreen extends StatelessWidget {
  const ExtrasScreen({super.key});

  Future<void> _bearbeiten(BuildContext context, [Extra? e]) async {
    final l = context.l;
    final name = TextEditingController(text: e?.name);
    final kosten = TextEditingController(
      text: e == null ? '' : euroFeld(e.kostenCent),
    );
    final form = GlobalKey<FormState>();
    final aktion = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(e == null ? l.extraAnlegen : l.extraBearbeiten),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l.name,
                  hintText: l.extraBeispiel,
                ),
                validator: (t) =>
                    (t ?? '').trim().isEmpty ? l.pflichtfeld : null,
              ),
              const SizedBox(height: 12),
              EuroFeld(
                controller: kosten,
                label: l.kostenProStueckFeld,
                pflicht: true,
              ),
            ],
          ),
        ),
        actions: [
          if (e != null)
            TextButton(
              onPressed: () => Navigator.pop(context, 'loeschen'),
              child: Text(l.loeschen),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.abbrechen),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(context, 'ok');
            },
            child: Text(l.speichern),
          ),
        ],
      ),
    );
    if (aktion == 'ok') {
      await db.extraSpeichern(
        ExtraTabelleCompanion(
          id: e == null ? const Value.absent() : Value(e.id),
          name: Value(name.text.trim()),
          kostenCent: Value(parseEuro(kosten.text) ?? 0),
        ),
      );
    } else if (aktion == 'loeschen') {
      await db.extraArchivieren(e!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.extras)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _bearbeiten(context),
        icon: const Icon(Icons.add),
        label: Text(l.extraAnlegen),
      ),
      body: StreamBuilder<List<Extra>>(
        stream: db.extrasBeobachten(),
        builder: (context, snap) {
          final liste = snap.data ?? const <Extra>[];
          if (snap.hasData && liste.isEmpty) {
            return LeerHinweis(
              symbol: Icons.redeem,
              titel: l.keineExtrasTitel,
              text: l.keineExtrasText,
              knopf: l.extraAnlegen,
              aktion: () => _bearbeiten(context),
            );
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              for (final e in liste)
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.redeem)),
                  title: Text(e.name),
                  trailing: Text(
                    euro(e.kostenCent),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  onTap: () => _bearbeiten(context, e),
                ),
            ],
          );
        },
      ),
    );
  }
}
