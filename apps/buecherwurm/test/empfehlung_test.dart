import 'package:buecherwurm/models/buch.dart';
import 'package:buecherwurm/services/empfehlung.dart';
import 'package:flutter_test/flutter_test.dart' hide Tags;

void main() {
  test('Fantasy-Fan bekommt Fantasy empfohlen', () {
    final liste = empfehlen(
      antworten: {
        'alter': ['14'],
        'genres': ['fantasy'],
        'welt': ['magie'],
      },
      eintraege: {},
    );
    expect(liste.take(3).every((e) => e.buch.tags.contains(Tags.fantasy)), isTrue);
  });

  test('Krimi-Fan bekommt Krimis empfohlen', () {
    final liste = empfehlen(
      antworten: {
        'alter': ['30'],
        'genres': ['krimi'],
        'wichtig': ['raetsel'],
      },
      eintraege: {},
    );
    expect(liste.first.buch.tags.contains(Tags.krimi), isTrue);
  });

  test('Bücher in der Bibliothek werden nicht empfohlen', () {
    final liste = empfehlen(
      antworten: {'genres': ['fantasy']},
      eintraege: {'hp1': Eintrag(status: Status.gelesen, sterne: 5)},
    );
    expect(liste.any((e) => e.buch.id == 'hp1'), isFalse);
  });

  test('Altersgrenze wird beachtet', () {
    final liste = empfehlen(
      antworten: {
        'alter': ['u10'],
        'genres': ['horror'],
      },
      eintraege: {},
      anzahl: 100,
    );
    expect(liste.any((e) => e.buch.id == 'es'), isFalse);
  });

  test('Lieblingsbuch zieht ähnliche Bücher nach oben', () {
    final ohne = empfehlen(antworten: {'alter': ['18']}, eintraege: {}, anzahl: 100);
    final mit = empfehlen(
      antworten: {'alter': ['18']},
      eintraege: {'1984': Eintrag(status: Status.gelesen, sterne: 5)},
      anzahl: 100,
    );
    int platz(List<Empfehlung> l) => l.indexWhere((e) => e.buch.id == 'fahrenheit');
    expect(platz(mit), lessThan(platz(ohne)));
    expect(mit.firstWhere((e) => e.buch.id == 'fahrenheit').gruende.first, contains('1984'));
  });
}
