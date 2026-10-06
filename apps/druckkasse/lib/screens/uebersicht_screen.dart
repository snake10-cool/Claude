import 'package:app_basis/app_basis.dart';

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../daten/datenbank.dart';
import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/csv_export.dart';
import '../logik/statistik.dart';
import '../logik/typen.dart';
import '../widgets/allgemein.dart';
import '../widgets/format.dart';
import '../widgets/monats_diagramm.dart';
import 'verkaufen_screen.dart';

/// Monatsübersicht: Umsatz, Kosten, Gewinn, Bestseller, Verlauf, Export.
class UebersichtScreen extends StatefulWidget {
  const UebersichtScreen({super.key});

  @override
  State<UebersichtScreen> createState() => _UebersichtScreenState();
}

class _UebersichtScreenState extends State<UebersichtScreen> {
  late DateTime _monat = DateTime(DateTime.now().year, DateTime.now().month);

  void _blaettern(int richtung) =>
      setState(() => _monat = DateTime(_monat.year, _monat.month + richtung));

  Future<void> _exportieren(List<Verkauf> alle) async {
    final l = context.l;
    if (!kauf.istPro) {
      await proGrenzeZeigen(context, l.exportNurPro);
      return;
    }
    final nurMonat = await showDialog<bool>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l.exportTitel),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.exportMonat(monatJahr(_monat))),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.exportAlles),
          ),
        ],
      ),
    );
    if (nurMonat == null || !mounted) return;
    final (von, bis) = monatsGrenzen(_monat);
    final auswahl = nurMonat
        ? alle.where(
            (v) => !v.zeitpunkt.isBefore(von) && v.zeitpunkt.isBefore(bis),
          )
        : alle;
    final csv = verkaeufeAlsCsv(
      auswahl.toList().reversed.map((v) => v.zeile),
      kopfzeile: [
        l.csvDatum,
        l.csvProdukt,
        l.csvMenge,
        l.csvEinzelpreis,
        l.csvUmsatz,
        l.csvKosten,
        l.csvGebuehr,
        l.csvGewinn,
        l.csvZahlung,
      ],
      zahlungsart: (z) => zahlungsartName(l, Zahlungsart.values[z.zahlungsart]),
    );
    // BOM, damit Excel die Umlaute richtig erkennt.
    final bytes = Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(csv)]);
    final name = nurMonat
        ? 'druckkasse_${_monat.year}-${_monat.month.toString().padLeft(2, '0')}.csv'
        : 'druckkasse_alle.csv';
    await speichernOderTeilen(context, bytes, name, 'text/csv');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    return StreamBuilder<List<Verkauf>>(
      stream: db.alleVerkaeufeBeobachten(),
      builder: (context, snap) {
        final alle = snap.data ?? const <Verkauf>[];
        final (von, bis) = monatsGrenzen(_monat);
        final imMonat = alle
            .where(
              (v) => !v.zeitpunkt.isBefore(von) && v.zeitpunkt.isBefore(bis),
            )
            .map((v) => v.zeile);
        final a = auswerten(imMonat);
        final verlauf = monatsVerlauf(
          alle.map((v) => v.zeile),
          bisMonat: _monat,
          anzahl: kauf.istPro ? 12 : 6,
        );
        final jetzt = DateTime.now();
        final istAktuell =
            _monat.year == jetzt.year && _monat.month == jetzt.month;

        return Scaffold(
          appBar: AppBar(
            title: Text(l.tabUebersicht),
            actions: [
              IconButton(
                tooltip: l.exportTitel,
                icon: const Icon(Icons.file_download_outlined),
                onPressed: alle.isEmpty ? null : () => _exportieren(alle),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: l.vorherigerMonat,
                    onPressed: () => _blaettern(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      monatJahr(_monat),
                      textAlign: TextAlign.center,
                      style: t.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: l.naechsterMonat,
                    onPressed: istAktuell ? null : () => _blaettern(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _GewinnKarte(a),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _Kachel(l.umsatz, euro(a.umsatzCent))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Kachel(
                      l.kosten,
                      euro(a.kostenCent + a.gebuehrenCent),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _Kachel(l.stueckVerkauft, '${a.stueck}')),
                ],
              ),
              if (a.gebuehrenCent > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l.davonGebuehren(euro(a.gebuehrenCent)),
                    style: t.textTheme.bodySmall,
                  ),
                ),
              Abschnitt(l.gewinnProMonat),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  child: MonatsDiagramm(
                    werte: verlauf,
                    gewaehlt: _monat,
                    onWaehlen: (m) => setState(() => _monat = m),
                  ),
                ),
              ),
              if (!kauf.istPro)
                TextButton.icon(
                  onPressed: () => proSeiteOeffnen(context),
                  icon: const Icon(Icons.workspace_premium, size: 18),
                  label: Text(l.verlaufPro),
                ),
              Abschnitt(l.bestseller),
              if (a.bestseller.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l.keineVerkaeufeImMonat,
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (final (i, b) in a.bestseller.take(10).indexed)
                        _BestsellerZeile(
                          platz: i + 1,
                          eintrag: b,
                          anteil: b.stueck / a.bestseller.first.stueck,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GewinnKarte extends StatelessWidget {
  const _GewinnKarte(this.a);
  final Auswertung a;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    return Card(
      color: t.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(l.gewinn, style: t.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              euro(a.gewinnCent),
              style: t.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (a.umsatzCent > 0)
              Text(
                l.margeVomUmsatz((a.gewinnCent / a.umsatzCent * 100).round()),
                style: t.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

class _Kachel extends StatelessWidget {
  const _Kachel(this.titel, this.wert);
  final String titel;
  final String wert;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            FittedBox(
              child: Text(
                wert,
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              titel,
              style: t.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BestsellerZeile extends StatelessWidget {
  const _BestsellerZeile({
    required this.platz,
    required this.eintrag,
    required this.anteil,
  });

  final int platz;
  final BestsellerEintrag eintrag;
  final double anteil;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '$platz.',
                  style: t.textTheme.titleSmall?.copyWith(
                    color: t.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Text(eintrag.name, style: t.textTheme.titleSmall),
              ),
              Text(l.stueckKurz(eintrag.stueck), style: t.textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const SizedBox(width: 28),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: anteil,
                    minHeight: 6,
                    backgroundColor: t.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l.plusGewinn(euro(eintrag.gewinnCent)),
                style: t.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Android: „Speichern unter“-Dialog oder Teilen. Windows: Speichern-Dialog.
Future<void> speichernOderTeilen(
  BuildContext context,
  Uint8List bytes,
  String name,
  String mime,
) async {
  final l = context.l;
  final messenger = ScaffoldMessenger.of(context);
  final android = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  final teilen = android
      ? await showDialog<bool>(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(name),
            children: [
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, false),
                child: ListTile(
                  leading: const Icon(Icons.save_alt),
                  title: Text(l.speichernUnter),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, true),
                child: ListTile(
                  leading: const Icon(Icons.share),
                  title: Text(l.teilen),
                ),
              ),
            ],
          ),
        )
      : false;
  if (teilen == null) return;
  try {
    if (teilen) {
      final ordner = await getTemporaryDirectory();
      final datei = File('${ordner.path}/$name');
      await datei.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(datei.path, mimeType: mime)]),
      );
    } else {
      final ziel = await FilePicker.saveFile(
        fileName: name,
        bytes: bytes,
        mimeType: mime,
      );
      if (ziel != null) {
        messenger.showSnackBar(SnackBar(content: Text(l.gespeichert)));
      }
    }
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(l.fehler('$e'))));
  }
}
