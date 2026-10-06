import 'package:app_basis/app_basis.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../daten/produkt_details.dart';
import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/grenzen.dart';
import '../logik/typen.dart';
import '../widgets/allgemein.dart';
import '../widgets/format.dart';
import '../widgets/sparziel_karte.dart';

const _zielSymbole = [
  '🎯',
  '🖨️',
  '💰',
  '🧵',
  '🏖️',
  '🎮',
  '🚗',
  '💻',
  '📱',
  '🎁',
  '🏠',
  '🚀',
];

class SparzieleScreen extends StatelessWidget {
  const SparzieleScreen({super.key});

  Future<void> _neu(BuildContext context, int anzahl) async {
    if (!darfAnlegen(
      vorhanden: anzahl,
      grenze: GratisGrenzen.sparziele,
      istPro: kauf.istPro,
    )) {
      await proGrenzeZeigen(context, context.l.grenzeSparziele);
      return;
    }
    await sparzielBearbeiten(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return StreamBuilder<List<Sparziel>>(
      stream: db.sparzieleBeobachten(),
      builder: (context, snap) {
        final ziele = snap.data ?? const <Sparziel>[];
        return Scaffold(
          appBar: AppBar(title: Text(l.sparziele)),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: null,
            onPressed: () => _neu(context, ziele.length),
            icon: const Icon(Icons.add),
            label: Text(l.neuesSparziel),
          ),
          body: snap.hasData && ziele.isEmpty
              ? LeerHinweis(
                  symbol: Icons.flag,
                  titel: l.keineSparziele,
                  text: l.keineSparzieleText,
                  knopf: l.neuesSparziel,
                  aktion: () => _neu(context, 0),
                )
              : StreamBuilder<List<ProduktDetails>>(
                  stream: db.produkteBeobachten(),
                  builder: (context, p) => ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    children: [
                      for (final z in ziele)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SparzielKarte(
                                ziel: z,
                                produkte: p.data ?? const [],
                                onTap: () => sparzielBearbeiten(context, z),
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: z.angeheftet
                                        ? Chip(
                                            avatar: const Icon(
                                              Icons.push_pin,
                                              size: 16,
                                            ),
                                            label: Text(
                                              l.angeheftet,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        : TextButton.icon(
                                            onPressed: () =>
                                                _anheften(z, ziele),
                                            icon: const Icon(
                                              Icons.push_pin_outlined,
                                            ),
                                            label: Text(
                                              l.anheften,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    l.seit(datum(z.startDatum)),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  /// Nur ein Ziel ist beim Verkaufen sichtbar.
  Future<void> _anheften(Sparziel z, List<Sparziel> alle) async {
    for (final a in alle) {
      await db.sparzielSpeichern(
        a.toCompanion(true).copyWith(angeheftet: Value(a.id == z.id)),
      );
    }
  }
}

Future<void> sparzielBearbeiten(BuildContext context, [Sparziel? z]) async {
  final l = context.l;
  final name = TextEditingController(text: z?.name);
  final betrag = TextEditingController(
    text: z == null ? '' : euroFeld(z.zielCent),
  );
  var symbol = z?.symbol ?? _zielSymbole.first;
  var basis = SparBasis.values[z?.basis ?? 0];
  var start = z?.startDatum ?? DateTime.now();
  final form = GlobalKey<FormState>();

  final aktion = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  z == null ? l.neuesSparziel : l.sparzielBearbeiten,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  children: [
                    for (final s in _zielSymbole)
                      ChoiceChip(
                        label: Text(s, style: const TextStyle(fontSize: 20)),
                        selected: symbol == s,
                        onSelected: (_) => setState(() => symbol = s),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: l.wofuerSparstDu,
                    hintText: l.sparzielBeispiel,
                  ),
                  validator: (t) =>
                      (t ?? '').trim().isEmpty ? l.pflichtfeld : null,
                ),
                const SizedBox(height: 12),
                EuroFeld(
                  controller: betrag,
                  label: l.zielbetrag,
                  pflicht: true,
                ),
                const SizedBox(height: 16),
                Text(
                  l.wasZaehlt,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SegmentedButton<SparBasis>(
                  segments: [
                    ButtonSegment(
                      value: SparBasis.gewinn,
                      label: Text(l.gewinn),
                    ),
                    ButtonSegment(
                      value: SparBasis.umsatz,
                      label: Text(l.umsatz),
                    ),
                  ],
                  selected: {basis},
                  onSelectionChanged: (s) => setState(() => basis = s.first),
                ),
                const SizedBox(height: 4),
                Text(
                  basis == SparBasis.gewinn
                      ? l.basisGewinnHilfe
                      : l.basisUmsatzHilfe,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event),
                  title: Text(l.zaehltAb(datum(start))),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: start,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setState(() => start = d);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (z != null)
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'loeschen'),
                        child: Text(l.loeschen),
                      ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        if (form.currentState!.validate()) {
                          Navigator.pop(context, 'ok');
                        }
                      },
                      child: Text(l.speichern),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  if (aktion == 'ok') {
    final zielCent = parseEuro(betrag.text) ?? 0;
    await db.sparzielSpeichern(
      SparzielTabelleCompanion(
        id: z == null ? const Value.absent() : Value(z.id),
        name: Value(name.text.trim()),
        symbol: Value(symbol),
        zielCent: Value(zielCent),
        basis: Value(basis.index),
        startDatum: Value(DateTime(start.year, start.month, start.day)),
        angeheftet: Value(z?.angeheftet ?? true),
        // Ziel oder Start geändert → neu prüfen, ob erreicht.
        erreichtAm: const Value(null),
      ),
    );
  } else if (aktion == 'loeschen' && context.mounted) {
    if (await bestaetigen(
      context,
      titel: l.sparzielLoeschen,
      text: l.sparzielLoeschenText,
    )) {
      await db.sparzielLoeschen(z!.id);
    }
  }
}
