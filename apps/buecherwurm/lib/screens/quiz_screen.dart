import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../main.dart';
import '../models/buch.dart';

/// Zeit pro Frage. Kurz genug, dass Nachschlagen kaum klappt.
const sekundenProFrage = 20;

/// Punkte für eine richtige Antwort: 10 plus Tempo-Bonus (max. 10).
int punkteFuer(int restSekunden) => 10 + (restSekunden / 2).ceil();

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.buch});

  final Buch buch;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with WidgetsBindingObserver {
  final _zufall = Random();
  late final List<(Frage, List<String>)> _fragen = [
    for (final f in [...widget.buch.quiz]..shuffle(_zufall)) (f, [...f.antworten]..shuffle(_zufall)),
  ];

  /// Nur der erste Versuch zählt, danach ist es Übung.
  late final bool _zaehlt = !SpeicherScope.of(context).quiz.containsKey(widget.buch.id);

  var _gestartet = false;
  var _index = 0;
  var _rest = sekundenProFrage;
  String? _gewaehlt;
  var _aufgeloest = false;
  var _richtig = 0;
  var _punkte = 0;
  var _verlassen = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  /// Wer die App während einer Frage verlässt (z. B. zum Googeln), verliert
  /// diese Frage.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_gestartet || _aufgeloest || _index >= _fragen.length) return;
    if (state == AppLifecycleState.hidden || state == AppLifecycleState.paused) {
      _verlassen++;
      _aufloesen(null);
    }
  }

  void _starten() {
    setState(() => _gestartet = true);
    _frageStarten();
  }

  void _frageStarten() {
    _rest = sekundenProFrage;
    _gewaehlt = null;
    _aufgeloest = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _rest--);
      if (_rest <= 0) _aufloesen(null);
    });
  }

  void _aufloesen(String? antwort) {
    if (_aufgeloest) return;
    _timer?.cancel();
    setState(() {
      _aufgeloest = true;
      _gewaehlt = antwort;
      if (antwort != null && antwort == _fragen[_index].$1.richtig) {
        _richtig++;
        _punkte += punkteFuer(_rest);
      }
    });
  }

  Future<void> _weiter() async {
    if (_index < _fragen.length - 1) {
      setState(() => _index++);
      _frageStarten();
      return;
    }
    setState(() => _index++);
    if (_zaehlt) {
      await SpeicherScope.of(context).quizBeendet(
        widget.buch.id,
        QuizErgebnis(richtig: _richtig, gesamt: _fragen.length, punkte: _punkte, datum: DateTime.now()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_gestartet || _index >= _fragen.length || !_zaehlt,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final abbrechen = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quiz abbrechen?'),
            content: const Text('Dann zählt das Quiz mit den bisherigen Antworten. Offene Fragen sind falsch.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Weiterspielen')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Abbrechen')),
            ],
          ),
        );
        if (abbrechen != true || !context.mounted) return;
        _timer?.cancel();
        _index = _fragen.length;
        final navigator = Navigator.of(context);
        await SpeicherScope.of(context).quizBeendet(
          widget.buch.id,
          QuizErgebnis(richtig: _richtig, gesamt: _fragen.length, punkte: _punkte, datum: DateTime.now()),
        );
        navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.buch.titel)),
        body: SafeArea(
          child: !_gestartet
              ? _vorStart(context)
              : _index >= _fragen.length
                  ? _ende(context)
                  : _frage(context),
        ),
      ),
    );
  }

  Widget _vorStart(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('🤞', textAlign: TextAlign.center, style: TextStyle(fontSize: 56)),
        const SizedBox(height: 12),
        Text(_zaehlt ? 'Bereit?' : 'Übungsrunde', textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text(
          _zaehlt
              ? '• ${_fragen.length} Fragen, je $sekundenProFrage Sekunden\n'
                  '• Schnelle Antworten geben Bonuspunkte\n'
                  '• Nur dieser erste Versuch zählt im Wettbewerb\n'
                  '• Verlässt du die App während einer Frage, ist sie falsch\n'
                  '• Ab ${(_fragen.length * 2 / 3).ceil()} richtigen Antworten gilt das Buch als bewiesen gelesen'
              : 'Du hast dieses Quiz schon gemacht. Diese Runde ist nur zum Spaß und bringt keine Punkte.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        if (_zaehlt && !speicher.ehrenwort)
          Card(
            color: theme.colorScheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('🤝 Ehrenwort', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text(
                    'Der Wettbewerb funktioniert nur, wenn alle fair spielen. '
                    'Ich verspreche: Ich google nicht, frage niemanden und schaue '
                    'nicht ins Buch.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: speicher.ehrenwortGeben,
                    child: const Text('Versprochen!'),
                  ),
                ],
              ),
            ),
          )
        else
          FilledButton.icon(
            onPressed: _starten,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Los geht\'s'),
          ),
      ],
    );
  }

  Widget _frage(BuildContext context) {
    final (frage, antworten) = _fragen[_index];
    final theme = Theme.of(context);
    final farben = theme.colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Text('Frage ${_index + 1}/${_fragen.length}', style: theme.textTheme.titleSmall),
            const Spacer(),
            Icon(Icons.timer_outlined, size: 18, color: _rest <= 5 ? farben.error : null),
            const SizedBox(width: 4),
            Text('$_rest s', style: theme.textTheme.titleSmall?.copyWith(color: _rest <= 5 ? farben.error : null)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: _rest / sekundenProFrage, minHeight: 6, borderRadius: BorderRadius.circular(3)),
        const SizedBox(height: 24),
        Text(frage.text, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 20),
        for (final a in antworten)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AntwortKnopf(
              text: a,
              zustand: !_aufgeloest
                  ? _Zustand.offen
                  : a == frage.richtig
                      ? _Zustand.richtig
                      : a == _gewaehlt
                          ? _Zustand.falsch
                          : _Zustand.neutral,
              onTap: _aufgeloest ? null : () => _aufloesen(a),
            ),
          ),
        if (_aufgeloest) ...[
          const SizedBox(height: 8),
          Text(
            _gewaehlt == frage.richtig
                ? '✅ Richtig! +${punkteFuer(_rest)} Punkte'
                : _gewaehlt == null
                    ? (_rest <= 0 ? '⏰ Zeit abgelaufen' : '🚪 App verlassen – Frage verloren')
                    : '❌ Leider falsch',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _weiter,
            child: Text(_index == _fragen.length - 1 ? 'Ergebnis' : 'Nächste Frage'),
          ),
        ],
      ],
    );
  }

  Widget _ende(BuildContext context) {
    final theme = Theme.of(context);
    final bestanden = _richtig * 3 >= _fragen.length * 2;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(bestanden ? '🏆' : '📖', textAlign: TextAlign.center, style: const TextStyle(fontSize: 64)),
        const SizedBox(height: 12),
        Text('$_richtig von ${_fragen.length} richtig', textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          !_zaehlt
              ? 'Übungsrunde – keine Punkte.'
              : bestanden
                  ? '+$_punkte Punkte! Das Buch zählt als bewiesen gelesen.'
                  : '+$_punkte Punkte. Für „bewiesen gelesen" hat es leider nicht gereicht.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
        if (_verlassen > 0) ...[
          const SizedBox(height: 8),
          Text('Du hast die App $_verlassen× während einer Frage verlassen.', textAlign: TextAlign.center),
        ],
        const SizedBox(height: 24),
        FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fertig')),
      ],
    );
  }
}

enum _Zustand { offen, richtig, falsch, neutral }

class _AntwortKnopf extends StatelessWidget {
  const _AntwortKnopf({required this.text, required this.zustand, this.onTap});

  final String text;
  final _Zustand zustand;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    final (hintergrund, rand, icon) = switch (zustand) {
      _Zustand.richtig => (Colors.green.withValues(alpha: 0.18), Colors.green, Icons.check_circle),
      _Zustand.falsch => (farben.errorContainer, farben.error, Icons.cancel),
      _ => (null, farben.outlineVariant, null),
    };
    return Material(
      color: hintergrund ?? Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: rand, width: zustand == _Zustand.offen ? 1 : 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
              if (icon != null) Icon(icon, color: rand),
            ],
          ),
        ),
      ),
    );
  }
}
