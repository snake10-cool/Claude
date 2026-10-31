import 'package:flutter/material.dart';

import '../main.dart';
import '../models/buch.dart';
import '../services/konto.dart';

/// Formular: eine Quizfrage zu einem Buch vorschlagen. Sie erscheint erst,
/// wenn der Admin sie freigegeben hat.
class QuizVorschlagScreen extends StatefulWidget {
  const QuizVorschlagScreen({super.key, required this.buch});

  final Buch buch;

  @override
  State<QuizVorschlagScreen> createState() => _QuizVorschlagScreenState();
}

class _QuizVorschlagScreenState extends State<QuizVorschlagScreen> {
  final _frage = TextEditingController();
  final _antworten = List.generate(4, (_) => TextEditingController());
  var _laedt = false;
  String? _fehler;

  @override
  void dispose() {
    _frage.dispose();
    for (final a in _antworten) {
      a.dispose();
    }
    super.dispose();
  }

  String? _pruefen() {
    final frage = _frage.text.trim();
    final antworten = [for (final a in _antworten) a.text.trim()];
    if (frage.length < 5) return 'Bitte schreib eine Frage.';
    if (antworten.any((a) => a.isEmpty)) return 'Bitte fülle alle vier Antworten aus.';
    if (antworten.map((a) => a.toLowerCase()).toSet().length < 4) return 'Die Antworten müssen verschieden sein.';
    return null;
  }

  Future<void> _senden() async {
    final fehler = _pruefen();
    if (fehler != null) {
      setState(() => _fehler = fehler);
      return;
    }
    final konto = KontoScope.of(context)!;
    setState(() {
      _laedt = true;
      _fehler = null;
    });
    try {
      await konto.quizVorschlagen(widget.buch, _frage.text, [for (final a in _antworten) a.text]);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Danke! Deine Frage wird geprüft und erscheint nach der Freigabe.'),
      ));
    } on KontoFehler catch (e) {
      if (mounted) setState(() => _fehler = e.text);
    } finally {
      if (mounted) setState(() => _laedt = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Quizfrage vorschlagen')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(widget.buch.titel, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          const Text(
            'Stell eine Frage, die nur beantworten kann, wer das Buch gelesen oder gehört hat. '
            'Sie wird vor der Freigabe geprüft.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _frage,
            maxLength: 200,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Frage', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          for (final (i, feld) in _antworten.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: feld,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: i == 0 ? 'Richtige Antwort' : 'Falsche Antwort $i',
                  prefixIcon: Icon(
                    i == 0 ? Icons.check_circle : Icons.cancel_outlined,
                    color: i == 0 ? Colors.green : theme.colorScheme.error,
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          if (_fehler != null) Text(_fehler!, style: TextStyle(color: theme.colorScheme.error)),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _laedt ? null : _senden,
            icon: const Icon(Icons.send),
            label: const Text('Zur Prüfung senden'),
          ),
        ],
      ),
    );
  }
}
