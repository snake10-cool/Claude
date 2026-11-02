import 'package:buecherwurm/data/korrekturen.dart';
import 'package:buecherwurm/models/buch.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const buch = Buch(
    id: 'x_test',
    titel: 'Alt',
    autor: 'A',
    jahr: 2020,
    seiten: 100,
    zielgruppe: Zielgruppe.kinder,
    tags: {'abenteuer'},
    beschreibung: 'Band 1 der Reihe „Test".',
  );

  tearDown(() => korrekturenSetzen({}, (_) => false));

  test('Korrektur ersetzt nur gesetzte Felder', () {
    korrekturenSetzen({
      'x_test': {'beschreibung': 'Nebenband.'},
    }, (id) => id == 'x_test');
    final k = korrigiert(buch);
    expect(k.beschreibung, 'Nebenband.');
    expect(k.titel, 'Alt');
    expect(k.seiten, 100);
    expect(korrekturNeueBuecher, isEmpty);
  });

  test('Ausblenden und neue Bücher', () {
    korrekturenSetzen({
      'x_test': {'ausblenden': true},
      'x_neu': {'neu': true, 'titel': 'Neu', 'autor': 'B', 'zielgruppe': 'jugend'},
      'x_kaputt': {'neu': true, 'titel': 'Ohne Autor'},
    }, (id) => id == 'x_test');
    expect(ausgeblendet('x_test'), isTrue);
    expect(korrekturNeueBuecher.map((b) => b.id), ['x_neu']);
    expect(korrekturNeueBuecher.single.zielgruppe, Zielgruppe.jugend);
  });
}
