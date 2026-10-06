import 'package:app_basis/app_basis.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const regel = BewertungsRegel();
  final installiert = DateTime(2026, 10, 1);

  bool fragen({
    int tage = 10,
    int anfragen = 0,
    DateTime? zuletzt,
    DateTime? jetzt,
  }) =>
      regel.sollteFragen(
        installiert: installiert,
        nutzungstage: tage,
        anfragen: anfragen,
        zuletztGefragt: zuletzt,
        jetzt: jetzt ?? DateTime(2026, 10, 20),
      );

  test('fragt nach genug Nutzung', () {
    expect(fragen(), isTrue);
  });

  test('fragt nicht bei zu wenig Nutzungstagen', () {
    expect(fragen(tage: 3), isFalse);
  });

  test('fragt nicht kurz nach der Installation', () {
    expect(fragen(jetzt: DateTime(2026, 10, 4)), isFalse);
  });

  test('wartet nach einer Anfrage den Abstand ab', () {
    expect(fragen(anfragen: 1, zuletzt: DateTime(2026, 10, 1)), isFalse);
    expect(
      fragen(
        anfragen: 1,
        zuletzt: DateTime(2026, 10, 1),
        jetzt: DateTime(2026, 12, 15),
      ),
      isTrue,
    );
  });

  test('fragt nie öfter als erlaubt', () {
    expect(
      fragen(anfragen: 2, zuletzt: DateTime(2025), jetzt: DateTime(2027)),
      isFalse,
    );
  });

  test('Mehr Apps zeigt die eigene App nicht', () {
    final andere = MehrAppsScreen.andereApps('com.snake10.druckkasse');
    expect(andere.any((a) => a.paketId == 'com.snake10.druckkasse'), isFalse);
    expect(andere.every((a) => a.veroeffentlicht), isTrue);
  });
}
