import 'package:drift/drift.dart';

// Alle Tabellen, die mit einer Gruppe geteilt werden können, haben:
// - id: UUID (Text), damit Geräte unabhängig voneinander anlegen können
// - gruppeId: null = nur auf diesem Gerät
// - geaendert: für „neueste Änderung gewinnt“ beim Synchronisieren
// - geloescht: gelöschte Einträge bleiben als „Grabstein“, damit das
//   Löschen auch auf den anderen Geräten ankommt
// - hochgeladen: false = lokale Änderung, die noch in die Cloud muss

mixin Teilbar on Table {
  TextColumn get id => text()();
  TextColumn get gruppeId => text().nullable()();
  DateTimeColumn get geaendert => dateTime()();
  BoolColumn get geloescht => boolean().withDefault(const Constant(false))();
  BoolColumn get hochgeladen => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('Gruppe')
class GruppeTabelle extends Table with Teilbar {
  @override
  String get tableName => 'gruppen';

  TextColumn get name => text()();

  /// wg, familie, urlaub, essen, sonst
  TextColumn get art => text().withDefault(const Constant('wg'))();

  /// Einladungscode, sobald die Gruppe in der Cloud ist.
  TextColumn get code => text().nullable()();

  /// Wird mit anderen Geräten synchronisiert.
  BoolColumn get online => boolean().withDefault(const Constant(false))();

  /// Welche Person in der Gruppe bin ich (nur lokal, nicht geteilt).
  TextColumn get ichPersonId => text().nullable()();
}

@DataClassName('Person')
class PersonTabelle extends Table with Teilbar {
  @override
  String get tableName => 'personen';

  TextColumn get name => text()();
  IntColumn get farbe => integer()();
}

@DataClassName('Liste')
class ListeTabelle extends Table with Teilbar {
  @override
  String get tableName => 'listen';

  TextColumn get name => text()();

  /// einkauf, packliste, mitnehmen
  TextColumn get art => text().withDefault(const Constant('einkauf'))();
  TextColumn get symbol => text().withDefault(const Constant('🛒'))();

  /// Bei „Ich nehm was mit“: für wen eingekauft wird.
  TextColumn get fuerPersonId => text().nullable()();
  IntColumn get sortierung => integer().withDefault(const Constant(0))();
}

@DataClassName('Artikel')
class ArtikelTabelle extends Table with Teilbar {
  @override
  String get tableName => 'artikel';

  TextColumn get listeId => text()();
  TextColumn get name => text()();
  TextColumn get menge => text().withDefault(const Constant(''))();

  /// Bei Packlisten die Kategorie (Kleidung, Technik …).
  TextColumn get kategorie => text().withDefault(const Constant(''))();
  BoolColumn get erledigt => boolean().withDefault(const Constant(false))();
  TextColumn get erledigtVon => text().nullable()();

  /// Ausgabe, die beim Abhaken entstanden ist.
  TextColumn get ausgabeId => text().nullable()();
  IntColumn get sortierung => integer().withDefault(const Constant(0))();
}

@DataClassName('Ausgabe')
class AusgabeTabelle extends Table with Teilbar {
  @override
  String get tableName => 'ausgaben';

  TextColumn get titel => text()();
  IntColumn get betragCent => integer()();
  TextColumn get zahlerId => text()();

  /// JSON: {personId: gewicht}
  TextColumn get anteile => text()();
  DateTimeColumn get datum => dateTime()();

  /// ausgabe oder zahlung (Rückzahlung zwischen zwei Personen)
  TextColumn get art => text().withDefault(const Constant('ausgabe'))();
}

/// Eigene Packlisten-Vorlagen (nur lokal).
@DataClassName('Vorlage')
class VorlageTabelle extends Table {
  @override
  String get tableName => 'vorlagen';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get symbol => text().withDefault(const Constant('🧳'))();

  /// JSON: {kategorie: [artikel, …]}
  TextColumn get artikel => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
