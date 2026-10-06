// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get tabVerkaufen => 'Verkaufen';

  @override
  String get tabAuftraege => 'Aufträge';

  @override
  String get tabProdukte => 'Produkte';

  @override
  String get tabUebersicht => 'Übersicht';

  @override
  String get tabMehr => 'Mehr';

  @override
  String get abbrechen => 'Abbrechen';

  @override
  String get speichern => 'Speichern';

  @override
  String get loeschen => 'Löschen';

  @override
  String get entfernen => 'Entfernen';

  @override
  String get weiter => 'Weiter';

  @override
  String get laden => 'Laden';

  @override
  String get super_ => 'Super!';

  @override
  String get oder => ' oder ';

  @override
  String get pflichtfeld => 'Bitte ausfüllen';

  @override
  String get ungueltigerBetrag => 'Bitte einen Betrag wie 12,50 eingeben';

  @override
  String get ungueltigeZahl => 'Bitte eine Zahl eingeben';

  @override
  String get name => 'Name';

  @override
  String get notiz => 'Notiz';

  @override
  String get menge => 'Menge';

  @override
  String get preis => 'Preis';

  @override
  String get kosten => 'Kosten';

  @override
  String get gewinn => 'Gewinn';

  @override
  String get umsatz => 'Umsatz';

  @override
  String get app => 'App';

  @override
  String get daten => 'Daten';

  @override
  String get grenzeErreicht => 'Gratis-Grenze erreicht';

  @override
  String get proAnsehen => 'Pro ansehen';

  @override
  String get proTitel => 'Druckkasse Pro';

  @override
  String get proKurz =>
      'Unbegrenzt Produkte und Drucker, CSV-Export, 12-Monats-Verlauf';

  @override
  String get proVorteilUnbegrenzt =>
      'Unbegrenzt viele Produkte, Drucker und Sparziele';

  @override
  String get proVorteilExport => 'Export als CSV für Excel und Steuer';

  @override
  String get proVorteilVerlauf => 'Gewinn-Verlauf über 12 Monate';

  @override
  String get proVorteilSparziele => 'Mehrere Sparziele gleichzeitig';

  @override
  String get proVorteilUnterstuetzen => 'Du unterstützt die Weiterentwicklung';

  @override
  String grenzeProdukte(int anzahl) {
    return 'In der Gratis-Version kannst du bis zu $anzahl Produkte anlegen. Mit Pro unbegrenzt viele.';
  }

  @override
  String grenzeDrucker(int anzahl) {
    return 'In der Gratis-Version kannst du bis zu $anzahl Drucker anlegen. Mit Pro unbegrenzt viele.';
  }

  @override
  String get grenzeSparziele =>
      'In der Gratis-Version gibt es ein Sparziel. Mit Pro kannst du mehrere gleichzeitig verfolgen.';

  @override
  String get exportNurPro => 'Der CSV-Export ist Teil von Pro.';

  @override
  String get heuteVerkauft => 'Heute verkauft';

  @override
  String get heuteUmsatz => 'Umsatz heute';

  @override
  String get heuteGewinn => 'Gewinn heute';

  @override
  String get heuteStueck => 'Stück heute';

  @override
  String get heuteNochNichts => 'Heute wurde noch nichts verkauft.';

  @override
  String get wischenZumLoeschen =>
      'Nach links wischen, um einen Verkauf zu löschen.';

  @override
  String get ausAuftrag => 'aus Auftrag';

  @override
  String verkauftMeldung(int menge, String name, String betrag) {
    return '$menge× $name verkauft · $betrag';
  }

  @override
  String get rueckgaengig => 'Rückgängig';

  @override
  String get zielErreichtTitel => 'Ziel erreicht! 🎉';

  @override
  String zielErreichtText(String name) {
    return 'Du hast genug für „$name“ zusammen. Glückwunsch!';
  }

  @override
  String get tippDesTages => 'Druck-Tipp des Tages';

  @override
  String get ausblenden => 'Ausblenden';

  @override
  String get ersteSchritteTitel => 'Los geht\'s!';

  @override
  String get ersteSchritteText => 'Drei Schritte, dann kannst du verkaufen:';

  @override
  String get schrittDrucker => 'Drucker anlegen';

  @override
  String get schrittFilament => 'Filament anlegen';

  @override
  String get schrittProdukt => 'Erstes Produkt anlegen';

  @override
  String get preisProStueck => 'Preis pro Stück';

  @override
  String verkaufenFuer(String betrag) {
    return 'Verkaufen für $betrag';
  }

  @override
  String get zahlungBar => 'Bar';

  @override
  String get zahlungKarte => 'Karte';

  @override
  String get zahlungOnline => 'Online';

  @override
  String sparStand(String stand, String ziel, String basis) {
    return '$stand von $ziel ($basis)';
  }

  @override
  String get sparZielErreicht => 'Geschafft! Ziel erreicht 🎉';

  @override
  String sparNoch(String rest, String produkte) {
    return 'Noch $rest: z. B. $produkte';
  }

  @override
  String sparNochOhne(String rest) {
    return 'Noch $rest';
  }

  @override
  String get archiv => 'Archiv';

  @override
  String get aktiveAnzeigen => 'Aktive Produkte anzeigen';

  @override
  String get archivAnzeigen => 'Archiv anzeigen';

  @override
  String get archivLeer => 'Keine archivierten Produkte';

  @override
  String get neuesProdukt => 'Neues Produkt';

  @override
  String get keineProdukte => 'Noch keine Produkte';

  @override
  String get keineProdukteText =>
      'Leg dein erstes Produkt an. Die App rechnet Kosten und schlägt einen Preis vor.';

  @override
  String get wiederherstellen => 'Wiederherstellen';

  @override
  String get produktBearbeiten => 'Produkt bearbeiten';

  @override
  String get duplizieren => 'Duplizieren (z. B. andere Farbe)';

  @override
  String get archivieren => 'Archivieren';

  @override
  String get produktArchivieren => 'Produkt archivieren?';

  @override
  String get produktArchivierenText =>
      'Das Produkt verschwindet aus der Liste und beim Verkaufen. Alte Verkäufe bleiben in der Übersicht. Du kannst es im Archiv wiederherstellen.';

  @override
  String get druck => 'Druck';

  @override
  String get drucker => 'Drucker';

  @override
  String get druckerAnlegen => 'Drucker anlegen';

  @override
  String get ohneDrucker => 'Ohne Drucker (keine Strom-/Abnutzungskosten)';

  @override
  String get stunden => 'Druckzeit Stunden';

  @override
  String get minuten => 'Minuten';

  @override
  String get stueckProDruck => 'Stück pro Druck';

  @override
  String get stueckProDruckHilfe =>
      'Wie viele Stück passen auf eine Druckplatte? Druckzeit und Gramm gelten für die ganze Platte.';

  @override
  String get filamente => 'Filamente';

  @override
  String get filament => 'Filament';

  @override
  String get filamentAnlegen => 'Filament anlegen';

  @override
  String get farbeHinzufuegen => 'Farbe hinzufügen';

  @override
  String get gramm => 'Gramm';

  @override
  String get grammHilfe =>
      'Gramm und Druckzeit so eintragen, wie der Slicer sie für den ganzen Druck anzeigt (Bambu Studio: „Gesamtfilament“).';

  @override
  String get spuelabfall => 'Spülabfall pro Druck';

  @override
  String get spuelabfallHilfe =>
      'Abfall bei Farbwechseln (AMS). Steht im Slicer unter „Spülung“/„Flushed“.';

  @override
  String get extrasUndArbeit => 'Extras & Arbeit';

  @override
  String get extrasVerwalten => 'Verwalten';

  @override
  String get keineExtras =>
      'Noch keine Extras. Lege z. B. Verpackung oder Schlüsselringe an.';

  @override
  String get arbeitProStueck => 'Handarbeit pro Stück';

  @override
  String get arbeitHilfeOhneLohn =>
      'Nacharbeit, Zusammenbauen, Verpacken. Zählt erst, wenn du in den Einstellungen einen Stundenlohn einträgst.';

  @override
  String arbeitHilfe(String lohn) {
    return 'Wird mit $lohn/h eingerechnet.';
  }

  @override
  String get kostenMaterial => 'Material';

  @override
  String get kostenStrom => 'Strom';

  @override
  String get kostenAbnutzung => 'Abnutzung Drucker';

  @override
  String kostenFehldruck(int prozent) {
    return 'Fehldruck-Zuschlag ($prozent %)';
  }

  @override
  String get kostenExtras => 'Extras';

  @override
  String get kostenArbeit => 'Handarbeit';

  @override
  String get kostenProStueck => 'Kosten pro Stück';

  @override
  String aufschlag(int prozent) {
    return 'Aufschlag auf die Kosten: $prozent %';
  }

  @override
  String get standardNehmen => 'Standard';

  @override
  String vorschlag(String betrag) {
    return 'Preisvorschlag: $betrag';
  }

  @override
  String get eigenerPreis => 'Eigener Verkaufspreis (optional)';

  @override
  String get eigenerPreisHilfe => 'Leer lassen, um den Vorschlag zu verwenden.';

  @override
  String get verkaufspreis => 'Verkaufspreis';

  @override
  String gewinnProStueck(String betrag) {
    return 'Gewinn $betrag';
  }

  @override
  String margeVomPreis(int prozent) {
    return '$prozent % vom Preis';
  }

  @override
  String get keineDrucker => 'Noch kein Drucker';

  @override
  String get keineDruckerText =>
      'Für Strom- und Abnutzungskosten braucht die App deinen Drucker.';

  @override
  String druckerInfo(int watt, String betrag) {
    return '$watt W · Abnutzung $betrag/h';
  }

  @override
  String get druckerBearbeiten => 'Drucker bearbeiten';

  @override
  String get druckerEntfernen => 'Drucker entfernen?';

  @override
  String get druckerEntfernenText =>
      'Der Drucker wird ausgeblendet. Produkte, die ihn verwenden, rechnen weiter mit seinen Werten.';

  @override
  String get vorlageWaehlen => 'Vorlage wählen (Werte danach anpassbar)';

  @override
  String get verbrauch => 'Durchschnittlicher Verbrauch';

  @override
  String get verbrauchHilfe =>
      'Beim Drucken gemessen, nicht die Netzteil-Angabe. Bambu A1 ca. 95 W, P1S ca. 120 W.';

  @override
  String get anschaffungspreis => 'Anschaffungspreis';

  @override
  String get lebensdauer => 'Lebensdauer';

  @override
  String get lebensdauerHilfe =>
      'Nach so vielen Druckstunden ist der Drucker abbezahlt. 5000 h sind ein guter Richtwert.';

  @override
  String get keineFilamente => 'Noch kein Filament';

  @override
  String get keineFilamenteText =>
      'Leg deine Filamente mit Kilopreis an, damit die Materialkosten stimmen.';

  @override
  String proKg(String betrag) {
    return '$betrag/kg';
  }

  @override
  String get filamentBearbeiten => 'Filament bearbeiten';

  @override
  String get filamentEntfernen => 'Filament entfernen?';

  @override
  String get filamentEntfernenText =>
      'Das Filament wird ausgeblendet. Produkte, die es verwenden, rechnen weiter mit seinem Preis.';

  @override
  String get material => 'Material';

  @override
  String get farbe => 'Farbe';

  @override
  String get filamentNameHilfe => 'z. B. „Bambu PLA Basic Rot“';

  @override
  String get preisProKg => 'Preis pro Kilo';

  @override
  String get preisProKgHilfe =>
      'Preis der Spule umgerechnet auf 1 kg (inkl. Versand, wenn du willst).';

  @override
  String get extras => 'Extras';

  @override
  String get extrasUntertitel => 'Verpackung, Schlüsselringe, Magnete …';

  @override
  String get extraAnlegen => 'Extra anlegen';

  @override
  String get extraBearbeiten => 'Extra bearbeiten';

  @override
  String get extraBeispiel => 'z. B. Geschenkschachtel';

  @override
  String get kostenProStueckFeld => 'Kosten pro Stück';

  @override
  String get keineExtrasTitel => 'Noch keine Extras';

  @override
  String get keineExtrasText =>
      'Extras sind Dinge, die du zusätzlich zum Druck brauchst, z. B. Verpackung.';

  @override
  String get neuerAuftrag => 'Neuer Auftrag';

  @override
  String get auftragBearbeiten => 'Auftrag bearbeiten';

  @override
  String get filterOffen => 'Offen';

  @override
  String get filterErledigt => 'Erledigt';

  @override
  String get filterAlle => 'Alle';

  @override
  String nochOffen(String betrag) {
    return 'Noch nicht bezahlt: $betrag';
  }

  @override
  String get keineOffenenAuftraege => 'Keine offenen Aufträge';

  @override
  String get keineAuftraege => 'Keine Aufträge';

  @override
  String get keineAuftraegeText =>
      'Hier landen Bestellungen: wer, was, bis wann. Ein Auftrag ist erledigt, wenn er abgeholt und bezahlt ist.';

  @override
  String faelligAm(String datum) {
    return 'Fällig am $datum';
  }

  @override
  String get statusOffen => 'Offen';

  @override
  String get statusGedruckt => 'Gedruckt';

  @override
  String get statusAbgeholt => 'Abgeholt';

  @override
  String get bezahlt => 'Bezahlt';

  @override
  String get nichtBezahlt => 'Nicht bezahlt';

  @override
  String get kunde => 'Kunde';

  @override
  String get kontaktFeld => 'Kontakt (Telefon, Instagram …)';

  @override
  String get keinTermin => 'Kein Termin';

  @override
  String get positionen => 'Was wurde bestellt?';

  @override
  String get produktHinzufuegen => 'Produkt';

  @override
  String get notizPosition => 'Notiz (z. B. Farbe)';

  @override
  String get statusUndZahlung => 'Status & Zahlung';

  @override
  String get bezahltHilfe => 'Bezahlte Aufträge zählen im Umsatz.';

  @override
  String get mindestensEinProdukt => 'Bitte mindestens ein Produkt hinzufügen.';

  @override
  String get auftragLoeschen => 'Auftrag löschen?';

  @override
  String get auftragLoeschenText =>
      'Der Auftrag und, falls bezahlt, sein Umsatz werden gelöscht.';

  @override
  String get exportTitel => 'Als CSV exportieren';

  @override
  String exportMonat(String monat) {
    return 'Nur $monat';
  }

  @override
  String get exportAlles => 'Alle Verkäufe';

  @override
  String get csvDatum => 'Datum';

  @override
  String get csvProdukt => 'Produkt';

  @override
  String get csvMenge => 'Menge';

  @override
  String get csvEinzelpreis => 'Einzelpreis';

  @override
  String get csvUmsatz => 'Umsatz';

  @override
  String get csvKosten => 'Kosten';

  @override
  String get csvGebuehr => 'Gebühr';

  @override
  String get csvGewinn => 'Gewinn';

  @override
  String get csvZahlung => 'Zahlung';

  @override
  String get vorherigerMonat => 'Vorheriger Monat';

  @override
  String get naechsterMonat => 'Nächster Monat';

  @override
  String get stueckVerkauft => 'Stück verkauft';

  @override
  String davonGebuehren(String betrag) {
    return 'Kosten inkl. $betrag Zahlungsgebühren';
  }

  @override
  String get gewinnProMonat => 'Gewinn pro Monat';

  @override
  String get verlaufPro => '12 Monate mit Pro';

  @override
  String get bestseller => 'Bestseller';

  @override
  String get keineVerkaeufeImMonat =>
      'In diesem Monat gibt es noch keine Verkäufe.';

  @override
  String margeVomUmsatz(int prozent) {
    return '$prozent % vom Umsatz';
  }

  @override
  String stueckKurz(int anzahl) {
    return '$anzahl Stk.';
  }

  @override
  String plusGewinn(String betrag) {
    return '+$betrag';
  }

  @override
  String get speichernUnter => 'Speichern unter …';

  @override
  String get teilen => 'Teilen';

  @override
  String get gespeichert => 'Gespeichert';

  @override
  String fehler(String text) {
    return 'Fehler: $text';
  }

  @override
  String get werkstatt => 'Werkstatt';

  @override
  String get ziele => 'Ziele';

  @override
  String get sparziele => 'Sparziele';

  @override
  String get einstellungen => 'Einstellungen';

  @override
  String get einstellungenUntertitel =>
      'Strompreis, Aufschlag, Sicherung, Design';

  @override
  String get neuesSparziel => 'Neues Sparziel';

  @override
  String get keineSparziele => 'Noch kein Sparziel';

  @override
  String get keineSparzieleText =>
      'Wofür sparst du? Ein neuer Drucker? Die App zeigt, wie viele Stück noch fehlen.';

  @override
  String get angeheftet => 'Beim Verkaufen sichtbar';

  @override
  String get anheften => 'Beim Verkaufen zeigen';

  @override
  String seit(String datum) {
    return 'seit $datum';
  }

  @override
  String get sparzielBearbeiten => 'Sparziel bearbeiten';

  @override
  String get wofuerSparstDu => 'Wofür sparst du?';

  @override
  String get sparzielBeispiel => 'z. B. Bambu Lab P1S';

  @override
  String get zielbetrag => 'Zielbetrag';

  @override
  String get wasZaehlt => 'Was zählt?';

  @override
  String get basisGewinnHilfe =>
      'Nur der Gewinn zählt, also was nach Material, Strom und Abnutzung übrig bleibt.';

  @override
  String get basisUmsatzHilfe => 'Alles, was Kunden bezahlen, zählt.';

  @override
  String zaehltAb(String datum) {
    return 'Zählt ab $datum';
  }

  @override
  String get sparzielLoeschen => 'Sparziel löschen?';

  @override
  String get sparzielLoeschenText => 'Deine Verkäufe bleiben erhalten.';

  @override
  String get kalkulation => 'Kalkulation';

  @override
  String get strompreis => 'Strompreis';

  @override
  String get strompreisFeld => 'Cent pro kWh';

  @override
  String get strompreisHilfe =>
      'Steht auf deiner Stromrechnung. Österreich 2026 meist 20–30 ct/kWh.';

  @override
  String get standardAufschlag => 'Standard-Aufschlag';

  @override
  String get aufschlagFeld => 'Prozent auf die Kosten';

  @override
  String get standardAufschlagHilfe =>
      '200 % heißt: Kosten 1 € → Preis 3 €. Für jedes Produkt einzeln änderbar.';

  @override
  String get fehldruckZuschlag => 'Fehldruck-Zuschlag';

  @override
  String get prozentFeld => 'Prozent';

  @override
  String get fehldruckHilfe =>
      'Aufschlag auf Material, Strom und Abnutzung für misslungene Drucke.';

  @override
  String get rundung => 'Preisvorschlag aufrunden';

  @override
  String get rundungKeine => 'Nicht runden';

  @override
  String rundungAuf(String betrag) {
    return 'Auf $betrag aufrunden';
  }

  @override
  String get stundenlohn => 'Stundenlohn für Handarbeit';

  @override
  String get nichtEingerechnet => 'Nicht eingerechnet';

  @override
  String get stundenlohnFeld => 'Euro pro Stunde';

  @override
  String get stundenlohnHilfe =>
      'Leer lassen, wenn deine Zeit nicht in die Kosten soll.';

  @override
  String get zahlung => 'Zahlung';

  @override
  String get standardZahlungsart => 'Standard-Zahlungsart';

  @override
  String get gebuehrKarte => 'Gebühr Kartenzahlung';

  @override
  String get gebuehrKarteHilfe => 'z. B. SumUp ca. 1,39 %. 0 = keine Gebühr.';

  @override
  String get gebuehrOnline => 'Gebühr Online-Zahlung';

  @override
  String get gebuehrOnlineHilfe => 'z. B. PayPal. 0 = keine Gebühr.';

  @override
  String get sicherungErstellen => 'Sicherung erstellen';

  @override
  String get sicherungErstellenText =>
      'Alle Daten als Datei speichern (z. B. in Google Drive)';

  @override
  String get sicherungWiederherstellen => 'Sicherung wiederherstellen';

  @override
  String get wiederherstellenWarnung =>
      'Alle aktuellen Daten werden durch die Sicherung ersetzt.';

  @override
  String get wiederhergestellt => 'Sicherung wiederhergestellt';

  @override
  String get keineSicherung =>
      'Diese Datei ist keine gültige Druckkasse-Sicherung.';

  @override
  String get beispieldatenLaden => 'Beispieldaten laden';

  @override
  String get beispieldatenText =>
      'Zum Ausprobieren: Drucker, Produkte, Verkäufe';

  @override
  String get beispieldatenWarnung =>
      'Beispiel-Drucker, -Produkte und -Verkäufe werden zu deinen Daten hinzugefügt.';

  @override
  String get beispieldatenGeladen => 'Beispieldaten geladen';

  @override
  String get allesLoeschen => 'Alle Daten löschen';

  @override
  String get allesLoeschenText =>
      'Alle Drucker, Filamente, Produkte, Verkäufe, Aufträge und Sparziele werden endgültig gelöscht.';

  @override
  String get allesGeloescht => 'Alle Daten gelöscht';

  @override
  String get willkommen => 'Willkommen bei Druckkasse';

  @override
  String get willkommenText =>
      'Kosten, Preise und Verkäufe für deine 3D-Drucke, alles an einem Ort.';

  @override
  String get einfuehrung1Titel => 'Was kostet ein Druck wirklich?';

  @override
  String get einfuehrung1Text =>
      'Material, Strom und Abnutzung pro Stück, mit Preisvorschlag.';

  @override
  String get einfuehrung2Titel => 'Verkaufen mit einem Tipp';

  @override
  String get einfuehrung2Text =>
      'Große Knöpfe für den Verkauf vor Ort, mit Rückgängig.';

  @override
  String get einfuehrung3Titel => 'Sparziel im Blick';

  @override
  String get einfuehrung3Text =>
      'Sieh, wie viele Stück bis zum neuen Drucker fehlen.';

  @override
  String get selbstEinrichten => 'Selbst einrichten';

  @override
  String get mitBeispielenStarten => 'Mit Beispieldaten ausprobieren';

  @override
  String get beispieleSpaeterLoeschen =>
      'Beispieldaten kannst du später in den Einstellungen löschen.';
}
