/// Ist ein Stapel nutzbar? Gratis, gekauft (bzw. Abo) oder per
/// Belohnungs-Video für 24 Stunden freigeschaltet.
bool stapelOffen({
  required String? produkt,
  required bool gekauft,
  required DateTime? freiBis,
  required DateTime jetzt,
}) {
  if (produkt == null || gekauft) return true;
  return freiBis != null && jetzt.isBefore(freiBis);
}

/// Wie lange ein Video freischaltet.
const videoFreischaltung = Duration(hours: 24);
