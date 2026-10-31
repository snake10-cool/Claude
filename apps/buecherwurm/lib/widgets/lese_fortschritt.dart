import 'package:flutter/material.dart';

import '../main.dart';
import '../models/buch.dart';

/// „Seite X von Y" mit Schieberegler – für Bücher, die man gerade liest.
class LeseFortschritt extends StatefulWidget {
  const LeseFortschritt({super.key, required this.buch, required this.eintrag});

  final Buch buch;
  final Eintrag eintrag;

  @override
  State<LeseFortschritt> createState() => _LeseFortschrittState();
}

class _LeseFortschrittState extends State<LeseFortschritt> {
  late double _seite = widget.eintrag.seite.clamp(0, widget.buch.seiten).toDouble();

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final gesamt = widget.buch.seiten;
    final theme = Theme.of(context);
    final prozent = gesamt == 0 ? 0 : (_seite / gesamt * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Seite ${_seite.round()} von $gesamt ($prozent %)', style: theme.textTheme.titleSmall),
        Slider(
          value: _seite,
          max: gesamt.toDouble(),
          divisions: gesamt,
          label: '${_seite.round()}',
          onChanged: (v) => setState(() => _seite = v),
          onChangeEnd: (v) async {
            await speicher.seiteSetzen(widget.buch.id, v.round());
            if (v.round() >= gesamt && context.mounted) {
              final fertig = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Fertig gelesen? 🎉'),
                  content: Text('Soll „${widget.buch.titel}" als gelesen eingetragen werden?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Noch nicht')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ja, gelesen')),
                  ],
                ),
              );
              if (fertig == true) {
                widget.eintrag
                  ..status = Status.gelesen
                  ..datum = DateTime.now();
                await speicher.eintragSetzen(widget.buch.id, widget.eintrag);
              }
            }
          },
        ),
      ],
    );
  }
}
