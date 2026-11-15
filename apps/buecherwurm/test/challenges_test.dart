import 'package:buecherwurm/models/buch.dart';
import 'package:buecherwurm/services/challenges.dart';
import 'package:buecherwurm/services/speicher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Jeden Monat drei verschiedene Challenges, für alle gleich', () {
    for (var m = 1; m <= 12; m++) {
      final c = challengesFuer(2026, m);
      expect(c.length, 3);
      expect(c.toSet().length, 3);
      expect(challengesFuer(2026, m).map((x) => x.id), c.map((x) => x.id));
    }
  });

  test('Geschaffte Challenges bringen Bonuspunkte – nur einmal', () async {
    SharedPreferences.setMockInitialValues({});
    final s = await Speicher.laden();
    final jetzt = DateTime.now();
    // Viele verschiedene Bücher lesen, damit fast jede Challenge klappt.
    for (final id in ['hp7', 'pippi', 'sherlock', 'harari', 'anhalter', 'farm', 'dracula', 'percy']) {
      await s.eintragSetzen(id, Eintrag(status: Status.gelesen, format: Format.gehoert, datum: jetzt));
    }
    final neu = await s.challengesPruefen(jetzt);
    expect(neu, isNotEmpty);
    expect(s.bonusPunkte, neu.length * challengePunkte(jetzt.month));
    expect(s.punkte, s.bonusPunkte);
    expect(await s.challengesPruefen(jetzt), isEmpty, reason: 'nicht doppelt gutschreiben');
  });
}
