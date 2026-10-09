import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/bilder.dart';
import '../data/fische.dart';
import '../models/fisch.dart';

const _runden = 10;

/// Fische anhand von Bildern erkennen – für Anfänger und Kinder.
class FischQuizScreen extends StatefulWidget {
  const FischQuizScreen({super.key});

  @override
  State<FischQuizScreen> createState() => _FischQuizScreenState();
}

class _FischQuizScreenState extends State<FischQuizScreen> {
  final _zufall = Random();
  late List<Fisch> _reihe;
  late List<Fisch> _optionen;
  int _runde = 0;
  int _punkte = 0;
  Fisch? _gewaehlt;
  int _rekord = 0;

  List<Fisch> get _mitBild =>
      fische.where((f) => fischBilder.containsKey(f.id)).toList();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (mounted) setState(() => _rekord = p.getInt('quiz_rekord') ?? 0);
    });
    _neu();
  }

  void _neu() {
    _reihe = (_mitBild..shuffle(_zufall)).take(_runden).toList();
    _runde = 0;
    _punkte = 0;
    _frage();
  }

  void _frage() {
    _gewaehlt = null;
    final richtig = _reihe[_runde];
    final andere = (_mitBild..remove(richtig)..shuffle(_zufall)).take(3);
    _optionen = [richtig, ...andere]..shuffle(_zufall);
  }

  Future<void> _waehlen(Fisch f) async {
    if (_gewaehlt != null) return;
    setState(() {
      _gewaehlt = f;
      if (f == _reihe[_runde]) _punkte++;
    });
  }

  Future<void> _weiter() async {
    if (_runde + 1 >= _runden) {
      if (_punkte > _rekord) {
        final p = await SharedPreferences.getInstance();
        await p.setInt('quiz_rekord', _punkte);
        _rekord = _punkte;
      }
      if (!mounted) return;
      setState(() => _runde++);
      return;
    }
    setState(() {
      _runde++;
      _frage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    if (_runde >= _runden) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fisch-Quiz')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_punkte >= 8 ? '🏆' : _punkte >= 5 ? '🐟' : '📚',
                    style: const TextStyle(fontSize: 64)),
                Text('$_punkte von $_runden richtig', style: text.headlineSmall),
                Text('Dein Rekord: $_rekord'),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => setState(_neu),
                  child: const Text('Nochmal spielen'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final richtig = _reihe[_runde];
    return Scaffold(
      appBar: AppBar(title: Text('Fisch-Quiz · ${_runde + 1}/$_runden')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Welcher Fisch ist das?', style: text.titleLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.white,
              height: 220,
              child: Image.asset(fischBilder[richtig.id]!.pfad,
                  fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 16),
          for (final f in _optionen)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: _gewaehlt == null
                      ? null
                      : f == richtig
                          ? Colors.green.shade400
                          : f == _gewaehlt
                              ? Colors.red.shade400
                              : null,
                ),
                onPressed: () => _waehlen(f),
                child: Text(f.name, style: const TextStyle(fontSize: 16)),
              ),
            ),
          if (_gewaehlt != null) ...[
            const SizedBox(height: 8),
            Text(_gewaehlt == richtig ? 'Richtig! 🎉' : 'Das war: ${richtig.name}',
                style: text.titleMedium, textAlign: TextAlign.center),
            Text(richtig.merkmale, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: _weiter, child: const Text('Weiter')),
          ],
          const SizedBox(height: 12),
          Text('Punkte: $_punkte · Rekord: $_rekord',
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
