import 'package:flutter/material.dart';

import '../main.dart';
import '../services/konto.dart';

/// Nur für den Admin: Quizfragen der Leser prüfen und freigeben.
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Quizfragen prüfen')),
      body: konto == null || !konto.istAdmin
          ? const Center(child: Text('Nur für den Administrator.'))
          : StreamBuilder<List<Vorschlag>>(
              stream: konto.offeneVorschlaege(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return const Center(child: Text('Vorschläge konnten nicht geladen werden.'));
                }
                final liste = snap.data;
                if (liste == null) return const Center(child: CircularProgressIndicator());
                if (liste.isEmpty) {
                  return const Center(child: Text('Keine offenen Vorschläge. 🎉'));
                }
                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: [for (final v in liste) _VorschlagKarte(konto, v)],
                );
              },
            ),
    );
  }
}

class _VorschlagKarte extends StatelessWidget {
  const _VorschlagKarte(this.konto, this.v);

  final Konto konto;
  final Vorschlag v;

  Future<void> _aktion(BuildContext context, Future<void> Function() f, String text) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await f();
      messenger.showSnackBar(SnackBar(content: Text(text)));
    } on KontoFehler catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${v.buchTitel} · von @${v.name}', style: theme.textTheme.labelMedium),
            const SizedBox(height: 6),
            Text(v.frage, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final (i, a) in v.antworten.indexed)
              Row(
                children: [
                  Icon(i == 0 ? Icons.check_circle : Icons.cancel_outlined,
                      size: 18, color: i == 0 ? Colors.green : theme.colorScheme.outline),
                  const SizedBox(width: 6),
                  Expanded(child: Text(a)),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _aktion(context, () => konto.ablehnen(v), 'Abgelehnt.'),
                  icon: const Icon(Icons.close),
                  label: const Text('Ablehnen'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => _aktion(context, () => konto.freigeben(v), 'Freigegeben – alle sehen die Frage jetzt.'),
                  icon: const Icon(Icons.check),
                  label: const Text('Freigeben'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
