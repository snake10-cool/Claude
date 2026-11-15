import 'package:flutter/material.dart';

import '../main.dart';
import '../models/meldung.dart';
import '../services/konto.dart';

/// Nur für den Admin: Quizfragen der Leser prüfen und gemeldete Fragen ansehen.
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context);
    if (konto == null || !konto.istAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: const Center(child: Text('Nur für den Administrator.')),
      );
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin'),
          bottom: const TabBar(tabs: [Tab(text: 'Vorgeschlagene Fragen'), Tab(text: 'Gemeldete Fragen')]),
        ),
        body: TabBarView(
          children: [
            _Liste<Vorschlag>(
              stream: konto.offeneVorschlaege(),
              leer: 'Keine offenen Vorschläge. 🎉',
              karte: (v) => _VorschlagKarte(konto, v),
            ),
            _Liste<FrageMeldung>(
              stream: konto.offeneMeldungen(),
              leer: 'Keine gemeldeten Fragen. 🎉',
              karte: (m) => _MeldungKarte(konto, m),
            ),
          ],
        ),
      ),
    );
  }
}

class _Liste<T> extends StatelessWidget {
  const _Liste({required this.stream, required this.leer, required this.karte});

  final Stream<List<T>> stream;
  final String leer;
  final Widget Function(T) karte;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<T>>(
        stream: stream,
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Konnte nicht geladen werden.'));
          final liste = snap.data;
          if (liste == null) return const Center(child: CircularProgressIndicator());
          if (liste.isEmpty) return Center(child: Text(leer));
          return ListView(padding: const EdgeInsets.all(12), children: [for (final x in liste) karte(x)]);
        },
      );
}

Future<void> _aktion(BuildContext context, Future<void> Function() f, String text) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await f();
    messenger.showSnackBar(SnackBar(content: Text(text)));
  } on KontoFehler catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.text)));
  }
}

class _MeldungKarte extends StatelessWidget {
  const _MeldungKarte(this.konto, this.m);

  final Konto konto;
  final FrageMeldung m;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${m.buchTitel} · von @${m.name}', style: theme.textTheme.labelMedium),
            const SizedBox(height: 6),
            Text(m.frage, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('Gewertet als richtig: ${m.richtig}'),
            if (m.gewaehlt.isNotEmpty && m.gewaehlt != m.richtig) Text('Angeklickt: ${m.gewaehlt}'),
            const SizedBox(height: 8),
            Text('⚑ ${m.grundText}', style: theme.textTheme.titleSmall),
            if (m.text.isNotEmpty) Text('„${m.text}“'),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _aktion(context, () => konto.meldungErledigt(m), 'Als erledigt markiert.'),
                icon: const Icon(Icons.done),
                label: const Text('Erledigt'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VorschlagKarte extends StatelessWidget {
  const _VorschlagKarte(this.konto, this.v);

  final Konto konto;
  final Vorschlag v;

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
