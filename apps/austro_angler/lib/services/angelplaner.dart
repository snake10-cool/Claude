import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import 'beisszeit.dart';
import 'sonne.dart';
import 'wetter.dart';

/// Ein Tag im Planer mit seinem Beißindex.
typedef PlanTag = ({DateTime tag, Beissindex index});

/// Ein Ort (Heimat oder Lieblingsgewässer) mit den nächsten Tagen.
typedef PlanOrt = ({String name, LatLng ort, List<PlanTag> tage});

/// Bester Termin der Woche.
typedef Termin = ({PlanOrt ort, PlanTag tag});

/// Nur für Tests und Store-Bilder: feste Wetterdaten statt Internet.
@visibleForTesting
Future<List<Stunde>> Function(LatLng ort)? planerTestWetter;

/// Beißindex für die nächsten [tage] Tage an jedem Ort. Orte ohne Wetter
/// (z. B. offline) fehlen im Ergebnis.
Future<List<PlanOrt>> planen(List<(String, LatLng)> orte,
    {int tage = 7, DateTime? ab}) async {
  final start = ab ?? DateTime.now();
  final heute = DateTime(start.year, start.month, start.day);
  final laden = planerTestWetter ?? (LatLng p) => stundenWetter(p, tage: tage);
  final ergebnisse = await Future.wait([
    for (final (name, ort) in orte)
      laden(ort).then<PlanOrt?>((stunden) {
        final liste = <PlanTag>[];
        for (var d = 0; d < tage; d++) {
          final tag = heute.add(Duration(days: d));
          final sonne = sonnenZeiten(tag, ort.latitude, ort.longitude);
          final index = beissindex(stunden, tag,
              aufgang: sonne.aufgang, untergang: sonne.untergang);
          if (index != null) liste.add((tag: tag, index: index));
        }
        return liste.isEmpty ? null : (name: name, ort: ort, tage: liste);
      }).catchError((Object e) {
        debugPrint('Planer $name: $e');
        return null;
      }),
  ]);
  return [for (final e in ergebnisse) ?e];
}

/// Der Termin mit dem höchsten Beißindex – bei Gleichstand der frühere.
/// Heute zählt nur, wenn das beste Zeitfenster noch nicht vorbei ist.
Termin? besterTermin(List<PlanOrt> plan, {DateTime? jetzt}) {
  final j = jetzt ?? DateTime.now();
  Termin? bester;
  for (final o in plan) {
    for (final t in o.tage) {
      final heute = t.tag.year == j.year &&
          t.tag.month == j.month &&
          t.tag.day == j.day;
      if (heute &&
          (t.index.fenster.isEmpty ||
              t.index.fenster.last.$2 <= j.hour)) {
        continue;
      }
      if (bester == null ||
          t.index.wert > bester.tag.index.wert ||
          (t.index.wert == bester.tag.index.wert &&
              t.tag.isBefore(bester.tag.tag))) {
        bester = (ort: o, tag: t);
      }
    }
  }
  return bester;
}
