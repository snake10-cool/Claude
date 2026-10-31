import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../models/buch.dart';
import '../services/konto.dart';
import '../widgets/buch_kachel.dart';

/// Meine Lesegruppen: gründen oder per Code beitreten.
class GruppenScreen extends StatelessWidget {
  const GruppenScreen({super.key});

  Future<String?> _eingabe(BuildContext context, String titel, String hinweis, {bool gross = false}) async {
    final feld = TextEditingController();
    final wert = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titel),
        content: TextField(
          controller: feld,
          autofocus: true,
          maxLength: gross ? 6 : 40,
          textCapitalization: gross ? TextCapitalization.characters : TextCapitalization.sentences,
          decoration: InputDecoration(hintText: hinweis),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, feld.text), child: const Text('OK')),
        ],
      ),
    );
    feld.dispose();
    return wert == null || wert.trim().isEmpty ? null : wert.trim();
  }

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    Future<void> versuch(Future<void> Function() f) async {
      try {
        await f();
      } on KontoFehler catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e.text)));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Lesegruppen')),
      body: StreamBuilder<List<Gruppe>>(
        stream: konto.meineGruppen(),
        builder: (context, snap) {
          final gruppen = snap.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Lest gemeinsam ein Buch, seht den Fortschritt der anderen und vergleicht '
                  'euch in der Gruppen-Rangliste – mit der Klasse, Familie oder Freunden.'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final name = await _eingabe(context, 'Gruppe gründen', 'z. B. Klasse 6b');
                        if (name != null) await versuch(() => konto.gruppeGruenden(name));
                      },
                      icon: const Icon(Icons.group_add),
                      label: const Text('Gründen'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final code = await _eingabe(context, 'Gruppe beitreten', '6-stelliger Code', gross: true);
                        if (code != null) await versuch(() => konto.gruppeBeitreten(code));
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Beitreten'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (snap.hasError) const Text('Gruppen konnten nicht geladen werden.'),
              if (gruppen == null && !snap.hasError) const LinearProgressIndicator(),
              if (gruppen != null && gruppen.isEmpty) const Text('Du bist noch in keiner Gruppe.'),
              for (final g in gruppen ?? const <Gruppe>[])
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.groups)),
                    title: Text(g.name),
                    subtitle: Text('${g.mitglieder.length} Mitglied(er)'
                        '${g.buchTitel == null ? '' : ' · liest „${g.buchTitel}"'}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GruppeScreen(gruppenId: g.id))),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Eine Lesegruppe: gemeinsames Buch, Fortschritt, Rangliste.
class GruppeScreen extends StatefulWidget {
  const GruppeScreen({super.key, required this.gruppenId});

  final String gruppenId;

  @override
  State<GruppeScreen> createState() => _GruppeScreenState();
}

class _GruppeScreenState extends State<GruppeScreen> {
  String? _gemeldetFuer;

  /// Eigenen Stand beim Gruppenbuch einmal pro Öffnen hochladen.
  void _meldenFallsNoetig(Konto konto, Gruppe g) {
    final buchId = g.buchId;
    if (buchId == null || _gemeldetFuer == buchId) return;
    _gemeldetFuer = buchId;
    final speicher = SpeicherScope.of(context);
    final e = speicher.eintraege[buchId];
    final buch = speicher.buch(buchId);
    konto
        .fortschrittMelden(g.id, e?.seite ?? 0, buch?.seiten ?? 0, e?.status == Status.gelesen)
        .catchError((_) {});
  }

  Future<void> _buchWaehlen(Konto konto, Gruppe g) async {
    final buch = await showModalBottomSheet<Buch>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _BuchAuswahl(),
    );
    if (buch != null) {
      _gemeldetFuer = null;
      await konto.gruppenBuchSetzen(g.id, buch).catchError((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context)!;
    final theme = Theme.of(context);
    return StreamBuilder<Gruppe>(
      stream: konto.gruppe(widget.gruppenId),
      builder: (context, snap) {
        final g = snap.data;
        if (g == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
        }
        _meldenFallsNoetig(konto, g);
        return Scaffold(
          appBar: AppBar(
            title: Text(g.name),
            actions: [
              IconButton(
                tooltip: 'Gruppe verlassen',
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await konto.gruppeVerlassen(g.id).catchError((_) {});
                  navigator.pop();
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.key),
                  title: Text('Beitrittscode: ${g.code}', style: theme.textTheme.titleMedium),
                  subtitle: const Text('Schick ihn deinen Freunden'),
                  trailing: IconButton(
                    tooltip: 'Kopieren',
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                          text: 'Komm in meine Bücherwurm-Lesegruppe „${g.name}"! Code: ${g.code}'));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kopiert!')));
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Gemeinsames Buch', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              if (g.buchTitel == null)
                OutlinedButton.icon(
                  onPressed: () => _buchWaehlen(konto, g),
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Buch auswählen'),
                )
              else
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _cover(context, g.buchId!),
                  title: Text(g.buchTitel!),
                  trailing: TextButton(onPressed: () => _buchWaehlen(konto, g), child: const Text('Ändern')),
                ),
              if (g.buchId != null) ...[
                const SizedBox(height: 8),
                StreamBuilder<List<GruppenFortschritt>>(
                  stream: konto.fortschritte(g.id),
                  builder: (context, s) {
                    final liste = s.data ?? const [];
                    if (liste.isEmpty) return const Text('Noch kein Fortschritt gemeldet.');
                    return Column(
                      children: [
                        for (final f in liste)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('@${f.name}'),
                            subtitle: f.gelesen
                                ? const Text('✅ Fertig gelesen')
                                : f.seiten > 0
                                    ? LinearProgressIndicator(value: (f.seite / f.seiten).clamp(0, 1).toDouble())
                                    : Text(f.seite > 0 ? 'Seite ${f.seite}' : 'Noch nicht angefangen'),
                            trailing: f.seiten > 0 && !f.gelesen ? Text('${(f.seite / f.seiten * 100).round()} %') : null,
                          ),
                      ],
                    );
                  },
                ),
                Text('Dein Stand kommt von „Seite X von Y" beim Buch.', style: theme.textTheme.bodySmall),
              ],
              const Divider(height: 32),
              Text('Gruppen-Rangliste', style: theme.textTheme.titleMedium),
              FutureBuilder<List<Spieler>>(
                key: ValueKey(g.mitglieder.join(',')),
                future: konto.staende(g.mitglieder),
                builder: (context, s) {
                  final liste = [...?s.data]..sort((a, b) => b.punkte.compareTo(a.punkte));
                  if (s.connectionState != ConnectionState.done) return const LinearProgressIndicator();
                  return Column(
                    children: [
                      for (final (i, sp) in liste.indexed)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(child: Text(switch (i) { 0 => '🥇', 1 => '🥈', 2 => '🥉', _ => '${i + 1}' })),
                          title: Text('@${sp.name}'),
                          subtitle: Text('${sp.bewiesen} Bücher bewiesen'),
                          trailing: Text('${sp.punkte}', style: theme.textTheme.titleMedium),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget? _cover(BuildContext context, String buchId) {
  final buch = SpeicherScope.of(context).buch(buchId);
  return buch == null ? null : BuchCover(buch, breite: 32);
}

class _BuchAuswahl extends StatefulWidget {
  const _BuchAuswahl();

  @override
  State<_BuchAuswahl> createState() => _BuchAuswahlState();
}

class _BuchAuswahlState extends State<_BuchAuswahl> {
  var _text = '';

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final s = _text.toLowerCase();
    final treffer = s.length < 2
        ? <Buch>[]
        : speicher.alleBuecher
            .where((b) => b.titel.toLowerCase().contains(s) || b.autor.toLowerCase().contains(s))
            .take(40)
            .toList();
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Titel oder Autor'),
              onChanged: (t) => setState(() => _text = t),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final b in treffer)
                  ListTile(
                    leading: BuchCover(b, breite: 30),
                    title: Text(b.titel),
                    subtitle: Text(b.autor),
                    onTap: () => Navigator.of(context).pop(b),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
