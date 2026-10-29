import 'dart:math';

import '../data/fragebogen.dart';
import '../data/katalog.dart';
import '../models/buch.dart';

class Empfehlung {
  const Empfehlung(this.buch, this.punkte, this.gruende);

  final Buch buch;
  final double punkte;

  /// Kurze Begründungen, z. B. „Fantasy" oder „Wie Der Hobbit (5★)".
  final List<String> gruende;
}

/// Wert einer Fragebogen-Antwort (Alter, Länge, Format), sonst null.
int? antwortWert(Map<String, List<String>> antworten, String frageId) {
  final gewaehlt = antworten[frageId];
  final frage = frageMitId(frageId);
  if (gewaehlt == null || gewaehlt.isEmpty || frage == null) return null;
  for (final o in frage.optionen) {
    if (o.id == gewaehlt.first) return o.wert;
  }
  return null;
}

/// Wie sehr jemand jedes Merkmal mag: Fragebogen plus eigene Bewertungen.
Map<String, double> leseprofil(
  Map<String, List<String>> antworten,
  Map<String, Eintrag> eintraege,
  Buch? Function(String id) buchFinden, {
  Map<String, double> vorlieben = const {},
}) {
  final profil = <String, double>{};
  void plus(String tag, double w) => profil[tag] = (profil[tag] ?? 0) + w;

  for (final frage in fragebogen) {
    final gewaehlt = antworten[frage.id] ?? const [];
    // Bei Mehrfachauswahl zählt jede Antwort etwas weniger, damit „alles
    // anklicken" nicht alles gleich stark macht.
    final faktor = gewaehlt.length > 2 ? 2 / gewaehlt.length : 1.0;
    for (final o in frage.optionen) {
      if (!gewaehlt.contains(o.id)) continue;
      o.gewichte.forEach((tag, w) => plus(tag, w * faktor));
    }
  }

  // Die eigene Bibliothek zählt stark: Ein 5-Sterne-Buch hebt seine
  // Merkmale, ein 1-Stern- oder abgebrochenes Buch senkt sie.
  eintraege.forEach((id, e) {
    final buch = buchFinden(id);
    if (buch == null) return;
    final double w = switch (e.status) {
      Status.abgebrochen => -0.8,
      Status.wunschliste => 0.3,
      _ => e.sterne == 0 ? 0.4 : (e.sterne - 3) * 0.7,
    };
    for (final t in buch.tags) {
      plus(t, w);
    }
  });

  // „Bücher gegeneinander": direkte Aussagen wie „Liebesgeschichten mag ich
  // nicht" zählen stark.
  vorlieben.forEach((t, w) => plus(t, w * 2));
  return profil;
}

List<Empfehlung> empfehlen({
  required Map<String, List<String>> antworten,
  required Map<String, Eintrag> eintraege,
  List<Buch> buecher = katalog,
  int anzahl = 20,
  Map<String, double> vorlieben = const {},
}) {
  final nachId = {for (final b in buecher) b.id: b};
  final profil = leseprofil(antworten, eintraege, (id) => nachId[id], vorlieben: vorlieben);
  final alter = antwortWert(antworten, 'alter');
  final laenge = antwortWert(antworten, 'laenge');

  // Lieblingsbücher (4–5 Sterne) für „Weil du … mochtest".
  final lieblinge = [
    for (final MapEntry(:key, :value) in eintraege.entries)
      if (value.sterne >= 4 && nachId[key] != null) (nachId[key]!, value.sterne),
  ]..sort((a, b) => b.$2.compareTo(a.$2));

  final ergebnis = <Empfehlung>[];
  for (final buch in buecher) {
    if (buch.eigenes || eintraege.containsKey(buch.id)) continue;
    if (alter != null && buch.minAlter > alter) continue;

    var punkte = 0.0;
    final treffer = <(String, double)>[];
    for (final t in buch.tags) {
      final w = profil[t] ?? 0;
      punkte += w;
      if (w > 0.9) treffer.add((t, w));
    }
    // Wurzel statt Anzahl: Bücher mit vielen Tags sollen nicht automatisch
    // gewinnen, aber auch nicht bestraft werden.
    punkte /= sqrt(max(buch.tags.length, 1));

    if (alter != null) punkte += _altersBonus(alter, buch.zielgruppe);
    if (laenge != null) punkte += _laengenBonus(laenge, buch.seiten);

    treffer.sort((a, b) => b.$2.compareTo(a.$2));
    final gruende = [for (final t in treffer.take(3)) Tags.namen[t.$1] ?? t.$1];
    for (final (liebling, sterne) in lieblinge) {
      if (liebling.tags.intersection(buch.tags).length >= 3) {
        gruende.insert(0, 'Wie ${liebling.titel} ($sterne★)');
        punkte += 0.5;
        break;
      }
    }
    ergebnis.add(Empfehlung(buch, punkte, gruende));
  }
  ergebnis.sort((a, b) => b.punkte.compareTo(a.punkte));
  return ergebnis.take(anzahl).toList();
}

double _altersBonus(int alter, Zielgruppe z) {
  final passend = switch (z) {
    Zielgruppe.kinder => alter < 13,
    Zielgruppe.jugend => alter >= 10 && alter < 30,
    Zielgruppe.erwachsene => alter >= 14,
  };
  if (passend) return 1;
  // Kinderbücher für Erwachsene nur leicht abwerten – manche lesen sie gern.
  return z == Zielgruppe.kinder ? -1.5 : -2.5;
}

double _laengenBonus(int laenge, int seiten) => switch (laenge) {
      0 => seiten <= 250 ? 1 : (seiten > 450 ? -2 : -0.5),
      1 => seiten > 600 ? -1.5 : 0.3,
      2 => seiten >= 450 ? 1 : 0,
      _ => 0,
    };
