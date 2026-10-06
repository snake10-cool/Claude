import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart';

import '../daten/datenbank.dart';
import 'fernspeicher.dart';

/// Einladungscode: 6 Zeichen ohne leicht verwechselbare (0/O, 1/I/L).
String neuerCode([Random? zufall]) {
  const zeichen = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  final r = zufall ?? Random.secure();
  return List.generate(6, (_) => zeichen[r.nextInt(zeichen.length)]).join();
}

/// Hält lokale Datenbank und Cloud für Online-Gruppen gleich.
///
/// - Lokale Änderungen (hochgeladen = false) werden hochgeladen.
/// - Änderungen aus der Cloud werden übernommen, wenn sie neuer sind
///   („neueste Änderung gewinnt“).
class SyncMotor {
  SyncMotor(this.d, this.fern);

  final AppDatenbank d;
  final Fernspeicher fern;
  final _abos = <String, StreamSubscription<List<FernObjekt>>>{};
  StreamSubscription<void>? _lokal;
  Timer? _verzoegerung;
  bool _laedtHoch = false;

  // Felder, die nur auf diesem Gerät gelten und nicht geteilt werden.
  static const _lokaleFelder = {'hochgeladen', 'online', 'ichPersonId', 'code'};

  /// Startet: Online-Gruppen beobachten und lokale Änderungen hochladen.
  Future<void> starten() async {
    await fern.anmelden();
    _lokal = d
        .customSelect(
          'SELECT 1',
          readsFrom: {
            d.gruppeTabelle,
            d.personTabelle,
            d.listeTabelle,
            d.artikelTabelle,
            d.ausgabeTabelle,
          },
        )
        .watch()
        .listen((_) => _bald());
    for (final g in await _onlineGruppen()) {
      _beobachten(g.id);
    }
    await hochladen();
  }

  Future<void> stoppen() async {
    _verzoegerung?.cancel();
    await _lokal?.cancel();
    for (final a in _abos.values) {
      await a.cancel();
    }
    _abos.clear();
  }

  void _bald() {
    _verzoegerung?.cancel();
    _verzoegerung = Timer(const Duration(milliseconds: 600), hochladen);
  }

  Future<List<Gruppe>> _onlineGruppen() =>
      (d.select(d.gruppeTabelle)..where((g) => g.online.equals(true))).get();

  /// Macht eine lokale Gruppe zur Online-Gruppe und gibt den Code zurück.
  Future<String> onlineStellen(String gruppeId) async {
    await fern.anmelden();
    String code;
    do {
      code = neuerCode();
    } while (!await fern.gruppeErstellen(gruppeId, code));
    await (d.update(
      d.gruppeTabelle,
    )..where((g) => g.id.equals(gruppeId))).write(
      GruppeTabelleCompanion(online: const Value(true), code: Value(code)),
    );
    // Alles der Gruppe muss einmal hoch.
    for (final t in _tabellen) {
      await d.customUpdate(
        'UPDATE ${t.actualTableName} SET hochgeladen = 0 WHERE gruppe_id = ?',
        variables: [Variable.withString(gruppeId)],
        updates: {t},
      );
    }
    _beobachten(gruppeId);
    await hochladen();
    return code;
  }

  /// Tritt einer Gruppe bei. Gibt die Gruppen-ID zurück oder `null`.
  Future<String?> beitreten(String code) async {
    await fern.anmelden();
    final gid = await fern.beitreten(code.trim().toUpperCase());
    if (gid == null) return null;
    // Platzhalter, bis die Daten aus der Cloud da sind.
    await d
        .into(d.gruppeTabelle)
        .insert(
          GruppeTabelleCompanion.insert(
            id: gid,
            gruppeId: Value(gid),
            name: '…',
            geaendert: DateTime.fromMillisecondsSinceEpoch(0),
            online: const Value(true),
            code: Value(code.trim().toUpperCase()),
            hochgeladen: const Value(true),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    final fertig = Completer<void>();
    _beobachten(gid, ersteDaten: fertig);
    await fertig.future.timeout(const Duration(seconds: 15), onTimeout: () {});
    return gid;
  }

  void _beobachten(String gruppeId, {Completer<void>? ersteDaten}) {
    if (_abos.containsKey(gruppeId)) {
      ersteDaten?.complete();
      return;
    }
    _abos[gruppeId] = fern.beobachten(gruppeId).listen((objekte) async {
      await anwenden(objekte);
      if (ersteDaten != null && !ersteDaten.isCompleted) ersteDaten.complete();
    });
  }

  List<TableInfo<Table, dynamic>> get _tabellen => [
    d.gruppeTabelle,
    d.personTabelle,
    d.listeTabelle,
    d.artikelTabelle,
    d.ausgabeTabelle,
  ];

  static const _typen = ['gruppe', 'person', 'liste', 'artikel', 'ausgabe'];

  /// Lädt alle noch nicht hochgeladenen Änderungen von Online-Gruppen hoch.
  Future<void> hochladen() async {
    if (_laedtHoch) return _bald();
    _laedtHoch = true;
    try {
      final online = {for (final g in await _onlineGruppen()) g.id};
      if (online.isEmpty) return;
      final proGruppe = <String, List<FernObjekt>>{};
      final erledigt = <(TableInfo<Table, dynamic>, String, DateTime)>[];
      for (final (i, t) in _tabellen.indexed) {
        final zeilen = await d
            .customSelect(
              'SELECT * FROM ${t.actualTableName} WHERE hochgeladen = 0',
              readsFrom: {t},
            )
            .get();
        for (final z in zeilen) {
          final daten = t.map(z.data) as DataClass;
          final json = daten.toJson();
          final gid = json['gruppeId'] as String?;
          if (gid == null || !online.contains(gid)) continue;
          final geaendert = DateTime.fromMillisecondsSinceEpoch(
            json['geaendert'] as int,
          );
          json.removeWhere((k, _) => _lokaleFelder.contains(k));
          proGruppe
              .putIfAbsent(gid, () => [])
              .add(
                FernObjekt(
                  typ: _typen[i],
                  id: json['id'] as String,
                  geaendert: geaendert,
                  daten: json,
                ),
              );
          erledigt.add((t, json['id'] as String, geaendert));
        }
      }
      for (final e in proGruppe.entries) {
        await fern.schreiben(e.key, e.value);
      }
      // Nur markieren, wenn sich die Zeile inzwischen nicht wieder geändert hat.
      for (final (t, id, geaendert) in erledigt) {
        await d.customUpdate(
          'UPDATE ${t.actualTableName} SET hochgeladen = 1 '
          'WHERE id = ? AND geaendert = ?',
          variables: [
            Variable.withString(id),
            Variable.withDateTime(geaendert),
          ],
          updates: {t},
        );
      }
    } finally {
      _laedtHoch = false;
    }
  }

  /// Übernimmt Objekte aus der Cloud, wenn sie neuer sind als lokal.
  Future<void> anwenden(List<FernObjekt> objekte) => d.transaction(() async {
    for (final o in objekte) {
      final i = _typen.indexOf(o.typ);
      if (i < 0) continue;
      final t = _tabellen[i];
      final lokal = await d
          .customSelect(
            'SELECT geaendert FROM ${t.actualTableName} WHERE id = ?',
            variables: [Variable.withString(o.id)],
            readsFrom: {t},
          )
          .getSingleOrNull();
      if (lokal != null) {
        final lokalZeit = lokal.read<DateTime>('geaendert');
        if (!o.geaendert.isAfter(lokalZeit)) continue;
      }
      final json = Map<String, dynamic>.from(o.daten)
        ..['hochgeladen'] = true
        ..['geaendert'] = o.geaendert.millisecondsSinceEpoch;
      if (o.typ == 'gruppe') {
        // Lokale Felder behalten.
        final alt = await d.gruppeLaden(o.id);
        json['online'] = true;
        json['ichPersonId'] = alt?.ichPersonId;
        json['code'] = alt?.code;
        await d
            .into(d.gruppeTabelle)
            .insertOnConflictUpdate(Gruppe.fromJson(json));
      } else if (o.typ == 'person') {
        await d
            .into(d.personTabelle)
            .insertOnConflictUpdate(Person.fromJson(json));
      } else if (o.typ == 'liste') {
        await d
            .into(d.listeTabelle)
            .insertOnConflictUpdate(Liste.fromJson(json));
      } else if (o.typ == 'artikel') {
        await d
            .into(d.artikelTabelle)
            .insertOnConflictUpdate(Artikel.fromJson(json));
      } else if (o.typ == 'ausgabe') {
        await d
            .into(d.ausgabeTabelle)
            .insertOnConflictUpdate(Ausgabe.fromJson(json));
      }
    }
  });
}
