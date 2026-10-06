import 'package:app_basis/app_basis.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../daten/produkt_details.dart';
import '../l10n/l.dart';
import '../logik/typen.dart';
import '../widgets/allgemein.dart';
import '../widgets/format.dart';
import 'auftraege_screen.dart';
import 'verkaufen_screen.dart';

class _Position {
  _Position({
    required this.produktId,
    required this.name,
    required this.symbol,
    required this.menge,
    required int preis,
    String notiz = '',
  }) : preis = TextEditingController(text: euroFeld(preis)),
       notiz = TextEditingController(text: notiz);

  final int produktId;
  final String name;
  final String symbol;
  int menge;
  final TextEditingController preis;
  final TextEditingController notiz;

  void dispose() {
    preis.dispose();
    notiz.dispose();
  }
}

class AuftragBearbeitenScreen extends StatefulWidget {
  const AuftragBearbeitenScreen({super.key, this.auftrag});
  final AuftragDetails? auftrag;

  @override
  State<AuftragBearbeitenScreen> createState() =>
      _AuftragBearbeitenScreenState();
}

class _AuftragBearbeitenScreenState extends State<AuftragBearbeitenScreen> {
  final _form = GlobalKey<FormState>();
  late final _kunde = TextEditingController(
    text: widget.auftrag?.auftrag.kunde,
  );
  late final _kontakt = TextEditingController(
    text: widget.auftrag?.auftrag.kontakt,
  );
  late final _notiz = TextEditingController(
    text: widget.auftrag?.auftrag.notiz,
  );
  late DateTime? _faellig = widget.auftrag?.auftrag.faelligAm;
  late AuftragStatus _status = widget.auftrag?.status ?? AuftragStatus.offen;
  late bool _bezahlt = widget.auftrag?.bezahlt ?? false;
  late Zahlungsart _art =
      Zahlungsart.values[widget.auftrag?.auftrag.zahlungsart ?? 0];
  final _positionen = <_Position>[];

  @override
  void initState() {
    super.initState();
    for (final (pos, produkt)
        in widget.auftrag?.positionen ??
            const <(AuftragPosition, Produkt?)>[]) {
      _positionen.add(
        _Position(
          produktId: pos.produktId,
          name: produkt?.name ?? '?',
          symbol: produkt?.symbol ?? '📦',
          menge: pos.menge,
          preis: pos.einzelpreisCent,
          notiz: pos.notiz,
        ),
      );
    }
    if (widget.auftrag == null) {
      db.einstellungenLesen().then((e) {
        if (mounted) {
          setState(() => _art = Zahlungsart.values[e.standardZahlungsart]);
        }
      });
    }
  }

  @override
  void dispose() {
    _kunde.dispose();
    _kontakt.dispose();
    _notiz.dispose();
    for (final p in _positionen) {
      p.dispose();
    }
    super.dispose();
  }

  int get _summe => _positionen.fold(
    0,
    (s, p) => s + p.menge * (parseEuro(p.preis.text) ?? 0),
  );

  Future<void> _produktHinzufuegen() async {
    final produkte = await db.produkteLaden();
    if (!mounted) return;
    final p = await showModalBottomSheet<ProduktDetails>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, scroll) => ListView(
          controller: scroll,
          children: [
            if (produkte.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  context.l.keineProdukte,
                  textAlign: TextAlign.center,
                ),
              ),
            for (final p in produkte)
              ListTile(
                leading: SymbolKreis(
                  symbol: p.produkt.symbol,
                  farbe: Color(p.anzeigeFarbe),
                ),
                title: Text(p.produkt.name),
                trailing: Text(euro(p.preisCent)),
                onTap: () => Navigator.pop(context, p),
              ),
          ],
        ),
      ),
    );
    if (p == null) return;
    setState(
      () => _positionen.add(
        _Position(
          produktId: p.produkt.id,
          name: p.produkt.name,
          symbol: p.produkt.symbol,
          menge: 1,
          preis: p.preisCent,
        ),
      ),
    );
  }

  Future<void> _datumWaehlen() async {
    final jetzt = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _faellig ?? jetzt.add(const Duration(days: 3)),
      firstDate: DateTime(jetzt.year - 1),
      lastDate: DateTime(jetzt.year + 2),
    );
    if (d != null) setState(() => _faellig = d);
  }

  Future<void> _speichern() async {
    if (!_form.currentState!.validate()) return;
    final l = context.l;
    if (_positionen.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.mindestensEinProdukt)));
      return;
    }
    final alt = widget.auftrag?.auftrag;
    final id = await db.auftragSpeichern(
      AuftragTabelleCompanion(
        id: alt == null ? const Value.absent() : Value(alt.id),
        kunde: Value(_kunde.text.trim()),
        kontakt: Value(_kontakt.text.trim()),
        notiz: Value(_notiz.text.trim()),
        erstelltAm: Value(alt?.erstelltAm ?? DateTime.now()),
        faelligAm: Value(_faellig),
        status: Value(_status.index),
        zahlungsart: Value(_art.index),
        bezahltAm: Value(alt?.bezahltAm),
      ),
      [
        for (final p in _positionen)
          AuftragPositionTabelleCompanion.insert(
            auftragId: alt?.id ?? 0,
            produktId: p.produktId,
            menge: p.menge,
            einzelpreisCent: parseEuro(p.preis.text) ?? 0,
            notiz: Value(p.notiz.text.trim()),
          ),
      ],
    );
    // „Bezahlt“ getrennt setzen, damit die Verkäufe entstehen oder
    // verschwinden.
    if (_bezahlt != (alt?.bezahltAm != null)) {
      await db.auftragBezahltSetzen(id, _bezahlt);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _loeschen() async {
    final l = context.l;
    if (!await bestaetigen(
      context,
      titel: l.auftragLoeschen,
      text: l.auftragLoeschenText,
    )) {
      return;
    }
    await db.auftragLoeschen(widget.auftrag!.auftrag.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.auftrag == null ? l.neuerAuftrag : l.auftragBearbeiten,
        ),
        actions: [
          if (widget.auftrag != null)
            IconButton(
              tooltip: l.loeschen,
              icon: const Icon(Icons.delete_outline),
              onPressed: _loeschen,
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: _speichern,
            icon: const Icon(Icons.check),
            label: Text('${l.speichern} · ${euro(_summe)}'),
          ),
        ),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _kunde,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: l.kunde,
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (t) =>
                        (t ?? '').trim().isEmpty ? l.pflichtfeld : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _kontakt,
                    decoration: InputDecoration(
                      labelText: l.kontaktFeld,
                      prefixIcon: const Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event),
                    title: Text(
                      _faellig == null
                          ? l.keinTermin
                          : l.faelligAm(datum(_faellig!)),
                    ),
                    trailing: _faellig == null
                        ? null
                        : IconButton(
                            tooltip: l.entfernen,
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() => _faellig = null),
                          ),
                    onTap: _datumWaehlen,
                  ),
                ],
              ),
            ),
            Abschnitt(
              l.positionen,
              trailing: TextButton.icon(
                onPressed: _produktHinzufuegen,
                icon: const Icon(Icons.add),
                label: Text(l.produktHinzufuegen),
              ),
            ),
            for (final p in _positionen)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              p.symbol,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                p.name,
                                style: t.textTheme.titleMedium,
                              ),
                            ),
                            IconButton(
                              onPressed: p.menge > 1
                                  ? () => setState(() => p.menge--)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('${p.menge}', style: t.textTheme.titleMedium),
                            IconButton(
                              onPressed: () => setState(() => p.menge++),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                            IconButton(
                              tooltip: l.entfernen,
                              onPressed: () => setState(() {
                                _positionen.remove(p);
                                p.dispose();
                              }),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: EuroFeld(
                                  controller: p.preis,
                                  label: l.preisProStueck,
                                  pflicht: true,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: p.notiz,
                                  decoration: InputDecoration(
                                    labelText: l.notizPosition,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_positionen.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: _produktHinzufuegen,
                  icon: const Icon(Icons.add),
                  label: Text(l.produktHinzufuegen),
                ),
              ),
            Abschnitt(l.statusUndZahlung),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<AuftragStatus>(
                    segments: [
                      for (final s in AuftragStatus.values)
                        ButtonSegment(value: s, label: Text(statusName(l, s))),
                    ],
                    selected: {_status},
                    onSelectionChanged: (s) =>
                        setState(() => _status = s.first),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.bezahlt),
                    subtitle: Text(l.bezahltHilfe),
                    value: _bezahlt,
                    onChanged: (v) => setState(() => _bezahlt = v),
                  ),
                  SegmentedButton<Zahlungsart>(
                    segments: [
                      for (final a in Zahlungsart.values)
                        ButtonSegment(
                          value: a,
                          label: Text(zahlungsartName(l, a)),
                        ),
                    ],
                    selected: {_art},
                    onSelectionChanged: (s) => setState(() => _art = s.first),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notiz,
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(labelText: l.notiz),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
