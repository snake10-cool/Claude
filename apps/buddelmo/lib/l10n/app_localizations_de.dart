// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get ok => 'OK';

  @override
  String get los => 'Los!';

  @override
  String get nochmal => 'Nochmal';

  @override
  String get spaeter => 'Später';

  @override
  String get einstellungen => 'Einstellungen';

  @override
  String get kaufen => 'Kaufen';

  @override
  String proSekunde(String wert) {
    return '$wert pro Sekunde';
  }

  @override
  String get shop => 'Shop & Einstellungen';

  @override
  String get tiefe => 'Tiefe';

  @override
  String get schichtWiese => 'Wiese';

  @override
  String get schichtErde => 'Erde';

  @override
  String get schichtLehm => 'Lehm';

  @override
  String get schichtStein => 'Stein';

  @override
  String get schichtKristall => 'Kristallhöhle';

  @override
  String get schichtLava => 'Lava';

  @override
  String get schichtKern => 'Erdkern';

  @override
  String get tagesbonus => 'Tagesbonus';

  @override
  String get wurmregen => 'Wurmregen';

  @override
  String get boost => 'Boost';

  @override
  String get helfer => 'Helfer';

  @override
  String get verbesserungen => 'Verbesserungen';

  @override
  String get huegel => 'Hügel';

  @override
  String get helferWurm => 'Regenwurm';

  @override
  String get helferIgel => 'Igel-Kumpel';

  @override
  String get helferSchaufel => 'Spitzhacke';

  @override
  String get helferLore => 'Grubenlore';

  @override
  String get helferBohrer => 'Tunnelbohrer';

  @override
  String get helferKristall => 'Kristallsucher';

  @override
  String get helferMagma => 'Magmapumpe';

  @override
  String get helferLaser => 'Erdkern-Laser';

  @override
  String helferInfo(String einzeln, String gesamt) {
    return 'je $einzeln/s · gesamt $gesamt/s';
  }

  @override
  String get naechsterHelfer => 'Neuer Helfer';

  @override
  String abGold(String gold) {
    return 'zeigt sich ab $gold';
  }

  @override
  String get vKrallen1 => 'Stärkere Krallen';

  @override
  String get vKrallen2 => 'Stahlkrallen';

  @override
  String get vKrallen3 => 'Diamantkrallen';

  @override
  String get vLampe => 'Helle Grubenlampe';

  @override
  String get vLampe2 => 'Superlampe';

  @override
  String get vKarte => 'Schatzkarte';

  @override
  String get vKompass => 'Goldkompass';

  @override
  String vHelfer(String helfer) {
    return 'Training: $helfer';
  }

  @override
  String wirkungTippen(String faktor) {
    return 'Tippen ×$faktor';
  }

  @override
  String wirkungHelfer(String helfer, String faktor) {
    return '$helfer ×$faktor';
  }

  @override
  String wirkungAnteil(int prozent) {
    return 'Tippen +$prozent % der Produktion';
  }

  @override
  String wirkungAlles(String faktor) {
    return 'Alles ×$faktor';
  }

  @override
  String get keineVerbesserungen =>
      'Gerade keine Verbesserungen. Grab weiter – bald gibt\'s neue!';

  @override
  String get neuerHuegel => 'Neuer Hügel';

  @override
  String neuerHuegelText(int glitzer, int prozent) {
    return 'Fang auf einem neuen Hügel von vorne an und nimm Glitzersteine mit. Jeder Stein bringt +10 % für immer. Du hast $glitzer ✨ (+$prozent %).';
  }

  @override
  String neuerHuegelKnopf(int anzahl) {
    return 'Neuer Hügel: +$anzahl ✨';
  }

  @override
  String neuerHuegelAb(String gold) {
    return 'Ab $gold Gold in dieser Runde';
  }

  @override
  String erfolge(int hast, int gesamt) {
    return 'Erfolge ($hast/$gesamt)';
  }

  @override
  String prestigeWarnung(int anzahl, int prozent) {
    return 'Gold, Helfer und Verbesserungen werden zurückgesetzt. Du bekommst $anzahl Glitzersteine (+$prozent % für immer).';
  }

  @override
  String get losGehts => 'Los geht\'s';

  @override
  String erfolgFreigeschaltet(String name) {
    return 'Erfolg: $name';
  }

  @override
  String klumpenGefunden(String gold) {
    return 'Glücksklumpen! +$gold Gold';
  }

  @override
  String get eTipp100 => '100 Mal gebuddelt';

  @override
  String get eTipp1000 => '1.000 Mal gebuddelt';

  @override
  String get eTipp10000 => 'Buddel-Profi: 10.000 Tipps';

  @override
  String get eGold1k => 'Erstes Säckchen: 1.000 Gold';

  @override
  String get eGold1m => 'Millionär';

  @override
  String get eGold1b => 'Milliardär';

  @override
  String get eGold1t => 'Goldkönig: 1 Billion';

  @override
  String get eHelfer10 => '10 Helfer';

  @override
  String get eHelfer100 => '100 Helfer';

  @override
  String get eAlleHelfer => 'Von jedem einen';

  @override
  String get ePrestige1 => 'Erster neuer Hügel';

  @override
  String get ePrestige5 => 'Hügel-Hüpfer: 5 Hügel';

  @override
  String get eWurm20 => 'Wurmfänger: 20 Punkte';

  @override
  String get eWurm50 => 'Wurmmeister: 50 Punkte';

  @override
  String get eSerie7 => 'Eine ganze Woche Bonus';

  @override
  String get willkommenZurueck => 'Willkommen zurück!';

  @override
  String offlineText(String zeit, String gold) {
    return 'Während du weg warst ($zeit), hat Mos Team $gold Gold gegraben.';
  }

  @override
  String get einsammeln => 'Einsammeln';

  @override
  String get verdoppeln => 'Video: ×2';

  @override
  String get videoNichtVerfuegbar =>
      'Gerade ist kein Video verfügbar. Versuch es später nochmal.';

  @override
  String tagNummer(int tag) {
    return 'Tag $tag';
  }

  @override
  String get tagesbonusText =>
      'Komm jeden Tag vorbei – an Tag 7 gibt es einen Glitzerstein!';

  @override
  String get tagesbonusMorgen =>
      'Für heute schon abgeholt. Morgen geht\'s weiter!';

  @override
  String get abholen => 'Abholen';

  @override
  String bonusErhalten(String gold) {
    return '+$gold Gold!';
  }

  @override
  String bonusMitGlitzer(String gold) {
    return '+$gold Gold und ein Glitzerstein ✨!';
  }

  @override
  String get boostTitel => 'Doppelte Kraft';

  @override
  String get boostText =>
      'Schau ein kurzes Video: 10 Minuten lang gräbt alles doppelt so schnell. Mehrere Videos verlängern den Boost.';

  @override
  String get videoAnsehen => 'Video ansehen';

  @override
  String get wurmregenErklaerung =>
      'Tippe in 20 Sekunden so viele Würmer wie möglich. Goldene Würmer 🌟 zählen 5!';

  @override
  String wurmErgebnis(int punkte) {
    return '$punkte Punkte!';
  }

  @override
  String wurmGold(String gold) {
    return '+$gold Gold';
  }

  @override
  String rekord(int punkte) {
    return 'Rekord: $punkte';
  }

  @override
  String get zurueckZuMo => 'Zurück zu Mo';

  @override
  String get angebote => 'Angebote';

  @override
  String get shopNichtVerfuegbar =>
      'Der Shop ist erst in der Play-Store-Version verfügbar.';

  @override
  String get werbefrei => 'Werbefrei';

  @override
  String get werbefreiText =>
      'Kein Banner mehr. Videos für Boni bleiben freiwillig.';

  @override
  String get goldsack => 'Goldsack';

  @override
  String get goldsackText => '2 Stunden Produktion sofort';

  @override
  String get glitzerpaket => 'Glitzerpaket';

  @override
  String get glitzerpaketText => '5 Glitzersteine (+50 % für immer)';

  @override
  String get kaeufeWiederherstellen => 'Käufe wiederherstellen';

  @override
  String get werbeEinwilligung => 'Einwilligung für Werbung ändern';

  @override
  String get spielZuruecksetzen => 'Spiel zurücksetzen';

  @override
  String get spielZuruecksetzenText =>
      'Der ganze Spielstand wird gelöscht, auch Glitzersteine und Erfolge.';
}
