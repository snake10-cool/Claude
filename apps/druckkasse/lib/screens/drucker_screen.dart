import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../daten/vorlagen.dart';
import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/grenzen.dart';
import '../widgets/allgemein.dart';
import '../widgets/format.dart';

class DruckerScreen extends StatelessWidget {
  const DruckerScreen({super.key});

  Future<void> _neu(BuildContext context) async {
    final anzahl = await db.anzahlAktiverDrucker();
    if (!context.mounted) return;
    if (!darfAnlegen(
      vorhanden: anzahl,
      grenze: GratisGrenzen.drucker,
      istPro: kauf.istPro,
    )) {
      await proGrenzeZeigen(
        context,
        context.l.grenzeDrucker(GratisGrenzen.drucker),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DruckerBearbeitenScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.drucker)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _neu(context),
        icon: const Icon(Icons.add),
        label: Text(l.druckerAnlegen),
      ),
      body: StreamBuilder<List<Drucker>>(
        stream: db.druckerBeobachten(),
        builder: (context, snap) {
          final liste = snap.data ?? const <Drucker>[];
          if (snap.hasData && liste.isEmpty) {
            return LeerHinweis(
              symbol: Icons.print,
              titel: l.keineDrucker,
              text: l.keineDruckerText,
              knopf: l.druckerAnlegen,
              aktion: () => _neu(context),
            );
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              for (final d in liste)
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.print)),
                  title: Text(d.name),
                  subtitle: Text(
                    l.druckerInfo(
                      d.leistungWatt,
                      euro(
                        d.lebensdauerStunden == 0
                            ? 0
                            : (d.anschaffungCent / d.lebensdauerStunden)
                                  .round(),
                      ),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DruckerBearbeitenScreen(drucker: d),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class DruckerBearbeitenScreen extends StatefulWidget {
  const DruckerBearbeitenScreen({super.key, this.drucker});
  final Drucker? drucker;

  @override
  State<DruckerBearbeitenScreen> createState() =>
      _DruckerBearbeitenScreenState();
}

class _DruckerBearbeitenScreenState extends State<DruckerBearbeitenScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.drucker?.name);
  late final _watt = TextEditingController(
    text: widget.drucker?.leistungWatt.toString(),
  );
  late final _preis = TextEditingController(
    text: widget.drucker == null
        ? ''
        : euroFeld(widget.drucker!.anschaffungCent),
  );
  late final _stunden = TextEditingController(
    text: (widget.drucker?.lebensdauerStunden ?? standardLebensdauerStunden)
        .toString(),
  );

  @override
  void dispose() {
    for (final c in [_name, _watt, _preis, _stunden]) {
      c.dispose();
    }
    super.dispose();
  }

  void _vorlage(DruckerVorlage v) => setState(() {
    _name.text = v.name;
    _watt.text = '${v.watt}';
    _preis.text = euroFeld(v.preisEuro * 100);
  });

  Future<void> _speichern() async {
    if (!_form.currentState!.validate()) return;
    await db.druckerSpeichern(
      DruckerTabelleCompanion(
        id: widget.drucker == null
            ? const Value.absent()
            : Value(widget.drucker!.id),
        name: Value(_name.text.trim()),
        leistungWatt: Value(int.parse(_watt.text)),
        anschaffungCent: Value(parseEuro(_preis.text) ?? 0),
        lebensdauerStunden: Value(int.parse(_stunden.text)),
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _entfernen() async {
    final l = context.l;
    if (!await bestaetigen(
      context,
      titel: l.druckerEntfernen,
      text: l.druckerEntfernenText,
    )) {
      return;
    }
    await db.druckerArchivieren(widget.drucker!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.drucker == null ? l.druckerAnlegen : l.druckerBearbeiten,
        ),
        actions: [
          if (widget.drucker != null)
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
            if (widget.drucker == null) ...[
              Text(
                l.vorlageWaehlen,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final v in druckerVorlagen)
                    ActionChip(
                      label: Text(v.name),
                      onPressed: () => _vorlage(v),
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: l.name),
              validator: (t) => (t ?? '').trim().isEmpty ? l.pflichtfeld : null,
            ),
            const SizedBox(height: 12),
            ZahlFeld(
              controller: _watt,
              label: l.verbrauch,
              suffix: 'W',
              hilfe: l.verbrauchHilfe,
            ),
            const SizedBox(height: 12),
            EuroFeld(
              controller: _preis,
              label: l.anschaffungspreis,
              pflicht: true,
            ),
            const SizedBox(height: 12),
            ZahlFeld(
              controller: _stunden,
              label: l.lebensdauer,
              suffix: 'h',
              hilfe: l.lebensdauerHilfe,
            ),
          ],
        ),
      ),
    );
  }
}
