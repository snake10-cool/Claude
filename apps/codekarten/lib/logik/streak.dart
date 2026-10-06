import 'srs.dart';

/// Tage am Stück, an denen das Tagesziel erreicht wurde. Ist heute noch
/// nicht erreicht, zählt die Serie bis gestern (sie ist noch nicht verloren).
int streak(Map<DateTime, int> kartenProTag, int tagesziel, DateTime heute) {
  bool erreicht(DateTime tag) =>
      (kartenProTag[tagBeginn(tag)] ?? 0) >= tagesziel;
  var tag = tagBeginn(heute);
  if (!erreicht(tag)) tag = DateTime(tag.year, tag.month, tag.day - 1);
  var anzahl = 0;
  while (erreicht(tag)) {
    anzahl++;
    tag = DateTime(tag.year, tag.month, tag.day - 1);
  }
  return anzahl;
}

/// Längste Serie überhaupt.
int laengsteStreak(Map<DateTime, int> kartenProTag, int tagesziel) {
  final tage =
      kartenProTag.entries
          .where((e) => e.value >= tagesziel)
          .map((e) => tagBeginn(e.key))
          .toSet()
          .toList()
        ..sort();
  var beste = 0, aktuell = 0;
  DateTime? vorher;
  for (final t in tage) {
    final folgt =
        vorher != null &&
        DateTime(vorher.year, vorher.month, vorher.day + 1) == t;
    aktuell = folgt ? aktuell + 1 : 1;
    if (aktuell > beste) beste = aktuell;
    vorher = t;
  }
  return beste;
}
