import 'package:buecherwurm/data/katalog.dart';
import 'package:buecherwurm/services/empfehlung.dart';
import 'package:buecherwurm/services/vergleich.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final hp1 = katalogBuch('hp1')!; // Fantasy, Freundschaft …
  final twilight = katalogBuch('twilight')!; // Fantasy, Liebe …
  final tschick = katalogBuch('tschick')!; // keine Fantasy

  test('Themen nur, wenn mindestens zwei Bücher sie haben', () {
    final r = runden([hp1, twilight, tschick]);
    final magie = r.firstWhere((x) => x.$1.id == 'magie');
    expect(magie.$2, containsAll([hp1, twilight]));
    expect(magie.$2, isNot(contains(tschick)));
    expect(r.where((x) => x.$1.id == 'liebe'), isEmpty, reason: 'nur Twilight hat Liebe');
    expect(r.firstWhere((x) => x.$1.id == 'gesamt').$2.length, 3);
  });

  test('Auswertung: Rangliste, Sieger und Vorlieben', () {
    final e = auswerten([hp1, twilight], {
      'gesamt': {'hp1': 3, 'twilight': 1},
      'magie': {'hp1': 3, 'twilight': 0},
    });
    expect(e.rangliste.first.$1, hp1);
    expect(e.sieger.values, contains(hp1));
    expect(e.vorlieben['fantasy'], closeTo(0, 0.01)); // einmal super, einmal gar nicht
    expect(e.sterne, {'hp1': 5, 'twilight': 3});
  });

  test('Vorlieben verschieben die Empfehlungen', () {
    final ohne = empfehlen(antworten: {'alter': ['18']}, eintraege: {}, anzahl: 400);
    final mit = empfehlen(antworten: {'alter': ['18']}, eintraege: {}, anzahl: 400, vorlieben: {'horror': 1});
    int platz(List<Empfehlung> l) => l.indexWhere((x) => x.buch.id == 'dracula');
    expect(platz(mit), lessThan(platz(ohne)));
  });
}
