import 'package:drift/drift.dart';

@DataClassName('Stapel')
class StapelTabelle extends Table {
  @override
  String get tableName => 'stapel';

  IntColumn get id => integer().autoIncrement()();

  /// Bei eingebauten Stapeln die ID aus der JSON-Datei, sonst `null`.
  TextColumn get schluessel => text().nullable().unique()();
  TextColumn get name => text()();
  TextColumn get sprache => text()();
  TextColumn get stufe => text().withDefault(const Constant(''))();
  TextColumn get beschreibung => text().withDefault(const Constant(''))();

  /// Play-Produkt, das den Stapel freischaltet; `null` = gratis.
  TextColumn get produkt => text().nullable()();
  BoolColumn get eigen => boolean().withDefault(const Constant(false))();

  /// Kommt in „Heute lernen“ vor.
  BoolColumn get aktiv => boolean().withDefault(const Constant(true))();
  IntColumn get sortierung => integer().withDefault(const Constant(0))();
}

@DataClassName('Karte')
class KarteTabelle extends Table {
  @override
  String get tableName => 'karten';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get stapelId =>
      integer().references(StapelTabelle, #id, onDelete: KeyAction.cascade)();

  /// Bei eingebauten Karten der Key aus der JSON-Datei.
  TextColumn get schluessel => text().nullable().unique()();

  /// Name von `KartenTyp`.
  TextColumn get typ => text()();
  TextColumn get frage => text()();
  TextColumn get antwort => text()();
  TextColumn get code => text().nullable()();

  /// Auswahlmöglichkeiten als JSON-Liste.
  TextColumn get optionen => text().withDefault(const Constant('[]'))();
  TextColumn get erklaerung => text().withDefault(const Constant(''))();
  IntColumn get reihenfolge => integer().withDefault(const Constant(0))();
}

/// Lernstand einer Karte (fehlt, solange sie neu ist).
@DataClassName('LernstandZeile')
class LernstandTabelle extends Table {
  @override
  String get tableName => 'lernstand';

  IntColumn get karteId =>
      integer().references(KarteTabelle, #id, onDelete: KeyAction.cascade)();
  IntColumn get wiederholungen => integer()();
  RealColumn get leichtigkeit => real()();
  IntColumn get intervallTage => integer()();
  DateTimeColumn get faellig => dateTime()();
  IntColumn get fehler => integer().withDefault(const Constant(0))();
  DateTimeColumn get zuletzt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {karteId};
}

/// Wie viele Karten an einem Tag gelernt wurden (für Ziel und Streak).
@DataClassName('Lerntag')
class LerntagTabelle extends Table {
  @override
  String get tableName => 'lerntage';

  DateTimeColumn get datum => dateTime()();
  IntColumn get karten => integer().withDefault(const Constant(0))();
  IntColumn get richtig => integer().withDefault(const Constant(0))();
  IntColumn get neu => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {datum};
}

@DataClassName('Snippet')
class SnippetTabelle extends Table {
  @override
  String get tableName => 'snippets';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get titel => text()();
  TextColumn get sprache => text()();
  TextColumn get code => text()();

  /// Mit Komma getrennt, klein geschrieben.
  TextColumn get tags => text().withDefault(const Constant(''))();
  TextColumn get notiz => text().withDefault(const Constant(''))();
  BoolColumn get favorit => boolean().withDefault(const Constant(false))();
  DateTimeColumn get erstellt => dateTime()();
  DateTimeColumn get geaendert => dateTime()();
}
