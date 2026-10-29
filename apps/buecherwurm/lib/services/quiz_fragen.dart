import 'dart:math';

import '../data/quiz_zusatz.dart';
import '../models/buch.dart';
import 'konto.dart';

/// Mindestens so viele Fragen braucht ein Quiz.
const mindestFragen = 5;

/// So viele Fragen hat ein Quiz höchstens – je nach Altersgruppe des Buchs.
int fragenProQuiz(Zielgruppe z) => switch (z) {
      Zielgruppe.kinder => 10,
      Zielgruppe.jugend => 12,
      Zielgruppe.erwachsene => 15,
    };

/// Fragen für ein Quiz: zufällig aus den eingebauten und den freigegebenen
/// Leserfragen. Gibt es mehr als nötig, ist jede Runde etwas anders.
/// Alle fest hinterlegten Fragen eines Buchs (Programmcode + Zusatz-Paket).
List<Frage> eingebauteFragen(Buch buch) => [...buch.quiz, ...?zusatzFragen[buch.id]];

/// Schwierigkeit des Quiz: aus dem Zusatz-Paket, sonst vom Buch.
Schwierigkeit stufeVon(Buch buch) => zusatzStufe[buch.id] ?? buch.stufe;

List<Frage> quizFragen(Buch buch, Konto? konto, [Random? zufall]) {
  final alle = [...eingebauteFragen(buch), ...?konto?.gemeinschaftsFragen[buch.id]]..shuffle(zufall);
  return alle.take(fragenProQuiz(buch.zielgruppe)).toList();
}

/// Bücher, die noch nicht erschienen sind: Ihr Quiz wird erst ab dem
/// Erscheinungstag freigeschaltet – vorher kann es niemand gelesen haben.
final quizErstAb = <String, DateTime>{
  'x_windwalkersspioneimschwarm': DateTime(2027, 1, 18),
};

/// Erscheinungstag, falls das Buch noch nicht erschienen ist, sonst null.
DateTime? nochNichtErschienen(Buch buch, {DateTime? jetzt}) {
  final ab = quizErstAb[buch.id];
  return ab != null && (jetzt ?? DateTime.now()).isBefore(ab) ? ab : null;
}

bool quizVerfuegbar(Buch buch, Konto? konto, {DateTime? jetzt}) =>
    nochNichtErschienen(buch, jetzt: jetzt) == null &&
    eingebauteFragen(buch).length + (konto?.gemeinschaftsFragen[buch.id]?.length ?? 0) >= mindestFragen;
