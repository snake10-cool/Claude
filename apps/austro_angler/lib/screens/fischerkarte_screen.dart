import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

import '../design.dart';
import '../main.dart';
import 'widgets.dart';

/// Digitale Fischerkarte: Name, Kartenart, Nummer und Ablauf mit QR-Code –
/// zum schnellen Herzeigen. Ersetzt nicht die amtliche Karte.
class FischerkarteScreen extends StatelessWidget {
  const FischerkarteScreen({super.key});

  Future<void> _bearbeiten(BuildContext context) async {
    final speicher = SpeicherScope.of(context);
    final k = speicher.fischerkarte;
    final name = TextEditingController(text: k['name'] ?? '');
    final art = TextEditingController(
        text: k['art'] ?? 'Amtliche Fischerkarte ${speicher.bundesland.name}');
    final nummer = TextEditingController(text: k['nummer'] ?? '');
    var bis = DateTime.tryParse(k['bis'] ?? '') ??
        DateTime(DateTime.now().year, 12, 31);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Fischerkarte'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 8),
                TextField(
                    controller: art,
                    decoration: const InputDecoration(labelText: 'Kartenart')),
                const SizedBox(height: 8),
                TextField(
                    controller: nummer,
                    decoration:
                        const InputDecoration(labelText: 'Kartennummer')),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event),
                  title: Text('Gültig bis ${datumText(bis)}'),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: bis,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 3650 * 3)),
                    );
                    if (d != null) setState(() => bis = d);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Abbrechen')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Speichern')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    await speicher.fischerkarteSetzen({
      'name': name.text.trim(),
      'art': art.text.trim(),
      'nummer': nummer.text.trim(),
      'bis': bis.toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final k = speicher.fischerkarte;
    final leer = (k['name'] ?? '').isEmpty && (k['nummer'] ?? '').isEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fischerkarte'),
        actions: [
          if (!leer)
            IconButton(
              tooltip: 'Bearbeiten',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _bearbeiten(context),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (leer)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('🎫', style: TextStyle(fontSize: 44)),
                    const SizedBox(height: 8),
                    Text('Deine Fischerkarte immer dabei',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 6),
                    const Text(
                        'Trag Name, Kartenart, Nummer und Ablauf ein. Dann '
                        'hast du die Daten am Wasser mit QR-Code griffbereit.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () => _bearbeiten(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Karte eintragen'),
                    ),
                  ],
                ),
              ),
            )
          else
            FischerkarteKarte(k),
          const SizedBox(height: 12),
          const HinweisKarte(
            'Nur zur Übersicht – ersetzt nicht die amtliche Fischerkarte und '
            'die Lizenz. Bei einer Kontrolle zählen die Originale.',
            icon: Icons.info_outline,
          ),
        ],
      ),
    );
  }
}

/// Die Karte selbst (auch für das Profil / die Heute-Seite nutzbar).
class FischerkarteKarte extends StatelessWidget {
  const FischerkarteKarte(this.k, {super.key});

  final Map<String, String> k;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final bis = DateTime.tryParse(k['bis'] ?? '');
    final abgelaufen = bis != null && bis.isBefore(DateTime.now());
    final daten = [
      'Austro Angler – Fischerkarte',
      if ((k['name'] ?? '').isNotEmpty) 'Name: ${k['name']}',
      if ((k['art'] ?? '').isNotEmpty) 'Karte: ${k['art']}',
      if ((k['nummer'] ?? '').isNotEmpty) 'Nr.: ${k['nummer']}',
      if (bis != null) 'Gültig bis: ${datumText(bis)}',
    ].join('\n');
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FISCHERKARTE',
                      style: text.labelMedium?.copyWith(
                          color: DesignInfo.von(context).akzent,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 6),
                  Text(k['name'] ?? '', style: text.headlineSmall),
                  const SizedBox(height: 4),
                  Text(k['art'] ?? '', style: text.bodyMedium),
                  if ((k['nummer'] ?? '').isNotEmpty)
                    Text('Nr. ${k['nummer']}', style: text.bodyMedium),
                  const SizedBox(height: 6),
                  if (bis != null)
                    Text(
                      abgelaufen
                          ? '⚠️ abgelaufen am ${datumText(bis)}'
                          : 'gültig bis ${datumText(bis)}',
                      style: text.titleSmall?.copyWith(
                          color: abgelaufen
                              ? Theme.of(context).colorScheme.error
                              : null),
                    ),
                  const SizedBox(height: 10),
                  const RotWeissRot(),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(6),
              color: Colors.white,
              child: SizedBox(
                width: 104,
                height: 104,
                child: CustomPaint(painter: _QrMaler(daten)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrMaler extends CustomPainter {
  _QrMaler(this.daten);

  final String daten;

  @override
  void paint(Canvas canvas, Size size) {
    final code = QrCode.fromData(
        data: daten, errorCorrectLevel: QrErrorCorrectLevel.M);
    final bild = QrImage(code);
    final n = bild.moduleCount;
    final zelle = size.width / n;
    final schwarz = Paint()..color = Colors.black;
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (bild.isDark(y, x)) {
          canvas.drawRect(
              Rect.fromLTWH(x * zelle, y * zelle, zelle + 0.3, zelle + 0.3),
              schwarz);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_QrMaler alt) => alt.daten != daten;
}
