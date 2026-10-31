import 'package:buecherwurm/models/meldung.dart';
import 'package:buecherwurm/services/speicher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Gemeldete Fragen bleiben ohne Konto gespeichert', () async {
    SharedPreferences.setMockInitialValues({});
    final s = await Speicher.laden();
    await s.meldungMerken(const FrageMeldung(
      buchId: 'loecher',
      buchTitel: 'Löcher',
      frage: 'Was essen sie?',
      richtig: 'Zwiebeln',
      gewaehlt: 'Pfirsiche',
      grund: 'mehrere',
      text: 'Pfirsich-Zeug auch',
    ));
    final neu = await Speicher.laden();
    expect(neu.offeneMeldungen, hasLength(1));
    expect(neu.offeneMeldungen.single.grundText, 'Mehrere Antworten könnten stimmen');
    await neu.meldungenGesendet();
    expect((await Speicher.laden()).offeneMeldungen, isEmpty);
  });
}
