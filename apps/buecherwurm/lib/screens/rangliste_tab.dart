import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../services/speicher.dart';

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
        Text('Wer liest am meisten?', style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        const Text(
          'Punkte gibt es nur für Quiz – also nur für Bücher, die man wirklich '
          'kennt. Teile deinen Code mit Freunden und füge ihre Codes ein.',
        ),
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
