import 'dart:math';

import 'package:flutter/material.dart';

/// Die 8 Schulstufen: Volksschule 1–4 und Mittelschule 1–4.
enum Stufe {
  vs1('VS 1', '1. Klasse Volksschule'),
  vs2('VS 2', '2. Klasse Volksschule'),
  vs3('VS 3', '3. Klasse Volksschule'),
  vs4('VS 4', '4. Klasse Volksschule'),
  ms1('MS 1', '1. Klasse Mittelschule'),
  ms2('MS 2', '2. Klasse Mittelschule'),
  ms3('MS 3', '3. Klasse Mittelschule'),
  ms4('MS 4', '4. Klasse Mittelschule');

  const Stufe(this.kurz, this.lang);

  final String kurz;
  final String lang;

  bool get volksschule => index < 4;
}

/// Eine Multiple-Choice-Aufgabe. Die App mischt die Antworten.
class Aufgabe {
  const Aufgabe(this.frage, this.richtig, this.falsch, {this.erklaerung});

  /// Kurzschreibweise: `'Frage|richtig|falsch1|falsch2|falsch3'`.
  factory Aufgabe.aus(String zeile) {
    final teile = zeile.split('|');
    return Aufgabe(teile[0], teile[1], teile.sublist(2));
  }

  final String frage;
  final String richtig;
  final List<String> falsch;
  final String? erklaerung;

  /// Richtige und falsche Antworten gemischt, ohne doppelte.
  List<String> gemischt(Random zufall) =>
      {richtig, ...falsch}.take(4).toList()..shuffle(zufall);
}

typedef Generator = Aufgabe Function(Random zufall);

class Thema {
  const Thema(this.id, this.titel, this.generator);

  /// Baut ein Thema aus festen Aufgaben (Kurzschreibweise, siehe [Aufgabe.aus]).
  factory Thema.liste(String id, String titel, List<String> zeilen) {
    final aufgaben = zeilen.map(Aufgabe.aus).toList();
    return Thema(id, titel, (z) => aufgaben[z.nextInt(aufgaben.length)]);
  }

  /// Fragt Paare ab, z. B. Vokabeln. Falsche Antworten kommen aus den
  /// anderen Paaren.
  factory Thema.paare(
    String id,
    String titel,
    Map<String, String> paare,
    String Function(String) frage,
  ) {
    final eintraege = paare.entries.toList();
    return Thema(id, titel, (z) {
      final richtig = eintraege[z.nextInt(eintraege.length)];
      final andere = eintraege
          .where((e) => e.value != richtig.value)
          .map((e) => e.value)
          .toSet()
          .toList()
        ..shuffle(z);
      return Aufgabe(frage(richtig.key), richtig.value, andere.take(3).toList());
    });
  }

  /// Ordnet Wörter einer Kategorie zu, z. B. Wortarten.
  factory Thema.kategorien(
    String id,
    String titel,
    Map<String, String> woerter,
    String Function(String) frage,
  ) {
    final kategorien = woerter.values.toSet().toList();
    final eintraege = woerter.entries.toList();
    return Thema(id, titel, (z) {
      final e = eintraege[z.nextInt(eintraege.length)];
      final andere = kategorien.where((k) => k != e.value).toList()..shuffle(z);
      return Aufgabe(frage(e.key), e.value, andere.take(3).toList());
    });
  }

  final String id;
  final String titel;
  final Generator generator;
}

class Fach {
  const Fach({
    required this.id,
    required this.name,
    required this.icon,
    required this.farbe,
    this.premium = false,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color farbe;
  final bool premium;
}
