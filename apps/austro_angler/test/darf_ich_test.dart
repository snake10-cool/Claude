import 'package:austro_angler/data/gewaesser.dart';
import 'package:austro_angler/models/bundesland.dart';
import 'package:austro_angler/services/alle_gewaesser.dart';
import 'package:austro_angler/services/darf_ich.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ki = DarfIch(gewaesserListe);
  final ooe = Bundesland.ooe;

  test('Fisch, Mundart und Tippfehler', () {
    expect(ki.verstehen('Darf ich heute Zander fangen?', DateTime(2026, 7, 1))
        .fische.first.id, 'zander');
    expect(ki.verstehen('waller mitnehmen', DateTime(2026, 7, 1)).fische.first.id,
        'wels');
    expect(ki.verstehen('darf ich eine Forelle behalten', DateTime(2026, 7, 1))
        .fische.first.id, 'bachforelle');
    final tipp = ki.verstehen('darf ich zandr fangen', DateTime(2026, 7, 1));
    expect(tipp.fische.first.id, 'zander');
    expect(tipp.unsicher, isNotEmpty);
    expect(ki.verstehen('Hechte im See', DateTime(2026, 7, 1)).fische.first.id,
        'hecht');
    expect(ki.verstehen('äsche', DateTime(2026, 7, 1)).fische.first.id, 'aesche');
    expect(ki.verstehen('aesche', DateTime(2026, 7, 1)).fische.first.id, 'aesche');
  });

  test('Datum, Länge, Bundesland', () {
    final j = DateTime(2026, 7, 1); // Mittwoch
    expect(ki.verstehen('morgen Hecht', j).von, DateTime(2026, 7, 2));
    expect(ki.verstehen('übermorgen Hecht', j).von, DateTime(2026, 7, 3));
    expect(ki.verstehen('am Samstag Hecht', j).von, DateTime(2026, 7, 4));
    expect(ki.verstehen('Hecht am 15.3.', j).von, DateTime(2027, 3, 15));
    expect(ki.verstehen('Hecht am 15. März', j).von, DateTime(2027, 3, 15));
    final mai = ki.verstehen('Hecht im Mai', j);
    expect(mai.von, DateTime(2027, 5, 1));
    expect(mai.bis, DateTime(2027, 5, 31));
    expect(ki.verstehen('ein 45 cm Hecht', j).laengeCm, 45);
    expect(ki.verstehen('hecht 52cm', j).laengeCm, 52);
    expect(ki.verstehen('Hecht in Tirol', j).land, Bundesland.tirol);
    expect(ki.verstehen('Hecht mitnehmen', j).mitnehmen, isTrue);
  });

  test('Gewässer erkennen', () {
    final f = ki.verstehen('Darf ich am Inn einen Zander fangen?', DateTime(2026, 7, 1));
    expect(f.gewaesser, isNotNull);
    expect(f.gewaesser!.name, contains('Inn'));
    expect(f.fische.first.id, 'zander');
  });

  test('Antworten: Schonzeit, Brittelmaß, offen', () {
    // Hecht OÖ: Schonzeit 1.2.–30.4., 60 cm
    final zu = ki.fragen('Darf ich heute einen Hecht fangen?', DateTime(2026, 3, 10), ooe);
    expect(zu.ampel, Ampel.nein);
    final offen = ki.fragen('Darf ich heute einen Hecht fangen?', DateTime(2026, 7, 10), ooe);
    expect(offen.ampel, isNot(Ampel.nein));
    final klein = ki.fragen('Darf ich einen 45 cm Hecht mitnehmen?', DateTime(2026, 7, 10), ooe);
    expect(klein.ampel, Ampel.nein);
    expect(klein.punkte.first, contains('Zu klein'));
    final gross = ki.fragen('Darf ich einen 75 cm Hecht mitnehmen?', DateTime(2026, 7, 10), ooe);
    expect(gross.ampel, isNot(Ampel.nein));
    final huchen = ki.fragen('Huchen', DateTime(2026, 7, 10), Bundesland.bgld);
    expect(huchen.ampel, Ampel.nein); // Bgld ganzjährig
  });

  test('Was darf ich …? und Unverständliches', () {
    final liste = ki.fragen('Was darf ich heute fangen?', DateTime(2026, 3, 10), ooe);
    expect(liste.ampel, Ampel.info);
    expect(liste.offen, isNotEmpty);
    expect(liste.geschont.any((f) => f.id == 'hecht'), isTrue);
    final unsinn = ki.fragen('blabla', DateTime(2026, 3, 10), ooe);
    expect(unsinn.ampel, Ampel.info);
    expect(unsinn.offen, isEmpty);
  });

  testWidgets('Mit allen Gewässern Österreichs', (tester) async {
    await tester.runAsync(alleGewaesser.laden);
    final alle = DarfIch(alleGewaesser.liste);
    final j = DateTime(2026, 7, 1);
    final m = alle.verstehen('Darf ich an der Mattig eine Äsche fangen?', j);
    expect(m.gewaesser?.name, contains('Mattig'));
    expect(m.fische.first.id, 'aesche');
    final i = alle.verstehen('Hecht im Ibmer See', j);
    expect(i.gewaesser?.name, contains('Ibmer'));
    final w = alle.verstehen('Was darf ich morgen am Wörthersee fangen', j);
    expect(w.gewaesser?.land, Bundesland.ktn);
    expect(w.wasDarfIch, isTrue);
    final a = alle.fragen('Zander am Wörthersee', j, Bundesland.ooe);
    expect(a.land, Bundesland.ktn); // Land kommt vom Gewässer
  });
}
