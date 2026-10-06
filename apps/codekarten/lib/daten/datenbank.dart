import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../logik/lernrunde.dart';
import '../logik/srs.dart';
import 'tabellen.dart';

export 'tabellen.dart';

part 'datenbank.g.dart';

late AppDatenbank db;

@DriftDatabase(
  tables: [
    StapelTabelle,
    KarteTabelle,
    LernstandTabelle,
    LerntagTabelle,
    SnippetTabelle,
  ],
)
class AppDatenbank extends _$AppDatenbank {
  AppDatenbank(super.e);

  factory AppDatenbank.oeffnen() => AppDatenbank(
    driftDatabase(
      name: 'codekarten',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    ),
  );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Stream<T> _beobachte<T>(
    Set<ResultSetImplementation<dynamic, dynamic>> tabellen,
    Future<T> Function() laden,
  ) => customSelect(
    'SELECT 1',
    readsFrom: tabellen,
  ).watch().asyncMap((_) => laden());

  // ───────────────────────── Eingebaute Stapel ─────────────────────────

  /// Übernimmt einen Stapel aus einer JSON-Datei. Neue Karten kommen dazu,
  /// vorhandene werden aktualisiert, der Lernstand bleibt erhalten.
  Future<void> stapelEinspielen(Map<String, dynamic> json, int sortierung) =>
      transaction(() async {
        final schluessel = json['id'] as String;
        final vorhanden = await (select(
          stapelTabelle,
        )..where((s) => s.schluessel.equals(schluessel))).getSingleOrNull();
        final daten = StapelTabelleCompanion(
          schluessel: Value(schluessel),
          name: Value(json['name'] as String),
          sprache: Value(json['sprache'] as String),
          stufe: Value(json['stufe'] as String? ?? ''),
          beschreibung: Value(json['beschreibung'] as String? ?? ''),
          produkt: Value(json['produkt'] as String?),
          sortierung: Value(sortierung),
        );
        final stapelId = vorhanden == null
            ? await into(stapelTabelle).insert(daten)
            : vorhanden.id;
        if (vorhanden != null) {
          await (update(
            stapelTabelle,
          )..where((s) => s.id.equals(stapelId))).write(daten);
        }
        final karten = [
          for (final k in json['karten'] as List)
            Map<String, dynamic>.from(k as Map),
        ];
        for (final (i, k) in karten.indexed) {
          await into(karteTabelle).insert(
            KarteTabelleCompanion.insert(
              stapelId: stapelId,
              schluessel: Value(k['key'] as String),
              typ: k['typ'] as String,
              frage: k['frage'] as String,
              antwort: k['antwort'] as String,
              code: Value(k['code'] as String?),
              optionen: Value(jsonEncode(k['optionen'] ?? const [])),
              erklaerung: Value(k['erklaerung'] as String? ?? ''),
              reihenfolge: Value(i),
            ),
            onConflict: DoUpdate(
              (alt) => KarteTabelleCompanion(
                frage: Value(k['frage'] as String),
                antwort: Value(k['antwort'] as String),
                code: Value(k['code'] as String?),
                optionen: Value(jsonEncode(k['optionen'] ?? const [])),
                erklaerung: Value(k['erklaerung'] as String? ?? ''),
                reihenfolge: Value(i),
                typ: Value(k['typ'] as String),
              ),
              target: [karteTabelle.schluessel],
            ),
          );
        }
      });

  // ───────────────────────── Stapel ─────────────────────────

  Future<List<StapelInfo>> stapelLaden() async {
    final jetzt = DateTime.now();
    final stapel =
        await (select(stapelTabelle)..orderBy([
              (s) => OrderingTerm.asc(s.eigen),
              (s) => OrderingTerm.asc(s.sortierung),
              (s) => OrderingTerm.asc(s.id),
            ]))
            .get();
    final karten = await select(karteTabelle).get();
    final staende = {
      for (final l in await select(lernstandTabelle).get()) l.karteId: l,
    };
    return [
      for (final s in stapel)
        () {
          final eigene = karten.where((k) => k.stapelId == s.id);
          var neu = 0, faellig = 0, gefestigt = 0;
          for (final k in eigene) {
            final l = staende[k.id];
            if (l == null) {
              neu++;
            } else {
              if (!l.faellig.isAfter(jetzt)) faellig++;
              if (l.intervallTage >= 21) gefestigt++;
            }
          }
          return StapelInfo(
            s,
            anzahl: eigene.length,
            neu: neu,
            faellig: faellig,
            gefestigt: gefestigt,
          );
        }(),
    ];
  }

  Stream<List<StapelInfo>> stapelBeobachten() =>
      _beobachte({stapelTabelle, karteTabelle, lernstandTabelle}, stapelLaden);

  Future<int> stapelSpeichern(StapelTabelleCompanion s) =>
      into(stapelTabelle).insertOnConflictUpdate(s);

  Future<void> stapelLoeschen(int id) =>
      (delete(stapelTabelle)..where((s) => s.id.equals(id))).go();

  Future<void> stapelAktivSetzen(int id, bool aktiv) =>
      (update(stapelTabelle)..where((s) => s.id.equals(id))).write(
        StapelTabelleCompanion(aktiv: Value(aktiv)),
      );

  /// Eigener Stapel „Meine Karten“ – wird bei Bedarf angelegt.
  Future<int> eigenerStapel(String name, String sprache) async {
    final vorhanden =
        await (select(stapelTabelle)
              ..where((s) => s.eigen.equals(true) & s.name.equals(name)))
            .getSingleOrNull();
    if (vorhanden != null) return vorhanden.id;
    return into(stapelTabelle).insert(
      StapelTabelleCompanion.insert(
        name: name,
        sprache: sprache,
        eigen: const Value(true),
      ),
    );
  }

  Future<void> stapelZuruecksetzen(int stapelId) async {
    final ids = selectOnly(karteTabelle)
      ..addColumns([karteTabelle.id])
      ..where(karteTabelle.stapelId.equals(stapelId));
    await (delete(
      lernstandTabelle,
    )..where((l) => l.karteId.isInQuery(ids))).go();
  }

  // ───────────────────────── Karten ─────────────────────────

  Stream<List<Karte>> kartenBeobachten(int stapelId) =>
      (select(karteTabelle)
            ..where((k) => k.stapelId.equals(stapelId))
            ..orderBy([
              (k) => OrderingTerm.asc(k.reihenfolge),
              (k) => OrderingTerm.asc(k.id),
            ]))
          .watch();

  Future<int> karteSpeichern(KarteTabelleCompanion k) =>
      into(karteTabelle).insertOnConflictUpdate(k);

  Future<void> karteLoeschen(int id) =>
      (delete(karteTabelle)..where((k) => k.id.equals(id))).go();

  Future<Karte?> karteLaden(int id) =>
      (select(karteTabelle)..where((k) => k.id.equals(id))).getSingleOrNull();

  // ───────────────────────── Lernen ─────────────────────────

  /// Alle Karten der gegebenen Stapel mit Lernstand.
  Future<List<LernKarte<Karte>>> lernkarten(Iterable<int> stapelIds) async {
    final ids = stapelIds.toList();
    if (ids.isEmpty) return const [];
    final query = select(karteTabelle).join([
      leftOuterJoin(
        lernstandTabelle,
        lernstandTabelle.karteId.equalsExp(karteTabelle.id),
      ),
    ])..where(karteTabelle.stapelId.isIn(ids));
    final zeilen = await query.get();
    return [
      for (final z in zeilen)
        () {
          final k = z.readTable(karteTabelle);
          final l = z.readTableOrNull(lernstandTabelle);
          return LernKarte(
            k,
            l == null
                ? null
                : Lernstand(
                    wiederholungen: l.wiederholungen,
                    leichtigkeit: l.leichtigkeit,
                    intervallTage: l.intervallTage,
                    faellig: l.faellig,
                    fehler: l.fehler,
                  ),
            reihenfolge: k.stapelId * 100000 + k.reihenfolge,
          );
        }(),
    ];
  }

  /// Speichert eine Bewertung und zählt sie für den heutigen Tag.
  Future<void> bewertungSpeichern(
    Karte karte,
    Lernstand neu, {
    required bool warNeu,
    required bool richtig,
    DateTime? jetzt,
  }) => transaction(() async {
    final zeit = jetzt ?? DateTime.now();
    await into(lernstandTabelle).insertOnConflictUpdate(
      LernstandTabelleCompanion.insert(
        karteId: Value(karte.id),
        wiederholungen: neu.wiederholungen,
        leichtigkeit: neu.leichtigkeit,
        intervallTage: neu.intervallTage,
        faellig: neu.faellig,
        fehler: Value(neu.fehler),
        zuletzt: zeit,
      ),
    );
    final tag = tagBeginn(zeit);
    await into(lerntagTabelle).insert(
      LerntagTabelleCompanion.insert(
        datum: tag,
        karten: const Value(1),
        richtig: Value(richtig ? 1 : 0),
        neu: Value(warNeu ? 1 : 0),
      ),
      onConflict: DoUpdate(
        (alt) => LerntagTabelleCompanion.custom(
          karten: alt.karten + const Constant(1),
          richtig: alt.richtig + Constant(richtig ? 1 : 0),
          neu: alt.neu + Constant(warNeu ? 1 : 0),
        ),
      ),
    );
  });

  Future<Map<DateTime, Lerntag>> lerntageLaden() async => {
    for (final t in await select(lerntagTabelle).get()) t.datum: t,
  };

  Stream<Map<DateTime, Lerntag>> lerntageBeobachten() =>
      _beobachte({lerntagTabelle}, lerntageLaden);

  // ───────────────────────── Snippets ─────────────────────────

  Stream<List<Snippet>> snippetsBeobachten() =>
      (select(snippetTabelle)..orderBy([
            (s) => OrderingTerm.desc(s.favorit),
            (s) => OrderingTerm.desc(s.geaendert),
          ]))
          .watch();

  Future<int> snippetSpeichern(SnippetTabelleCompanion s) =>
      into(snippetTabelle).insertOnConflictUpdate(s);

  Future<void> snippetLoeschen(int id) =>
      (delete(snippetTabelle)..where((s) => s.id.equals(id))).go();
}

/// Ein Stapel mit Zahlen für die Anzeige.
class StapelInfo {
  const StapelInfo(
    this.stapel, {
    required this.anzahl,
    required this.neu,
    required this.faellig,
    required this.gefestigt,
  });

  final Stapel stapel;
  final int anzahl;
  final int neu;
  final int faellig;
  final int gefestigt;

  double get fortschritt => anzahl == 0 ? 0 : gefestigt / anzahl;
  int get gelernt => anzahl - neu;
}

extension KarteOptionen on Karte {
  List<String> get optionenListe =>
      (jsonDecode(optionen) as List).cast<String>();
}
