import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'widgets.dart';

/// Gegenstände mit bekannter Länge zum Vergleich.
const _referenzen = <(String, double)>[
  ('Bankomatkarte (lange Seite)', 8.56),
  ('1-Euro-Münze (Durchmesser)', 2.325),
  ('2-Euro-Münze (Durchmesser)', 2.575),
  ('Feuerzeug (Standard)', 8.0),
  ('Lineal / Maßband: 10 cm', 10),
];

/// Fischlänge aus einem Foto: erst einen bekannten Gegenstand markieren,
/// dann Maul und Schwanzende antippen. Gibt die Länge in cm zurück.
class MessenScreen extends StatefulWidget {
  const MessenScreen({super.key});

  @override
  State<MessenScreen> createState() => _MessenScreenState();
}

class _MessenScreenState extends State<MessenScreen> {
  Uint8List? _bild;
  var _referenz = _referenzen.first;
  final _punkte = <Offset>[];

  bool get _hatKamera =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> _waehlen(ImageSource quelle) async {
    final datei = await ImagePicker()
        .pickImage(source: quelle, maxWidth: 1600, imageQuality: 80);
    if (datei == null) return;
    final bytes = await datei.readAsBytes();
    setState(() {
      _bild = bytes;
      _punkte.clear();
    });
  }

  double? get _ergebnis {
    if (_punkte.length < 4) return null;
    final ref = (_punkte[1] - _punkte[0]).distance;
    final fisch = (_punkte[3] - _punkte[2]).distance;
    if (ref < 5) return null;
    return fisch / ref * _referenz.$2;
  }

  String get _anleitung => switch (_punkte.length) {
        0 => '1️⃣ Tippe auf ein Ende der ${_referenz.$1.split(' (').first}.',
        1 => '2️⃣ Jetzt auf das andere Ende.',
        2 => '3️⃣ Tippe auf die Maulspitze des Fisches.',
        3 => '4️⃣ Jetzt auf das Ende der Schwanzflosse.',
        _ => '✅ Fertig! Zum Neu-Messen auf "Zurücksetzen" tippen.',
      };

  @override
  Widget build(BuildContext context) {
    final ergebnis = _ergebnis;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Länge per Foto messen')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const HinweisKarte(
            'Leg den Fisch flach hin und daneben einen Gegenstand, dessen '
            'Länge du kennst – z. B. eine Bankomatkarte. Fotografiere genau '
            'von oben. Das Ergebnis ist eine Schätzung: Fürs Brittelmaß im '
            'Zweifel mit dem Maßband messen!',
            icon: Icons.straighten,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<(String, double)>(
            initialValue: _referenz,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Vergleichsgegenstand'),
            items: [
              for (final r in _referenzen)
                DropdownMenuItem(value: r, child: Text(r.$1)),
            ],
            onChanged: (r) => setState(() => _referenz = r ?? _referenz),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (_hatKamera)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _waehlen(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Foto machen'),
                  ),
                ),
              if (_hatKamera) const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _waehlen(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Aus Galerie'),
                ),
              ),
            ],
          ),
          if (_bild != null) ...[
            const SizedBox(height: 12),
            Text(_anleitung, style: text.titleSmall),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onTapUp: (d) {
                  if (_punkte.length < 4) {
                    setState(() => _punkte.add(d.localPosition));
                  }
                },
                child: CustomPaint(
                  foregroundPainter: _Markierungen(_punkte),
                  child: Image.memory(_bild!, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    ergebnis == null
                        ? ''
                        : 'Länge: ca. ${ergebnis.toStringAsFixed(0)} cm',
                    style: text.headlineSmall,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(_punkte.clear),
                  child: const Text('Zurücksetzen'),
                ),
              ],
            ),
            if (ergebnis != null)
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, ergebnis),
                icon: const Icon(Icons.check),
                label: const Text('Länge übernehmen'),
              ),
          ],
        ],
      ),
    );
  }
}

class _Markierungen extends CustomPainter {
  _Markierungen(this.punkte);

  final List<Offset> punkte;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < punkte.length; i++) {
      final farbe = i < 2 ? Colors.amber : Colors.lightGreenAccent;
      final stift = Paint()
        ..color = farbe
        ..strokeWidth = 3;
      canvas.drawCircle(punkte[i], 7, stift);
      canvas.drawCircle(punkte[i], 3, Paint()..color = Colors.black);
      if (i.isOdd) canvas.drawLine(punkte[i - 1], punkte[i], stift);
    }
  }

  @override
  bool shouldRepaint(_Markierungen alt) => true;
}
