import 'dart:math';

import 'package:flutter/material.dart';

import '../data/fragen.dart';
import '../main.dart';
import 'widgets.dart';

const _fragenProRunde = 10;

class PruefungScreen extends StatefulWidget {
  const PruefungScreen({super.key});

  @override
  State<PruefungScreen> createState() => _PruefungScreenState();
}

class _PruefungScreenState extends State<PruefungScreen> {
  final _zufall = Random();
  List<Frage>? _runde;
  List<String> _antworten = [];
  int _nummer = 0;
  int _richtig = 0;
  String? _gewaehlt;

  void _start() {
    setState(() {
      _runde = (List.of(pruefungsfragen)..shuffle(_zufall))
          .take(_fragenProRunde)
          .toList();
      _nummer = 0;
      _richtig = 0;
      _naechsteFrageVorbereiten();
    });
  }

  void _naechsteFrageVorbereiten() {
    _gewaehlt = null;
    _antworten = List.of(_runde![_nummer].antworten)..shuffle(_zufall);
  }

  void _waehlen(String antwort) {
    if (_gewaehlt != null) return;
    setState(() {
      _gewaehlt = antwort;
      if (antwort == _runde![_nummer].antworten.first) _richtig++;
    });
  }

  void _weiter() {
    setState(() {
      _nummer++;
      if (_nummer < _runde!.length) {
        _naechsteFrageVorbereiten();
      } else {
        SpeicherScope.of(context).quizErgebnis(_richtig);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fischerprüfung üben')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: switch (_runde) {
          null => _startAnsicht(context),
          final runde when _nummer >= runde.length => _ergebnis(context),
          final runde => _frage(context, runde[_nummer]),
        },
      ),
    );
  }

  Widget _startAnsicht(BuildContext context) {
    final beste = SpeicherScope.of(context).besteQuizPunkte;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.school, size: 72),
        const SizedBox(height: 16),
        Text(
          '${pruefungsfragen.length} Übungsfragen zu Fischkunde, Gewässern, '
          'Geräten, Tierschutz und Recht.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Dein Rekord: $beste von $_fragenProRunde',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _start,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Runde starten'),
        ),
        const Spacer(),
        const HinweisKarte(
          'Eigene Übungsfragen – kein offizieller Prüfungskatalog. Für die '
          'echte Prüfung brauchst du den Fischerkurs.',
        ),
      ],
    );
  }

  Widget _frage(BuildContext context, Frage frage) {
    final farben = Theme.of(context).colorScheme;
    final richtig = frage.antworten.first;
    return ListView(
      children: [
        LinearProgressIndicator(value: (_nummer + 1) / _runde!.length),
        const SizedBox(height: 8),
        Text('Frage ${_nummer + 1} von ${_runde!.length} · ${frage.thema}'),
        const SizedBox(height: 16),
        Text(frage.text, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        for (final a in _antworten)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(14),
                backgroundColor: _gewaehlt == null
                    ? null
                    : a == richtig
                        ? Colors.green.withValues(alpha: 0.25)
                        : a == _gewaehlt
                            ? farben.errorContainer
                            : null,
              ),
              onPressed: () => _waehlen(a),
              child: Text(a),
            ),
          ),
        if (_gewaehlt != null) ...[
          const SizedBox(height: 8),
          HinweisKarte(
            '${_gewaehlt == richtig ? 'Richtig! ' : 'Leider falsch. '}'
            '${frage.erklaerung}',
            icon: _gewaehlt == richtig ? Icons.check_circle : Icons.cancel,
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _weiter, child: const Text('Weiter')),
        ],
      ],
    );
  }

  Widget _ergebnis(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final gut = _richtig >= _runde!.length * 0.8;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(gut ? '🎉' : '💪', style: const TextStyle(fontSize: 64),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Text('$_richtig von ${_runde!.length} richtig',
            style: text.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(gut ? 'Petri Heil – das sitzt!' : 'Weiter üben, du schaffst das!',
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        FilledButton(onPressed: _start, child: const Text('Neue Runde')),
      ],
    );
  }
}
