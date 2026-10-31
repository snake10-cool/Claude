import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/buchsuche.dart';

/// Scannt den Strichcode auf der Buchrückseite und gibt die ISBN zurück.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _kamera = MobileScannerController(formats: const [BarcodeFormat.ean13, BarcodeFormat.ean8]);
  var _fertig = false;

  @override
  void dispose() {
    _kamera.dispose();
    super.dispose();
  }

  void _erkannt(BarcodeCapture fang) {
    if (_fertig) return;
    for (final code in fang.barcodes) {
      final isbn = isbnAus(code.rawValue ?? '');
      if (isbn != null) {
        _fertig = true;
        Navigator.of(context).pop(isbn);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ISBN scannen'),
        actions: [
          IconButton(
            tooltip: 'Taschenlampe',
            icon: const Icon(Icons.flashlight_on_outlined),
            onPressed: _kamera.toggleTorch,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _kamera,
            onDetect: _erkannt,
            errorBuilder: (context, fehler) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  fehler.errorCode == MobileScannerErrorCode.permissionDenied
                      ? 'Bitte erlaube den Zugriff auf die Kamera in den Einstellungen.'
                      : 'Die Kamera konnte nicht gestartet werden.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 280,
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: Text(
              'Halte den Strichcode auf der Rückseite des Buchs in den Rahmen.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, shadows: [Shadow(blurRadius: 6)]),
            ),
          ),
        ],
      ),
    );
  }
}
