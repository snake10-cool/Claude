// Automatisch erzeugt von tools/bilder_holen.py – nicht von Hand ändern.

class BildQuelle {
  const BildQuelle(this.pfad, this.datei, this.urheber, this.lizenz);

  final String pfad;
  final String datei;
  final String urheber;
  final String lizenz;

  String get text => 'Bild: $urheber, $lizenz, via Wikimedia Commons';
}

const fischBilder = <String, BildQuelle>{
  'bachforelle': BildQuelle('assets/bilder/fische/bachforelle.jpg', 'Bachforelle_Zeichnung.jpg', 'Duane Raver, U.S. Fish and Wildlife Service', 'Public domain'),
  'regenbogenforelle': BildQuelle('assets/bilder/fische/regenbogenforelle.jpg', 'Rainbow_Trout_(Oncorhynchus_mykiss)_(cropped).jpg', 'Liquid Art', 'CC BY-SA 4.0'),
  'seeforelle': BildQuelle('assets/bilder/fische/seeforelle.jpg', 'Salmo_trutta.jpg', 'Eric Engbretson for U.S. Fish and Wildlife Service', 'Public domain'),
  'bachsaibling': BildQuelle('assets/bilder/fische/bachsaibling.jpg', 'Native_brook_trout.jpg', 'Zach Matthews', 'CC BY-SA 3.0'),
  'seesaibling': BildQuelle('assets/bilder/fische/seesaibling.jpg', 'Salvelinus_umbla_IMG_5130.jpg', 'Bjoertvedt', 'CC BY-SA 3.0'),
  'aesche': BildQuelle('assets/bilder/fische/aesche.jpg', 'Thymallus_thymallus_Pénzes_pér.jpg', 'Zsoldos Márton', 'CC BY-SA 3.0'),
  'huchen': BildQuelle('assets/bilder/fische/huchen.jpg', 'Danube_Salmon_-_Huchen_(Hucho_hucho).jpg', 'Liquid Art', 'CC BY-SA 4.0'),
  'reinanke': BildQuelle('assets/bilder/fische/reinanke.jpg', 'Sik,_Iduns_kokbok.jpg', 'see Iduns kokbok', 'Public domain'),
  'hecht': BildQuelle('assets/bilder/fische/hecht.jpg', 'Europäischer_Hecht.jpg', 'HalbsHännile', 'CC BY-SA 4.0'),
  'zander': BildQuelle('assets/bilder/fische/zander.jpg', 'Sander_lucioperca_1.jpg', 'eLNuko', 'Public domain'),
  'flussbarsch': BildQuelle('assets/bilder/fische/flussbarsch.jpg', 'Perca_fluviatilis.jpg', 'The original uploader was GerardM at Dutch Wikipedia.', 'CC BY-SA 3.0'),
  'wels': BildQuelle('assets/bilder/fische/wels.jpg', 'Freischwimmender_Wels.jpg', 'HalbsHännile', 'CC BY-SA 4.0'),
  'aalrutte': BildQuelle('assets/bilder/fische/aalrutte.jpg', 'Trüsche_Zürichsee.jpg', 'Jeolme', 'CC BY-SA 4.0'),
  'karpfen': BildQuelle('assets/bilder/fische/karpfen.jpg', 'Common_carp.jpg', 'USFWS', 'Public domain'),
  'schleie': BildQuelle('assets/bilder/fische/schleie.jpg', 'Tinca_tinca_Prague_Vltava_1.jpg', 'Karelj', 'Public domain'),
  'brachse': BildQuelle('assets/bilder/fische/brachse.jpg', 'Carp_bream.jpg', 'Микова Наталия', 'Public domain'),
  'barbe': BildQuelle('assets/bilder/fische/barbe.jpg', 'Barbel.jpg', 'Neil Phillips from uk', 'CC BY 2.0'),
  'nase': BildQuelle('assets/bilder/fische/nase.jpg', 'Chondrostoma_nasus_(aka).jpg', 'André Karwath aka Aka', 'CC BY-SA 2.5'),
  'aitel': BildQuelle('assets/bilder/fische/aitel.jpg', 'Squalius_cephalus_Prague_Vltava_2.jpg', 'Karelj', 'Public domain'),
  'rapfen': BildQuelle('assets/bilder/fische/rapfen.jpg', 'Aspius_aspius_Prague_Vltava_1_(cropped).jpg', 'Karelj', 'Public domain'),
  'rotauge': BildQuelle('assets/bilder/fische/rotauge.jpg', 'Rutilus_rutilus_by_Algirdas_cropped.jpg', 'Scardinius_erythropthalmus1_resize.jpg: Original uploader was Algirdas at lt.wikipedia derivative work: George Chernilev', 'CC BY-SA 3.0'),
  'rotfeder': BildQuelle('assets/bilder/fische/rotfeder.jpg', 'Scardinius_erythropthalmus_2009_G1.jpg', 'George Chernilevsky', 'Public domain'),
  'laube': BildQuelle('assets/bilder/fische/laube.jpg', 'A_large_common_bleak.jpg', 'Peter van der Sluijs', 'CC BY-SA 3.0'),
  'seelaube': BildQuelle('assets/bilder/fische/seelaube.jpg', 'Alburnus_mento_állas_küsz.jpg', 'Zsoldos Márton', 'CC BY-SA 3.0'),
  'giebel': BildQuelle('assets/bilder/fische/giebel.jpg', 'Carassius_gibelio_2008_G3.jpg', 'George Chernilevsky', 'CC BY-SA 3.0'),
  'karausche': BildQuelle('assets/bilder/fische/karausche.jpg', 'Männliche_Karausche.jpg', 'Swaggo42', 'CC BY-SA 4.0'),
  'perlfisch': BildQuelle('assets/bilder/fische/perlfisch.jpg', 'Unsere_Süßwasserfische_(Tafel_45)_(6102605799).jpg', 'Walter, Emil', 'Public domain'),
  'kaulbarsch': BildQuelle('assets/bilder/fische/kaulbarsch.jpg', 'Gymnocephalus_cernuus_Pärnu_River_Estonia_2010-01-06.jpg', 'Tiit Hunt', 'CC BY-SA 3.0'),
  'aal': BildQuelle('assets/bilder/fische/aal.jpg', 'Anguilla_anguilla.jpg', 'GerardM', 'CC BY-SA 3.0'),
  'koppe': BildQuelle('assets/bilder/fische/koppe.jpg', 'CottusGobioSpreadingFins.JPG', 'Piet Spaans', 'CC BY-SA 2.5'),
  'elritze': BildQuelle('assets/bilder/fische/elritze.jpg', 'Phoxinus_phoxinus_img_33486.jpg', 'Pmau', 'CC BY-SA 4.0'),
};

const knotenBilder = <String, BildQuelle>{
  'clinch': BildQuelle('assets/bilder/knoten/clinch.jpg', 'KlammerknotenLose.JPG', 'StromBer 17:02, 6. Apr. 2008 (CEST)', 'CC BY-SA 2.0 de'),
  'palomar': BildQuelle('assets/bilder/knoten/palomar.jpg', 'Barb07.Palomarknoten.jpg', 'Der Barbar', 'CC BY 4.0'),
  'grinner': BildQuelle('assets/bilder/knoten/grinner.jpg', 'Uni_knot.jpg', 'Snapper G', 'CC BY-SA 3.0'),
  'chirurgenschlaufe': BildQuelle('assets/bilder/knoten/chirurgenschlaufe.jpg', 'Surgeon\'s_Loop_knot.svg', 'No machine-readable author provided. LadyofHats assumed (based on copyright claims).', 'Public domain'),
};
