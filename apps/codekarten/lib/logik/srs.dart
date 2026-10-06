import 'dart:math' as math;

/// Wie gut man eine Karte konnte.
enum Bewertung { nochmal, schwer, gut, leicht }

/// Lernstand einer Karte nach dem SM-2-Verfahren (wie Anki, vereinfacht).
class Lernstand {
  const Lernstand({
    required this.wiederholungen,
    required this.leichtigkeit,
    required this.intervallTage,
    required this.faellig,
    this.fehler = 0,
  });

  /// Wie oft hintereinander richtig gewusst.
  final int wiederholungen;

  /// Faktor, um den das Intervall wächst (1,3 bis ca. 3).
  final double leichtigkeit;

  /// 0 = heute nochmal.
  final int intervallTage;
  final DateTime faellig;

  /// Wie oft insgesamt vergessen.
  final int fehler;

  static const startLeichtigkeit = 2.5;
  static const minLeichtigkeit = 1.3;

  /// Gilt als „gelernt“, sobald das Intervall mindestens 21 Tage beträgt.
  bool get gefestigt => intervallTage >= 21;
}

DateTime tagBeginn(DateTime t) => DateTime(t.year, t.month, t.day);

/// Neuer Lernstand nach einer Bewertung. [alt] ist `null` bei neuen Karten.
Lernstand bewerten(Lernstand? alt, Bewertung b, DateTime jetzt) {
  final wdh = alt?.wiederholungen ?? 0;
  final ease = alt?.leichtigkeit ?? Lernstand.startLeichtigkeit;
  final intervall = alt?.intervallTage ?? 0;
  final fehler = alt?.fehler ?? 0;

  if (b == Bewertung.nochmal) {
    return Lernstand(
      wiederholungen: 0,
      leichtigkeit: math.max(Lernstand.minLeichtigkeit, ease - 0.2),
      intervallTage: 0,
      // Kommt in der gleichen Lernrunde gleich nochmal.
      faellig: jetzt.add(const Duration(minutes: 1)),
      fehler: fehler + 1,
    );
  }

  final int neu;
  var neueEase = ease;
  switch (b) {
    case Bewertung.schwer:
      neu = wdh == 0 ? 1 : math.max(intervall + 1, (intervall * 1.2).round());
      neueEase = math.max(Lernstand.minLeichtigkeit, ease - 0.15);
    case Bewertung.gut:
      neu = switch (wdh) {
        0 => 1,
        1 => 3,
        _ => math.max(intervall + 1, (intervall * ease).round()),
      };
    case Bewertung.leicht:
      neu = switch (wdh) {
        0 => 4,
        1 => 6,
        _ => math.max(intervall + 1, (intervall * ease * 1.3).round()),
      };
      neueEase = ease + 0.15;
    case Bewertung.nochmal:
      throw StateError('oben behandelt');
  }
  // Höchstens ein Jahr.
  final tage = math.min(neu, 365);
  final heute = tagBeginn(jetzt);
  return Lernstand(
    wiederholungen: wdh + 1,
    leichtigkeit: neueEase,
    intervallTage: tage,
    faellig: DateTime(heute.year, heute.month, heute.day + tage),
    fehler: fehler,
  );
}

/// Vorschau für die Knöpfe: „1 T“, „3 T“, „2 M“ …
int naechstesIntervall(Lernstand? alt, Bewertung b, DateTime jetzt) =>
    bewerten(alt, b, jetzt).intervallTage;
