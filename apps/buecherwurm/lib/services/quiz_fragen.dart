import 'dart:math';

import '../models/buch.dart';
import 'konto.dart';

/// Mindestens so viele Fragen braucht ein Quiz.
const mindestFragen = 3;

/// Fragen für ein Quiz: alle eingebauten plus freigegebene Leserfragen
/// (höchstens 2 zusätzlich, bei Büchern ohne eigenes Quiz höchstens 5).
List<Frage> quizFragen(Buch buch, Konto? konto, [Random? zufall]) {
  final leser = [...?konto?.gemeinschaftsFragen[buch.id]]..shuffle(zufall);
  return [...buch.quiz, ...leser.take(buch.quiz.isEmpty ? 5 : 2)];
}

bool quizVerfuegbar(Buch buch, Konto? konto) =>
    buch.quiz.length + (konto?.gemeinschaftsFragen[buch.id]?.length ?? 0) >= mindestFragen;
