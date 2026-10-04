import 'package:austro_angler/models/bundesland.dart';
import 'package:austro_angler/services/alle_gewaesser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

    // Suche nach Anzeigenamen klappt.
    final g = alleGewaesser.liste.firstWhere((g) => g.ausOsm);
    expect(alleGewaesser.zuName(g.anzeigeName), isNotNull);
  });
}
