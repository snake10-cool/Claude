import 'package:austro_angler/data/bekannte_fische.dart';
import 'package:austro_angler/data/fische.dart';
import 'package:austro_angler/models/bundesland.dart';
import 'package:austro_angler/models/gewaesser.dart';
import 'package:austro_angler/services/alle_gewaesser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Fischarten der großen Gewässer gibt es alle im Lexikon', () {
    final ids = fische.map((f) => f.id).toSet();
    expect(fische.length, greaterThanOrEqualTo(80));
    for (final e in bekannteFische.entries) {
      for (final id in e.value.fische) {
        expect(ids, contains(id), reason: '${e.key}: $id');
      }
    }
    for (final l in typischeFische.values) {
      for (final id in l) {
        expect(ids, contains(id));
      }
    }
  });

  test('Alle Gewässer Österreichs werden geladen und zugeordnet', () async {
    await alleGewaesser.laden();
    expect(alleGewaesser.liste.length, greaterThan(20000));
    expect(alleGewaesser.bezirke.keys.length, Bundesland.values.length);
    expect(alleGewaesser.bezirke[Bundesland.ooe], contains('Braunau'));
    expect(alleGewaesser.gemeindenVon(Bundesland.ooe, 'Braunau'),
        contains('Mattighofen'));

    // Geprüftes Gewässer hat Bezirk und Gemeinden aus OSM bekommen …
    final inn = alleGewaesser.liste.firstWhere((g) => g.id == 'inn-braunau');
    expect(inn.bezirk, 'Braunau');
    expect(inn.gemeinden, contains('Braunau am Inn'));
    // … und der gleichnamige OSM-Eintrag im selben Bezirk ist weg.
    expect(
        alleGewaesser.liste.where(
            (g) => g.ausOsm && g.name == 'Inn' && g.bezirk == 'Braunau'),
        isEmpty);

    // Ort-Filter findet Bäche in Mattighofen.
    final mattighofen =
        alleGewaesser.liste.where((g) => g.liegtIn('Mattighofen')).toList();
    expect(mattighofen.length, greaterThan(3));

    // Große Gewässer haben Fischarten aus Fachquellen.
    final donau = alleGewaesser.liste.firstWhere((g) => g.name == 'Donau');
    expect(donau.fischQuelle, FischQuelle.bekannt);
    expect(donau.fischarten, contains('huchen'));

    // Suche nach Anzeigenamen klappt.
    final g = alleGewaesser.liste.firstWhere((g) => g.ausOsm);
    expect(alleGewaesser.zuName(g.anzeigeName), isNotNull);
  });
}
