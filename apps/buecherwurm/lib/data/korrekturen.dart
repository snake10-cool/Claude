import '../models/buch.dart';

/// Katalog-Korrekturen aus Firestore (Sammlung `buchkorrekturen`, Dokument-ID
/// = Buch-ID). So lassen sich Titel, Beschreibung & Co. ohne App-Update
/// berichtigen, Bücher ausblenden oder ganz neue Bücher ergänzen.
/// Gefüllt von `Konto` beim Start; leer, solange nichts geladen ist.
final buchKorrekturen = <String, Map<String, dynamic>>{};

/// Neue Bücher, die nur über Firestore kommen (Dokument mit `neu: true`).
final korrekturNeueBuecher = <Buch>[];

/// Das Buch mit den Korrekturen aus Firestore, oder unverändert.
Buch korrigiert(Buch b) {
  final k = buchKorrekturen[b.id];
  if (k == null) return b;
  return _mitDaten(b, k);
}

/// True, wenn das Buch per Korrektur ausgeblendet ist (`ausblenden: true`).
bool ausgeblendet(String id) => buchKorrekturen[id]?['ausblenden'] == true;

/// Füllt [buchKorrekturen] und [korrekturNeueBuecher] neu.
void korrekturenSetzen(Map<String, Map<String, dynamic>> daten, bool Function(String id) imKatalog) {
  buchKorrekturen
    ..clear()
    ..addAll(daten);
  korrekturNeueBuecher.clear();
  for (final MapEntry(key: id, value: d) in daten.entries) {
    if (d['neu'] != true || imKatalog(id) || d['titel'] is! String || d['autor'] is! String) continue;
    korrekturNeueBuecher.add(_mitDaten(
      Buch(
        id: id,
        titel: '',
        autor: '',
        jahr: 0,
        seiten: 0,
        zielgruppe: Zielgruppe.erwachsene,
        tags: const {},
        beschreibung: '',
      ),
      d,
    ));
  }
}

Buch _mitDaten(Buch b, Map<String, dynamic> k) => Buch(
      id: b.id,
      titel: _text(k['titel']) ?? b.titel,
      autor: _text(k['autor']) ?? b.autor,
      jahr: (k['jahr'] as num?)?.toInt() ?? b.jahr,
      seiten: (k['seiten'] as num?)?.toInt() ?? b.seiten,
      zielgruppe: Zielgruppe.values.asNameMap()[k['zielgruppe']] ?? b.zielgruppe,
      tags: k['tags'] is List ? {...(k['tags'] as List).whereType<String>()} : b.tags,
      beschreibung: _text(k['beschreibung']) ?? b.beschreibung,
      minAlter: (k['minAlter'] as num?)?.toInt() ?? b.minAlter,
      quiz: b.quiz,
      eigenes: b.eigenes,
      coverUrl: _text(k['coverUrl']) ?? b.coverUrl,
      isbn: _text(k['isbn']) ?? b.isbn,
      schwierigkeit: b.schwierigkeit,
    );

String? _text(Object? v) => v is String && v.trim().isNotEmpty ? v : null;
