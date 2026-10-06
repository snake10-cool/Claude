/// Grenzen der Gratis-Version. Pro hebt alle auf.
abstract final class GratisGrenzen {
  static const produkte = 15;
  static const drucker = 2;
  static const sparziele = 1;
}

/// Darf noch etwas angelegt werden?
bool darfAnlegen({
  required int vorhanden,
  required int grenze,
  required bool istPro,
}) => istPro || vorhanden < grenze;
