import 'package:drift/drift.dart';

// Alle Geldbeträge sind ganze Cent (int), damit keine Rundungsfehler
// entstehen. Gewichte in Gramm, Zeiten in Minuten.

@DataClassName('Drucker')
class DruckerTabelle extends Table {
  @override
  String get tableName => 'drucker';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// Durchschnittlicher Verbrauch beim Drucken (nicht das Netzteil-Maximum).
  IntColumn get leistungWatt => integer()();
  IntColumn get anschaffungCent => integer()();

  /// Nach so vielen Stunden gilt der Drucker als abbezahlt.
  IntColumn get lebensdauerStunden => integer()();
  BoolColumn get archiviert => boolean().withDefault(const Constant(false))();
}

@DataClassName('Filament')
class FilamentTabelle extends Table {
  @override
  String get tableName => 'filamente';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get material => text()();

  /// Farbe als ARGB-Zahl (z. B. 0xFF2196F3).
  IntColumn get farbe => integer()();
  IntColumn get preisProKgCent => integer()();
  BoolColumn get archiviert => boolean().withDefault(const Constant(false))();
}

@DataClassName('Extra')
class ExtraTabelle extends Table {
  @override
  String get tableName => 'extras';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get kostenCent => integer()();
  BoolColumn get archiviert => boolean().withDefault(const Constant(false))();
}

@DataClassName('Produkt')
class ProduktTabelle extends Table {
  @override
  String get tableName => 'produkte';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// Ein Emoji als Bild für den Verkaufen-Knopf, z. B. 🐉.
  TextColumn get symbol => text().withDefault(const Constant('📦'))();
  IntColumn get farbe => integer()();
  IntColumn get druckerId =>
      integer().nullable().references(DruckerTabelle, #id)();

  // Werte für EINEN Druck (eine volle Druckplatte). Geteilt durch
  // stueckProDruck ergibt sich der Wert pro Stück.
  IntColumn get druckzeitMinuten => integer()();
  IntColumn get stueckProDruck => integer().withDefault(const Constant(1))();

  /// Spülabfall bei Farbwechseln (AMS), in Gramm pro Druck.
  RealColumn get spuelabfallGramm => real().withDefault(const Constant(0))();

  /// Handarbeit pro Stück (Nacharbeit, Zusammenbauen, Verpacken).
  IntColumn get arbeitMinuten => integer().withDefault(const Constant(0))();

  /// Eigener Aufschlag; `null` = Standard aus den Einstellungen.
  IntColumn get aufschlagProzent => integer().nullable()();

  /// Fester Verkaufspreis; `null` = Preisvorschlag verwenden.
  IntColumn get preisManuellCent => integer().nullable()();
  IntColumn get sortierung => integer().withDefault(const Constant(0))();
  BoolColumn get archiviert => boolean().withDefault(const Constant(false))();
}

@DataClassName('ProduktFilament')
class ProduktFilamentTabelle extends Table {
  @override
  String get tableName => 'produkt_filamente';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get produktId =>
      integer().references(ProduktTabelle, #id, onDelete: KeyAction.cascade)();
  IntColumn get filamentId => integer().references(FilamentTabelle, #id)();

  /// Gramm pro Druck (so wie der Slicer es anzeigt).
  RealColumn get gramm => real()();
}

@DataClassName('ProduktExtra')
class ProduktExtraTabelle extends Table {
  @override
  String get tableName => 'produkt_extras';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get produktId =>
      integer().references(ProduktTabelle, #id, onDelete: KeyAction.cascade)();
  IntColumn get extraId => integer().references(ExtraTabelle, #id)();

  /// Menge pro Stück.
  IntColumn get menge => integer().withDefault(const Constant(1))();
}

/// Ein Verkauf. Preis und Kosten werden beim Verkauf festgehalten, damit
/// alte Auswertungen stimmen, auch wenn sich später Preise ändern.
@DataClassName('Verkauf')
class VerkaufTabelle extends Table {
  @override
  String get tableName => 'verkaeufe';

  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get zeitpunkt => dateTime()();
  IntColumn get produktId =>
      integer().nullable().references(ProduktTabelle, #id)();

  /// Name zum Zeitpunkt des Verkaufs (für Export und falls das Produkt
  /// später umbenannt wird).
  TextColumn get produktName => text()();
  IntColumn get menge => integer()();
  IntColumn get einzelpreisCent => integer()();
  IntColumn get einzelkostenCent => integer()();

  /// Zahlungsgebühr für den ganzen Verkauf (z. B. SumUp).
  IntColumn get gebuehrCent => integer().withDefault(const Constant(0))();

  /// 0 = bar, 1 = Karte, 2 = online (siehe [Zahlungsart]).
  IntColumn get zahlungsart => integer().withDefault(const Constant(0))();
  IntColumn get auftragId => integer().nullable().references(
    AuftragTabelle,
    #id,
    onDelete: KeyAction.cascade,
  )();
}

@DataClassName('Auftrag')
class AuftragTabelle extends Table {
  @override
  String get tableName => 'auftraege';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get kunde => text()();
  TextColumn get kontakt => text().withDefault(const Constant(''))();
  TextColumn get notiz => text().withDefault(const Constant(''))();
  DateTimeColumn get erstelltAm => dateTime()();
  DateTimeColumn get faelligAm => dateTime().nullable()();

  /// 0 = offen, 1 = gedruckt, 2 = abgeholt (siehe [AuftragStatus]).
  IntColumn get status => integer().withDefault(const Constant(0))();
  DateTimeColumn get bezahltAm => dateTime().nullable()();
  IntColumn get zahlungsart => integer().withDefault(const Constant(0))();
}

@DataClassName('AuftragPosition')
class AuftragPositionTabelle extends Table {
  @override
  String get tableName => 'auftrag_positionen';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get auftragId =>
      integer().references(AuftragTabelle, #id, onDelete: KeyAction.cascade)();
  IntColumn get produktId => integer().references(ProduktTabelle, #id)();
  IntColumn get menge => integer()();
  IntColumn get einzelpreisCent => integer()();

  /// z. B. Wunschfarbe.
  TextColumn get notiz => text().withDefault(const Constant(''))();
}

@DataClassName('Sparziel')
class SparzielTabelle extends Table {
  @override
  String get tableName => 'sparziele';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get symbol => text().withDefault(const Constant('🎯'))();
  IntColumn get zielCent => integer()();

  /// 0 = Gewinn zählt, 1 = Umsatz zählt (siehe [SparBasis]).
  IntColumn get basis => integer().withDefault(const Constant(0))();
  DateTimeColumn get startDatum => dateTime()();

  /// Wird auf dem Verkaufen-Bildschirm angezeigt.
  BoolColumn get angeheftet => boolean().withDefault(const Constant(true))();
  DateTimeColumn get erreichtAm => dateTime().nullable()();
}

/// Genau eine Zeile (id = 1) mit den Einstellungen für die Kalkulation.
@DataClassName('Einstellungen')
class EinstellungenTabelle extends Table {
  @override
  String get tableName => 'einstellungen';

  IntColumn get id => integer()();
  RealColumn get strompreisCentProKwh =>
      real().withDefault(const Constant(25))();
  IntColumn get standardAufschlagProzent =>
      integer().withDefault(const Constant(200))();
  IntColumn get fehldruckProzent => integer().withDefault(const Constant(10))();

  /// Preisvorschläge werden auf diesen Betrag aufgerundet (50 = 0,50 €).
  IntColumn get rundungCent => integer().withDefault(const Constant(50))();
  IntColumn get stundenlohnCent => integer().withDefault(const Constant(0))();
  RealColumn get gebuehrKarteProzent => real().withDefault(const Constant(0))();
  RealColumn get gebuehrOnlineProzent =>
      real().withDefault(const Constant(0))();
  IntColumn get standardZahlungsart =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
