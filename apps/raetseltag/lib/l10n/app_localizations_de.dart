// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get mehr => 'Mehr';

  @override
  String get statistik => 'Statistik';

  @override
  String get einstellungen => 'Einstellungen';

  @override
  String get loeschen => 'Löschen';

  @override
  String get weiter => 'Weiter';

  @override
  String get teilen => 'Teilen';

  @override
  String get tipp => 'Tipp (Video)';

  @override
  String get super_ => 'Super!';

  @override
  String get leiderNicht => 'Leider nicht';

  @override
  String raetselNr(int nummer) {
    return 'Rätsel #$nummer';
  }

  @override
  String get wortraetsel => 'Worträtsel';

  @override
  String get wortraetselText =>
      'Finde das Wort mit 5 Buchstaben in 6 Versuchen.';

  @override
  String get sudoku => 'Sudoku';

  @override
  String get sudokuText => 'Leicht, mittel oder schwer.';

  @override
  String get schiebepuzzle => 'Schiebepuzzle';

  @override
  String get schiebepuzzleText => 'Bring die Zahlen von 1 bis 15 in Reihe.';

  @override
  String geschafftVersuche(int anzahl) {
    return 'Geschafft in $anzahl/6 ✅';
  }

  @override
  String get nichtGeschafft => 'Diesmal nicht geschafft';

  @override
  String geschafftZuege(int zuege) {
    return 'Geschafft in $zuege Zügen ✅';
  }

  @override
  String geschafftSudoku(String stufe, String zeit) {
    return '$stufe geschafft in $zeit ✅';
  }

  @override
  String get weiterspielen => 'Weiterspielen …';

  @override
  String get alleDreiGeschafft => '⭐ Alle drei geschafft! Bis morgen!';

  @override
  String get archiv => 'Archiv';

  @override
  String get endlos => 'Endlos spielen';

  @override
  String get archivLeer =>
      'Ab morgen findest du hier die Rätsel der vergangenen Tage.';

  @override
  String get stufeWaehlen => 'Schwierigkeit';

  @override
  String get leicht => 'Leicht';

  @override
  String get mittel => 'Mittel';

  @override
  String get schwer => 'Schwer';

  @override
  String serieTage(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '🔥 $anzahl Tage am Stück',
      one: '🔥 1 Tag am Stück',
      zero: 'Starte heute deine Serie 🌱',
    );
    return '$_temp0';
  }

  @override
  String get zuKurz => 'Zu wenige Buchstaben';

  @override
  String get keinWort => 'Kenne ich nicht als Wort';

  @override
  String wortGeschafft(int anzahl) {
    return 'Du hast das Wort in $anzahl Versuchen gefunden.';
  }

  @override
  String wortWar(String wort) {
    return 'Das Wort war: $wort';
  }

  @override
  String tippText(String tipps) {
    return 'Tipp – Stelle $tipps';
  }

  @override
  String get videoNichtVerfuegbar =>
      'Gerade ist kein Video verfügbar. Versuch es später nochmal.';

  @override
  String get notizen => 'Notizen';

  @override
  String sudokuGeschafft(String stufe, String zeit) {
    return 'Sudoku $stufe gelöst in $zeit.';
  }

  @override
  String schiebeGeschafft(int zuege, String zeit) {
    return 'Gelöst in $zuege Zügen und $zeit.';
  }

  @override
  String get zuege => 'Züge';

  @override
  String get zuegeKurz => 'Züge';

  @override
  String get schiebeHilfe =>
      'Tippe auf ein Feld in der Reihe oder Spalte der Lücke – es rutscht hinein.';

  @override
  String get aktuelleSerie => 'Serie';

  @override
  String get laengsteSerie => 'Längste Serie';

  @override
  String get tageGespielt => 'Tage gelöst';

  @override
  String get gespielt => 'Gespielt';

  @override
  String get gewonnen => 'Gewonnen';

  @override
  String get versucheVerteilung => 'Versuche bis zur Lösung';

  @override
  String bestzeit(String zeit) {
    return 'Bestzeit $zeit';
  }

  @override
  String get geloestAnzahl => 'Gelöst';

  @override
  String get wenigsteZuege => 'Wenigste Züge';

  @override
  String get proTitel => 'Rätseltag Pro';

  @override
  String get proKurz => 'Archiv, Endlos-Modus, Tipps ohne Video, werbefrei';

  @override
  String get proArchiv => 'Alle vergangenen Rätsel im Archiv';

  @override
  String get proEndlos => 'Endlos neue Rätsel';

  @override
  String get proWerbefrei => 'Keine Werbung, Tipps ohne Video';

  @override
  String get proUnterstuetzen => 'Du unterstützt die Weiterentwicklung';

  @override
  String get werbeEinwilligung => 'Einwilligung für Werbung ändern';

  @override
  String get statistikLoeschen => 'Statistik löschen';

  @override
  String get statistikLoeschenText =>
      'Alle Ergebnisse und deine Serie werden gelöscht.';
}
