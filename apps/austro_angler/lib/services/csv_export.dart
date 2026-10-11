import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/fische.dart';
import '../models/fang.dart';

/// Fangbuch als CSV – mit Semikolon und BOM, damit Excel (deutsch) es direkt
/// richtig öffnet.
String fangbuchCsv(List<Fang> faenge) {
  String feld(Object? w) {
    final t = (w ?? '').toString();
    return RegExp(r'[;"\n\r]').hasMatch(t)
        ? '"${t.replaceAll('"', '""')}"'
        : t;
  }

  String zahl(num? z) => z == null ? '' : z.toString().replaceAll('.', ',');
  String zwei(int z) => z.toString().padLeft(2, '0');

  final zeilen = [
    ['Datum', 'Uhrzeit', 'Fischart', 'Länge (cm)', 'Gewicht (g)', 'Gewässer',
      'Bundesland', 'Köder', 'Zurückgesetzt', 'Temperatur (°C)',
      'Luftdruck (hPa)', 'Notiz'],
    for (final f in [...faenge]..sort((a, b) => a.datum.compareTo(b.datum)))
      [
        '${zwei(f.datum.day)}.${zwei(f.datum.month)}.${f.datum.year}',
        '${zwei(f.datum.hour)}:${zwei(f.datum.minute)}',
        (fischById(f.fischId)?.name ?? f.fischId).split(' (').first,
        zahl(f.laengeCm),
        zahl(f.gewichtG),
        f.gewaesser,
        f.bundesland,
        f.koeder,
        f.zurueckgesetzt ? 'ja' : 'nein',
        zahl(f.wetter?['temp']),
        zahl(f.wetter?['druck']),
        f.notiz,
      ],
  ];
  return '﻿${zeilen.map((z) => z.map(feld).join(';')).join('\r\n')}\r\n';
}

Future<void> fangbuchCsvTeilen(List<Fang> faenge) async {
  final ordner = await getTemporaryDirectory();
  final datei = File('${ordner.path}/fangbuch.csv');
  await datei.writeAsString(fangbuchCsv(faenge), encoding: utf8);
  await SharePlus.instance.share(ShareParams(
    files: [XFile(datei.path, mimeType: 'text/csv')],
    text: 'Mein Fangbuch (${faenge.length} Fänge) – Austro Angler',
  ));
}
