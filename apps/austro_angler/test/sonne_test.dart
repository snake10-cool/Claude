import 'package:austro_angler/services/sonne.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Sonnenzeiten Braunau', () {
    // Braunau am 21.6.2026: Aufgang ca. 3:05 UTC, Untergang ca. 19:15 UTC.
    final z = sonnenZeiten(DateTime(2026, 6, 21), 48.258, 13.040);
    final auf = z.aufgang!.toUtc();
    final unter = z.untergang!.toUtc();
    expect(auf.hour * 60 + auf.minute, closeTo(3 * 60 + 5, 12));
    expect(unter.hour * 60 + unter.minute, closeTo(19 * 60 + 15, 12));
    expect(z.morgendaemmerung!.isBefore(z.aufgang!), isTrue);
    expect(z.goldeneStundeAbendBeginn!.isBefore(z.untergang!), isTrue);
  });
}
