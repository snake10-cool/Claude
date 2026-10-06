import 'package:app_basis/app_basis.dart';

import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../daten/produkt_details.dart';
import '../daten/vorlagen.dart';
import '../l10n/l.dart';
import '../logik/kalkulation.dart';
import '../widgets/allgemein.dart';
import '../widgets/format.dart';
import 'drucker_screen.dart';
import 'extras_screen.dart';
import 'filamente_screen.dart';

/// Produkt anlegen oder bearbeiten, mit Live-Kalkulation.
class ProduktBearbeitenScreen extends StatefulWidget {
  const ProduktBearbeitenScreen({super.key, this.produkt, this.kopie = false});

  /// `null` = neues Produkt.
  final ProduktDetails? produkt;

  /// Werte von [produkt] übernehmen, aber als neues Produkt speichern.
  final bool kopie;

  @override
  State<ProduktBearbeitenScreen> createState() =>
      _ProduktBearbeitenScreenState();
}

class _FilamentZeile {
  _FilamentZeile(this.filamentId, double gramm)
    : gramm = TextEditingController(text: gramm == 0 ? '' : zahl(gramm));
  int filamentId;
  final TextEditingController gramm;
}

class _ProduktBearbeitenScreenState extends State<ProduktBearbeitenScreen> {
  final _form = GlobalKey<FormState>();
  final _abos = <StreamSubscription<Object?>>[];

  List<Drucker> _drucker = [];
  List<Filament> _filamente = [];
  List<Extra> _extras = [];
  Einstellungen? _einstellungen;

  late final _name = TextEditingController();
  late final _stunden = TextEditingController();
  late final _minuten = TextEditingController();
  late final _stueck = TextEditingController(text: '1');
  late final _spuel = TextEditingController();
  late final _arbeit = TextEditingController();
  late final _preis = TextEditingController();
  String _symbol = '📦';
  int? _druckerId;
  int? _aufschlag; // null = Standard
  final _filamentZeilen = <_FilamentZeile>[];
  final _extraMengen = <int, int>{};

  bool get _bearbeiten => widget.produkt != null && !widget.kopie;

  @override
  void initState() {
    super.initState();
    final p = widget.produkt;
    if (p != null) {
      final pr = p.produkt;
      _name.text = widget.kopie ? '${pr.name} (2)' : pr.name;
      _symbol = pr.symbol;
      _druckerId = pr.druckerId;
      _stunden.text = '${pr.druckzeitMinuten ~/ 60}';
      _minuten.text = '${pr.druckzeitMinuten % 60}';
      _stueck.text = '${pr.stueckProDruck}';
      _spuel.text = pr.spuelabfallGramm == 0 ? '' : zahl(pr.spuelabfallGramm);
      _arbeit.text = pr.arbeitMinuten == 0 ? '' : '${pr.arbeitMinuten}';
      _aufschlag = pr.aufschlagProzent;
      _preis.text = pr.preisManuellCent == null
          ? ''
          : euroFeld(pr.preisManuellCent!);
      for (final (pf, _) in p.filamente) {
        _filamentZeilen.add(_FilamentZeile(pf.filamentId, pf.gramm));
      }
      for (final (pe, _) in p.extras) {
        _extraMengen[pe.extraId] = pe.menge;
      }
    }
    _abos.addAll([
      db.druckerBeobachten().listen(
        (d) => setState(() {
          _drucker = d;
          // Neuer Artikel: ersten Drucker vorschlagen.
          if (widget.produkt == null && _druckerId == null && d.isNotEmpty) {
            _druckerId = d.first.id;
          }
        }),
      ),
      db.filamenteBeobachten().listen(
        (f) => setState(() {
          _filamente = f;
          if (widget.produkt == null &&
              _filamentZeilen.isEmpty &&
              f.isNotEmpty) {
            _filamentZeilen.add(_FilamentZeile(f.first.id, 0));
          }
        }),
      ),
      db.extrasBeobachten().listen((e) => setState(() => _extras = e)),
      db.einstellungenBeobachten().listen(
        (e) => setState(() => _einstellungen = e),
      ),
    ]);
  }

  @override
  void dispose() {
    for (final a in _abos) {
      a.cancel();
    }
    for (final c in [
      _name,
      _stunden,
      _minuten,
      _stueck,
      _spuel,
      _arbeit,
      _preis,
    ]) {
      c.dispose();
    }
    for (final z in _filamentZeilen) {
      z.gramm.dispose();
    }
    super.dispose();
  }

  int get _druckzeit =>
      (int.tryParse(_stunden.text) ?? 0) * 60 +
      (int.tryParse(_minuten.text) ?? 0);

  Filament? _filament(int id) =>
      _filamente.where((f) => f.id == id).firstOrNull;

  Drucker? get _gewaehlterDrucker =>
      _drucker.where((d) => d.id == _druckerId).firstOrNull;

  KalkulationsEingabe _eingabe(Einstellungen e) {
    final d = _gewaehlterDrucker;
    return KalkulationsEingabe(
      druckzeitMinuten: _druckzeit,
      stueckProDruck: int.tryParse(_stueck.text) ?? 1,
      filamente: [
        for (final z in _filamentZeilen)
          if (_filament(z.filamentId) case final f?)
            FilamentAnteil(
              gramm: parseKomma(z.gramm.text) ?? 0,
              preisProKgCent: f.preisProKgCent,
            ),
      ],
      spuelabfallGramm: parseKomma(_spuel.text) ?? 0,
      drucker: d == null
          ? null
          : DruckerWerte(
              leistungWatt: d.leistungWatt,
              anschaffungCent: d.anschaffungCent,
              lebensdauerStunden: d.lebensdauerStunden,
            ),
      strompreisCentProKwh: e.strompreisCentProKwh,
      extrasCent: _extraMengen.entries.fold(0, (s, x) {
        final extra = _extras.where((e) => e.id == x.key).firstOrNull;
        return s + (extra?.kostenCent ?? 0) * x.value;
      }),
      arbeitMinuten: int.tryParse(_arbeit.text) ?? 0,
      stundenlohnCent: e.stundenlohnCent,
      fehldruckProzent: e.fehldruckProzent,
    );
  }

  Future<void> _speichern() async {
    if (!_form.currentState!.validate()) return;
    final farbe = _filamentZeilen.isNotEmpty
        ? (_filament(_filamentZeilen.first.filamentId)?.farbe ?? 0xFF9E9E9E)
        : 0xFF9E9E9E;
    final companion = ProduktTabelleCompanion(
      id: _bearbeiten
          ? Value(widget.produkt!.produkt.id)
          : const Value.absent(),
      name: Value(_name.text.trim()),
      symbol: Value(_symbol),
      farbe: Value(farbe),
      druckerId: Value(_druckerId),
      druckzeitMinuten: Value(_druckzeit),
      stueckProDruck: Value((int.tryParse(_stueck.text) ?? 1).clamp(1, 999)),
      spuelabfallGramm: Value(parseKomma(_spuel.text) ?? 0),
      arbeitMinuten: Value(int.tryParse(_arbeit.text) ?? 0),
      aufschlagProzent: Value(_aufschlag),
      preisManuellCent: Value(parseEuro(_preis.text)),
      sortierung: _bearbeiten
          ? Value(widget.produkt!.produkt.sortierung)
          : const Value(9999),
    );
    await db.produktSpeichern(
      companion,
      filamente: [
        for (final z in _filamentZeilen)
          if ((parseKomma(z.gramm.text) ?? 0) > 0)
            (z.filamentId, parseKomma(z.gramm.text)!),
      ],
      extras: [
        for (final e in _extraMengen.entries)
          if (e.value > 0) (e.key, e.value),
      ],
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _archivieren() async {
    final l = context.l;
    final ok = await bestaetigen(
      context,
      titel: l.produktArchivieren,
      text: l.produktArchivierenText,
      ja: l.archivieren,
    );
    if (!ok) return;
    await db.produktArchivieren(widget.produkt!.produkt.id);
    if (mounted) Navigator.pop(context);
  }

  void _duplizieren() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) =>
            ProduktBearbeitenScreen(produkt: widget.produkt, kopie: true),
      ),
    );
  }

  Future<void> _symbolWaehlen() async {
    final gewaehlt = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => GridView.count(
        crossAxisCount: 6,
        padding: const EdgeInsets.all(12),
        shrinkWrap: true,
        children: [
          for (final s in produktSymbole)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context, s),
              child: Center(
                child: Text(s, style: const TextStyle(fontSize: 30)),
              ),
            ),
        ],
      ),
    );
    if (gewaehlt != null) setState(() => _symbol = gewaehlt);
  }

  void _oeffnen(Widget seite) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => seite));

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final e = _einstellungen;
    void neu([_]) => setState(() {});

    return Scaffold(
      appBar: AppBar(
        title: Text(_bearbeiten ? l.produktBearbeiten : l.neuesProdukt),
        actions: [
          if (_bearbeiten)
            PopupMenuButton<String>(
              onSelected: (w) => w == 'kopie' ? _duplizieren() : _archivieren(),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'kopie', child: Text(l.duplizieren)),
                if (!widget.produkt!.produkt.archiviert)
                  PopupMenuItem(value: 'archiv', child: Text(l.archivieren)),
              ],
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
      body: e == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: _symbolWaehlen,
                          borderRadius: BorderRadius.circular(40),
                          child: SymbolKreis(
                            symbol: _symbol,
                            farbe: Color(
                              _filamentZeilen.isNotEmpty
                                  ? (_filament(_filamentZeilen.first.filamentId)
                                            ?.farbe ??
                                        0xFF9E9E9E)
                                  : 0xFF9E9E9E,
                            ),
                            groesse: 56,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _name,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(labelText: l.name),
                            validator: (t) =>
                                (t ?? '').trim().isEmpty ? l.pflichtfeld : null,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Abschnitt(l.druck),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _drucker.isEmpty
                            ? OutlinedButton.icon(
                                onPressed: () =>
                                    _oeffnen(const DruckerScreen()),
                                icon: const Icon(Icons.add),
                                label: Text(l.druckerAnlegen),
                              )
                            : DropdownButtonFormField<int?>(
                                initialValue: _druckerId,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: l.drucker,
                                ),
                                items: [
                                  for (final d in _drucker)
                                    DropdownMenuItem(
                                      value: d.id,
                                      child: Text(d.name),
                                    ),
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text(l.ohneDrucker),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _druckerId = v),
                              ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ZahlFeld(
                                controller: _stunden,
                                label: l.stunden,
                                suffix: 'h',
                                pflicht: false,
                                onChanged: neu,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ZahlFeld(
                                controller: _minuten,
                                label: l.minuten,
                                suffix: 'min',
                                pflicht: false,
                                onChanged: neu,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ZahlFeld(
                          controller: _stueck,
                          label: l.stueckProDruck,
                          hilfe: l.stueckProDruckHilfe,
                          onChanged: neu,
                        ),
                      ],
                    ),
                  ),

                  Abschnitt(
                    l.filamente,
                    trailing: TextButton.icon(
                      onPressed: _filamente.isEmpty
                          ? () => _oeffnen(const FilamenteScreen())
                          : () => setState(
                              () => _filamentZeilen.add(
                                _FilamentZeile(_filamente.first.id, 0),
                              ),
                            ),
                      icon: const Icon(Icons.add),
                      label: Text(
                        _filamente.isEmpty
                            ? l.filamentAnlegen
                            : l.farbeHinzufuegen,
                      ),
                    ),
                  ),
                  for (final z in _filamentZeilen)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 4, 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<int>(
                              initialValue: _filament(z.filamentId) == null
                                  ? null
                                  : z.filamentId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: l.filament,
                              ),
                              items: [
                                for (final f in _filamente)
                                  DropdownMenuItem(
                                    value: f.id,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 8,
                                          backgroundColor: Color(f.farbe),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            f.name,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                              onChanged: (v) => setState(
                                () => z.filamentId = v ?? z.filamentId,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: ZahlFeld(
                              controller: z.gramm,
                              label: l.gramm,
                              suffix: 'g',
                              komma: true,
                              onChanged: neu,
                            ),
                          ),
                          IconButton(
                            tooltip: l.entfernen,
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() {
                              _filamentZeilen.remove(z);
                              z.gramm.dispose();
                            }),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l.grammHilfe,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (_filamentZeilen.length > 1) ...[
                          const SizedBox(height: 12),
                          ZahlFeld(
                            controller: _spuel,
                            label: l.spuelabfall,
                            suffix: 'g',
                            komma: true,
                            pflicht: false,
                            hilfe: l.spuelabfallHilfe,
                            onChanged: neu,
                          ),
                        ],
                      ],
                    ),
                  ),

                  Abschnitt(
                    l.extrasUndArbeit,
                    trailing: TextButton.icon(
                      onPressed: () => _oeffnen(const ExtrasScreen()),
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(l.extrasVerwalten),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_extras.isEmpty)
                          Text(
                            l.keineExtras,
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final x in _extras)
                                FilterChip(
                                  label: Text(
                                    '${(_extraMengen[x.id] ?? 0) > 1 ? '${_extraMengen[x.id]}× ' : ''}${x.name} (${euro(x.kostenCent)})',
                                  ),
                                  selected: (_extraMengen[x.id] ?? 0) > 0,
                                  onSelected: (an) => setState(
                                    () => an
                                        ? _extraMengen[x.id] = 1
                                        : _extraMengen.remove(x.id),
                                  ),
                                ),
                            ],
                          ),
                        const SizedBox(height: 12),
                        ZahlFeld(
                          controller: _arbeit,
                          label: l.arbeitProStueck,
                          suffix: 'min',
                          pflicht: false,
                          hilfe: e.stundenlohnCent == 0
                              ? l.arbeitHilfeOhneLohn
                              : l.arbeitHilfe(euro(e.stundenlohnCent)),
                          onChanged: neu,
                        ),
                      ],
                    ),
                  ),

                  Abschnitt(l.preis),
                  _PreisBereich(
                    eingabe: _eingabe(e),
                    einstellungen: e,
                    aufschlag: _aufschlag,
                    preisController: _preis,
                    aufschlagGeaendert: (a) => setState(() => _aufschlag = a),
                    preisGeaendert: neu,
                  ),
                ],
              ),
            ),
    );
  }
}

/// Aufschlüsselung der Kosten, Aufschlag-Regler, Preisvorschlag, Gewinn.
class _PreisBereich extends StatelessWidget {
  const _PreisBereich({
    required this.eingabe,
    required this.einstellungen,
    required this.aufschlag,
    required this.preisController,
    required this.aufschlagGeaendert,
    required this.preisGeaendert,
  });

  final KalkulationsEingabe eingabe;
  final Einstellungen einstellungen;
  final int? aufschlag;
  final TextEditingController preisController;
  final ValueChanged<int?> aufschlagGeaendert;
  final ValueChanged<String> preisGeaendert;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    final k = berechneKosten(eingabe);
    final kosten = k.gesamtCent;
    final a = aufschlag ?? einstellungen.standardAufschlagProzent;
    final vorschlag = preisVorschlag(
      kostenCent: kosten,
      aufschlagProzent: a,
      rundungCent: einstellungen.rundungCent,
    );
    final manuell = parseEuro(preisController.text);
    final preis = manuell ?? vorschlag;
    final gewinn = preis - kosten;

    Widget zeile(String text, double cent, {bool fett = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(text)),
          Text(
            euro(cent.round()),
            style: fett ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  zeile(l.kostenMaterial, k.material),
                  zeile(l.kostenStrom, k.strom),
                  zeile(l.kostenAbnutzung, k.abnutzung),
                  if (k.fehldruck > 0)
                    zeile(
                      l.kostenFehldruck(einstellungen.fehldruckProzent),
                      k.fehldruck,
                    ),
                  if (k.extras > 0) zeile(l.kostenExtras, k.extras),
                  if (k.arbeit > 0) zeile(l.kostenArbeit, k.arbeit),
                  const Divider(),
                  zeile(l.kostenProStueck, k.summe, fett: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(l.aufschlag(a), style: t.textTheme.titleSmall),
              ),
              if (aufschlag != null)
                TextButton(
                  onPressed: () => aufschlagGeaendert(null),
                  child: Text(l.standardNehmen),
                ),
            ],
          ),
          Slider(
            value: a.clamp(0, 500).toDouble(),
            min: 0,
            max: 500,
            divisions: 50,
            label: '$a %',
            onChanged: (v) => aufschlagGeaendert(v.round()),
          ),
          Text(l.vorschlag(euro(vorschlag)), style: t.textTheme.bodyMedium),
          const SizedBox(height: 12),
          EuroFeld(
            controller: preisController,
            label: l.eigenerPreis,
            hilfe: l.eigenerPreisHilfe,
            onChanged: preisGeaendert,
          ),
          const SizedBox(height: 16),
          Card(
            color: gewinn > 0
                ? t.colorScheme.primaryContainer
                : t.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.verkaufspreis, style: t.textTheme.bodySmall),
                        Text(
                          euro(preis),
                          style: t.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l.gewinnProStueck(euro(gewinn)),
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l.margeVomPreis(
                          margeVomPreis(
                            preisCent: preis,
                            kostenCent: kosten,
                          ).round(),
                        ),
                        style: t.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
