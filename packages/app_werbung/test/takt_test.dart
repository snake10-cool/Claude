import 'package:app_werbung/app_werbung.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nur jede zweite Gelegenheit und mit Mindestabstand', () {
    final takt = ZwischenwerbungsTakt();
    final t0 = DateTime(2026, 10, 6, 12);
    expect(takt.gelegenheit(t0), isFalse); // 1. Gelegenheit
    expect(takt.gelegenheit(t0), isTrue); // 2. → Werbung
    expect(takt.gelegenheit(t0.add(const Duration(minutes: 1))), isFalse);
    // 4. Gelegenheit, aber erst 1 Minute vergangen
    expect(takt.gelegenheit(t0.add(const Duration(minutes: 1))), isFalse);
    expect(takt.gelegenheit(t0.add(const Duration(minutes: 5))), isFalse);
    expect(takt.gelegenheit(t0.add(const Duration(minutes: 5))), isTrue);
  });

  test('Test-IDs, solange nurTest gilt', () {
    const ids = WerbeIds(banner: 'echt', nurTest: true);
    expect(ids.bannerId, WerbeIds.testBanner);
    const echt = WerbeIds(banner: 'echt', nurTest: false);
    expect(echt.bannerId, 'echt');
    expect(echt.belohnungId, WerbeIds.testBelohnung); // nicht gesetzt
  });
}
