import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../daten/datenbank.dart';
import '../dienste.dart';
import '../l10n/l.dart';
import 'gruppe_screen.dart';

/// Einer geteilten Gruppe per Code oder QR-Code beitreten.
class BeitretenScreen extends StatefulWidget {
  const BeitretenScreen({super.key});

  @override
  State<BeitretenScreen> createState() => _BeitretenScreenState();
}

class _BeitretenScreenState extends State<BeitretenScreen> {
  final _code = TextEditingController();
  bool _laedt = false;
  String? _fehler;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _beitreten(String code) async {
    final s = sync;
    if (s == null) return;
    final c = code.replaceFirst('teilbar:', '').trim().toUpperCase();
    if (c.length != 6) {
      setState(() => _fehler = context.l.codeUngueltig);
      return;
    }
    setState(() {
      _laedt = true;
      _fehler = null;
    });
    try {
      final gid = await s.beitreten(c);
      if (!mounted) return;
      if (gid == null) {
        setState(() => _fehler = context.l.codeNichtGefunden);
        return;
      }
      await _werBistDu(gid);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => GruppeScreen(gruppeId: gid)),
      );
    } catch (e) {
      if (mounted) setState(() => _fehler = context.l.keinInternet);
    } finally {
      if (mounted) setState(() => _laedt = false);
    }
  }

  Future<void> _werBistDu(String gid) async {
    final l = context.l;
    final personen = await db.personenLaden(gid);
    if (!mounted) return;
    final wahl = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
        title: Text(l.werBistDu),
        children: [
          for (final p in personen)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, p.id),
              child: Text(p.name),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ''),
            child: Text(l.ichBinNeu),
          ),
        ],
      ),
    );
    if (wahl == null) return;
    if (wahl.isEmpty) {
      final name = profil.name.isNotEmpty ? profil.name : l.ich;
      final id = await db.personHinzufuegen(gid, name);
      await db.ichSetzen(gid, id);
    } else {
      await db.ichSetzen(gid, wahl);
    }
  }

  Future<void> _scannen() async {
    final code = await Navigator.of(context)
        .push<String>(MaterialPageRoute(builder: (_) => const _Scanner()));
    if (code != null) await _beitreten(code);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.beitreten)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (sync == null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l.onlineNichtEingerichtet),
              ),
            )
          else ...[
            Text(l.beitretenText, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              style: const TextStyle(
                fontSize: 28,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'ABC123',
                errorText: _fehler,
              ),
              onSubmitted: _beitreten,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _laedt ? null : () => _beitreten(_code.text),
              child: _laedt
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l.beitreten),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _laedt ? null : _scannen,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(l.qrScannen),
            ),
          ],
        ],
      ),
    );
  }
}

class _Scanner extends StatefulWidget {
  const _Scanner();

  @override
  State<_Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<_Scanner> {
  bool _fertig = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l.qrScannen)),
    body: MobileScanner(
      onDetect: (erfassung) {
        if (_fertig) return;
        final wert = erfassung.barcodes.firstOrNull?.rawValue;
        if (wert != null && wert.startsWith('teilbar:')) {
          _fertig = true;
          Navigator.pop(context, wert);
        }
      },
    ),
  );
}
