import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Mo, der Maulwurf mit Grubenhelm. [druck] (0–1) staucht ihn beim Tippen.
class MoMaler extends CustomPainter {
  MoMaler({this.druck = 0, this.blinzeln = false});

  final double druck;
  final bool blinzeln;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset p(double x, double y) => Offset(x * w, y * h);
    Rect oval(double cx, double cy, double bw, double bh) =>
        Rect.fromCenter(center: p(cx, cy), width: bw * w, height: bh * h);

    // Schatten
    canvas.drawOval(
      oval(0.5, 0.9, 0.6, 0.08),
      Paint()..color = Colors.black.withValues(alpha: 0.25),
    );

    canvas.save();
    // Stauchen um den Fußpunkt.
    final boden = p(0.5, 0.88);
    canvas.translate(boden.dx, boden.dy);
    canvas.scale(1 + 0.07 * druck, 1 - 0.09 * druck);
    canvas.translate(-boden.dx, -boden.dy);

    // Körper
    final koerper = oval(0.5, 0.6, 0.64, 0.58);
    canvas.drawOval(
      koerper,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.5),
          radius: 0.9,
          colors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
        ).createShader(koerper),
    );
    // Bauch
    canvas.drawOval(
      oval(0.5, 0.7, 0.38, 0.3),
      Paint()..color = const Color(0xFFBCAAA4),
    );

    // Pfoten mit Krallen
    for (final x in [0.25, 0.75]) {
      canvas.drawOval(
        oval(x, 0.74, 0.17, 0.13),
        Paint()..color = const Color(0xFFF8BBD0),
      );
      final kralle = Paint()
        ..color = Colors.white
        ..strokeWidth = w * 0.012
        ..strokeCap = StrokeCap.round;
      for (final dx in [-0.04, 0.0, 0.04]) {
        canvas.drawLine(p(x + dx, 0.77), p(x + dx * 1.3, 0.82), kralle);
      }
    }

    // Schnauze und Nase
    canvas.drawOval(
      oval(0.5, 0.53, 0.24, 0.15),
      Paint()..color = const Color(0xFFD7CCC8),
    );
    canvas.drawCircle(
      p(0.5, 0.48),
      w * 0.05,
      Paint()..color = const Color(0xFFEC407A),
    );
    canvas.drawCircle(
      p(0.485, 0.468),
      w * 0.014,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );
    // Mund
    canvas.drawArc(
      oval(0.5, 0.55, 0.08, 0.05),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFF3E2723)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.01
        ..strokeCap = StrokeCap.round,
    );
    // Schnurrhaare
    final haar = Paint()
      ..color = const Color(0xFF3E2723).withValues(alpha: 0.6)
      ..strokeWidth = w * 0.006;
    for (final s in [-1.0, 1.0]) {
      for (final dy in [-0.015, 0.015]) {
        canvas.drawLine(
          p(0.5 + s * 0.09, 0.52 + dy),
          p(0.5 + s * 0.2, 0.5 + dy * 2.2),
          haar,
        );
      }
    }
    // Bäckchen
    for (final x in [0.36, 0.64]) {
      canvas.drawCircle(
        p(x, 0.5),
        w * 0.03,
        Paint()..color = const Color(0x55F06292),
      );
    }
    // Augen
    for (final x in [0.42, 0.58]) {
      if (blinzeln || druck > 0.6) {
        canvas.drawArc(
          oval(x, 0.42, 0.06, 0.04),
          math.pi,
          math.pi,
          false,
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.012
            ..strokeCap = StrokeCap.round,
        );
      } else {
        canvas.drawCircle(p(x, 0.42), w * 0.026, Paint()..color = Colors.black);
        canvas.drawCircle(
          p(x - 0.008, 0.412),
          w * 0.009,
          Paint()..color = Colors.white,
        );
      }
    }

    // Helm
    final helm = Path()
      ..moveTo(p(0.24, 0.36).dx, p(0.24, 0.36).dy)
      ..arcTo(oval(0.5, 0.36, 0.52, 0.38), math.pi, math.pi, false)
      ..close();
    canvas.drawPath(helm, Paint()..color = const Color(0xFFFFC107));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        oval(0.5, 0.36, 0.6, 0.05),
        Radius.circular(w * 0.03),
      ),
      Paint()..color = const Color(0xFFFFA000),
    );
    // Lampe mit Lichtschein
    final lampe = p(0.5, 0.24);
    canvas.drawCircle(
      lampe,
      w * 0.14,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF59D).withValues(alpha: 0.7),
            const Color(0xFFFFF59D).withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: lampe, radius: w * 0.14)),
    );
    canvas.drawCircle(
      lampe,
      w * 0.055,
      Paint()..color = const Color(0xFF9E9E9E),
    );
    canvas.drawCircle(
      lampe,
      w * 0.04,
      Paint()..color = const Color(0xFFFFFDE7),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(MoMaler alt) =>
      alt.druck != druck || alt.blinzeln != blinzeln;
}

/// Hintergrund: Himmel/Höhle oben, Erdschicht unten, Tunnel unter Mo.
class ErdeMaler extends CustomPainter {
  ErdeMaler({required this.oben, required this.unten, required this.tiefe});

  final Color oben;
  final Color unten;

  /// 0 = Wiese, höher = tiefer (dunkler, Steine).
  final int tiefe;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [oben, unten],
        ).createShader(r),
    );
    // Steinchen (fest verteilt, damit nichts flackert)
    final zufall = math.Random(tiefe * 7 + 3);
    final stein = Paint()..color = Colors.black.withValues(alpha: 0.12);
    for (var i = 0; i < 40; i++) {
      final x = zufall.nextDouble() * size.width;
      final y = zufall.nextDouble() * size.height;
      final g = 3 + zufall.nextDouble() * 8;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: g * 1.6, height: g),
        stein,
      );
    }
    if (tiefe >= 4) {
      // Kristalle/Glut funkeln in den tiefen Schichten
      final funkel = Paint()..color = Colors.white.withValues(alpha: 0.35);
      for (var i = 0; i < 18; i++) {
        canvas.drawCircle(
          Offset(
            zufall.nextDouble() * size.width,
            zufall.nextDouble() * size.height,
          ),
          1.5 + zufall.nextDouble() * 2,
          funkel,
        );
      }
    }
    // Tunnel unter Mo
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.86),
        width: size.width * 0.5,
        height: size.height * 0.12,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(ErdeMaler alt) =>
      alt.oben != oben || alt.unten != unten || alt.tiefe != tiefe;
}

/// Goldklumpen (für den Glücksklumpen und als Symbol).
class KlumpenMaler extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final pfad = Path()
      ..moveTo(w * 0.15, w * 0.6)
      ..lineTo(w * 0.3, w * 0.25)
      ..lineTo(w * 0.62, w * 0.15)
      ..lineTo(w * 0.88, w * 0.42)
      ..lineTo(w * 0.8, w * 0.8)
      ..lineTo(w * 0.4, w * 0.88)
      ..close();
    canvas.drawPath(
      pfad,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFF176), Color(0xFFFFB300), Color(0xFFFF8F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      pfad,
      Paint()
        ..color = const Color(0xFFE65100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.05
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(
      Offset(w * 0.42, w * 0.38),
      w * 0.07,
      Paint()..color = Colors.white70,
    );
  }

  @override
  bool shouldRepaint(KlumpenMaler alt) => false;
}
