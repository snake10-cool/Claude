import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../l10n/l.dart';
import '../logik/typen.dart';

/// Macht aus einer Karte mit einem Tipp ein Snippet.
Future<void> karteAlsSnippet(
  BuildContext context,
  Karte karte,
  String sprache,
  String stapelName,
) async {
  final typ = KartenTyp.values.byName(karte.typ);
  final code =
      karte.code ?? (typ == KartenTyp.begriff ? '// ${karte.frage}' : '');
  final fertig = typ == KartenTyp.luecke
      ? code.replaceAll('___', karte.antwort)
      : code;
  final notiz = [
    if (typ == KartenTyp.begriff) karte.antwort,
    if (typ == KartenTyp.ausgabe) '→ ${karte.antwort}',
    if (karte.erklaerung.isNotEmpty) karte.erklaerung,
  ].join('\n\n');
  final jetzt = DateTime.now();
  await db.snippetSpeichern(
    SnippetTabelleCompanion.insert(
      titel: karte.frage.length > 60
          ? '${karte.frage.substring(0, 57)}…'
          : karte.frage,
      sprache: sprache,
      code: fertig,
      tags: Value([sprache, stapelName.toLowerCase()].join(',')),
      notiz: Value(notiz),
      erstellt: jetzt,
      geaendert: jetzt,
    ),
  );
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l.alsSnippetGespeichert)));
  }
}
