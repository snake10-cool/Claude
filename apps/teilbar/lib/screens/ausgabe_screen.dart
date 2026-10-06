import 'dart:convert';

import 'package:app_basis/app_basis.dart';
import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../l10n/l.dart';
import '../logik/geld.dart';
import '../widgets/format.dart';

/// Ausgabe anlegen oder ändern: wer hat bezahlt, für wen.
class AusgabeScreen extends StatefulWidget {
  const AusgabeScreen({
    super.key,
    required this.gruppe,
    required this.personen,
    this.ausgabe,
  });

  final Gruppe gruppe;
  final List<Person> personen;
  final Ausgabe? ausgabe;

  @override
  State<AusgabeScreen> createState() => _AusgabeScreenState();
}

class _AusgabeScreenState extends State<AusgabeScreen> {
  final _form = GlobalKey<FormState>();
  late final _titel = TextEditingController(text: widget.ausgabe?.titel);
  late final _betrag = TextEditingController(
    text: widget.ausgabe == null ? '' : euroFeld(widget.ausgabe!.betragCent),
  );
  late String _zahler =
      widget.ausgabe?.zahlerId ??
      widget.gruppe.ichPersonId ??
      widget.personen.first.id;
  late final Set<String> _fuer = widget.ausgabe == null
      ? {for (final p in widget.personen) p.id}
      : widget.ausgabe!.anteilMap.keys.toSet();
  late DateTime _datum = widget.ausgabe?.datum ?? DateTime.now();

  @override
  void dispose() {
    _titel.dispose();
    _betrag.dispose();
    super.dispose();
  }

  Future<void> _speichern() async {
    if (!_form.currentState!.validate()) return;
    if (_fuer.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l.mindestensEinePerson)));
      return;
    }
    final anteile = {for (final id in _fuer) id: 1};
    final betrag = parseEuro(_betrag.text)!;
    final a = widget.ausgabe;
    if (a == null) {
      await db.ausgabeAnlegen(
        gruppeId: widget.gruppe.id,
        titel: _titel.text.trim(),
        betragCent: betrag,
        zahlerId: _zahler,
        anteile: anteile,
        datum: _datum,
      );
    } else {
      await db.ausgabeSpeichern(
        a.copyWith(
          titel: _titel.text.trim(),
          betragCent: betrag,
          zahlerId: _zahler,
          anteile: jsonEncode(anteile),
          datum: _datum,
        ),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final betrag = parseEuro(_betrag.text) ?? 0;
    final teile = aufteilen(betrag, {for (final id in _fuer) id: 1});
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.ausgabe == null ? l.neueAusgabe : l.ausgabeBearbeiten,
        ),
        actions: [
          if (widget.ausgabe != null)
            IconButton(
              tooltip: l.loeschen,
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                if (await bestaetigen(
                  context,
                  titel: l.ausgabeLoeschen,
                  text: widget.ausgabe!.titel,
                )) {
                  await db.ausgabeLoeschen(widget.ausgabe!.id);
                  if (context.mounted) Navigator.pop(context);
                }
              },
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
            TextFormField(
              controller: _titel,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l.wofuer,
                hintText: l.wofuerBeispiel,
              ),
              validator: (t) => (t ?? '').trim().isEmpty ? l.pflichtfeld : null,
            ),
            const SizedBox(height: 12),
            EuroFeld(
              controller: _betrag,
              label: l.betrag,
              pflicht: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _zahler,
              decoration: InputDecoration(labelText: l.werHatBezahlt),
              items: [
                for (final p in widget.personen)
                  DropdownMenuItem(value: p.id, child: Text(p.name)),
              ],
              onChanged: (v) => setState(() => _zahler = v ?? _zahler),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text(datum(_datum)),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _datum,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) setState(() => _datum = d);
              },
            ),
            Abschnitt(l.fuerWenGeteilt),
            for (final p in widget.personen)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                secondary: PersonKreis(name: p.name, farbe: p.farbe),
                title: Text(p.name),
                subtitle: _fuer.contains(p.id) && betrag > 0
                    ? Text(euro(teile[p.id] ?? 0))
                    : null,
                value: _fuer.contains(p.id),
                onChanged: (v) => setState(
                  () => v == true ? _fuer.add(p.id) : _fuer.remove(p.id),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
