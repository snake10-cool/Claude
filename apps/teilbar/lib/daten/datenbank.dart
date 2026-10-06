import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../logik/geld.dart';
import 'tabellen.dart';

export 'tabellen.dart';

part 'datenbank.g.dart';

late AppDatenbank db;

const _uuid = Uuid();
String neueId() => _uuid.v4();

/// Farben für Personen in Gruppen (gut unterscheidbar).
const personenFarben = [
  0xFF1F9D6B,
  0xFF2563EB,
  0xFFDB2777,
  0xFFEA580C,
  0xFF7C3AED,
  0xFF0891B2,
  0xFFCA8A04,
  0xFF4B5563,
];

@DriftDatabase(
  tables: [
    GruppeTabelle,
    PersonTabelle,
    ListeTabelle,
    ArtikelTabelle,
    AusgabeTabelle,
    VorlageTabelle,
  ],
)
class AppDatenbank extends _$AppDatenbank {
  AppDatenbank(super.e);

  factory AppDatenbank.oeffnen() => AppDatenbank(
    driftDatabase(
      name: 'teilbar',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    ),
  );

  @override
  int get schemaVersion => 1;

  /// Für Tests: feste Uhr.
  DateTime Function() uhr = DateTime.now;

  Stream<T> _beobachte<T>(
    Set<ResultSetImplementation<dynamic, dynamic>> tabellen,
    Future<T> Function() laden,
  ) => customSelect(
    'SELECT 1',
    readsFrom: tabellen,
  ).watch().asyncMap((_) => laden());

  // ───────────────────────── Gruppen & Personen ─────────────────────────

  Future<List<Gruppe>> gruppenLaden() =>
      (select(gruppeTabelle)
            ..where((g) => g.geloescht.equals(false))
            ..orderBy([(g) => OrderingTerm.asc(g.name)]))
          .get();

  Stream<List<Gruppe>> gruppenBeobachten() =>
      (select(gruppeTabelle)
            ..where((g) => g.geloescht.equals(false))
            ..orderBy([(g) => OrderingTerm.asc(g.name)]))
          .watch();

  Future<Gruppe?> gruppeLaden(String id) =>
      (select(gruppeTabelle)..where((g) => g.id.equals(id))).getSingleOrNull();

  Stream<Gruppe?> gruppeBeobachten(String id) => (select(
    gruppeTabelle,
  )..where((g) => g.id.equals(id))).watchSingleOrNull();

  /// Legt eine Gruppe an, mit mir selbst als erster Person.
  Future<String> gruppeAnlegen({
    required String name,
    required String art,
    required String meinName,
    List<String> weitere = const [],
  }) => transaction(() async {
    final gid = neueId();
    final ich = neueId();
    await into(gruppeTabelle).insert(
      GruppeTabelleCompanion.insert(
        id: gid,
        gruppeId: Value(gid),
        name: name,
        art: Value(art),
        geaendert: uhr(),
        ichPersonId: Value(ich),
      ),
    );
    await _personEinfuegen(gid, meinName, 0, id: ich);
    for (final (i, n) in weitere.indexed) {
      await _personEinfuegen(gid, n, i + 1);
    }
    return gid;
  });

  Future<void> gruppeSpeichern(Gruppe g) => into(gruppeTabelle)
      .insertOnConflictUpdate(g.copyWith(geaendert: uhr(), hochgeladen: false));

  Future<void> ichSetzen(String gruppeId, String personId) =>
      (update(gruppeTabelle)..where((g) => g.id.equals(gruppeId))).write(
        GruppeTabelleCompanion(ichPersonId: Value(personId)),
      );

  Future<void> gruppeLoeschen(String id) => transaction(() async {
    final jetzt = uhr();
    for (final t in <TableInfo<Table, dynamic>>[
      personTabelle,
      listeTabelle,
      artikelTabelle,
      ausgabeTabelle,
    ]) {
      await customUpdate(
        'UPDATE ${t.actualTableName} SET geloescht = 1, hochgeladen = 0, '
        'geaendert = ? WHERE gruppe_id = ?',
        variables: [Variable.withDateTime(jetzt), Variable.withString(id)],
        updates: {t},
      );
    }
    await (update(gruppeTabelle)..where((g) => g.id.equals(id))).write(
      GruppeTabelleCompanion(
        geloescht: const Value(true),
        hochgeladen: const Value(false),
        geaendert: Value(jetzt),
      ),
    );
  });

  Future<String> _personEinfuegen(
    String gruppeId,
    String name,
    int nr, {
    String? id,
  }) async {
    final pid = id ?? neueId();
    await into(personTabelle).insert(
      PersonTabelleCompanion.insert(
        id: pid,
        gruppeId: Value(gruppeId),
        name: name,
        farbe: personenFarben[nr % personenFarben.length],
        geaendert: uhr(),
      ),
    );
    return pid;
  }

  Future<List<Person>> personenLaden(String gruppeId) =>
      (select(personTabelle)
            ..where(
              (p) => p.gruppeId.equals(gruppeId) & p.geloescht.equals(false),
            )
            ..orderBy([(p) => OrderingTerm.asc(p.name)]))
          .get();

  Stream<List<Person>> personenBeobachten(String gruppeId) =>
      (select(personTabelle)
            ..where(
              (p) => p.gruppeId.equals(gruppeId) & p.geloescht.equals(false),
            )
            ..orderBy([(p) => OrderingTerm.asc(p.name)]))
          .watch();

  Future<String> personHinzufuegen(String gruppeId, String name) async {
    final anzahl = (await (select(
      personTabelle,
    )..where((p) => p.gruppeId.equals(gruppeId))).get()).length;
    return _personEinfuegen(gruppeId, name, anzahl);
  }

  Future<void> personUmbenennen(Person p, String name) => into(personTabelle)
      .insertOnConflictUpdate(
        p.copyWith(name: name, geaendert: uhr(), hochgeladen: false),
      );

  // ───────────────────────── Listen ─────────────────────────

  Future<List<ListeInfo>> listenLaden() async {
    final listen =
        await (select(listeTabelle)
              ..where((l) => l.geloescht.equals(false))
              ..orderBy([
                (l) => OrderingTerm.asc(l.sortierung),
                (l) => OrderingTerm.asc(l.name),
              ]))
            .get();
    final artikel = await (select(
      artikelTabelle,
    )..where((a) => a.geloescht.equals(false))).get();
    final gruppen = {for (final g in await gruppenLaden()) g.id: g};
    return [
      for (final l in listen)
        if (l.gruppeId == null || gruppen.containsKey(l.gruppeId))
          ListeInfo(
            l,
            gruppe: gruppen[l.gruppeId],
            offen: artikel
                .where((a) => a.listeId == l.id && !a.erledigt)
                .length,
            gesamt: artikel.where((a) => a.listeId == l.id).length,
          ),
    ];
  }

  Stream<List<ListeInfo>> listenBeobachten() =>
      _beobachte({listeTabelle, artikelTabelle, gruppeTabelle}, listenLaden);

  Stream<Liste?> listeBeobachten(String id) =>
      (select(listeTabelle)..where((l) => l.id.equals(id))).watchSingleOrNull();

  Future<String> listeAnlegen({
    required String name,
    String art = 'einkauf',
    String symbol = '🛒',
    String? gruppeId,
    String? fuerPersonId,
  }) async {
    final id = neueId();
    await into(listeTabelle).insert(
      ListeTabelleCompanion.insert(
        id: id,
        name: name,
        art: Value(art),
        symbol: Value(symbol),
        gruppeId: Value(gruppeId),
        fuerPersonId: Value(fuerPersonId),
        geaendert: uhr(),
      ),
    );
    return id;
  }

  Future<void> listeSpeichern(Liste l) => into(listeTabelle)
      .insertOnConflictUpdate(l.copyWith(geaendert: uhr(), hochgeladen: false));

  Future<void> listeLoeschen(String id) => transaction(() async {
    final jetzt = uhr();
    await (update(artikelTabelle)..where((a) => a.listeId.equals(id))).write(
      ArtikelTabelleCompanion(
        geloescht: const Value(true),
        hochgeladen: const Value(false),
        geaendert: Value(jetzt),
      ),
    );
    await (update(listeTabelle)..where((l) => l.id.equals(id))).write(
      ListeTabelleCompanion(
        geloescht: const Value(true),
        hochgeladen: const Value(false),
        geaendert: Value(jetzt),
      ),
    );
  });

  // ───────────────────────── Artikel ─────────────────────────

  Stream<List<Artikel>> artikelBeobachten(String listeId) =>
      (select(artikelTabelle)
            ..where(
              (a) => a.listeId.equals(listeId) & a.geloescht.equals(false),
            )
            ..orderBy([
              (a) => OrderingTerm.asc(a.erledigt),
              (a) => OrderingTerm.asc(a.kategorie),
              (a) => OrderingTerm.asc(a.sortierung),
              (a) => OrderingTerm.asc(a.name),
            ]))
          .watch();

  Future<List<Artikel>> artikelLaden(String listeId) => (select(
    artikelTabelle,
  )..where((a) => a.listeId.equals(listeId) & a.geloescht.equals(false))).get();

  Future<String> artikelHinzufuegen(
    Liste liste, {
    required String name,
    String menge = '',
    String kategorie = '',
  }) async {
    final id = neueId();
    await into(artikelTabelle).insert(
      ArtikelTabelleCompanion.insert(
        id: id,
        listeId: liste.id,
        gruppeId: Value(liste.gruppeId),
        name: name,
        menge: Value(menge),
        kategorie: Value(kategorie),
        geaendert: uhr(),
        sortierung: Value(uhr().millisecondsSinceEpoch ~/ 1000),
      ),
    );
    return id;
  }

  Future<void> artikelSpeichern(Artikel a) => into(artikelTabelle)
      .insertOnConflictUpdate(a.copyWith(geaendert: uhr(), hochgeladen: false));

  /// Abhaken. Mit [betragCent] entsteht in Gruppenlisten eine Ausgabe:
  /// bezahlt von [zahlerId], geteilt auf alle (oder bei „Ich nehm was mit“
  /// nur auf die Person, für die eingekauft wurde).
  Future<void> artikelAbhaken(
    Artikel a,
    Liste liste, {
    required bool erledigt,
    String? vonPersonId,
    int? betragCent,
  }) => transaction(() async {
    var ausgabeId = a.ausgabeId;
    if (!erledigt && ausgabeId != null) {
      await ausgabeLoeschen(ausgabeId);
      ausgabeId = null;
    }
    if (erledigt &&
        betragCent != null &&
        betragCent > 0 &&
        liste.gruppeId != null &&
        vonPersonId != null) {
      final anteile = liste.fuerPersonId != null
          ? {liste.fuerPersonId!: 1}
          : {for (final p in await personenLaden(liste.gruppeId!)) p.id: 1};
      ausgabeId = await ausgabeAnlegen(
        gruppeId: liste.gruppeId!,
        titel: [a.menge, a.name].where((s) => s.isNotEmpty).join(' '),
        betragCent: betragCent,
        zahlerId: vonPersonId,
        anteile: anteile,
      );
    }
    await artikelSpeichern(
      a.copyWith(
        erledigt: erledigt,
        erledigtVon: Value(erledigt ? vonPersonId : null),
        ausgabeId: Value(ausgabeId),
      ),
    );
  });

  Future<void> artikelLoeschen(Artikel a) =>
      artikelSpeichern(a.copyWith(geloescht: true));

  Future<void> erledigteEntfernen(String listeId) async {
    for (final a in await artikelLaden(listeId)) {
      if (a.erledigt) await artikelLoeschen(a);
    }
  }

  Future<void> alleZuruecksetzen(String listeId) async {
    for (final a in await artikelLaden(listeId)) {
      if (a.erledigt) {
        await artikelSpeichern(
          a.copyWith(erledigt: false, erledigtVon: const Value(null)),
        );
      }
    }
  }

  // ───────────────────────── Ausgaben ─────────────────────────

  Stream<List<Ausgabe>> ausgabenBeobachten(String gruppeId) =>
      (select(ausgabeTabelle)
            ..where(
              (a) => a.gruppeId.equals(gruppeId) & a.geloescht.equals(false),
            )
            ..orderBy([(a) => OrderingTerm.desc(a.datum)]))
          .watch();

  Future<String> ausgabeAnlegen({
    required String gruppeId,
    required String titel,
    required int betragCent,
    required String zahlerId,
    required Map<String, int> anteile,
    String art = 'ausgabe',
    DateTime? datum,
  }) async {
    final id = neueId();
    await into(ausgabeTabelle).insert(
      AusgabeTabelleCompanion.insert(
        id: id,
        gruppeId: Value(gruppeId),
        titel: titel,
        betragCent: betragCent,
        zahlerId: zahlerId,
        anteile: jsonEncode(anteile),
        datum: datum ?? uhr(),
        art: Value(art),
        geaendert: uhr(),
      ),
    );
    return id;
  }

  Future<void> ausgabeSpeichern(Ausgabe a) => into(ausgabeTabelle)
      .insertOnConflictUpdate(a.copyWith(geaendert: uhr(), hochgeladen: false));

  Future<void> ausgabeLoeschen(String id) async {
    final a = await (select(
      ausgabeTabelle,
    )..where((x) => x.id.equals(id))).getSingleOrNull();
    if (a != null) await ausgabeSpeichern(a.copyWith(geloescht: true));
  }

  /// Salden der Gruppe: positiv = bekommt Geld.
  Stream<Map<String, int>> saldenBeobachten(String gruppeId) => _beobachte(
    {ausgabeTabelle, personTabelle},
    () async {
      final personen = await personenLaden(gruppeId);
      final ausgaben =
          await (select(ausgabeTabelle)..where(
                (a) => a.gruppeId.equals(gruppeId) & a.geloescht.equals(false),
              ))
              .get();
      return salden(ausgaben.map((a) => a.buchung), personen.map((p) => p.id));
    },
  );

  // ───────────────────────── Vorlagen ─────────────────────────

  Stream<List<Vorlage>> vorlagenBeobachten() => (select(
    vorlageTabelle,
  )..orderBy([(v) => OrderingTerm.asc(v.name)])).watch();

  /// Speichert die Artikel einer Liste als eigene Packvorlage.
  Future<void> alsVorlageSpeichern(Liste liste) async {
    final artikel = await artikelLaden(liste.id);
    final nachKategorie = <String, List<String>>{};
    for (final a in artikel) {
      nachKategorie.putIfAbsent(a.kategorie, () => []).add(a.name);
    }
    await into(vorlageTabelle).insert(
      VorlageTabelleCompanion.insert(
        id: neueId(),
        name: liste.name,
        symbol: Value(liste.symbol),
        artikel: jsonEncode(nachKategorie),
      ),
    );
  }

  Future<void> vorlageLoeschen(String id) =>
      (delete(vorlageTabelle)..where((v) => v.id.equals(id))).go();

  /// Neue Packliste aus Kategorien → Artikel.
  Future<String> packlisteAnlegen(
    String name,
    String symbol,
    Map<String, List<String>> artikel, {
    String? gruppeId,
  }) => transaction(() async {
    final id = await listeAnlegen(
      name: name,
      art: 'packliste',
      symbol: symbol,
      gruppeId: gruppeId,
    );
    final liste = await (select(
      listeTabelle,
    )..where((l) => l.id.equals(id))).getSingle();
    for (final e in artikel.entries) {
      for (final a in e.value) {
        await artikelHinzufuegen(liste, name: a, kategorie: e.key);
      }
    }
    return id;
  });
}

/// Eine Liste mit Zählern für die Übersicht.
class ListeInfo {
  const ListeInfo(
    this.liste, {
    required this.gruppe,
    required this.offen,
    required this.gesamt,
  });
  final Liste liste;
  final Gruppe? gruppe;
  final int offen;
  final int gesamt;
}

extension AusgabeBuchung on Ausgabe {
  Map<String, int> get anteilMap => (jsonDecode(anteile) as Map).map(
    (k, v) => MapEntry(k as String, v as int),
  );

  Buchung get buchung =>
      Buchung(zahler: zahlerId, betragCent: betragCent, anteile: anteilMap);
}
