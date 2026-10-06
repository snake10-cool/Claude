import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teilbar/daten/datenbank.dart';
import 'package:teilbar/sync/fernspeicher.dart';
import 'package:teilbar/sync/sync_motor.dart';

/// Cloud im Speicher: verhält sich wie Firestore (Snapshot mit allen
/// Objekten, danach nur Änderungen).
class FakeCloud {
  final gruppen = <String, Map<String, FernObjekt>>{};
  final codes = <String, String>{};
  final _strom = <String, StreamController<List<FernObjekt>>>{};

  StreamController<List<FernObjekt>> strom(String g) =>
      _strom.putIfAbsent(g, StreamController<List<FernObjekt>>.broadcast);
}

class FakeSpeicher implements Fernspeicher {
  FakeSpeicher(this.cloud);
  final FakeCloud cloud;

  @override
  Future<String> anmelden() async => 'uid';

  @override
  Future<bool> gruppeErstellen(String gruppeId, String code) async {
    if (cloud.codes.containsKey(code)) return false;
    cloud.codes[code] = gruppeId;
    cloud.gruppen[gruppeId] = {};
    return true;
  }

  @override
  Future<String?> beitreten(String code) async => cloud.codes[code];

  @override
  Stream<List<FernObjekt>> beobachten(String gruppeId) {
    final c = cloud.strom(gruppeId);
    return Stream.multi((ziel) {
      ziel.add(cloud.gruppen[gruppeId]!.values.toList());
      final abo = c.stream.listen(ziel.add);
      ziel.onCancel = abo.cancel;
    });
  }

  @override
  Future<void> schreiben(String gruppeId, List<FernObjekt> objekte) async {
    for (final o in objekte) {
      cloud.gruppen[gruppeId]![o.id] = o;
    }
    cloud.strom(gruppeId).add(objekte);
  }
}

Future<void> kurz() => Future<void>.delayed(const Duration(milliseconds: 900));

void main() {
  late FakeCloud cloud;
  late AppDatenbank anna, ben;
  late SyncMotor syncA, syncB;

  setUp(() async {
    cloud = FakeCloud();
    anna = AppDatenbank(NativeDatabase.memory());
    ben = AppDatenbank(NativeDatabase.memory());
    syncA = SyncMotor(anna, FakeSpeicher(cloud));
    syncB = SyncMotor(ben, FakeSpeicher(cloud));
    await syncA.starten();
    await syncB.starten();
  });

  tearDown(() async {
    await syncA.stoppen();
    await syncB.stoppen();
    await anna.close();
    await ben.close();
  });

  test('WG-Liste: anlegen, beitreten, abhaken mit Betrag, löschen', () async {
    final gid = await anna.gruppeAnlegen(
      name: 'WG Linz',
      art: 'wg',
      meinName: 'Anna',
      weitere: ['Ben'],
    );
    final lid = await anna.listeAnlegen(name: 'Einkauf', gruppeId: gid);
    final liste = (await anna.listenLaden()).single.liste;
    await anna.artikelHinzufuegen(liste, name: 'Milch', menge: '2');
    await anna.artikelHinzufuegen(liste, name: 'Brot');

    final code = await syncA.onlineStellen(gid);
    expect(code.length, 6);

    // Ben tritt bei und sieht alles.
    final beigetreten = await syncB.beitreten(code.toLowerCase());
    expect(beigetreten, gid);
    await kurz();
    expect((await ben.gruppeLaden(gid))!.name, 'WG Linz');
    final personenBen = await ben.personenLaden(gid);
    expect(personenBen.map((p) => p.name).toSet(), {'Anna', 'Ben'});
    final benPerson = personenBen.firstWhere((p) => p.name == 'Ben');
    await ben.ichSetzen(gid, benPerson.id);
    expect(await ben.artikelLaden(lid), hasLength(2));

    // Ben kauft die Milch um 2,40 € → Ausgabe für alle.
    final milch = (await ben.artikelLaden(lid))
        .firstWhere((a) => a.name == 'Milch');
    final listeBen = (await ben.listenLaden()).single.liste;
    await ben.artikelAbhaken(
      milch,
      listeBen,
      erledigt: true,
      vonPersonId: benPerson.id,
      betragCent: 240,
    );
    await kurz();

    final milchAnna = (await anna.artikelLaden(lid))
        .firstWhere((a) => a.name == 'Milch');
    expect(milchAnna.erledigt, isTrue);
    final saldenAnna = await anna.saldenBeobachten(gid).first;
    expect(saldenAnna[benPerson.id], 120);
    expect(saldenAnna.values.fold(0, (a, b) => a + b), 0);

    // Anna löscht das Brot → bei Ben weg.
    final brot = (await anna.artikelLaden(lid))
        .firstWhere((a) => a.name == 'Brot');
    await anna.artikelLoeschen(brot);
    await kurz();
    expect((await ben.artikelLaden(lid)).map((a) => a.name), ['Milch']);
  });

  test('neuere Änderung gewinnt, ältere wird ignoriert', () async {
    final gid = await anna.gruppeAnlegen(
      name: 'Urlaub',
      art: 'urlaub',
      meinName: 'Anna',
    );
    final code = await syncA.onlineStellen(gid);
    await syncB.beitreten(code);
    await kurz();

    final g = (await anna.gruppeLaden(gid))!;
    await anna.gruppeSpeichern(g.copyWith(name: 'Kroatien 2026'));
    await kurz();
    expect((await ben.gruppeLaden(gid))!.name, 'Kroatien 2026');

    // Eine veraltete Version aus der Cloud darf nichts überschreiben.
    await syncB.anwenden([
      FernObjekt(
        typ: 'gruppe',
        id: gid,
        geaendert: DateTime(2000),
        daten: {...g.toJson(), 'name': 'Alt'},
      ),
    ]);
    expect((await ben.gruppeLaden(gid))!.name, 'Kroatien 2026');
    // Lokale Felder bleiben lokal.
    expect((await ben.gruppeLaden(gid))!.ichPersonId, isNull);
    expect((await anna.gruppeLaden(gid))!.ichPersonId, isNotNull);
  });

  test('lokale Gruppen gehen nie in die Cloud', () async {
    await anna.gruppeAnlegen(name: 'Nur ich', art: 'sonst', meinName: 'Anna');
    await syncA.hochladen();
    expect(cloud.gruppen, isEmpty);
  });

  test('Codes sind 6 Zeichen ohne verwechselbare Zeichen', () {
    for (var i = 0; i < 200; i++) {
      final c = neuerCode();
      expect(c, matches(RegExp(r'^[A-HJ-NP-Z2-9]{6}$')));
      expect(c.contains('O') || c.contains('I') || c.contains('L'), isFalse);
    }
  });
}
