import 'package:flutter/material.dart';

import '../models/buch.dart';

/// Kleines Schild „leicht / mittel / schwierig“ für ein Quiz.
class StufeSchild extends StatelessWidget {
  const StufeSchild(this.stufe, {super.key});

  final Schwierigkeit stufe;

  @override
  Widget build(BuildContext context) {
    final (farbe, symbol) = switch (stufe) {
      Schwierigkeit.leicht => (Colors.green, '●'),
      Schwierigkeit.mittel => (Colors.orange, '●●'),
      Schwierigkeit.schwierig => (Colors.red, '●●●'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: farbe.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$symbol ${stufe.text}', style: TextStyle(color: farbe, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
