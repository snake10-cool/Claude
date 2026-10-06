import 'dart:convert';
import 'dart:io';

import 'package:codekarten/daten/datenbank.dart';
import 'package:codekarten/logik/lernrunde.dart';
import 'package:codekarten/logik/srs.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> stapelDatei(String id) =>
    jsonDecode(File('assets/stapel/$id.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  late AppDatenbank d;
  setUp(() => d = AppDatenbank(NativeDatabase.memory()));
  tearDown(() => d.close());

  test('alle eingebauten Stapel lassen sich einspielen', () async {
    final dateien = Directory('assets/stapel')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'));
    var i = 0;
    for (final f in dateien) {
      await d.stapelEinspielen(
        jsonDecode(f.readAsStringSync()) as Map<String, dynamic>,
        i++,
      );
    }
    final stapel = await d.stapelLaden();
    expect(stapel.length, i);
    expect(stapel.every((s) => s.anzahl >= 40), isTrue);
    final gratis = stapel.where((s) => s.stapel.produkt == null).toList();
    expect(gratis.single.stapel.schluessel, 'java_grundlagen');
  });

  test('erneutes Einspielen behält den Lernstand und ändert Texte', () async {
    final json = stapelDatei('java_grundlagen');
    await d.stapelEinspielen(json, 0);
    final info = (await d.stapelLaden()).single;
    final karten = await d.lernkarten([info.stapel.id]);
    final erste = karten.first.karte;
    await d.bewertungSpeichern(
      erste,
      bewerten(null, Bewertung.gut, DateTime.now()),
      warNeu: true,
      richtig: true,
    );

    final geaendert = Map<String, dynamic>.from(json);
    geaendert['karten'] = [
      for (final k in json['karten'] as List)
        if ((k as Map)['key'] == erste.schluessel)
          {...k, 'frage': 'Neue Frage'}
        else
          k,
    ];
    await d.stapelEinspielen(geaendert, 0);

    final nachher = (await d.stapelLaden()).single;
    expect(nachher.anzahl, info.anzahl);
    expect(nachher.neu, info.anzahl - 1);
    expect((await d.karteLaden(erste.id))!.frage, 'Neue Frage');
  });

  test('Lernrunde: fällige zuerst, dann neue bis zum Limit', () async {
    await d.stapelEinspielen(stapelDatei('python_grundlagen'), 0);
    final id = (await d.stapelLaden()).single.stapel.id;
    final jetzt = DateTime(2026, 10, 6, 12);
    var karten = await d.lernkarten([id]);
    // Zwei Karten gestern gelernt → heute fällig.
    for (final k in karten.take(2)) {
      await d.bewertungSpeichern(
        k.karte,
        bewerten(null, Bewertung.gut, DateTime(2026, 10, 5, 12)),
        warNeu: true,
        richtig: true,
        jetzt: DateTime(2026, 10, 5, 12),
      );
    }
    karten = await d.lernkarten([id]);
    final runde = lernrundeZusammenstellen(
      karten,
      jetzt: jetzt,
      neueProTag: 10,
      neueHeuteSchon: 3,
    );
    expect(runde.length, 2 + 7);
    expect(runde.take(2).every((k) => !k.neu), isTrue);
    expect(runde.skip(2).every((k) => k.neu), isTrue);
  });

  test('Lerntag zählt Karten, richtige und neue', () async {
    await d.stapelEinspielen(stapelDatei('dart_grundlagen'), 0);
    final id = (await d.stapelLaden()).single.stapel.id;
    final karten = await d.lernkarten([id]);
    final jetzt = DateTime(2026, 10, 6, 9);
    await d.bewertungSpeichern(
      karten[0].karte,
      bewerten(null, Bewertung.gut, jetzt),
      warNeu: true,
      richtig: true,
      jetzt: jetzt,
    );
    await d.bewertungSpeichern(
      karten[1].karte,
      bewerten(null, Bewertung.nochmal, jetzt),
      warNeu: true,
      richtig: false,
      jetzt: jetzt,
    );
    final tage = await d.lerntageLaden();
    final heute = tage[DateTime(2026, 10, 6)]!;
    expect(heute.karten, 2);
    expect(heute.richtig, 1);
    expect(heute.neu, 2);
  });

  test(
    'Snippets speichern und eigener Stapel wird nur einmal angelegt',
    () async {
      final a = await d.eigenerStapel('Meine Karten', 'java');
      final b = await d.eigenerStapel('Meine Karten', 'java');
      expect(a, b);
      await d.snippetSpeichern(
        SnippetTabelleCompanion.insert(
          titel: 'Hallo Welt',
          sprache: 'java',
          code: 'System.out.println("Hallo");',
          tags: const Value('basics,ausgabe'),
          erstellt: DateTime.now(),
          geaendert: DateTime.now(),
        ),
      );
      final s = await d.snippetsBeobachten().first;
      expect(s.single.titel, 'Hallo Welt');
    },
  );
}
