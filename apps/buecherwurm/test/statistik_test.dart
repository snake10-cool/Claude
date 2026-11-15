import 'package:buecherwurm/models/buch.dart';
import 'package:buecherwurm/services/abzeichen.dart';
import 'package:buecherwurm/services/speicher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Lese-Serie zählt zusammenhängende Tage bis heute bzw. gestern', () async {
    SharedPreferences.setMockInitialValues({});
    final s = await Speicher.laden();
    final heute = DateTime.now();
    for (var i = 1; i <= 3; i++) {
      await s.leseTagMerken(heute.subtract(Duration(days: i)));
    }
    expect(leseSerie(s), 3, reason: 'heute noch nicht gelesen ist kein Abbruch');
    await s.leseTagMerken();
    expect(leseSerie(s), 4);
    expect(s.heuteGelesen, isTrue);
  });

  test('Leseziel und Abzeichen', () async {
    SharedPreferences.setMockInitialValues({});
    final s = await Speicher.laden();
    await s.jahreszielSetzen(1);
    expect(alleAbzeichen.where((a) => a.erreicht(s)), isEmpty);
    await s.eintragSetzen('hp1', Eintrag(status: Status.gelesen));
    expect(s.gelesenImJahr(DateTime.now().year), 1);
    final namen = alleAbzeichen.where((a) => a.erreicht(s)).map((a) => a.name);
    expect(namen, containsAll(['Erstes Buch', 'Ziel erreicht']));
    expect(gesamtSeiten(s), 336);
  });

  test('Seite setzen merkt sich den Lese-Tag', () async {
    SharedPreferences.setMockInitialValues({});
    final s = await Speicher.laden();
    await s.eintragSetzen('hp1', Eintrag(status: Status.lese));
    await s.seiteSetzen('hp1', 100);
    expect(s.eintraege['hp1']!.seite, 100);
    expect(s.heuteGelesen, isTrue);
  });
}
