import 'dart:math';

import 'package:flutter/material.dart';

import '../main.dart';
import '../models/lehrplan.dart';
import '../services/fortschritt.dart';

const _aufgabenProRunde = 10;

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.thema, required this.farbe});

  final Thema thema;
  final Color farbe;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _zufall = Random();
  int _nummer = 0;
  int _richtig = 0;
  late Aufgabe _aufgabe;
  late List<String> _antworten;
  String? _gewaehlt;
  final _gestellt = <String>{};

  @override
  void initState() {
    super.initState();
    _neueAufgabe();
  }

  /// Zieht eine neue Aufgabe und vermeidet nach Möglichkeit Wiederholungen.
  void _neueAufgabe() {
    var a = widget.thema.generator(_zufall);
    for (var i = 0; i < 20 && _gestellt.contains(a.frage + a.richtig); i++) {
      a = widget.thema.generator(_zufall);
    }
    _gestellt.add(a.frage + a.richtig);
    _aufgabe = a;
    _antworten = a.gemischt(_zufall);
    _gewaehlt = null;
  }

  void _waehlen(String antwort) {
    if (_gewaehlt != null) return;
    setState(() {
      _gewaehlt = antwort;
      if (antwort == _aufgabe.richtig) _richtig++;
    });
  }

  void _weiter() {
    if (_nummer + 1 >= _aufgabenProRunde) {
      FortschrittScope.of(context)
          .rundeBeendet(widget.thema.id, _richtig, _aufgabenProRunde);
    }
    setState(() {
      _nummer++;
      if (_nummer < _aufgabenProRunde) _neueAufgabe();
    });
  }

  void _nochmal() {
    setState(() {
      _nummer = 0;
      _richtig = 0;
      _gestellt.clear();
      _neueAufgabe();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.thema.titel),
        backgroundColor: widget.farbe,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _nummer >= _aufgabenProRunde ? _ergebnis() : _frage(),
        ),
      ),
    );
  }

  Widget _frage() {
    final text = Theme.of(context).textTheme;
    final farben = Theme.of(context).colorScheme;
    return ListView(
      children: [
        LinearProgressIndicator(
          value: (_nummer + 1) / _aufgabenProRunde,
          color: widget.farbe,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        Text('Aufgabe ${_nummer + 1} von $_aufgabenProRunde'),
        const SizedBox(height: 24),
        Text(_aufgabe.frage, style: text.headlineSmall,
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        for (final a in _antworten)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: _gewaehlt == null
                    ? null
                    : a == _aufgabe.richtig
                        ? Colors.green.shade400
                        : a == _gewaehlt
                            ? farben.error
                            : null,
                foregroundColor: _gewaehlt != null &&
                        (a == _aufgabe.richtig || a == _gewaehlt)
                    ? Colors.white
                    : null,
              ),
              onPressed: () => _waehlen(a),
              child: Text(a, style: const TextStyle(fontSize: 18)),
            ),
          ),
        if (_gewaehlt != null) ...[
          const SizedBox(height: 8),
          Text(
            _gewaehlt == _aufgabe.richtig
                ? 'Super! 🎉'
                : 'Richtig wäre: ${_aufgabe.richtig}',
            style: text.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (_aufgabe.erklaerung != null)
            Text(_aufgabe.erklaerung!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: widget.farbe),
            onPressed: _weiter,
            child: const Text('Weiter'),
          ),
        ],
      ],
    );
  }

  Widget _ergebnis() {
    final text = Theme.of(context).textTheme;
    final sterne = Fortschritt.sterneFuer(_richtig, _aufgabenProRunde);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          List.generate(3, (i) => i < sterne ? '⭐' : '☆').join(' '),
          style: const TextStyle(fontSize: 48),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text('$_richtig von $_aufgabenProRunde richtig',
            style: text.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          switch (sterne) {
            3 => 'Perfekt, du bist ein echter Lernfuchs! 🦊',
            2 => 'Sehr gut gemacht!',
            1 => 'Gut! Mit etwas Übung schaffst du 3 Sterne.',
            _ => 'Nicht aufgeben – probier es gleich nochmal!',
          },
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: widget.farbe),
          onPressed: _nochmal,
          child: const Text('Nochmal'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Zurück zu den Themen'),
        ),
      ],
    );
  }
}
