import 'package:codekarten/logik/freischaltung.dart';
import 'package:codekarten/logik/suche.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Tags werden getrimmt, klein und ohne Doppelte', () {
    expect(tagsLesen(' Java, Basics ,java,, Schleifen'), [
      'java',
      'basics',
      'schleifen',
    ]);
  });

  test('Suche: alle Wörter müssen vorkommen', () {
    bool p(String s) => passtZurSuche(
      suche: s,
      titel: 'For-Schleife',
      code: 'for (int i = 0; i < 3; i++) {}',
      notiz: 'zählt hoch',
      tags: 'java,schleifen',
    );
    expect(p('schleife'), isTrue);
    expect(p('JAVA i++'), isTrue);
    expect(p('java python'), isFalse);
    expect(p(''), isTrue);
  });

  test('Stapel-Freischaltung', () {
    final jetzt = DateTime(2026, 10, 6, 12);
    expect(
      stapelOffen(produkt: null, gekauft: false, freiBis: null, jetzt: jetzt),
      isTrue,
    );
    expect(
      stapelOffen(produkt: 'p', gekauft: true, freiBis: null, jetzt: jetzt),
      isTrue,
    );
    expect(
      stapelOffen(produkt: 'p', gekauft: false, freiBis: null, jetzt: jetzt),
      isFalse,
    );
    expect(
      stapelOffen(
        produkt: 'p',
        gekauft: false,
        freiBis: jetzt.add(const Duration(hours: 1)),
        jetzt: jetzt,
      ),
      isTrue,
    );
    expect(
      stapelOffen(
        produkt: 'p',
        gekauft: false,
        freiBis: jetzt.subtract(const Duration(minutes: 1)),
        jetzt: jetzt,
      ),
      isFalse,
    );
  });
}
