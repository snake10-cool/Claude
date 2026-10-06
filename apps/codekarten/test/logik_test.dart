import 'package:codekarten/logik/srs.dart';
import 'package:codekarten/logik/streak.dart';
import 'package:codekarten/logik/syntax.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final jetzt = DateTime(2026, 10, 6, 18, 30);

  group('Spaced Repetition', () {
    test('neue Karte: gut → morgen, dann 3 Tage, dann × Leichtigkeit', () {
      var s = bewerten(null, Bewertung.gut, jetzt);
      expect(s.intervallTage, 1);
      expect(s.faellig, DateTime(2026, 10, 7));
      s = bewerten(s, Bewertung.gut, jetzt);
      expect(s.intervallTage, 3);
      s = bewerten(s, Bewertung.gut, jetzt);
      expect(s.intervallTage, 8); // 3 × 2,5 = 7,5 → 8
      expect(s.wiederholungen, 3);
    });

    test('nochmal setzt zurück, senkt Leichtigkeit und zählt Fehler', () {
      var s = bewerten(null, Bewertung.gut, jetzt);
      s = bewerten(s, Bewertung.gut, jetzt);
      s = bewerten(s, Bewertung.nochmal, jetzt);
      expect(s.wiederholungen, 0);
      expect(s.intervallTage, 0);
      expect(s.fehler, 1);
      expect(s.leichtigkeit, closeTo(2.3, 1e-9));
      expect(s.faellig.isAfter(jetzt), isTrue);
      expect(s.faellig.difference(jetzt).inMinutes, lessThan(5));
    });

    test('Leichtigkeit fällt nie unter 1,3', () {
      Lernstand? s;
      for (var i = 0; i < 20; i++) {
        s = bewerten(s, Bewertung.nochmal, jetzt);
      }
      expect(s!.leichtigkeit, Lernstand.minLeichtigkeit);
    });

    test('leicht springt weiter, schwer weniger weit', () {
      final basis = bewerten(
        bewerten(null, Bewertung.gut, jetzt),
        Bewertung.gut,
        jetzt,
      ); // 3 Tage
      final leicht = bewerten(basis, Bewertung.leicht, jetzt);
      final gut = bewerten(basis, Bewertung.gut, jetzt);
      final schwer = bewerten(basis, Bewertung.schwer, jetzt);
      expect(leicht.intervallTage, greaterThan(gut.intervallTage));
      expect(gut.intervallTage, greaterThan(schwer.intervallTage));
      expect(schwer.intervallTage, greaterThan(basis.intervallTage));
    });

    test('Intervall höchstens ein Jahr', () {
      var s = bewerten(null, Bewertung.leicht, jetzt);
      for (var i = 0; i < 30; i++) {
        s = bewerten(s, Bewertung.leicht, jetzt);
      }
      expect(s.intervallTage, 365);
    });
  });

  group('Streak', () {
    final heute = DateTime(2026, 10, 6, 9);
    Map<DateTime, int> tage(List<int> rueckwaerts) => {
      for (var i = 0; i < rueckwaerts.length; i++)
        DateTime(2026, 10, 6 - i): rueckwaerts[i],
    };

    test('zählt Tage mit erreichtem Ziel bis heute', () {
      expect(streak(tage([20, 25, 20, 3, 20]), 20, heute), 3);
    });

    test('heute noch offen → Serie bis gestern bleibt', () {
      expect(streak(tage([5, 20, 20]), 20, heute), 2);
    });

    test('gestern verpasst → 0 (wenn heute auch noch nicht)', () {
      expect(streak(tage([0, 0, 20, 20]), 20, heute), 0);
    });

    test('über Monatsgrenze', () {
      final t = {
        DateTime(2026, 10, 1): 20,
        DateTime(2026, 9, 30): 20,
        DateTime(2026, 9, 29): 20,
      };
      expect(streak(t, 20, DateTime(2026, 10, 1, 22)), 3);
    });

    test('längste Serie', () {
      final t = {
        DateTime(2026, 9, 1): 20,
        DateTime(2026, 9, 2): 20,
        DateTime(2026, 9, 3): 20,
        DateTime(2026, 9, 10): 20,
        DateTime(2026, 9, 11): 5,
      };
      expect(laengsteStreak(t, 20), 3);
    });
  });

  group('Syntax', () {
    test('Java: Schlüsselwörter, Strings, Zahlen, Kommentare, Funktionen', () {
      final t = zerlegen(
        'int x = 5; // fünf\nSystem.out.println("Hi");',
        'java',
      );
      String art(String text) =>
          t.firstWhere((x) => x.text.contains(text)).art.name;
      expect(art('int'), 'schluesselwort');
      expect(art('5'), 'zahl');
      expect(art('// fünf'), 'kommentar');
      expect(art('"Hi"'), 'string');
      expect(art('println'), 'funktion');
      expect(art('System'), 'typ');
      // Nichts geht verloren.
      expect(
        t.map((x) => x.text).join(),
        'int x = 5; // fünf\nSystem.out.println("Hi");',
      );
    });

    test('Python: # ist Kommentar, // ist Division', () {
      final t = zerlegen('x = 7 // 2  # Rest weg', 'python');
      expect(
        t.any((x) => x.art == TokenArt.kommentar && x.text == '# Rest weg'),
        isTrue,
      );
      expect(
        t.any((x) => x.art == TokenArt.kommentar && x.text.contains('//')),
        isFalse,
      );
      expect(t.map((x) => x.text).join(), 'x = 7 // 2  # Rest weg');
    });

    test('JavaScript: Template-Strings', () {
      final t = zerlegen(r'const s = `Hallo ${name}`;', 'javascript');
      expect(
        t.any((x) => x.art == TokenArt.string && x.text.startsWith('`')),
        isTrue,
      );
    });
  });
}
