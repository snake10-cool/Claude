// Automatisch erzeugt von tools/bilder_holen.py – nicht von Hand ändern.

class BildQuelle {
  const BildQuelle(this.pfad, this.datei, this.urheber, this.lizenz);

  final String pfad;
  final String datei;
  final String urheber;
  final String lizenz;

  String get text => 'Bild: $urheber, $lizenz, via Wikimedia Commons';
}

const fischBilder = <String, BildQuelle>{};

const knotenBilder = <String, BildQuelle>{};
