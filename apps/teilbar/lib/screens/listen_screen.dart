import 'package:app_basis/app_basis.dart';
import 'package:app_werbung/app_werbung.dart';
import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../dienste.dart';
import '../l10n/l.dart';
import 'liste_screen.dart';

/// Einkaufslisten: für mich, für Gruppen, „Ich nehm was mit“.
class ListenScreen extends StatelessWidget {
  const ListenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.tabListen)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => neueListe(context),
        icon: const Icon(Icons.add),
        label: Text(l.neueListe),
      ),
      bottomNavigationBar: WerbeBanner(dienst: werbung),
      body: StreamBuilder<List<ListeInfo>>(
        stream: db.listenBeobachten(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final listen = snap.data!
              .where((i) => i.liste.art != 'packliste')
              .toList();
          if (listen.isEmpty) {
            return LeerHinweis(
              symbol: Icons.shopping_cart_outlined,
              titel: l.keineListen,
              text: l.keineListenText,
              knopf: l.neueListe,
              aktion: () => neueListe(context),
            );
          }
          final eigene = listen.where((i) => i.gruppe == null).toList();
          final nachGruppe = <String, List<ListeInfo>>{};
          for (final i in listen.where((i) => i.gruppe != null)) {
            nachGruppe.putIfAbsent(i.gruppe!.name, () => []).add(i);
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              if (eigene.isNotEmpty) ...[
                Abschnitt(l.fuerMich),
                for (final i in eigene) ListenKachel(i),
              ],
              for (final e in nachGruppe.entries) ...[
                Abschnitt(e.key),
                for (final i in e.value) ListenKachel(i),
              ],
            ],
          );
        },
      ),
    );
  }
}

class ListenKachel extends StatelessWidget {
  const ListenKachel(this.info, {super.key});
  final ListeInfo info;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    final li = info.liste;
    final fertig = info.gesamt > 0 && info.offen == 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Text(li.symbol, style: const TextStyle(fontSize: 30)),
          title: Text(
            li.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            info.gesamt == 0
                ? l.leer
                : fertig
                ? l.allesErledigt
                : l.offenVon(info.offen, info.gesamt),
          ),
          trailing: info.gruppe?.online == true
              ? Icon(Icons.cloud_done_outlined, color: t.colorScheme.primary)
              : const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ListeScreen(listeId: li.id),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog: neue Liste (Name, für wen, Art).
Future<void> neueListe(BuildContext context, {String art = 'einkauf'}) async {
  final l = context.l;
  final gruppen = await db.gruppenLaden();
  if (!context.mounted) return;
  final name = TextEditingController(text: art == 'einkauf' ? l.einkauf : '');
  String? gruppeId;
  var mitnehmen = false;
  String? fuer;
  List<Person> personen = const [];
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.neueListe, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextFormField(
                controller: name,
                autofocus: true,
                decoration: InputDecoration(labelText: l.name),
                validator: (t) =>
                    (t ?? '').trim().isEmpty ? l.pflichtfeld : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: gruppeId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l.werSiehtDieListe),
                items: [
                  DropdownMenuItem(value: null, child: Text(l.nurIch)),
                  for (final g in gruppen)
                    DropdownMenuItem(value: g.id, child: Text(g.name)),
                ],
                onChanged: (v) async {
                  final p = v == null
                      ? const <Person>[]
                      : await db.personenLaden(v);
                  setState(() {
                    gruppeId = v;
                    personen = p;
                    if (v == null) mitnehmen = false;
                    fuer = null;
                  });
                },
              ),
              if (gruppen.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    l.gruppeFuerTeilen,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              if (gruppeId != null) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.ichNehmWasMit),
                  subtitle: Text(l.ichNehmWasMitText),
                  value: mitnehmen,
                  onChanged: (v) => setState(() => mitnehmen = v),
                ),
                if (mitnehmen)
                  DropdownButtonFormField<String>(
                    initialValue: fuer,
                    decoration: InputDecoration(labelText: l.fuerWen),
                    items: [
                      for (final p in personen)
                        DropdownMenuItem(value: p.id, child: Text(p.name)),
                    ],
                    validator: (v) => v == null ? l.pflichtfeld : null,
                    onChanged: (v) => setState(() => fuer = v),
                  ),
              ],
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
  );
  if (ok != true) return;
  final id = await db.listeAnlegen(
    name: name.text.trim(),
    art: mitnehmen ? 'mitnehmen' : art,
    symbol: mitnehmen ? '🛍️' : '🛒',
    gruppeId: gruppeId,
    fuerPersonId: mitnehmen ? fuer : null,
  );
  if (context.mounted) {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => ListeScreen(listeId: id)));
  }
}
