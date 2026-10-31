import 'package:flutter/material.dart';

import '../main.dart';
import '../models/buch.dart';
import '../services/vergleich.dart';
import '../widgets/buch_kachel.dart';

/// „Bücher gegeneinander": 2–15 gelesene Bücher auswählen und Thema für
/// Thema bewerten. Das Ergebnis fließt in die Empfehlungen.
class VergleichScreen extends StatefulWidget {
  const VergleichScreen({super.key});

  @override
  State<VergleichScreen> createState() => _VergleichScreenState();
}

enum _Phase { auswahl, fragen, ergebnis }

class _VergleichScreenState extends State<VergleichScreen> {
  static const maxBuecher = 15;

  var _phase = _Phase.auswahl;
  final _gewaehlt = <String>{};
  var _suche = '';
  late List<(Aspekt, List<Buch>)> _runden;
  var _runde = 0;

  /// Aspekt-ID → (Buch-ID → Wert 0–3 oder null = weiß nicht).
  final _antworten = <String, Map<String, int?>>{};
  VergleichsErgebnis? _ergebnis;

  List<Buch> _buecher() {
    final speicher = SpeicherScope.of(context);
    return [for (final id in _gewaehlt) speicher.buch(id)!];
  }

  void _starten() {
    setState(() {
      _runden = runden(_buecher());
      _runde = 0;
      _antworten.clear();
      _phase = _Phase.fragen;
    });
  }

  Future<void> _weiter() async {
    if (_runde < _runden.length - 1) {
      setState(() => _runde++);
      return;
    }
    final ergebnis = auswerten(_buecher(), _antworten);
    await SpeicherScope.of(context).vergleichUebernehmen(ergebnis.vorlieben, ergebnis.sterne);
    setState(() {
      _ergebnis = ergebnis;
      _phase = _Phase.ergebnis;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _phase != _Phase.fragen,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        setState(() {
          if (_runde > 0) {
            _runde--;
          } else {
            _phase = _Phase.auswahl;
          }
        });
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Bücher gegeneinander')),
        body: switch (_phase) {
          _Phase.auswahl => _auswahl(context),
          _Phase.fragen => _fragen(context),
          _Phase.ergebnis => _ergebnisAnsicht(context),
        },
      ),
    );
  }

  Widget _auswahl(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final theme = Theme.of(context);
    final s = _suche.toLowerCase();
    final kandidaten = speicher.eintraege.entries
        .where((e) => e.value.status != Status.wunschliste && speicher.buch(e.key) != null)
        .map((e) => speicher.buch(e.key)!)
        .where((b) => s.isEmpty || b.titel.toLowerCase().contains(s) || b.autor.toLowerCase().contains(s))
        .toList()
      ..sort((a, b) => a.titel.compareTo(b.titel));

    if (speicher.eintraege.values.where((e) => e.status != Status.wunschliste).length < 2) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Du brauchst mindestens 2 gelesene Bücher.\nHake unter „Bücher abhaken" ein paar ab, dann geht\'s los!',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'Wähle 2 bis $maxBuecher Bücher, die du gelesen hast. Dann fragen wir dich Thema für Thema, '
            'wie sie dir gefallen haben – Themen, die ein Buch nicht hat, werden dort übersprungen.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'In deinen Büchern suchen',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (t) => setState(() => _suche = t),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              for (final b in kandidaten)
                CheckboxListTile(
                  secondary: BuchCover(b, breite: 32),
                  title: Text(b.titel),
                  subtitle: Text(b.autor),
                  value: _gewaehlt.contains(b.id),
                  onChanged: (an) => setState(() {
                    if (an == true && _gewaehlt.length < maxBuecher) {
                      _gewaehlt.add(b.id);
                    } else {
                      _gewaehlt.remove(b.id);
                    }
                  }),
                ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _gewaehlt.length >= 2 ? _starten : null,
                child: Text(_gewaehlt.length < 2
                    ? 'Noch ${2 - _gewaehlt.length} Buch auswählen'
                    : '${_gewaehlt.length} Bücher vergleichen'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fragen(BuildContext context) {
    final (aspekt, buecher) = _runden[_runde];
    final werte = _antworten.putIfAbsent(aspekt.id, () => {});
    final fertig = buecher.every((b) => werte.containsKey(b.id));
    final theme = Theme.of(context);

    return Column(
      children: [
        LinearProgressIndicator(value: (_runde + 1) / _runden.length),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Thema ${_runde + 1} von ${_runden.length}', style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(aspekt.frage, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              for (final b in buecher)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            BuchCover(b, breite: 28),
                            const SizedBox(width: 10),
                            Expanded(child: Text(b.titel, style: theme.textTheme.titleSmall)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final (emoji, text, wert) in bewertungen)
                              ChoiceChip(
                                label: Text('$emoji $text'),
                                selected: werte.containsKey(b.id) && werte[b.id] == wert,
                                onSelected: (_) => setState(() => werte[b.id] = wert),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: fertig ? _weiter : null,
                child: Text(_runde == _runden.length - 1 ? 'Auswerten' : 'Weiter'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _ergebnisAnsicht(BuildContext context) {
    final e = _ergebnis!;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Deine Rangliste', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        for (final (i, (buch, wert)) in e.rangliste.indexed)
          ListTile(
            leading: CircleAvatar(child: Text(switch (i) { 0 => '🥇', 1 => '🥈', 2 => '🥉', _ => '${i + 1}' })),
            title: Text(buch.titel),
            trailing: Text('${(wert / 3 * 100).round()} %', style: theme.textTheme.titleMedium),
          ),
        if (e.sieger.isNotEmpty) ...[
          const Divider(height: 32),
          Text('Sieger je Thema', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final MapEntry(key: aspekt, value: buch) in e.sieger.entries)
            ListTile(
              dense: true,
              leading: const Icon(Icons.emoji_events_outlined),
              title: Text(aspekt.frage.replaceFirst('?', '')),
              subtitle: Text(buch.titel),
            ),
        ],
        const SizedBox(height: 16),
        Card(
          color: theme.colorScheme.secondaryContainer,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Gespeichert! Deine Empfehlungen berücksichtigen jetzt, was dir an Büchern '
                'gefällt – und Bücher ohne Sterne haben deine Gesamtbewertung bekommen.'),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => setState(() {
            _gewaehlt.clear();
            _phase = _Phase.auswahl;
          }),
          child: const Text('Neuer Vergleich'),
        ),
      ],
    );
  }
}
