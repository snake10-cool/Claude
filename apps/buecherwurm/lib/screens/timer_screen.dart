import 'dart:async';

import 'package:flutter/material.dart';

import '../main.dart';
import '../models/buch.dart';
import '../widgets/buch_kachel.dart';

/// Lese-Timer: zählt, wie lange man liest. Die Zeit wird beim Beenden
/// gespeichert (auch beim Zurückgehen).
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key, required this.buch});

  final Buch buch;

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final _uhr = Stopwatch();
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _umschalten() {
    setState(() {
      if (_uhr.isRunning) {
        _uhr.stop();
        _ticker?.cancel();
      } else {
        _uhr.start();
        _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
      }
    });
  }

  Future<void> _speichern() async {
    _uhr.stop();
    _ticker?.cancel();
    final minuten = (_uhr.elapsed.inSeconds / 60).round();
    await SpeicherScope.of(context).leseZeitHinzufuegen(widget.buch.id, minuten);
  }

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final theme = Theme.of(context);
    final d = _uhr.elapsed;
    final zeit = '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && _uhr.elapsed.inSeconds >= 30) _speichern();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Lese-Timer')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BuchCover(widget.buch, breite: 90),
                const SizedBox(height: 12),
                Text(widget.buch.titel, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
                const SizedBox(height: 32),
                Text(zeit, style: theme.textTheme.displayLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _umschalten,
                  icon: Icon(_uhr.isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_uhr.isRunning ? 'Pause' : (d.inSeconds == 0 ? 'Start' : 'Weiter')),
                ),
                const SizedBox(height: 8),
                if (d.inSeconds > 0)
                  TextButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      await _speichern();
                      _uhr.reset();
                      navigator.pop();
                    },
                    child: const Text('Fertig – Zeit speichern'),
                  ),
                const SizedBox(height: 24),
                Text('Bisher mit diesem Buch: ${speicher.leseMinuten(widget.buch.id)} Minuten',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
