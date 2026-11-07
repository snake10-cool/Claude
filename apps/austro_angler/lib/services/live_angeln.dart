import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ein Ereignis während eines Angeltags am Wasser.
enum Ereignis {
  biss('🎣', 'Biss'),
  fang('🐟', 'Fang'),
  koeder('🪝', 'Köder gewechselt'),
  notiz('📝', 'Notiz');

  const Ereignis(this.symbol, this.titel);
  final String symbol;
  final String titel;
}

typedef Eintrag = ({DateTime zeit, Ereignis art, String text});

/// Laufender Angeltag („Live-Angeln“): Zeit, Bisse, Fänge und Köderwechsel.
/// Wird am Gerät gespeichert, damit nichts verloren geht, wenn das Handy
/// die App im Hintergrund beendet.
class Sitzung {
  Sitzung({
    required this.start,
    required this.gewaesser,
    required this.koeder,
    List<Eintrag>? eintraege,
  }) : eintraege = eintraege ?? [];

  final DateTime start;
  final String gewaesser;
  String koeder;
  final List<Eintrag> eintraege;

  int zaehle(Ereignis e) => eintraege.where((x) => x.art == e).length;

  Duration dauer(DateTime jetzt) => jetzt.difference(start);

  /// Bisse pro Stunde (Fänge zählen als Biss mit).
  double bisseProStunde(DateTime jetzt) {
    final h = dauer(jetzt).inMinutes / 60;
    if (h < 0.05) return 0;
    return (zaehle(Ereignis.biss) + zaehle(Ereignis.fang)) / h;
  }

  /// Köder mit den meisten Bissen und Fängen – oder null.
  String? besterKoeder() {
    final punkte = <String, int>{};
    for (final e in eintraege) {
      if ((e.art == Ereignis.biss || e.art == Ereignis.fang) &&
          e.text.isNotEmpty) {
        punkte[e.text] = (punkte[e.text] ?? 0) + (e.art == Ereignis.fang ? 2 : 1);
      }
    }
    if (punkte.isEmpty) return null;
    return (punkte.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .first
        .key;
  }

  Map<String, Object?> toJson() => {
        'start': start.toIso8601String(),
        'gewaesser': gewaesser,
        'koeder': koeder,
        'eintraege': [
          for (final e in eintraege)
            {'zeit': e.zeit.toIso8601String(), 'art': e.art.name, 'text': e.text},
        ],
      };

  static Sitzung? fromJson(Map<String, dynamic> j) {
    final start = DateTime.tryParse(j['start'] as String? ?? '');
    if (start == null) return null;
    return Sitzung(
      start: start,
      gewaesser: j['gewaesser'] as String? ?? '',
      koeder: j['koeder'] as String? ?? '',
      eintraege: [
        for (final e in (j['eintraege'] as List?) ?? const [])
          if (e is Map &&
              DateTime.tryParse(e['zeit'] as String? ?? '') != null &&
              Ereignis.values.asNameMap()[e['art']] != null)
            (
              zeit: DateTime.parse(e['zeit'] as String),
              art: Ereignis.values.asNameMap()[e['art']]!,
              text: e['text'] as String? ?? '',
            ),
      ],
    );
  }
}

class LiveAngeln extends ChangeNotifier {
  LiveAngeln._();

  static final instanz = LiveAngeln._();

  Sitzung? sitzung;
  bool _geladen = false;

  Future<void> laden() async {
    if (_geladen) return;
    _geladen = true;
    try {
      final p = await SharedPreferences.getInstance();
      final roh = p.getString('live_sitzung');
      if (roh != null) {
        sitzung = Sitzung.fromJson(jsonDecode(roh) as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Live-Angeln: $e');
    }
  }

  Future<void> _speichern() async {
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    final s = sitzung;
    if (s == null) {
      await p.remove('live_sitzung');
    } else {
      await p.setString('live_sitzung', jsonEncode(s.toJson()));
    }
  }

  Future<void> starten(String gewaesser, String koeder) {
    sitzung = Sitzung(
        start: DateTime.now(), gewaesser: gewaesser.trim(), koeder: koeder.trim());
    return _speichern();
  }

  Future<void> eintragen(Ereignis art, [String? text]) {
    final s = sitzung;
    if (s == null) return Future.value();
    if (art == Ereignis.koeder && text != null) s.koeder = text.trim();
    s.eintraege.add((
      zeit: DateTime.now(),
      art: art,
      text: (text ?? (art == Ereignis.notiz ? '' : s.koeder)).trim(),
    ));
    return _speichern();
  }

  /// Letzten Eintrag zurücknehmen (falsch getippt).
  Future<void> rueckgaengig() {
    final s = sitzung;
    if (s == null || s.eintraege.isEmpty) return Future.value();
    s.eintraege.removeLast();
    return _speichern();
  }

  /// Beendet den Angeltag und gibt ihn zurück (für die Zusammenfassung).
  Future<Sitzung?> beenden() async {
    final s = sitzung;
    sitzung = null;
    await _speichern();
    return s;
  }
}

final liveAngeln = LiveAngeln.instanz;
