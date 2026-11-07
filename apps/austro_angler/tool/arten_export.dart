// Schreibt die Artenliste für die KI-Funktion (functions/src/arten.ts).
// Aufruf: dart run tool/arten_export.dart
import 'dart:convert';
import 'dart:io';

import 'package:austro_angler/data/fische.dart';

void main() {
  final zeilen = [
    for (final f in fische)
      if (!f.ausgestorben)
        '  {id: ${jsonEncode(f.id)}, name: ${jsonEncode(f.name)}, '
            'familie: ${jsonEncode(f.familie)}, merkmale: ${jsonEncode(f.merkmale)}},',
  ];
  File('functions/src/arten.ts').writeAsStringSync('''
// Automatisch erzeugt aus lib/data/fische.dart – nicht von Hand ändern.
// Neu erzeugen: dart run tool/arten_export.dart

export interface Art {
  id: string;
  name: string;
  familie: string;
  merkmale: string;
}

export const ARTEN: readonly Art[] = [
${zeilen.join('\n')}
];
''');
  stdout.writeln('${zeilen.length} Arten geschrieben.');
}
