import 'package:app_kauf/app_kauf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ohne Kaufpflicht ist alles frei', () {
    expect(
      proFreigeschaltet(
          kaufPflicht: false, plattformMitKauf: true, gekauft: false),
      isTrue,
    );
  });

  test('mit Kaufpflicht nur nach Kauf', () {
    expect(
      proFreigeschaltet(
          kaufPflicht: true, plattformMitKauf: true, gekauft: false),
      isFalse,
    );
    expect(
      proFreigeschaltet(
          kaufPflicht: true, plattformMitKauf: true, gekauft: true),
      isTrue,
    );
  });

  test('ohne Play Store (z. B. Windows) ist alles frei', () {
    expect(
      proFreigeschaltet(
          kaufPflicht: true, plattformMitKauf: false, gekauft: false),
      isTrue,
    );
  });
}
