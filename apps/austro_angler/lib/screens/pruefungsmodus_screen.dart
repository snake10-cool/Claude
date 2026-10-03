import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/fragen.dart';
import 'widgets.dart';

const _anzahl = 25;
const _zeit = Duration(minutes: 15);

/// Wie eine echte Prüfung: 25 Fragen, 15 Minuten, Auswertung erst am Ende.
class PruefungsModusScreen extends StatefulWidget {
  const PruefungsModusScreen({super.key});

  @override
  State<PruefungsModusScreen> createState() => _PruefungsModusScreenState();
}

class _PruefungsModusScreenState extends State<PruefungsModusScreen> {
  final _zufall = Random();
  late final List<Frage> _fragen =
      (List.of(pruefungsfragen)..shuffle(_zufall)).take(_anzahl).toList();
  late final List<List<String>> _antworten = [
    for (final f in _fragen) List.of(f.antworten)..shuffle(_zufall),
  ];
  late final List<String?> _gewaehlt = List.filled(_fragen.length, null);
  int _nummer = 0;
  bool _fertig = false;
  late final DateTime _ende = DateTime.now().add(_zeit);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (DateTime.now().isAfter(_ende)) _abgeben();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _abgeben() {
    _timer?.cancel();
    setState(() => _fertig = true);
  }

  int get _richtig => [
        for (var i = 0; i < _fragen.length; i++)
          if (_gewaehlt[i] == _fragen[i].antworten.first) 1,
      ].length;

  @override
  Widget build(BuildContext context) {
    final rest = _ende.difference(DateTime.now());
    final minuten = rest.isNegative ? 0 : rest.inMinutes;
    final sekunden = rest.isNegative ? 0 : rest.inSeconds % 60;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prüfungsmodus'),
        actions: [
          if (!_fertig)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '⏱ $minuten:${sekunden.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
        ],
      ),
      body: _fertig ? _ergebnis(context) : _frage(context),
    );
  }

  Widget _frage(BuildContext context) {
    final f = _fragen[_nummer];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LinearProgressIndicator(value: (_nummer + 1) / _fragen.length),
        const SizedBox(height: 8),
        Text('Frage ${_nummer + 1} von ${_fragen.length} · ${f.thema}'),
        const SizedBox(height: 16),
        Text(f.text, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        for (final a in _antworten[_nummer])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _gewaehlt[_nummer] == a
                ? FilledButton(
                    style: FilledButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(14)),
                    onPressed: () {},
                    child: Text(a))
                : OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(14)),
                    onPressed: () => setState(() => _gewaehlt[_nummer] = a),
                    child: Text(a)),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (_nummer > 0)
              OutlinedButton(
                onPressed: () => setState(() => _nummer--),
                child: const Text('Zurück'),
              ),
            const Spacer(),
            if (_nummer < _fragen.length - 1)
              FilledButton(
                onPressed: () => setState(() => _nummer++),
                child: const Text('Weiter'),
              )
            else
              FilledButton(
                onPressed: _abgeben,
                child: const Text('Abgeben'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Beantwortet: ${_gewaehlt.where((g) => g != null).length} von '
            '${_fragen.length}'),
      ],
    );
  }

  Widget _ergebnis(BuildContext context) {
    final bestanden = _richtig >= (_fragen.length * 0.8).ceil();
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(bestanden ? '🎉' : '📚',
            style: const TextStyle(fontSize: 64), textAlign: TextAlign.center),
        Text(bestanden ? 'Bestanden!' : 'Noch nicht bestanden',
            style: text.headlineSmall, textAlign: TextAlign.center),
        Text('$_richtig von ${_fragen.length} richtig (80 % nötig)',
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        const HinweisKarte('Übungsprüfung mit eigenen Fragen – die echte '
            'Fischerprüfung kann anders aufgebaut sein.'),
        const SizedBox(height: 8),
        Text('Deine Fehler', style: text.titleMedium),
        for (var i = 0; i < _fragen.length; i++)
          if (_gewaehlt[i] != _fragen[i].antworten.first)
            Card(
              child: ListTile(
                title: Text(_fragen[i].text),
                subtitle: Text(
                  'Deine Antwort: ${_gewaehlt[i] ?? '–'}\n'
                  'Richtig: ${_fragen[i].antworten.first}\n'
                  '${_fragen[i].erklaerung}',
                ),
              ),
            ),
      ],
    );
  }
}
