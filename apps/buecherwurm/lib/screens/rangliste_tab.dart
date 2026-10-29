import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../services/konto.dart';
import '../services/speicher.dart';
import 'challenges_screen.dart';
import 'konto_screen.dart';

/// Rangliste mit Freunden. Ohne Server: Jeder teilt seinen Punkte-Code
/// (z. B. per WhatsApp) und die anderen fügen ihn hier ein.
class RanglisteTab extends StatelessWidget {
  const RanglisteTab({super.key});

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final theme = Theme.of(context);
    final ich = Freund(speicher.name, speicher.punkte, speicher.bewiesen, DateTime.now());
    final liste = [ich, ...speicher.freunde.where((f) => f.name != speicher.name)]
      ..sort((a, b) => b.punkte != a.punkte ? b.punkte.compareTo(a.punkte) : b.bewiesen.compareTo(a.bewiesen));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: theme.colorScheme.secondaryContainer,
          child: ListTile(
            leading: const Text('🏁', style: TextStyle(fontSize: 28)),
            title: const Text('Monats-Challenges'),
            subtitle: Text('3 Aufgaben diesen Monat – ${speicher.bonusPunkte} Bonuspunkte bisher'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChallengesScreen())),
          ),
        ),
        const SizedBox(height: 12),
        Text('Wer liest am meisten?', style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        const Text(
          'Punkte gibt es nur für Quiz – also nur für Bücher, die man wirklich kennt.',
        ),
        if (KontoScope.of(context) case final konto?) ...[
          const SizedBox(height: 12),
          _OnlineRangliste(konto),
          const SizedBox(height: 24),
          Text('Ohne Konto: per Code', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text('Für Freunde ohne Konto: Code teilen und ihre Codes einfügen.'),
        ] else
          const Text('Teile deinen Code mit Freunden und füge ihre Codes ein.'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                    text: 'Mein Bücherwurm-Stand: ${speicher.punkte} Punkte, '
                        '${speicher.bewiesen} Bücher. Code: ${speicher.meinCode}',
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Code kopiert – jetzt in WhatsApp & Co. einfügen.'),
                  ));
                },
                icon: const Icon(Icons.share),
                label: const Text('Mein Code'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _codeEingeben(context),
                icon: const Icon(Icons.group_add),
                label: const Text('Freund-Code'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final (i, f) in liste.indexed)
          Card(
            color: identical(f, ich) ? theme.colorScheme.primaryContainer : null,
            child: ListTile(
              leading: CircleAvatar(
                child: Text(switch (i) { 0 => '🥇', 1 => '🥈', 2 => '🥉', _ => '${i + 1}' }),
              ),
              title: Text(identical(f, ich) ? '${f.name} (du)' : f.name),
              subtitle: Text('${f.bewiesen} Bücher bewiesen'
                  '${identical(f, ich) ? '' : ' · Stand ${f.datum.day}.${f.datum.month}.'}'),
              trailing: Text('${f.punkte}', style: theme.textTheme.titleLarge),
              onLongPress: identical(f, ich)
                  ? null
                  : () async {
                      final weg = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('${f.name} entfernen?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Nein')),
                            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Entfernen')),
                          ],
                        ),
                      );
                      if (weg == true) speicher.freundEntfernen(f.name);
                    },
            ),
          ),
        const SizedBox(height: 16),
        Text(
          '🤝 Fair Play: Alles beruht auf Vertrauen. Während eines Quiz läuft die '
          'Zeit, und wer die App verlässt, verliert die Frage – aber am Ende zählt '
          'euer Ehrenwort.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Future<void> _codeEingeben(BuildContext context) async {
    final speicher = SpeicherScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final feld = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Code von Freund'),
        content: TextField(
          controller: feld,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Ganze Nachricht oder Code einfügen (BW1-…)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, feld.text), child: const Text('Hinzufügen')),
        ],
      ),
    );
    feld.dispose();
    if (code == null || code.trim().isEmpty) return;
    final freund = await speicher.codeEinlesen(code);
    messenger.showSnackBar(SnackBar(
      content: Text(freund == null
          ? 'Ungültiger Code.'
          : '${freund.name} ist dabei: ${freund.punkte} Punkte.'),
    ));
  }
}

/// Rangliste über Firebase: Freunde (per @Name) und die Top 50 weltweit.
class _OnlineRangliste extends StatefulWidget {
  const _OnlineRangliste(this.konto);

  final Konto konto;

  @override
  State<_OnlineRangliste> createState() => _OnlineRanglisteState();
}

class _OnlineRanglisteState extends State<_OnlineRangliste> {
  var _weltweit = false;
  late Stream<List<String>> _freunde = widget.konto.freundUids();
  late final Stream<List<Spieler>> _top = widget.konto.weltweit();
  String? _uid;

  @override
  Widget build(BuildContext context) {
    final konto = widget.konto;
    final theme = Theme.of(context);
    if (!konto.angemeldet) {
      return Card(
        color: theme.colorScheme.secondaryContainer,
        child: ListTile(
          leading: const Icon(Icons.public),
          title: const Text('Online-Rangliste'),
          subtitle: const Text('Erstelle ein Konto und tritt gegen Freunde und alle Leser an.'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const KontoScreen())),
        ),
      );
    }
    // Nach An- oder Abmelden die Freundesliste des neuen Kontos abonnieren.
    if (_uid != konto.nutzer!.uid) {
      _uid = konto.nutzer!.uid;
      _freunde = konto.freundUids();
    }
    final ich = konto.nutzer!.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, icon: Icon(Icons.group), label: Text('Freunde')),
                  ButtonSegment(value: true, icon: Icon(Icons.public), label: Text('Weltweit')),
                ],
                selected: {_weltweit},
                onSelectionChanged: (s) => setState(() => _weltweit = s.first),
              ),
            ),
            IconButton(
              tooltip: 'Konto',
              icon: const Icon(Icons.manage_accounts_outlined),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const KontoScreen())),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_weltweit)
          StreamBuilder<List<Spieler>>(
            stream: _top,
            builder: (context, snap) => _liste(snap.data, ich, fehler: snap.hasError),
          )
        else ...[
          StreamBuilder<List<String>>(
            stream: _freunde,
            builder: (context, snap) {
              final uids = snap.data;
              if (uids == null) return _liste(null, ich, fehler: snap.hasError);
              return FutureBuilder<List<Spieler>>(
                // Schlüssel: neu laden, wenn sich die Freundesliste ändert.
                key: ValueKey(uids.join(',')),
                future: konto.staende([ich, ...uids]),
                builder: (context, s) => _liste(s.data, ich, fehler: s.hasError, freunde: true),
              );
            },
          ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () => _freundHinzufuegen(konto),
            icon: const Icon(Icons.person_add_alt),
            label: const Text('Freund per @Name hinzufügen'),
          ),
          if (konto.name != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Dein @Name: @${konto.name}', textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
            ),
        ],
      ],
    );
  }

  Widget _liste(List<Spieler>? spieler, String ich, {bool fehler = false, bool freunde = false}) {
    if (fehler) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Die Rangliste konnte nicht geladen werden. Bist du online?', textAlign: TextAlign.center),
      );
    }
    if (spieler == null) {
      return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
    }
    final sortiert = [...spieler]..sort((a, b) => b.punkte.compareTo(a.punkte));
    if (freunde && sortiert.length <= 1) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('Noch keine Freunde. Füge sie über ihren @Namen hinzu!', textAlign: TextAlign.center),
      );
    }
    final theme = Theme.of(context);
    return Column(
      children: [
        for (final (i, s) in sortiert.indexed)
          Card(
            color: s.uid == ich ? theme.colorScheme.primaryContainer : null,
            child: ListTile(
              leading: CircleAvatar(child: Text(switch (i) { 0 => '🥇', 1 => '🥈', 2 => '🥉', _ => '${i + 1}' })),
              title: Text(s.uid == ich ? '@${s.name} (du)' : '@${s.name}'),
              subtitle: Text('${s.bewiesen} bewiesen · ${s.gelesen} gelesen'),
              trailing: Text('${s.punkte}', style: theme.textTheme.titleLarge),
              onLongPress: !freunde || s.uid == ich ? null : () => _freundEntfernen(s),
            ),
          ),
      ],
    );
  }

  Future<void> _freundHinzufuegen(Konto konto) async {
    final messenger = ScaffoldMessenger.of(context);
    final feld = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Freund hinzufügen'),
        content: TextField(
          controller: feld,
          autofocus: true,
          autocorrect: false,
          decoration: const InputDecoration(prefixText: '@', hintText: 'name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, feld.text), child: const Text('Hinzufügen')),
        ],
      ),
    );
    feld.dispose();
    if (name == null || name.trim().isEmpty) return;
    try {
      await konto.freundHinzufuegen(name);
      messenger.showSnackBar(SnackBar(content: Text('@${nameNormal(name)} ist jetzt dein Freund.')));
    } on KontoFehler catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.text)));
    }
  }

  Future<void> _freundEntfernen(Spieler s) async {
    final weg = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('@${s.name} entfernen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Nein')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Entfernen')),
        ],
      ),
    );
    if (weg == true) await widget.konto.freundEntfernen(s.uid).catchError((_) {});
  }
}
