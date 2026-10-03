import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/bilder.dart';
import '../data/fische.dart';
import '../models/fang.dart';
import '../services/fang_dienst.dart';
import 'widgets.dart';

/// Macht aus einem Fang ein Bild zum Teilen (WhatsApp, Instagram …).
class StoryScreen extends StatefulWidget {
  const StoryScreen(this.fang, {super.key});

  final Fang fang;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final _schluessel = GlobalKey();
  late final Future<Uint8List?> _foto = widget.fang.hatFoto
      ? fangDienst.foto(widget.fang.id)
      : Future.value(null);
  bool _teilt = false;

  Future<void> _teilen() async {
    setState(() => _teilt = true);
    try {
      final grenze = _schluessel.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      final bild = await grenze.toImage(pixelRatio: 3);
      final daten = await bild.toByteData(format: ui.ImageByteFormat.png);
      final ordner = await getTemporaryDirectory();
      final datei = File('${ordner.path}/austro_angler_fang.png');
      await datei.writeAsBytes(daten!.buffer.asUint8List());
      final fisch = fischById(widget.fang.fischId)?.name ?? '';
      await SharePlus.instance.share(ShareParams(
        files: [XFile(datei.path, mimeType: 'image/png')],
        text: 'Petri Heil! $fisch'
            '${widget.fang.laengeCm == null ? '' : ' mit ${widget.fang.laengeCm!.toStringAsFixed(0)} cm'}'
            ' 🎣 – gefangen mit Austro Angler',
      ));
    } catch (e) {
      if (mounted) meldung(context, 'Teilen fehlgeschlagen: $e');
    } finally {
      if (mounted) setState(() => _teilt = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fang teilen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: RepaintBoundary(
              key: _schluessel,
              child: FutureBuilder<Uint8List?>(
                future: _foto,
                builder: (context, snap) =>
                    _StoryKarte(widget.fang, snap.data),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _teilt ? null : _teilen,
            icon: const Icon(Icons.share),
            label: const Text('Bild teilen'),
          ),
        ],
      ),
    );
  }
}

class _StoryKarte extends StatelessWidget {
  const _StoryKarte(this.fang, this.foto);

  final Fang fang;
  final Uint8List? foto;

  @override
  Widget build(BuildContext context) {
    final fisch = fischById(fang.fischId);
    final ersatzBild = fischBilder[fang.fischId];
    const weiss = TextStyle(color: Colors.white);
    return Container(
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E6F5C), Color(0xFF0B3D33)],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎣 PETRI HEIL!',
              style: TextStyle(color: Colors.amber, fontSize: 22,
                  fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: Colors.white,
              height: 220,
              width: double.infinity,
              child: foto != null
                  ? Image.memory(foto!, fit: BoxFit.cover)
                  : ersatzBild != null
                      ? Image.asset(ersatzBild.pfad, fit: BoxFit.contain)
                      : const Icon(Icons.set_meal, size: 80),
            ),
          ),
          const SizedBox(height: 12),
          Text(fisch?.name ?? fang.fischId,
              style: weiss.copyWith(fontSize: 26, fontWeight: FontWeight.bold)),
          if (fang.laengeCm != null || fang.gewichtG != null)
            Text(
              [
                if (fang.laengeCm != null)
                  '${fang.laengeCm!.toStringAsFixed(0)} cm',
                if (fang.gewichtG != null)
                  fang.gewichtG! >= 1000
                      ? '${(fang.gewichtG! / 1000).toStringAsFixed(1).replaceAll('.', ',')} kg'
                      : '${fang.gewichtG} g',
              ].join(' · '),
              style: weiss.copyWith(fontSize: 20, color: Colors.amber),
            ),
          const SizedBox(height: 6),
          if (fang.gewaesser.isNotEmpty) Text('📍 ${fang.gewaesser}', style: weiss),
          Text('📅 ${datumText(fang.datum)}', style: weiss),
          if (fang.koeder.isNotEmpty) Text('🪱 ${fang.koeder}', style: weiss),
          const SizedBox(height: 12),
          Row(
            children: [
              if (fang.nutzerName.isNotEmpty)
                Text(at(fang.nutzerName),
                    style: weiss.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('Austro Angler',
                  style: weiss.copyWith(fontSize: 12, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}
