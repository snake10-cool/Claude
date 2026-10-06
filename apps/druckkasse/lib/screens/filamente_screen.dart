import 'package:app_basis/app_basis.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../daten/vorlagen.dart';
import '../l10n/l.dart';
import '../widgets/allgemein.dart';
import '../widgets/format.dart';

class FilamenteScreen extends StatelessWidget {
  const FilamenteScreen({super.key});

  void _oeffnen(BuildContext context, [Filament? f]) => Navigator.of(context)
      .push(
        MaterialPageRoute<void>(
          builder: (_) => FilamentBearbeitenScreen(filament: f),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.filamente)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _oeffnen(context),
        icon: const Icon(Icons.add),
        label: Text(l.filamentAnlegen),
      ),
      body: StreamBuilder<List<Filament>>(
        stream: db.filamenteBeobachten(),
        builder: (context, snap) {
          final liste = snap.data ?? const <Filament>[];
          if (snap.hasData && liste.isEmpty) {
            return LeerHinweis(
              symbol: Icons.circle_outlined,
              titel: l.keineFilamente,
              text: l.keineFilamenteText,
              knopf: l.filamentAnlegen,
              aktion: () => _oeffnen(context),
            );
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              for (final f in liste)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(f.farbe),
                    child: Icon(
                      Icons.blur_circular,
                      color:
                          ThemeData.estimateBrightnessForColor(
                                Color(f.farbe),
                              ) ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black54,
                    ),
                  ),
                  title: Text(f.name),
                  subtitle: Text(
                    '${f.material} · ${l.proKg(euro(f.preisProKgCent))}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _oeffnen(context, f),
                ),
            ],
          );
        },
      ),
    );
  }
}

class FilamentBearbeitenScreen extends StatefulWidget {
  const FilamentBearbeitenScreen({super.key, this.filament});
  final Filament? filament;

  @override
  State<FilamentBearbeitenScreen> createState() =>
      _FilamentBearbeitenScreenState();
}

class _FilamentBearbeitenScreenState extends State<FilamentBearbeitenScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.filament?.name);
  late final _preis = TextEditingController(
    text: euroFeld(widget.filament?.preisProKgCent ?? 1999),
  );
  late String _material = widget.filament?.material ?? materialien.first;
  late int _farbe = widget.filament?.farbe ?? filamentFarben[3].$2.toARGB32();
  bool _nameGeaendert = false;

  @override
  void initState() {
    super.initState();
    _nameGeaendert = widget.filament != null;
  }

  @override
  void dispose() {
    _name.dispose();
    _preis.dispose();
    super.dispose();
  }

  /// Name automatisch vorschlagen („PLA Rot“), solange er nicht selbst
  /// geändert wurde.
  void _namenVorschlagen() {
    if (_nameGeaendert) return;
    final farbe = filamentFarben
        .where((f) => f.$2.toARGB32() == _farbe)
        .map((f) => f.$1)
        .firstOrNull;
    _name.text = [_material, ?farbe].join(' ');
  }

  Future<void> _speichern() async {
    if (!_form.currentState!.validate()) return;
    await db.filamentSpeichern(
      FilamentTabelleCompanion(
        id: widget.filament == null
            ? const Value.absent()
            : Value(widget.filament!.id),
        name: Value(_name.text.trim()),
        material: Value(_material),
        farbe: Value(_farbe),
        preisProKgCent: Value(parseEuro(_preis.text) ?? 0),
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _entfernen() async {
    final l = context.l;
    if (!await bestaetigen(
      context,
      titel: l.filamentEntfernen,
      text: l.filamentEntfernenText,
    )) {
      return;
    }
    await db.filamentArchivieren(widget.filament!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    if (_name.text.isEmpty && !_nameGeaendert) _namenVorschlagen();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.filament == null ? l.filamentAnlegen : l.filamentBearbeiten,
        ),
        actions: [
          if (widget.filament != null)
            IconButton(
              tooltip: l.loeschen,
              icon: const Icon(Icons.delete_outline),
              onPressed: _entfernen,
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: _speichern,
            icon: const Icon(Icons.check),
            label: Text(l.speichern),
          ),
        ),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.material, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in materialien)
                  ChoiceChip(
                    label: Text(m),
                    selected: _material == m,
                    onSelected: (_) => setState(() {
                      _material = m;
                      _namenVorschlagen();
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(l.farbe, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final (name, farbe) in filamentFarben)
                  Tooltip(
                    message: name,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => setState(() {
                        _farbe = farbe.toARGB32();
                        _namenVorschlagen();
                      }),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: farbe,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _farbe == farbe.toARGB32()
                                ? Theme.of(context).colorScheme.primary
                                : Colors.black26,
                            width: _farbe == farbe.toARGB32() ? 4 : 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(
                labelText: l.name,
                helperText: l.filamentNameHilfe,
              ),
              onChanged: (_) => _nameGeaendert = true,
              validator: (t) => (t ?? '').trim().isEmpty ? l.pflichtfeld : null,
            ),
            const SizedBox(height: 12),
            EuroFeld(
              controller: _preis,
              label: l.preisProKg,
              pflicht: true,
              hilfe: l.preisProKgHilfe,
            ),
          ],
        ),
      ),
    );
  }
}
