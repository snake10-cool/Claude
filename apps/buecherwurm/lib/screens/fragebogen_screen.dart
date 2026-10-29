import 'package:flutter/material.dart';

import '../data/fragebogen.dart';
import '../main.dart';
import 'gelesen_auswahl_screen.dart';

/// Eine Frage pro Seite. Beim ersten Start ([pflicht]) geht es danach zur
/// Auswahl der gelesenen Bücher.
class FragebogenScreen extends StatefulWidget {
  const FragebogenScreen({super.key, required this.pflicht});

  final bool pflicht;

  @override
  State<FragebogenScreen> createState() => _FragebogenScreenState();
}

class _FragebogenScreenState extends State<FragebogenScreen> {
  late final Map<String, List<String>> _antworten = {
    for (final MapEntry(:key, :value) in SpeicherScope.of(context).antworten.entries)
      key: [...value],
  };
  var _index = 0;

  FragebogenFrage get _frage => fragebogen[_index];
  List<String> get _gewaehlt => _antworten[_frage.id] ?? const [];

  void _tippen(String optionId) {
    setState(() {
      if (_frage.mehrfach) {
        final liste = [..._gewaehlt];
        liste.contains(optionId) ? liste.remove(optionId) : liste.add(optionId);
        _antworten[_frage.id] = liste;
      } else {
        _antworten[_frage.id] = [optionId];
      }
    });
    if (!_frage.mehrfach) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) _weiter();
      });
    }
  }

  Future<void> _weiter() async {
    if (_gewaehlt.isEmpty) return;
    if (_index < fragebogen.length - 1) {
      setState(() => _index++);
      return;
    }
    final speicher = SpeicherScope.of(context);
    await speicher.antwortenSetzen(_antworten);
    if (!mounted) return;
    if (widget.pflicht) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => const GelesenAuswahlScreen(pflicht: true),
      ));
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gespeichert – deine Empfehlungen sind aktualisiert.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _index--);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Frage ${_index + 1} von ${fragebogen.length}'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(value: (_index + 1) / fragebogen.length),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(_frage.text, style: theme.textTheme.headlineSmall),
            if (_frage.hinweis != null || _frage.mehrfach) ...[
              const SizedBox(height: 6),
              Text(_frage.hinweis ?? 'Mehrere Antworten möglich.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
            ],
            const SizedBox(height: 16),
            for (final o in _frage.optionen)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AntwortKarte(
                  text: o.text,
                  gewaehlt: _gewaehlt.contains(o.id),
                  mehrfach: _frage.mehrfach,
                  onTap: () => _tippen(o.id),
                ),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                if (_index > 0)
                  TextButton(
                    onPressed: () => setState(() => _index--),
                    child: const Text('Zurück'),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: _gewaehlt.isEmpty ? null : _weiter,
                  child: Text(_index == fragebogen.length - 1 ? 'Fertig' : 'Weiter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AntwortKarte extends StatelessWidget {
  const _AntwortKarte({
    required this.text,
    required this.gewaehlt,
    required this.mehrfach,
    required this.onTap,
  });

  final String text;
  final bool gewaehlt;
  final bool mehrfach;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: gewaehlt ? farben.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: gewaehlt ? farben.primary : farben.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                mehrfach
                    ? (gewaehlt ? Icons.check_box : Icons.check_box_outline_blank)
                    : (gewaehlt ? Icons.radio_button_checked : Icons.radio_button_off),
                color: gewaehlt ? farben.primary : farben.outline,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
            ],
          ),
        ),
      ),
    );
  }
}
