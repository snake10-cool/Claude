import 'package:flutter/material.dart';

import '../models/buch.dart';

/// Farbiges Platzhalter-Cover mit den Anfangsbuchstaben des Titels.
class BuchCover extends StatelessWidget {
  const BuchCover(this.buch, {super.key, this.breite = 48});

  final Buch buch;
  final double breite;

  static const _farben = [
    Color(0xFF8D6E63),
    Color(0xFF5C6BC0),
    Color(0xFF26A69A),
    Color(0xFFEF5350),
    Color(0xFFAB47BC),
    Color(0xFFFFA726),
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFF78909C),
  ];

  @override
  Widget build(BuildContext context) {
    final farbe = _farben[buch.titel.hashCode.abs() % _farben.length];
    final woerter = buch.titel
        .split(RegExp(r'[\s–-]+'))
        .where((w) => w.isNotEmpty && RegExp(r'[A-Za-zÄÖÜäöü0-9]').hasMatch(w[0]))
        .toList();
    final kuerzel = woerter.take(2).map((w) => w[0].toUpperCase()).join();
    return Container(
      width: breite,
      height: breite * 1.45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(breite / 10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [farbe, Color.lerp(farbe, Colors.black, 0.35)!],
        ),
      ),
      child: Text(
        kuerzel,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: breite * 0.38,
        ),
      ),
    );
  }
}

/// 1–5 Sterne. Mit [onChanged] antippbar, erneutes Tippen auf den aktuellen
/// Stern setzt auf 0 zurück.
class Sterne extends StatelessWidget {
  const Sterne(this.wert, {super.key, this.onChanged, this.groesse = 28});

  final int wert;
  final ValueChanged<int>? onChanged;
  final double groesse;

  @override
  Widget build(BuildContext context) {
    final farbe = Colors.amber.shade700;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          InkResponse(
            onTap: onChanged == null ? null : () => onChanged!(i == wert ? 0 : i),
            radius: groesse * 0.7,
            child: Padding(
              padding: EdgeInsets.all(onChanged == null ? 0 : 3),
              child: Icon(
                i <= wert ? Icons.star_rounded : Icons.star_outline_rounded,
                color: farbe,
                size: groesse,
                semanticLabel: i == 1 ? '$wert von 5 Sternen' : null,
              ),
            ),
          ),
      ],
    );
  }
}
