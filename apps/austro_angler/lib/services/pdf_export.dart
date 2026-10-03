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
