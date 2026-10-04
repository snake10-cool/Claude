import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/fische.dart';
import '../models/fang.dart';

String _datum(DateTime d) => '${d.day.toString().padLeft(2, '0')}.'
    '${d.month.toString().padLeft(2, '0')}.${d.year} '
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Erstellt das Fangbuch eines Jahres als PDF und öffnet "Teilen/Drucken".
Future<void> fangbuchAlsPdf(List<Fang> alle, int jahr, String name) async {
  final faenge = alle.where((f) => f.datum.year == jahr).toList()
    ..sort((a, b) => a.datum.compareTo(b.datum));
  final doc = pw.Document(title: 'Fangbuch $jahr', author: name);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(24),
      header: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Fangbuch $jahr',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.Text('$name · ${faenge.length} Fänge · erstellt mit Austro Angler'),
          pw.SizedBox(height: 10),
        ],
      ),
      build: (_) => [
        if (faenge.isEmpty)
          pw.Text('Keine Fänge in $jahr.')
        else
          pw.TableHelper.fromTextArray(
            headers: ['Datum', 'Fischart', 'Länge', 'Gewicht', 'Gewässer',
              'Köder', 'Entnommen'],
            data: [
              for (final f in faenge)
                [
                  _datum(f.datum),
                  fischById(f.fischId)?.name ?? f.fischId,
                  f.laengeCm == null ? '' : '${f.laengeCm!.toStringAsFixed(0)} cm',
                  f.gewichtG == null ? '' : '${f.gewichtG} g',
                  f.gewaesser,
                  f.koeder,
                  f.zurueckgesetzt ? 'nein' : 'ja',
                ],
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          ),
        pw.SizedBox(height: 12),
        pw.Text('Entnommene Fische nach Art:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        for (final e in _proArt(faenge.where((f) => !f.zurueckgesetzt)).entries)
          pw.Text('${e.key}: ${e.value}'),
      ],
    ),
  );

  await Printing.sharePdf(
      bytes: await doc.save(), filename: 'Fangbuch_$jahr.pdf');
}

Map<String, int> _proArt(Iterable<Fang> faenge) {
  final m = <String, int>{};
  for (final f in faenge) {
    final n = fischById(f.fischId)?.name ?? f.fischId;
    m[n] = (m[n] ?? 0) + 1;
  }
  return m;
}

/// Fangstatistik für ein Revier – so, wie sie viele Vereine am Saisonende
/// verlangen: entnommene Fische je Art mit Stück und Gewicht.
Future<void> revierStatistikPdf(
    List<Fang> alle, int jahr, String gewaesser, String name) async {
  final faenge = alle
      .where((f) => f.datum.year == jahr && f.gewaesser == gewaesser)
      .toList()
    ..sort((a, b) => a.datum.compareTo(b.datum));
  final entnommen = faenge.where((f) => !f.zurueckgesetzt).toList();
  final proArt = <String, ({int stueck, int gramm, int zurueck})>{};
  for (final f in faenge) {
    final n = fischById(f.fischId)?.name ?? f.fischId;
    final alt = proArt[n] ?? (stueck: 0, gramm: 0, zurueck: 0);
    proArt[n] = f.zurueckgesetzt
        ? (stueck: alt.stueck, gramm: alt.gramm, zurueck: alt.zurueck + 1)
        : (
            stueck: alt.stueck + 1,
            gramm: alt.gramm + (f.gewichtG ?? 0),
            zurueck: alt.zurueck,
          );
  }
  final tage = faenge
      .map((f) => DateTime(f.datum.year, f.datum.month, f.datum.day))
      .toSet()
      .length;
  final doc = pw.Document(title: 'Fangstatistik $gewaesser $jahr', author: name);
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (_) => [
        pw.Text('Fangstatistik $jahr',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.Text('Gewässer / Revier: $gewaesser'),
        pw.SizedBox(height: 12),
        pw.Text('Name: $name ______________________________'),
        pw.SizedBox(height: 6),
        pw.Text('Fischerkarten-Nr.: ________________   '
            'Lizenz-Nr.: ________________'),
        pw.SizedBox(height: 16),
        pw.Text('Fangtage mit Fang: $tage   ·   Fänge gesamt: ${faenge.length}'
            '   ·   davon entnommen: ${entnommen.length}'),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headers: ['Fischart', 'Entnommen (Stk.)', 'Gewicht (kg)',
            'Zurückgesetzt'],
          data: [
            for (final e in proArt.entries)
              [
                e.key,
                '${e.value.stueck}',
                (e.value.gramm / 1000).toStringAsFixed(1).replaceAll('.', ','),
                '${e.value.zurueck}',
              ],
          ],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        ),
        pw.SizedBox(height: 16),
        pw.Text('Entnommene Fische im Einzelnen:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        if (entnommen.isEmpty)
          pw.Text('Keine.')
        else
          pw.TableHelper.fromTextArray(
            headers: ['Datum', 'Fischart', 'Länge', 'Gewicht'],
            data: [
              for (final f in entnommen)
                [
                  _datum(f.datum),
                  fischById(f.fischId)?.name ?? f.fischId,
                  f.laengeCm == null ? '' : '${f.laengeCm!.toStringAsFixed(0)} cm',
                  f.gewichtG == null ? '' : '${f.gewichtG} g',
                ],
            ],
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        pw.SizedBox(height: 32),
        pw.Text('Datum, Unterschrift: _______________________________'),
        pw.SizedBox(height: 8),
        pw.Text('Erstellt mit Austro Angler aus dem persönlichen Fangbuch.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
      ],
    ),
  );
  await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'Fangstatistik_${gewaesser.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')}_$jahr.pdf');
}
