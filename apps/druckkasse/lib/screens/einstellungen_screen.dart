import 'dart:async';

import 'package:app_basis/app_basis.dart';
import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../daten/beispieldaten.dart';
import '../daten/datenbank.dart';
import '../daten/sicherung.dart';
import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/typen.dart';
import '../widgets/allgemein.dart';
import '../widgets/format.dart';
import 'uebersicht_screen.dart';
import 'verkaufen_screen.dart';

class EinstellungenScreen extends StatelessWidget {
  const EinstellungenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.einstellungen)),
      body: StreamBuilder<Einstellungen>(
        stream: db.einstellungenBeobachten(),
        builder: (context, snap) {
          final e = snap.data;
          if (e == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Abschnitt(l.kalkulation),
              _ZahlEintrag(
                symbol: Icons.bolt,
                titel: l.strompreis,
                wert: '${zahl(e.strompreisCentProKwh)} ct/kWh',
                feld: l.strompreisFeld,
                start: zahl(e.strompreisCentProKwh),
                hilfe: l.strompreisHilfe,
                speichern: (t) => db.einstellungenSpeichern(
                  EinstellungenTabelleCompanion(
                    strompreisCentProKwh: Value(parseKomma(t) ?? 25),
                  ),
                ),
              ),
              _ZahlEintrag(
                symbol: Icons.trending_up,
                titel: l.standardAufschlag,
                wert: '${e.standardAufschlagProzent} %',
                feld: l.aufschlagFeld,
                start: '${e.standardAufschlagProzent}',
                hilfe: l.standardAufschlagHilfe,
                speichern: (t) => db.einstellungenSpeichern(
                  EinstellungenTabelleCompanion(
                    standardAufschlagProzent: Value(int.tryParse(t) ?? 200),
                  ),
                ),
              ),
              _ZahlEintrag(
                symbol: Icons.error_outline,
                titel: l.fehldruckZuschlag,
                wert: '${e.fehldruckProzent} %',
                feld: l.prozentFeld,
                start: '${e.fehldruckProzent}',
                hilfe: l.fehldruckHilfe,
                speichern: (t) => db.einstellungenSpeichern(
                  EinstellungenTabelleCompanion(
                    fehldruckProzent: Value(int.tryParse(t) ?? 10),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.price_change_outlined),
                title: Text(l.rundung),
                subtitle: Text(_rundungText(l, e.rundungCent)),
                onTap: () => _rundungWaehlen(context, e.rundungCent),
              ),
              _ZahlEintrag(
                symbol: Icons.schedule,
                titel: l.stundenlohn,
                wert: e.stundenlohnCent == 0
                    ? l.nichtEingerechnet
                    : '${euro(e.stundenlohnCent)}/h',
                feld: l.stundenlohnFeld,
                start: e.stundenlohnCent == 0
                    ? ''
                    : euroFeld(e.stundenlohnCent),
                hilfe: l.stundenlohnHilfe,
                speichern: (t) => db.einstellungenSpeichern(
                  EinstellungenTabelleCompanion(
                    stundenlohnCent: Value(parseEuro(t) ?? 0),
                  ),
                ),
              ),
              Abschnitt(l.zahlung),
              ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: Text(l.standardZahlungsart),
                subtitle: Text(
                  zahlungsartName(l, Zahlungsart.values[e.standardZahlungsart]),
                ),
                onTap: () =>
                    _zahlungsartWaehlen(context, e.standardZahlungsart),
              ),
              _ZahlEintrag(
                symbol: Icons.credit_card,
                titel: l.gebuehrKarte,
                wert: '${zahl(e.gebuehrKarteProzent)} %',
                feld: l.prozentFeld,
                start: zahl(e.gebuehrKarteProzent),
                hilfe: l.gebuehrKarteHilfe,
                speichern: (t) => db.einstellungenSpeichern(
                  EinstellungenTabelleCompanion(
                    gebuehrKarteProzent: Value(parseKomma(t) ?? 0),
                  ),
                ),
              ),
              _ZahlEintrag(
                symbol: Icons.language,
                titel: l.gebuehrOnline,
                wert: '${zahl(e.gebuehrOnlineProzent)} %',
                feld: l.prozentFeld,
                start: zahl(e.gebuehrOnlineProzent),
                hilfe: l.gebuehrOnlineHilfe,
                speichern: (t) => db.einstellungenSpeichern(
                  EinstellungenTabelleCompanion(
                    gebuehrOnlineProzent: Value(parseKomma(t) ?? 0),
                  ),
                ),
              ),
              Abschnitt(l.daten),
              ListTile(
                leading: const Icon(Icons.backup_outlined),
                title: Text(l.sicherungErstellen),
                subtitle: Text(l.sicherungErstellenText),
                onTap: () => _sicherungErstellen(context),
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: Text(l.sicherungWiederherstellen),
                onTap: () => _wiederherstellen(context),
              ),
              ListTile(
                leading: const Icon(Icons.science_outlined),
                title: Text(l.beispieldatenLaden),
                subtitle: Text(l.beispieldatenText),
                onTap: () => _beispieldaten(context),
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(l.allesLoeschen),
                onTap: () => _allesLoeschen(context),
              ),
              Abschnitt(l.app),
              AppInfoKacheln(info: appInfo, designModus: designModus),
            ],
          );
        },
      ),
    );
  }

  static String _rundungText(AppLocalizations l, int cent) => switch (cent) {
    <= 1 => l.rundungKeine,
    _ => l.rundungAuf(euro(cent)),
  };

  Future<void> _rundungWaehlen(BuildContext context, int aktuell) async {
    final l = context.l;
    final wahl = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l.rundung),
        children: [
          RadioGroup<int>(
            groupValue: aktuell,
            onChanged: (v) => Navigator.pop(context, v),
            child: Column(
              children: [
                for (final c in [1, 10, 50, 100])
                  RadioListTile<int>(value: c, title: Text(_rundungText(l, c))),
              ],
            ),
          ),
        ],
      ),
    );
    if (wahl != null) {
      await db.einstellungenSpeichern(
        EinstellungenTabelleCompanion(rundungCent: Value(wahl)),
      );
    }
  }

  Future<void> _zahlungsartWaehlen(BuildContext context, int aktuell) async {
    final l = context.l;
    final wahl = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l.standardZahlungsart),
        children: [
          RadioGroup<int>(
            groupValue: aktuell,
            onChanged: (v) => Navigator.pop(context, v),
            child: Column(
              children: [
                for (final a in Zahlungsart.values)
                  RadioListTile<int>(
                    value: a.index,
                    title: Text(zahlungsartName(l, a)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (wahl != null) {
      await db.einstellungenSpeichern(
        EinstellungenTabelleCompanion(standardZahlungsart: Value(wahl)),
      );
    }
  }

  Future<void> _sicherungErstellen(BuildContext context) async {
    final bytes = await Sicherung(db).erstellen();
    final j = DateTime.now();
    final name =
        'druckkasse_sicherung_${j.year}-${j.month.toString().padLeft(2, '0')}-${j.day.toString().padLeft(2, '0')}.sqlite';
    if (context.mounted) {
      await speichernOderTeilen(
        context,
        bytes,
        name,
        'application/octet-stream',
      );
    }
  }

  Future<void> _wiederherstellen(BuildContext context) async {
    final l = context.l;
    final messenger = ScaffoldMessenger.of(context);
    if (!await bestaetigen(
      context,
      titel: l.sicherungWiederherstellen,
      text: l.wiederherstellenWarnung,
      ja: l.weiter,
    )) {
      return;
    }
    final dateien = await FilePicker.pickFiles();
    if (dateien.isEmpty) return;
    try {
      final bytes = await dateien.first.xFile.readAsBytes();
      await Sicherung(db).wiederherstellen(bytes);
      messenger.showSnackBar(SnackBar(content: Text(l.wiederhergestellt)));
    } on FormatException {
      messenger.showSnackBar(SnackBar(content: Text(l.keineSicherung)));
    }
  }

  Future<void> _beispieldaten(BuildContext context) async {
    final l = context.l;
    if (!await bestaetigen(
      context,
      titel: l.beispieldatenLaden,
      text: l.beispieldatenWarnung,
      ja: l.laden,
    )) {
      return;
    }
    await beispieldatenLaden(db);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.beispieldatenGeladen)));
    }
  }

  Future<void> _allesLoeschen(BuildContext context) async {
    final l = context.l;
    if (!await bestaetigen(
      context,
      titel: l.allesLoeschen,
      text: l.allesLoeschenText,
    )) {
      return;
    }
    await db.allesLoeschen();
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.allesGeloescht)));
    }
  }
}

/// Eintrag mit Wert, der beim Antippen einen Eingabedialog öffnet.
class _ZahlEintrag extends StatelessWidget {
  const _ZahlEintrag({
    required this.symbol,
    required this.titel,
    required this.wert,
    required this.feld,
    required this.start,
    required this.speichern,
    this.hilfe,
  });

  final IconData symbol;
  final String titel;
  final String wert;
  final String feld;
  final String start;
  final String? hilfe;
  final FutureOr<void> Function(String) speichern;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return ListTile(
      leading: Icon(symbol),
      title: Text(titel),
      subtitle: Text(wert),
      onTap: () async {
        final c = TextEditingController(text: start);
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(titel),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: c,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(labelText: feld),
                ),
                if (hilfe != null) ...[
                  const SizedBox(height: 12),
                  Text(hilfe!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.abbrechen),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.speichern),
              ),
            ],
          ),
        );
        if (ok == true) await speichern(c.text);
      },
    );
  }
}
