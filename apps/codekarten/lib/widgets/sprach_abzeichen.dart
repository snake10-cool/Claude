import 'package:flutter/material.dart';

import '../logik/typen.dart';

/// Kleines farbiges Kürzel für eine Programmiersprache.
class SprachAbzeichen extends StatelessWidget {
  const SprachAbzeichen(this.sprache, {super.key, this.gross = false});
  final String sprache;
  final bool gross;

  static Color farbe(String sprache) => switch (sprache) {
    'java' => const Color(0xFFE76F00),
    'python' => const Color(0xFF3776AB),
    'dart' => const Color(0xFF0175C2),
    'javascript' => const Color(0xFFB59B00),
    _ => const Color(0xFF6B7280),
  };

  static String kuerzel(String sprache) => switch (sprache) {
    'java' => 'Java',
    'python' => 'Py',
    'dart' => 'Dart',
    'javascript' => 'JS',
    _ => '</>',
  };

  @override
  Widget build(BuildContext context) {
    final f = farbe(sprache);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: gross ? 10 : 6,
        vertical: gross ? 4 : 2,
      ),
      decoration: BoxDecoration(
        color: f.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: f.withValues(alpha: 0.6)),
      ),
      child: Text(
        gross ? spracheName(sprache) : kuerzel(sprache),
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Color.lerp(f, Colors.white, 0.4)
              : Color.lerp(f, Colors.black, 0.25),
          fontWeight: FontWeight.bold,
          fontSize: gross ? 13 : 11,
        ),
      ),
    );
  }
}
