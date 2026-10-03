import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/fische.dart';
import '../data/gewaesser.dart';
import '../main.dart';
import '../models/bundesland.dart';
import '../models/fang.dart';
import '../services/fang_dienst.dart';
import 'widgets.dart';

class FangbuchScreen extends StatefulWidget {
  const FangbuchScreen({super.key});

  @override
  State<FangbuchScreen> createState() => _FangbuchScreenState();
}

class _FangbuchScreenState extends State<FangbuchScreen> {
  String? _uid;
  Stream<List<Fang>>? _stream;

  /// Den Stream nur neu anlegen, wenn sich der Nutzer ändert.
  Stream<List<Fang>> _streamFuer(String uid) {
    if (uid != _uid || _stream == null) {
      _uid = uid;
      _stream = fangDienst.meineFaenge(uid);
    }
    return _stream!;
  }

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context);
    final online = konto?.angemeldet ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Mein Fangbuch')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FangFormular()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Fang eintragen'),
      ),
      body: online
          ? StreamBuilder<List<Fang>>(
              stream: _streamFuer(konto!.uid!),
              builder: (context, snap) {
                if (snap.hasError) {
                  return const Center(child: Text('Laden fehlgeschlagen.'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _FangListe(snap.data!);
              },
            )
          : _FangListe(
              SpeicherScope.of(context).faenge,
              oben: konto == null
                  ? null
                  : const AnmeldenKarte(
                      'Melde dich an, damit deine Fänge auf allen Geräten '
                      'gespeichert sind und du sie mit der Community teilen '
                      'kannst.',
                    ),
            ),
    );
  }
}

class _FangListe extends StatelessWidget {
  const _FangListe(this.faenge, {this.oben});

  final List<Fang> faenge;
  final Widget? oben;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
      children: [
        ?oben,
        if (faenge.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Noch keine Fänge.\nPetri Heil beim nächsten Mal! 🎣',
              textAlign: TextAlign.center,
            ),
          )
        else ...[
          _Statistik(faenge),
          for (final f in faenge)
            FangKarte(
              f,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => FangFormular(fang: f)),
              ),
            ),
        ],
      ],
    );
  }
}

class _Statistik extends StatelessWidget {
  const _Statistik(this.faenge);

  final List<Fang> faenge;

  @override
  Widget build(BuildContext context) {
    final mitLaenge = faenge.where((f) => f.laengeCm != null).toList()
      ..sort((a, b) => b.laengeCm!.compareTo(a.laengeCm!));
    final groesster = mitLaenge.isEmpty ? null : mitLaenge.first;

    String haeufigster(Iterable<String> werte) {
      final zaehler = <String, int>{};
      for (final w in werte.where((w) => w.isNotEmpty)) {
        zaehler[w] = (zaehler[w] ?? 0) + 1;
      }
      if (zaehler.isEmpty) return '–';
      return (zaehler.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)))
          .first
          .key;
    }

    final topFisch = haeufigster(faenge.map((f) => f.fischId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Zahl('${faenge.length}', 'Fänge'),
                _Zahl(
                  groesster == null
                      ? '–'
                      : '${groesster.laengeCm!.toStringAsFixed(0)} cm',
                  groesster == null
                      ? 'Größter'
                      : fischById(groesster.fischId)?.name ?? 'Größter',
                ),
                _Zahl(
                  '${faenge.where((f) => f.zurueckgesetzt).length}',
                  'Zurückgesetzt',
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Zahl(fischById(topFisch)?.name ?? '–', 'Häufigster Fisch'),
                _Zahl(haeufigster(faenge.map((f) => f.koeder)), 'Top-Köder'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Zahl extends StatelessWidget {
  const _Zahl(this.wert, this.label);

  final String wert;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Flexible(
      child: Column(
        children: [
          Text(wert, style: text.titleMedium, overflow: TextOverflow.ellipsis),
          Text(label, style: text.bodySmall, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// Karte für einen Fang – im Fangbuch und im Community-Feed.
class FangKarte extends StatelessWidget {
  const FangKarte(this.fang, {super.key, this.onTap, this.unten});

  final Fang fang;
  final VoidCallback? onTap;
  final Widget? unten;

  @override
  Widget build(BuildContext context) {
    final fisch = fischById(fang.fischId);
    final text = Theme.of(context).textTheme;
    final details = [
      if (fang.laengeCm != null) '${fang.laengeCm!.toStringAsFixed(0)} cm',
      if (fang.gewichtG != null) _gewicht(fang.gewichtG!),
      if (fang.koeder.isNotEmpty) 'Köder: ${fang.koeder}',
    ].join(' · ');
    final ort = [
      if (fang.gewaesser.isNotEmpty) fang.gewaesser,
      if (fang.bundesland.isNotEmpty) fang.bundesland,
    ].join(', ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (fang.hatFoto) FangFoto(fang.id),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(fisch?.name ?? fang.fischId,
                            style: text.titleMedium),
                      ),
                      if (fang.zurueckgesetzt)
                        const Tooltip(
                          message: 'Zurückgesetzt',
                          child: Icon(Icons.replay, size: 18),
                        ),
                      if (fang.uid.isNotEmpty && !fang.oeffentlich)
                        const Tooltip(
                          message: 'Privat',
                          child: Icon(Icons.lock_outline, size: 18),
                        ),
                    ],
                  ),
                  if (details.isNotEmpty) Text(details),
                  Text(
                    [
                      if (fang.nutzerName.isNotEmpty) fang.nutzerName,
                      datumText(fang.datum),
                      if (ort.isNotEmpty) ort,
                    ].join(' · '),
                    style: text.bodySmall,
                  ),
                  if (fang.notiz.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(fang.notiz),
                  ],
                  ?unten,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _gewicht(int g) => g >= 1000
      ? '${(g / 1000).toStringAsFixed(1).replaceAll('.', ',')} kg'
      : '$g g';
}

class FangFormular extends StatefulWidget {
  const FangFormular({super.key, this.fang});

  final Fang? fang;

  @override
  State<FangFormular> createState() => _FangFormularState();
}

class _FangFormularState extends State<FangFormular> {
  late String _fischId = widget.fang?.fischId ?? fische.first.id;
  late DateTime _datum = widget.fang?.datum ?? DateTime.now();
  late bool _zurueck = widget.fang?.zurueckgesetzt ?? false;
  late bool _oeffentlich = widget.fang?.oeffentlich ?? true;
  late Bundesland _land = Bundesland.ausName(widget.fang?.bundesland) ??
      SpeicherScope.of(context).bundesland;
  late final _laenge = TextEditingController(
    text: widget.fang?.laengeCm?.toStringAsFixed(0) ?? '',
  );
  late final _gewicht =
      TextEditingController(text: widget.fang?.gewichtG?.toString() ?? '');
  late final _gewaesser =
      TextEditingController(text: widget.fang?.gewaesser ?? '');
  late final _koeder = TextEditingController(text: widget.fang?.koeder ?? '');
  late final _notiz = TextEditingController(text: widget.fang?.notiz ?? '');
  Uint8List? _neuesFoto;
  bool _fotoEntfernen = false;
  bool _speichert = false;

  bool get _online => KontoScope.of(context)?.angemeldet ?? false;

  @override
  void dispose() {
    for (final c in [_laenge, _gewicht, _gewaesser, _koeder, _notiz]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Warnung, wenn der Fisch geschont oder untermaßig ist.
  String? _warnung() {
    if (_zurueck) return null;
    final regel = fischById(_fischId)!.regel(_land);
    if (regel.istGeschont(_datum) == true) {
      return 'Achtung: Dieser Fisch hat am ${datumText(_datum)} Schonzeit in '
          '${_land.name} – zurücksetzen!';
    }
    final laenge = double.tryParse(_laenge.text.replaceAll(',', '.'));
    final mindest = regel.mindestmassCm;
    if (laenge != null && mindest != null && laenge < mindest) {
      return 'Achtung: Unter dem Brittelmaß von $mindest cm in ${_land.name} '
          '– zurücksetzen!';
    }
    return null;
  }

  Future<void> _fotoWaehlen(ImageSource quelle) async {
    final datei = await ImagePicker().pickImage(
      source: quelle,
      maxWidth: 900,
      maxHeight: 900,
      imageQuality: 60,
    );
    if (datei == null) return;
    final bytes = await datei.readAsBytes();
    setState(() {
      _neuesFoto = bytes;
      _fotoEntfernen = false;
    });
  }

  Fang _ausFormular(String id) {
    final konto = KontoScope.of(context);
    return Fang(
      id: id,
      fischId: _fischId,
      datum: _datum,
      laengeCm: double.tryParse(_laenge.text.replaceAll(',', '.')),
      gewichtG: int.tryParse(_gewicht.text),
      gewaesser: _gewaesser.text.trim(),
      bundesland: _land.name,
      koeder: _koeder.text.trim(),
      notiz: _notiz.text.trim(),
      zurueckgesetzt: _zurueck,
      uid: konto?.uid ?? '',
      nutzerName: konto?.name ?? '',
      oeffentlich: _oeffentlich,
    );
  }

  Future<void> _speichern() async {
    setState(() => _speichert = true);
    try {
      if (_online) {
        await fangDienst.speichern(
          _ausFormular(widget.fang?.id ?? ''),
          vorher: widget.fang,
          foto: _neuesFoto,
          fotoEntfernen: _fotoEntfernen,
        );
      } else {
        final speicher = SpeicherScope.of(context);
        await speicher.fangSpeichern(
          _ausFormular(widget.fang?.id ?? speicher.neueId()),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _speichert = false);
        meldung(context, 'Speichern fehlgeschlagen: $e');
      }
    }
  }

  Future<void> _loeschen() async {
    final fang = widget.fang!;
    if (_online) {
      await fangDienst.loeschen(fang);
    } else {
      await SpeicherScope.of(context).fangLoeschen(fang.id);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final warnung = _warnung();
    final online = _online;
    final zeigeAltesFoto =
        widget.fang?.hatFoto == true && _neuesFoto == null && !_fotoEntfernen;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fang == null ? 'Neuer Fang' : 'Fang bearbeiten'),
        actions: [
          if (widget.fang != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _loeschen,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (online) ...[
            if (_neuesFoto != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(_neuesFoto!, height: 220,
                    fit: BoxFit.cover),
              )
            else if (zeigeAltesFoto)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FangFoto(widget.fang!.id),
              ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _fotoWaehlen(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Foto'),
                ),
                TextButton.icon(
                  onPressed: () => _fotoWaehlen(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galerie'),
                ),
                if (_neuesFoto != null || zeigeAltesFoto)
                  IconButton(
                    tooltip: 'Foto entfernen',
                    onPressed: () => setState(() {
                      _neuesFoto = null;
                      _fotoEntfernen = true;
                    }),
                    icon: const Icon(Icons.hide_image_outlined),
                  ),
              ],
            ),
          ],
          DropdownButtonFormField<String>(
            initialValue: _fischId,
            decoration: const InputDecoration(labelText: 'Fischart'),
            items: [
              for (final f in fische)
                DropdownMenuItem(value: f.id, child: Text(f.name)),
            ],
            onChanged: (v) => setState(() => _fischId = v!),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _laenge,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Länge (cm)'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _gewicht,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Gewicht (g)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Autocomplete<String>(
            initialValue: TextEditingValue(text: _gewaesser.text),
            optionsBuilder: (v) => gewaesserListe
                .map((g) => g.name)
                .where((n) => n.toLowerCase().contains(v.text.toLowerCase())),
            onSelected: (v) {
              _gewaesser.text = v;
              final g = gewaesserListe.firstWhere((g) => g.name == v);
              setState(() => _land = g.land);
            },
            fieldViewBuilder: (context, controller, focus, _) => TextField(
              controller: controller,
              focusNode: focus,
              decoration: const InputDecoration(labelText: 'Gewässer'),
              onChanged: (v) => _gewaesser.text = v,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Bundesland>(
            key: ValueKey(_land),
            initialValue: _land,
            decoration: const InputDecoration(labelText: 'Bundesland'),
            items: [
              for (final b in Bundesland.values)
                DropdownMenuItem(value: b, child: Text(b.name)),
            ],
            onChanged: (v) => setState(() => _land = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _koeder,
            decoration: const InputDecoration(labelText: 'Köder'),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: Text('Datum: ${datumText(_datum)}'),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _datum,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (d != null) setState(() => _datum = d);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Zurückgesetzt'),
            value: _zurueck,
            onChanged: (v) => setState(() => _zurueck = v),
          ),
          if (online)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Öffentlich teilen'),
              subtitle: const Text('In der Community sichtbar'),
              value: _oeffentlich,
              onChanged: (v) => setState(() => _oeffentlich = v),
            ),
          TextField(
            controller: _notiz,
            maxLines: 3,
            maxLength: 500,
            decoration: const InputDecoration(labelText: 'Notiz (Wetter …)'),
          ),
          if (warnung != null) ...[
            const SizedBox(height: 12),
            HinweisKarte(warnung, icon: Icons.warning_amber),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _speichert ? null : _speichern,
            child: _speichert
                ? const SizedBox.square(
                    dimension: 20, child: CircularProgressIndicator())
                : const Text('Speichern'),
          ),
        ],
      ),
    );
  }
}
