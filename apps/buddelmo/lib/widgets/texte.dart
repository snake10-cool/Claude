import '../l10n/l.dart';
import '../logik/katalog.dart';
import '../logik/zahlen.dart';

String helferName(AppLocalizations l, String id) => switch (id) {
  'wurm' => l.helferWurm,
  'igel' => l.helferIgel,
  'schaufel' => l.helferSchaufel,
  'lore' => l.helferLore,
  'bohrer' => l.helferBohrer,
  'kristall' => l.helferKristall,
  'magma' => l.helferMagma,
  'laser' => l.helferLaser,
  _ => id,
};

String verbesserungName(AppLocalizations l, Verbesserung v) => switch (v.id) {
  'krallen1' => l.vKrallen1,
  'krallen2' => l.vKrallen2,
  'krallen3' => l.vKrallen3,
  'lampe' => l.vLampe,
  'lampe2' => l.vLampe2,
  'karte' => l.vKarte,
  'kompass' => l.vKompass,
  _ => l.vHelfer(helferName(l, v.ziel ?? '')),
};

String verbesserungWirkung(AppLocalizations l, Verbesserung v) {
  final f = v.faktor
      .toString()
      .replaceAll('.', ',')
      .replaceAll(RegExp(r',0$'), '');
  return switch (v.wirkung) {
    Wirkung.tippen => l.wirkungTippen(f),
    Wirkung.helfer => l.wirkungHelfer(helferName(l, v.ziel ?? ''), f),
    Wirkung.tippenAnteil => l.wirkungAnteil((v.faktor * 100).round()),
    Wirkung.alles => l.wirkungAlles(f),
  };
}

String erfolgName(AppLocalizations l, String id) => switch (id) {
  'tipp100' => l.eTipp100,
  'tipp1000' => l.eTipp1000,
  'tipp10000' => l.eTipp10000,
  'gold1k' => l.eGold1k,
  'gold1m' => l.eGold1m,
  'gold1b' => l.eGold1b,
  'gold1t' => l.eGold1t,
  'helfer10' => l.eHelfer10,
  'helfer100' => l.eHelfer100,
  'alleHelfer' => l.eAlleHelfer,
  'prestige1' => l.ePrestige1,
  'prestige5' => l.ePrestige5,
  'wurm20' => l.eWurm20,
  'wurm50' => l.eWurm50,
  'serie7' => l.eSerie7,
  _ => id,
};

String schichtName(AppLocalizations l, int i) => switch (i) {
  0 => l.schichtWiese,
  1 => l.schichtErde,
  2 => l.schichtLehm,
  3 => l.schichtStein,
  4 => l.schichtKristall,
  5 => l.schichtLava,
  _ => l.schichtKern,
};

String gold(double g) => '${grosseZahl(g)} 🪙';
