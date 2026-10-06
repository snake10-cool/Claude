import 'package:buddelmo/logik/katalog.dart';
import 'package:buddelmo/logik/spiel.dart';
import 'package:buddelmo/logik/zahlen.dart';
import 'package:flutter_test/flutter_test.dart';

HelferArt h(String id) => helferArten.firstWhere((x) => x.id == id);
Verbesserung v(String id) => verbesserungen.firstWhere((x) => x.id == id);

void main() {
  final jetzt = DateTime(2026, 10, 6, 12);

  test('Tippen bringt 1 Gold, Verbesserung verdoppelt', () {
    final s = Spiel(Spielstand());
    expect(s.tippen(jetzt), 1);
    s.stand.gold = 100;
    expect(s.verbesserungKaufen(v('krallen1')), isTrue);
    expect(s.stand.gold, 0);
    expect(s.tippen(jetzt), 2);
    expect(s.stand.tipps, 2);
  });

  test('Helfer kosten 15 % mehr pro Stück, Summenformel stimmt', () {
    final s = Spiel(Spielstand(gold: 1000));
    final drei = s.helferKosten(h('wurm'), 3);
    expect(drei, closeTo(15 + 15 * 1.15 + 15 * 1.15 * 1.15, 1e-9));
    expect(s.helferKaufen(h('wurm'), 3), isTrue);
    expect(s.stand.helfer['wurm'], 3);
    expect(s.helferKosten(h('wurm')), closeTo(15 * 1.15 * 1.15 * 1.15, 1e-9));
  });

  test('„Max“ kauft genau so viele, wie man sich leisten kann', () {
    final s = Spiel(Spielstand(gold: 1000));
    final n = s.helferLeistbar(h('wurm'));
    expect(s.helferKosten(h('wurm'), n), lessThanOrEqualTo(1000));
    expect(s.helferKosten(h('wurm'), n + 1), greaterThan(1000));
    expect(s.helferKaufen(h('wurm'), n), isTrue);
    expect(s.helferLeistbar(h('wurm')), 0);
  });

  test('Produktion mit Helfer-Verbesserung, Glitzer und Boost', () {
    final s = Spiel(Spielstand(helfer: {'wurm': 10, 'igel': 2}));
    expect(s.proSekunde(jetzt), closeTo(1 + 2, 1e-9));
    s.stand.gekauft.add('wurm2');
    expect(s.proSekunde(jetzt), closeTo(2 + 2, 1e-9));
    s.stand.glitzer = 5; // +50 %
    expect(s.proSekunde(jetzt), closeTo(6, 1e-9));
    s.stand.boostBis = jetzt.add(const Duration(minutes: 5));
    expect(s.proSekunde(jetzt), closeTo(12, 1e-9));
  });

  test('tick schreibt Produktion gut', () {
    final s = Spiel(Spielstand(helfer: {'igel': 3}));
    s.tick(const Duration(milliseconds: 500), jetzt);
    expect(s.stand.gold, closeTo(1.5, 1e-9));
    expect(s.stand.goldGesamt, closeTo(1.5, 1e-9));
  });

  test('Offline: halbe Produktion, höchstens 8 Stunden, ohne Boost', () {
    final s = Spiel(
      Spielstand(
        helfer: {'igel': 10},
        letzterBesuch: jetzt.subtract(const Duration(hours: 2)),
        boostBis: jetzt.subtract(const Duration(hours: 1, minutes: 50)),
      ),
    );
    final (gold, zeit) = s.offlineErtrag(jetzt);
    expect(zeit, const Duration(hours: 2));
    expect(gold, closeTo(10 * 0.5 * 7200, 1e-6));
    s.stand.letzterBesuch = jetzt.subtract(const Duration(days: 3));
    expect(s.offlineErtrag(jetzt).$2, offlineMaximum);
  });

  test('Prestige: Wurzel aus Millionen, setzt Runde zurück', () {
    final s = Spiel(
      Spielstand(
        gold: 5e6,
        goldDieseRunde: 9e6,
        goldGesamt: 9e6,
        helfer: {'wurm': 50},
        gekauft: {'krallen1'},
      ),
    );
    expect(s.glitzerFuerPrestige(), 3);
    expect(s.prestigeMachen(), isTrue);
    expect(s.stand.glitzer, 3);
    expect(s.stand.gold, 0);
    expect(s.stand.helfer, isEmpty);
    expect(s.stand.gekauft, isEmpty);
    expect(s.stand.goldGesamt, 9e6);
    expect(s.prestigeMachen(), isFalse);
  });

  test('Tagesbonus: einmal pro Tag, Serie, Tag 7 gibt Glitzer', () {
    final s = Spiel(Spielstand());
    var tag = DateTime(2026, 10, 1, 9);
    for (var i = 1; i <= 7; i++) {
      expect(s.tagesbonusVerfuegbar(tag), isTrue);
      expect(s.bonusTagNummer(tag), i);
      final (gold, glitzer) = s.tagesbonusAbholen(tag)!;
      expect(gold, greaterThanOrEqualTo(100.0 * i));
      expect(glitzer, i == 7 ? 1 : 0);
      expect(s.tagesbonusAbholen(tag), isNull);
      tag = tag.add(const Duration(days: 1));
    }
    expect(s.bonusTagNummer(tag), 1); // nach Tag 7 von vorne
    // Einen Tag auslassen → Serie beginnt neu.
    s.tagesbonusAbholen(tag);
    expect(s.bonusTagNummer(tag.add(const Duration(days: 2))), 1);
  });

  test('Erfolge werden einmal gemeldet', () {
    final s = Spiel(Spielstand(tipps: 150, goldGesamt: 2000));
    final neu = s.erfolgePruefen().map((e) => e.id).toSet();
    expect(neu, {'tipp100', 'gold1k'});
    expect(s.erfolgePruefen(), isEmpty);
  });

  test('Speichern und Laden ergibt denselben Stand', () {
    final s = Spielstand(
      gold: 12.5,
      helfer: {'wurm': 3},
      gekauft: {'krallen1'},
      glitzer: 2,
      erfolge: {'tipp100'},
      boostBis: DateTime(2026, 10, 6, 13),
      letzterBesuch: jetzt,
    );
    final kopie = Spielstand.ausJson(s.toJson());
    expect(kopie.toJson(), s.toJson());
  });

  test('Zahlen lesbar', () {
    expect(grosseZahl(0), '0');
    expect(grosseZahl(2.5), '2,5');
    expect(grosseZahl(999), '999');
    expect(grosseZahl(12345), '12.345');
    expect(grosseZahl(1500000), '1,50 Mio');
    expect(grosseZahl(23400000000), '23,4 Mrd');
    expect(grosseZahl(1e15), '1,00 Brd');
  });

  test('Schichten nach Gesamtgold', () {
    expect(schichtIndex(0), 0);
    expect(schichtIndex(5e3), 1);
    expect(schichtIndex(1e14), schichten.length - 1);
  });
}
