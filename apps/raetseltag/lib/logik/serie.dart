import 'tag.dart';

/// Tage am Stück mit mindestens einem gelösten Rätsel. Heute noch nichts
/// gelöst → Serie zählt bis gestern.
int serie(Set<int> geloesteNummern, DateTime heute) {
  var n = raetselNummer(heute);
  if (!geloesteNummern.contains(n)) n--;
  var anzahl = 0;
  while (geloesteNummern.contains(n)) {
    anzahl++;
    n--;
  }
  return anzahl;
}

int laengsteSerie(Set<int> geloesteNummern) {
  final liste = geloesteNummern.toList()..sort();
  var beste = 0, aktuell = 0;
  int? vorher;
  for (final n in liste) {
    aktuell = vorher != null && n == vorher + 1 ? aktuell + 1 : 1;
    if (aktuell > beste) beste = aktuell;
    vorher = n;
  }
  return beste;
}
