import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../logik/kalkulation.dart';
import '../logik/statistik.dart';
import '../logik/typen.dart';
import 'produkt_details.dart';
import 'tabellen.dart';

export 'tabellen.dart';

part 'datenbank.g.dart';

/// Die eine Datenbank der App. Wird in `main.dart` angelegt und ist über
/// [db] überall erreichbar.
late AppDatenbank db;

@DriftDatabase(
  tables: [
    DruckerTabelle,
    FilamentTabelle,
    ExtraTabelle,
    ProduktTabelle,
    ProduktFilamentTabelle,
    ProduktExtraTabelle,
    VerkaufTabelle,
    AuftragTabelle,
    AuftragPositionTabelle,
    SparzielTabelle,
    EinstellungenTabelle,
  ],
)
class AppDatenbank extends _$AppDatenbank {
  AppDatenbank(super.e);

  /// Die echte Datei auf dem Gerät.
  factory AppDatenbank.oeffnen() => AppDatenbank(
    driftDatabase(
      name: dateiName,
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    ),
  );

  static const dateiName = 'druckkasse';

  static Future<File> datei() async {
    final ordner = await getApplicationSupportDirectory();
    return File('${ordner.path}/$dateiName.sqlite');
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await into(einstellungenTabelle).insert(
        const EinstellungenTabelleCompanion(id: Value(1)),
        mode: InsertMode.insertOrIgnore,
      );
    },
  );

  /// Liefert bei jeder Änderung an [tabellen] neu das Ergebnis von [laden].
  Stream<T> _beobachte<T>(
    Set<ResultSetImplementation<dynamic, dynamic>> tabellen,
    Future<T> Function() laden,
  ) => customSelect(
    'SELECT 1',
    readsFrom: tabellen,
  ).watch().asyncMap((_) => laden());

  // ───────────────────────── Einstellungen ─────────────────────────

  Future<Einstellungen> einstellungenLesen() =>
      (select(einstellungenTabelle)..where((e) => e.id.equals(1))).getSingle();

  Stream<Einstellungen> einstellungenBeobachten() => (select(
    einstellungenTabelle,
  )..where((e) => e.id.equals(1))).watchSingle();

  Future<void> einstellungenSpeichern(EinstellungenTabelleCompanion werte) =>
      (update(einstellungenTabelle)..where((e) => e.id.equals(1))).write(werte);

  // ───────────────────────── Drucker, Filamente, Extras ─────────────────────────

  Stream<List<Drucker>> druckerBeobachten() =>
      (select(druckerTabelle)
            ..where((d) => d.archiviert.equals(false))
            ..orderBy([(d) => OrderingTerm.asc(d.name)]))
          .watch();

  Future<int> druckerSpeichern(DruckerTabelleCompanion d) =>
      into(druckerTabelle).insertOnConflictUpdate(d);

  Future<void> druckerArchivieren(int id) =>
      (update(druckerTabelle)..where((d) => d.id.equals(id))).write(
        const DruckerTabelleCompanion(archiviert: Value(true)),
      );

  Stream<List<Filament>> filamenteBeobachten() =>
      (select(filamentTabelle)
            ..where((f) => f.archiviert.equals(false))
            ..orderBy([
              (f) => OrderingTerm.asc(f.material),
              (f) => OrderingTerm.asc(f.name),
            ]))
          .watch();

  Future<int> filamentSpeichern(FilamentTabelleCompanion f) =>
      into(filamentTabelle).insertOnConflictUpdate(f);

  Future<void> filamentArchivieren(int id) =>
      (update(filamentTabelle)..where((f) => f.id.equals(id))).write(
        const FilamentTabelleCompanion(archiviert: Value(true)),
      );

  Stream<List<Extra>> extrasBeobachten() =>
      (select(extraTabelle)
            ..where((e) => e.archiviert.equals(false))
            ..orderBy([(e) => OrderingTerm.asc(e.name)]))
          .watch();

  Future<int> extraSpeichern(ExtraTabelleCompanion e) =>
      into(extraTabelle).insertOnConflictUpdate(e);

  Future<void> extraArchivieren(int id) =>
      (update(extraTabelle)..where((e) => e.id.equals(id))).write(
        const ExtraTabelleCompanion(archiviert: Value(true)),
      );

  // ───────────────────────── Produkte ─────────────────────────

  Future<List<ProduktDetails>> produkteLaden({bool archivierte = false}) async {
    final einstellungen = await einstellungenLesen();
    final produkte =
        await (select(produktTabelle)
              ..where((p) => p.archiviert.equals(archivierte))
              ..orderBy([
                (p) => OrderingTerm.asc(p.sortierung),
                (p) => OrderingTerm.asc(p.name),
              ]))
            .get();
    final drucker = {
      for (final d in await select(druckerTabelle).get()) d.id: d,
    };
    final filamente = {
      for (final f in await select(filamentTabelle).get()) f.id: f,
    };
    final extras = {for (final e in await select(extraTabelle).get()) e.id: e};
    final pf = await select(produktFilamentTabelle).get();
    final pe = await select(produktExtraTabelle).get();
    return [
      for (final p in produkte)
        ProduktDetails(
          produkt: p,
          drucker: drucker[p.druckerId],
          filamente: [
            for (final z in pf)
              if (z.produktId == p.id && filamente[z.filamentId] != null)
                (z, filamente[z.filamentId]!),
          ],
          extras: [
            for (final z in pe)
              if (z.produktId == p.id && extras[z.extraId] != null)
                (z, extras[z.extraId]!),
          ],
          einstellungen: einstellungen,
        ),
    ];
  }

  Stream<List<ProduktDetails>> produkteBeobachten() => _beobachte({
    produktTabelle,
    produktFilamentTabelle,
    produktExtraTabelle,
    druckerTabelle,
    filamentTabelle,
    extraTabelle,
    einstellungenTabelle,
  }, produkteLaden);

  Future<ProduktDetails?> produktLaden(int id) async {
    final alle = [
      ...await produkteLaden(),
      ...await produkteLaden(archivierte: true),
    ];
    return alle.where((p) => p.produkt.id == id).firstOrNull;
  }

  /// Speichert ein Produkt samt Filamenten und Extras. Gibt die ID zurück.
  Future<int> produktSpeichern(
    ProduktTabelleCompanion produkt, {
    required List<(int filamentId, double gramm)> filamente,
    required List<(int extraId, int menge)> extras,
  }) => transaction(() async {
    final id = await into(produktTabelle).insertOnConflictUpdate(produkt);
    final produktId = produkt.id.present ? produkt.id.value : id;
    await (delete(
      produktFilamentTabelle,
    )..where((z) => z.produktId.equals(produktId))).go();
    await (delete(
      produktExtraTabelle,
    )..where((z) => z.produktId.equals(produktId))).go();
    for (final (filamentId, gramm) in filamente) {
      await into(produktFilamentTabelle).insert(
        ProduktFilamentTabelleCompanion.insert(
          produktId: produktId,
          filamentId: filamentId,
          gramm: gramm,
        ),
      );
    }
    for (final (extraId, menge) in extras) {
      await into(produktExtraTabelle).insert(
        ProduktExtraTabelleCompanion.insert(
          produktId: produktId,
          extraId: extraId,
          menge: Value(menge),
        ),
      );
    }
    return produktId;
  });

  Future<void> produktArchivieren(int id, {bool archiviert = true}) =>
      (update(produktTabelle)..where((p) => p.id.equals(id))).write(
        ProduktTabelleCompanion(archiviert: Value(archiviert)),
      );

  Future<int> anzahlAktiverProdukte() async {
    final anzahl = produktTabelle.id.count();
    final q = selectOnly(produktTabelle)
      ..addColumns([anzahl])
      ..where(produktTabelle.archiviert.equals(false));
    return (await q.getSingle()).read(anzahl) ?? 0;
  }

  Future<int> anzahlAktiverDrucker() async {
    final anzahl = druckerTabelle.id.count();
    final q = selectOnly(druckerTabelle)
      ..addColumns([anzahl])
      ..where(druckerTabelle.archiviert.equals(false));
    return (await q.getSingle()).read(anzahl) ?? 0;
  }

  /// Neue Reihenfolge der Produkt-Knöpfe speichern.
  Future<void> produktReihenfolge(List<int> ids) => transaction(() async {
    for (var i = 0; i < ids.length; i++) {
      await (update(produktTabelle)..where((p) => p.id.equals(ids[i]))).write(
        ProduktTabelleCompanion(sortierung: Value(i)),
      );
    }
  });

  // ───────────────────────── Verkäufe ─────────────────────────

  /// Bucht einen Verkauf und gibt seine ID zurück (für „Rückgängig“).
  Future<int> verkaufen(
    ProduktDetails p, {
    int menge = 1,
    int? einzelpreisCent,
    Zahlungsart? zahlungsart,
    DateTime? zeitpunkt,
  }) async {
    final e = p.einstellungen;
    final art = zahlungsart ?? Zahlungsart.values[e.standardZahlungsart];
    final preis = einzelpreisCent ?? p.preisCent;
    return into(verkaufTabelle).insert(
      VerkaufTabelleCompanion.insert(
        zeitpunkt: zeitpunkt ?? DateTime.now(),
        produktId: Value(p.produkt.id),
        produktName: p.produkt.name,
        menge: menge,
        einzelpreisCent: preis,
        einzelkostenCent: p.kostenCent,
        gebuehrCent: Value(gebuehrCent(menge * preis, _gebuehrProzent(e, art))),
        zahlungsart: Value(art.index),
      ),
    );
  }

  double _gebuehrProzent(Einstellungen e, Zahlungsart art) => switch (art) {
    Zahlungsart.bar => 0,
    Zahlungsart.karte => e.gebuehrKarteProzent,
    Zahlungsart.online => e.gebuehrOnlineProzent,
  };

  Future<void> verkaufLoeschen(int id) =>
      (delete(verkaufTabelle)..where((v) => v.id.equals(id))).go();

  Future<List<Verkauf>> verkaeufeLaden(DateTime von, DateTime bis) =>
      (select(verkaufTabelle)
            ..where(
              (v) =>
                  v.zeitpunkt.isBiggerOrEqualValue(von) &
                  v.zeitpunkt.isSmallerThanValue(bis),
            )
            ..orderBy([(v) => OrderingTerm.desc(v.zeitpunkt)]))
          .get();

  Stream<List<Verkauf>> verkaeufeBeobachten(DateTime von, DateTime bis) =>
      (select(verkaufTabelle)
            ..where(
              (v) =>
                  v.zeitpunkt.isBiggerOrEqualValue(von) &
                  v.zeitpunkt.isSmallerThanValue(bis),
            )
            ..orderBy([(v) => OrderingTerm.desc(v.zeitpunkt)]))
          .watch();

  Stream<List<Verkauf>> alleVerkaeufeBeobachten() => (select(
    verkaufTabelle,
  )..orderBy([(v) => OrderingTerm.desc(v.zeitpunkt)])).watch();

  Future<int> anzahlVerkaeufe() async {
    final anzahl = verkaufTabelle.id.count();
    final q = selectOnly(verkaufTabelle)..addColumns([anzahl]);
    return (await q.getSingle()).read(anzahl) ?? 0;
  }

  // ───────────────────────── Aufträge ─────────────────────────

  Future<List<AuftragDetails>> auftraegeLaden() async {
    final auftraege =
        await (select(auftragTabelle)..orderBy([
              (a) => OrderingTerm.asc(a.status),
              (a) =>
                  OrderingTerm(expression: a.faelligAm, nulls: NullsOrder.last),
              (a) => OrderingTerm.desc(a.erstelltAm),
            ]))
            .get();
    final produkte = {
      for (final p in await select(produktTabelle).get()) p.id: p,
    };
    final positionen = await select(auftragPositionTabelle).get();
    return [
      for (final a in auftraege)
        AuftragDetails(a, [
          for (final pos in positionen)
            if (pos.auftragId == a.id) (pos, produkte[pos.produktId]),
        ]),
    ];
  }

  Stream<List<AuftragDetails>> auftraegeBeobachten() => _beobachte({
    auftragTabelle,
    auftragPositionTabelle,
    produktTabelle,
  }, auftraegeLaden);

  Future<int> auftragSpeichern(
    AuftragTabelleCompanion auftrag,
    List<AuftragPositionTabelleCompanion> positionen,
  ) => transaction(() async {
    final id = await into(auftragTabelle).insertOnConflictUpdate(auftrag);
    final auftragId = auftrag.id.present ? auftrag.id.value : id;
    await (delete(
      auftragPositionTabelle,
    )..where((p) => p.auftragId.equals(auftragId))).go();
    for (final p in positionen) {
      await into(auftragPositionTabelle)
          .insert(p.copyWith(auftragId: Value(auftragId)));
    }
    // Bezahlte Aufträge: Verkäufe passend zu den neuen Positionen.
    final gespeichert = await (select(
      auftragTabelle,
    )..where((a) => a.id.equals(auftragId))).getSingle();
    if (gespeichert.bezahltAm != null) {
      await _auftragsVerkaeufeNeu(gespeichert);
    }
    return auftragId;
  });

  Future<void> auftragStatusSetzen(int id, AuftragStatus status) =>
      (update(auftragTabelle)..where((a) => a.id.equals(id))).write(
        AuftragTabelleCompanion(status: Value(status.index)),
      );

  /// Bezahlt setzen erzeugt Verkäufe (zählen dann im Umsatz). Zurücknehmen
  /// löscht sie wieder.
  Future<void> auftragBezahltSetzen(int id, bool bezahlt) =>
      transaction(() async {
        await (update(auftragTabelle)..where((a) => a.id.equals(id))).write(
          AuftragTabelleCompanion(
            bezahltAm: Value(bezahlt ? DateTime.now() : null),
          ),
        );
        final a = await (select(
          auftragTabelle,
        )..where((a) => a.id.equals(id))).getSingle();
        if (bezahlt) {
          await _auftragsVerkaeufeNeu(a);
        } else {
          await (delete(
            verkaufTabelle,
          )..where((v) => v.auftragId.equals(id))).go();
        }
      });

  Future<void> _auftragsVerkaeufeNeu(Auftrag a) async {
    await (delete(verkaufTabelle)..where((v) => v.auftragId.equals(a.id))).go();
    final positionen = await (select(
      auftragPositionTabelle,
    )..where((p) => p.auftragId.equals(a.id))).get();
    final produkte = {
      for (final p in [
        ...await produkteLaden(),
        ...await produkteLaden(archivierte: true),
      ])
        p.produkt.id: p,
    };
    final art = Zahlungsart.values[a.zahlungsart];
    for (final pos in positionen) {
      final p = produkte[pos.produktId];
      if (p == null) continue;
      final umsatz = pos.menge * pos.einzelpreisCent;
      await into(verkaufTabelle).insert(
        VerkaufTabelleCompanion.insert(
          zeitpunkt: a.bezahltAm ?? DateTime.now(),
          produktId: Value(p.produkt.id),
          produktName: p.produkt.name,
          menge: pos.menge,
          einzelpreisCent: pos.einzelpreisCent,
          einzelkostenCent: p.kostenCent,
          gebuehrCent: Value(
            gebuehrCent(umsatz, _gebuehrProzent(p.einstellungen, art)),
          ),
          zahlungsart: Value(art.index),
          auftragId: Value(a.id),
        ),
      );
    }
  }

  Future<void> auftragLoeschen(int id) =>
      (delete(auftragTabelle)..where((a) => a.id.equals(id))).go();

  // ───────────────────────── Sparziele ─────────────────────────

  Stream<List<Sparziel>> sparzieleBeobachten() =>
      (select(sparzielTabelle)..orderBy([
            (s) => OrderingTerm.desc(s.angeheftet),
            (s) => OrderingTerm.desc(s.startDatum),
          ]))
          .watch();

  Future<int> sparzielSpeichern(SparzielTabelleCompanion s) =>
      into(sparzielTabelle).insertOnConflictUpdate(s);

  Future<void> sparzielLoeschen(int id) =>
      (delete(sparzielTabelle)..where((s) => s.id.equals(id))).go();

  Future<void> sparzielErreicht(int id, DateTime? wann) =>
      (update(sparzielTabelle)..where((s) => s.id.equals(id))).write(
        SparzielTabelleCompanion(erreichtAm: Value(wann)),
      );

  // ───────────────────────── Alles löschen ─────────────────────────

  Future<void> allesLoeschen() => transaction(() async {
    for (final t in <TableInfo<Table, dynamic>>[
      verkaufTabelle,
      auftragPositionTabelle,
      auftragTabelle,
      produktExtraTabelle,
      produktFilamentTabelle,
      produktTabelle,
      extraTabelle,
      filamentTabelle,
      druckerTabelle,
      sparzielTabelle,
    ]) {
      await delete(t).go();
    }
  });
}

/// Ein Auftrag mit seinen Positionen.
class AuftragDetails {
  AuftragDetails(this.auftrag, this.positionen);

  final Auftrag auftrag;

  /// Produkt kann `null` sein, falls es gelöscht wurde.
  final List<(AuftragPosition, Produkt?)> positionen;

  int get summeCent =>
      positionen.fold(0, (s, p) => s + p.$1.menge * p.$1.einzelpreisCent);

  int get stueck => positionen.fold(0, (s, p) => s + p.$1.menge);

  AuftragStatus get status => AuftragStatus.values[auftrag.status];
  bool get bezahlt => auftrag.bezahltAm != null;

  /// Fertig = abgeholt und bezahlt.
  bool get erledigt => status == AuftragStatus.abgeholt && bezahlt;
}

extension VerkaufAlsZeile on Verkauf {
  VerkaufZeile get zeile => VerkaufZeile(
    zeitpunkt: zeitpunkt,
    produktId: produktId,
    produktName: produktName,
    menge: menge,
    einzelpreisCent: einzelpreisCent,
    einzelkostenCent: einzelkostenCent,
    // `this.`, weil es auch die Funktion gebuehrCent() gibt.
    gebuehrCent: this.gebuehrCent,
    zahlungsart: zahlungsart,
  );
}
