import 'package:flutter/material.dart';

import '../data/fische.dart';
import '../data/gewaesser.dart';
import '../main.dart';
import '../models/fang.dart';
import 'widgets.dart';

String datumText(DateTime d) => '${d.day}.${d.month}.${d.year}';

class FangbuchScreen extends StatelessWidget {
  const FangbuchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faenge = SpeicherScope.of(context).faenge;

    return Scaffold(
      appBar: AppBar(title: const Text('Fangbuch')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FangFormular()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Fang eintragen'),
      ),
      body: faenge.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Noch keine Fänge.\nPetri Heil beim nächsten Mal! 🎣',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              children: [
                _Statistik(faenge),
                for (final f in faenge) _FangKachel(f),
              ],
            ),
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

    final koederZaehler = <String, int>{};
    for (final f in faenge.where((f) => f.koeder.isNotEmpty)) {
      koederZaehler[f.koeder] = (koederZaehler[f.koeder] ?? 0) + 1;
    }
    final topKoeder = koederZaehler.entries.isEmpty
        ? '–'
        : (koederZaehler.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
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
            _Zahl(topKoeder, 'Top-Köder'),
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
          Text(wert, style: text.titleLarge, overflow: TextOverflow.ellipsis),
          Text(label, style: text.bodySmall, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _FangKachel extends StatelessWidget {
  const _FangKachel(this.fang);

  final Fang fang;

  @override
  Widget build(BuildContext context) {
    final fisch = fischById(fang.fischId);
    final details = [
      if (fang.laengeCm != null) '${fang.laengeCm!.toStringAsFixed(0)} cm',
      if (fang.gewichtG != null) '${fang.gewichtG} g',
      if (fang.gewaesser.isNotEmpty) fang.gewaesser,
      if (fang.koeder.isNotEmpty) fang.koeder,
    ].join(' · ');

    return Card(
      child: ListTile(
        leading: Icon(fang.zurueckgesetzt ? Icons.replay : Icons.set_meal),
        title: Text(fisch?.name ?? fang.fischId),
        subtitle: Text(
          [datumText(fang.datum), if (details.isNotEmpty) details].join('\n'),
        ),
        isThreeLine: details.isNotEmpty,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => FangFormular(fang: fang)),
        ),
      ),
    );
  }
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
  late final _laenge = TextEditingController(
    text: widget.fang?.laengeCm?.toStringAsFixed(0) ?? '',
  );
  late final _gewicht =
      TextEditingController(text: widget.fang?.gewichtG?.toString() ?? '');
  late final _gewaesser =
      TextEditingController(text: widget.fang?.gewaesser ?? '');
  late final _koeder = TextEditingController(text: widget.fang?.koeder ?? '');
  late final _notiz = TextEditingController(text: widget.fang?.notiz ?? '');

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
    final land = SpeicherScope.of(context).bundesland;
    final regel = fischById(_fischId)!.regel(land);
    if (regel.istGeschont(_datum) == true) {
      return 'Achtung: Dieser Fisch hat am ${datumText(_datum)} Schonzeit in '
          '${land.name} – zurücksetzen!';
    }
    final laenge = double.tryParse(_laenge.text.replaceAll(',', '.'));
    final mindest = regel.mindestmassCm;
    if (laenge != null && mindest != null && laenge < mindest) {
      return 'Achtung: Unter dem Brittelmaß von $mindest cm in ${land.name} – '
          'zurücksetzen!';
    }
    return null;
  }

  Future<void> _speichern() async {
    final speicher = SpeicherScope.of(context);
    await speicher.fangSpeichern(
      Fang(
        id: widget.fang?.id ?? speicher.neueId(),
        fischId: _fischId,
        datum: _datum,
        laengeCm: double.tryParse(_laenge.text.replaceAll(',', '.')),
        gewichtG: int.tryParse(_gewicht.text),
        gewaesser: _gewaesser.text.trim(),
        koeder: _koeder.text.trim(),
        notiz: _notiz.text.trim(),
        zurueckgesetzt: _zurueck,
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final warnung = _warnung();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fang == null ? 'Neuer Fang' : 'Fang bearbeiten'),
        actions: [
          if (widget.fang != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                SpeicherScope.of(context).fangLoeschen(widget.fang!.id);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
            onSelected: (v) => _gewaesser.text = v,
            fieldViewBuilder: (context, controller, focus, _) => TextField(
              controller: controller,
              focusNode: focus,
              decoration: const InputDecoration(labelText: 'Gewässer'),
              onChanged: (v) => _gewaesser.text = v,
            ),
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
          TextField(
            controller: _notiz,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Notiz (Wetter …)'),
          ),
          if (warnung != null) ...[
            const SizedBox(height: 12),
            HinweisKarte(warnung, icon: Icons.warning_amber),
          ],
          const SizedBox(height: 20),
          FilledButton(onPressed: _speichern, child: const Text('Speichern')),
        ],
      ),
    );
  }
}
