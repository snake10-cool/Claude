import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../data/fische.dart';
import '../models/bundesland.dart';
import '../models/fang.dart';
import 'beisszeit.dart';
import 'konto.dart';
import 'sonne.dart';
import 'wetter.dart';

/// Eine Nachricht im Chat mit Petri.
typedef KiNachricht = ({bool vonMir, String text});

/// Ergebnis der Foto-Bestimmung.
class FotoErgebnis {
  const FotoErgebnis({
    required this.erkannt,
    this.fischId,
    this.sicherheit = 'niedrig',
    this.merkmale = const [],
    this.alternativen = const [],
    this.hinweis = '',
  });

  factory FotoErgebnis.ausJson(Map<String, dynamic> j) {
    final id = j['fisch_id'];
    final fischId = id is String && fischById(id) != null ? id : null;
    return FotoErgebnis(
      erkannt: j['erkannt'] == true && fischId != null,
      fischId: fischId,
      sicherheit: switch (j['sicherheit']) {
        'hoch' => 'hoch',
        'mittel' => 'mittel',
        _ => 'niedrig',
      },
      merkmale: [
        for (final m in (j['merkmale'] as List?) ?? const [])
          if (m is String && m.trim().isNotEmpty) m.trim(),
      ],
      alternativen: [
        for (final a in (j['alternativen'] as List?) ?? const [])
          if (a is Map &&
              a['fisch_id'] is String &&
              fischById(a['fisch_id'] as String) != null)
            (a['fisch_id'] as String, (a['grund'] as String?) ?? ''),
      ],
      hinweis: (j['hinweis'] as String?)?.trim() ?? '',
    );
  }

  final bool erkannt;
  final String? fischId;

  /// hoch, mittel oder niedrig.
  final String sicherheit;
  final List<String> merkmale;

  /// Ähnliche Arten mit kurzem Grund.
  final List<(String, String)> alternativen;
  final String hinweis;

  String get sicherheitText => switch (sicherheit) {
        'hoch' => 'sehr sicher',
        'mittel' => 'ziemlich sicher',
        _ => 'unsicher',
      };
}

class KiFehler implements Exception {
  const KiFehler(this.text, {this.anmelden = false});

  final String text;

  /// Ob eine Anmeldung das Problem löst.
  final bool anmelden;

  @override
  String toString() => text;
}

/// Bildformat anhand der ersten Bytes (die KI nimmt JPEG, PNG und WebP).
String? bildTyp(Uint8List b) {
  if (b.length > 3 && b[0] == 0xFF && b[1] == 0xD8) return 'image/jpeg';
  if (b.length > 8 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) {
    return 'image/png';
  }
  if (b.length > 12 &&
      String.fromCharCodes(b.sublist(0, 4)) == 'RIFF' &&
      String.fromCharCodes(b.sublist(8, 12)) == 'WEBP') {
    return 'image/webp';
  }
  return null;
}

/// Petri-KI: Chat mit dem KI-Angelguide und Foto-Bestimmung. Läuft über die
/// Cloud Function „petri“ (Claude) – der Schlüssel liegt nur am Server.
class PetriKi extends ChangeNotifier {
  PetriKi._();

  static final instanz = PetriKi._();

  static const adresse =
      'https://europe-west3-austro-angler-202495bd.cloudfunctions.net/petri';

  /// Nur für Tests und Store-Bilder: Antwort des Servers (Status, JSON).
  @visibleForTesting
  static Future<(int, Map<String, dynamic>)> Function(Map<String, dynamic>)?
      testServer;

  /// Ob Testantworten aktiv sind (dann ohne Anmeldung nutzbar).
  static bool get testModus => testServer != null;

  final List<KiNachricht> verlauf = [];
  String? _kontext;
  bool denkt = false;

  /// Restliche KI-Anfragen für heute (sobald der Server es gesagt hat).
  int? rest;

  void neuerChat() {
    verlauf.clear();
    _kontext = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> _senden(
      Konto? konto, Map<String, dynamic> body) async {
    final int status;
    Map<String, dynamic> d = const {};
    final test = testServer;
    if (test != null) {
      (status, d) = await test(body);
    } else {
      final nutzer = konto?.nutzer;
      if (nutzer == null) {
        throw const KiFehler('Melde dich an, um Petri zu fragen.',
            anmelden: true);
      }
      final http.Response r;
      try {
        final token = await nutzer.getIdToken();
        r = await http
            .post(
              Uri.parse(adresse),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 110));
      } catch (e) {
        debugPrint('Petri: $e');
        throw const KiFehler('Keine Verbindung – Petri braucht Internet.');
      }
      status = r.statusCode;
      try {
        d = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      } catch (_) {}
    }
    if (d['rest'] is int) rest = d['rest'] as int;
    switch (status) {
      case 200:
        return d;
      case 401:
        throw const KiFehler('Bitte melde dich neu an.', anmelden: true);
      case 429:
        rest = 0;
        throw const KiFehler(
            'Deine KI-Fragen für heute sind aufgebraucht – morgen geht’s weiter.');
      case 503:
        throw const KiFehler(
            'Petri ist gerade ausgelastet. Probier es gleich nochmal.');
      default:
        throw const KiFehler('Das hat nicht geklappt. Probier es nochmal.');
    }
  }

  /// Stellt Petri eine Frage. Frage und Antwort landen im [verlauf].
  /// [kontext] wird nur beim ersten Mal im Chat gebaut und bleibt dann gleich.
  Future<void> fragen(String frage,
      {required Konto? konto,
      required FutureOr<String> Function() kontext}) async {
    final f = frage.trim();
    if (f.isEmpty || denkt) return;
    verlauf.add((vonMir: true, text: f));
    denkt = true;
    notifyListeners();
    try {
      _kontext ??= await kontext();
      // Der Server nimmt bis zu 20 Nachrichten; die erste muss eine Frage sein.
      var schicken = verlauf.length > 19
          ? verlauf.sublist(verlauf.length - 19)
          : List.of(verlauf);
      if (!schicken.first.vonMir) schicken = schicken.sublist(1);
      final d = await _senden(konto, {
        'modus': 'chat',
        'kontext': _kontext,
        'verlauf': [
          for (final n in schicken)
            {'rolle': n.vonMir ? 'nutzer' : 'petri', 'text': n.text},
        ],
      });
      final antwort = (d['antwort'] as String?)?.trim() ?? '';
      verlauf.add((
        vonMir: false,
        text: antwort.isEmpty ? 'Hm, da fällt mir gerade nichts ein.' : antwort,
      ));
    } catch (e) {
      // Frage zurücknehmen, damit sie nochmal gestellt werden kann.
      verlauf.removeLast();
      if (e is KiFehler) rethrow;
      debugPrint('Petri: $e');
      throw const KiFehler('Das hat nicht geklappt. Probier es nochmal.');
    } finally {
      denkt = false;
      notifyListeners();
    }
  }

  /// Bestimmt die Fischart auf einem Foto.
  Future<FotoErgebnis> fotoBestimmen(Uint8List bild,
      {required Konto? konto}) async {
    final typ = bildTyp(bild);
    if (typ == null) {
      throw const KiFehler(
          'Dieses Bildformat geht leider nicht – nimm ein JPG oder PNG.');
    }
    try {
      final d = await _senden(
          konto, {'modus': 'foto', 'typ': typ, 'bild': base64Encode(bild)});
      return FotoErgebnis.ausJson(
          (d['ergebnis'] as Map?)?.cast<String, dynamic>() ?? const {});
    } on KiFehler {
      rethrow;
    } catch (e) {
      // Unerwartete Antwort – lieber ein klarer Hinweis als ein Absturz.
      debugPrint('Petri-Foto: $e');
      throw const KiFehler('Das hat nicht geklappt. Probier es nochmal.');
    } finally {
      notifyListeners();
    }
  }
}

final petriKi = PetriKi.instanz;

const _wochentage = [
  'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag',
  'Sonntag', //
];

/// Was Petri über den Tag, den Ort, die Regeln und das Fangbuch wissen soll.
/// Steht im Chat vor der ersten Frage.
String kiKontext({
  required DateTime jetzt,
  required Bundesland land,
  String heimat = '',
  List<String> lieblinge = const [],
  List<Fang> faenge = const [],
  String? wetter,
}) {
  String zwei(int z) => z.toString().padLeft(2, '0');
  String name(String id) => fischById(id)?.name.split(' (').first ?? id;
  final b = StringBuffer()
    ..writeln('Heute: ${_wochentage[jetzt.weekday - 1]}, ${jetzt.day}.'
        '${jetzt.month}.${jetzt.year}, ${zwei(jetzt.hour)}:${zwei(jetzt.minute)} Uhr')
    ..writeln('Bundesland: ${land.name}');
  if (heimat.isNotEmpty) b.writeln('Heimatort: $heimat');
  if (lieblinge.isNotEmpty) {
    b.writeln('Lieblingsfische: ${lieblinge.map(name).join(', ')}');
  }
  if (wetter != null && wetter.isNotEmpty) b.writeln('Wetter: $wetter');

  if (faenge.isNotEmpty) {
    Map<String, int> zaehlen(Iterable<String> werte) {
      final m = <String, int>{};
      for (final w in werte) {
        if (w.trim().isNotEmpty) m[w.trim()] = (m[w.trim()] ?? 0) + 1;
      }
      return m;
    }

    String top(Map<String, int> m) => (m.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(3)
        .map((e) => '${e.key} (${e.value})')
        .join(', ');
    b
      ..writeln('Fangbuch: ${faenge.length} Fänge')
      ..writeln('  Häufigste Arten: ${top(zaehlen(faenge.map((f) => name(f.fischId))))}');
    final koeder = zaehlen(faenge.map((f) => f.koeder));
    if (koeder.isNotEmpty) b.writeln('  Beste Köder: ${top(koeder)}');
    if (faenge.length >= 3) {
      b.writeln('  Fangmuster je Art:');
      final nachArt = <String, List<Fang>>{};
      for (final f in faenge) {
        (nachArt[f.fischId] ??= []).add(f);
      }
      final arten = nachArt.entries.toList()
        ..sort((a, b) => b.value.length.compareTo(a.value.length));
      const monate = ['Jän', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug',
          'Sep', 'Okt', 'Nov', 'Dez'];
      for (final e in arten.take(6)) {
        final l = e.value;
        final laengen = [for (final f in l) if (f.laengeCm != null) f.laengeCm!];
        final stunden = zaehlen(l.map((f) => switch (f.datum.hour) {
              < 5 => 'Nacht',
              < 9 => 'früh (5–9)',
              < 12 => 'Vormittag',
              < 15 => 'Mittag',
              < 18 => 'Nachmittag',
              < 22 => 'Abend (18–22)',
              _ => 'Nacht',
            }));
        final teile = [
          '${l.length} Fänge',
          if (laengen.isNotEmpty)
            'Ø ${(laengen.reduce((a, b) => a + b) / laengen.length).round()} cm, '
                'max ${laengen.reduce((a, b) => a > b ? a : b).round()} cm',
          'meist ${(stunden.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key}',
          'Monate: ${top(zaehlen(l.map((f) => monate[f.datum.month - 1])))}',
          if (zaehlen(l.map((f) => f.koeder)).isNotEmpty)
            'Köder: ${top(zaehlen(l.map((f) => f.koeder)))}',
          if (zaehlen(l.map((f) => f.gewaesser)).isNotEmpty)
            'Gewässer: ${top(zaehlen(l.map((f) => f.gewaesser)))}',
        ];
        b.writeln('  - ${name(e.key)}: ${teile.join('; ')}');
      }
    }
    b.writeln('  Letzte Fänge:');
    final neueste = List.of(faenge)..sort((a, b) => b.datum.compareTo(a.datum));
    for (final f in neueste.take(3)) {
      b.writeln('  - ${f.datum.day}.${f.datum.month}.${f.datum.year}: '
          '${name(f.fischId)}'
          '${f.laengeCm == null ? '' : ' ${f.laengeCm!.round()} cm'}'
          '${f.gewaesser.isEmpty ? '' : ', ${f.gewaesser}'}'
          '${f.koeder.isEmpty ? '' : ', Köder: ${f.koeder}'}');
    }
  }

  b
    ..writeln()
    ..writeln('Regeln ${land.name} laut App (Art: heute · Schonzeit · '
        'Brittelmaß · Hinweis):');
  for (final f in fische) {
    if (f.ausgestorben) continue;
    final r = f.regel(land);
    final heute = f.geschuetzt
        ? 'geschützt'
        : r.ganzjaehrigGeschont
            ? 'ganzjährig geschont'
            : switch (r.istGeschont(jetzt)) {
                true => 'geschont',
                false => 'offen',
                null => 'unbekannt',
              };
    var hinweis = r.hinweis ?? '';
    if (hinweis.length > 140) hinweis = '${hinweis.substring(0, 137)}…';
    b.writeln('${f.name}: $heute · ${r.schonzeitText} · ${r.mindestmassText}'
        '${hinweis.isEmpty ? '' : ' · $hinweis'}');
  }
  return b.toString().trim();
}

/// Wetter und Beißindex heute am [ort] als kurzer Text für Petri – oder null.
Future<String?> kiWetter(LatLng ort, {DateTime? jetzt}) async {
  try {
    final j = jetzt ?? DateTime.now();
    final stunden =
        await stundenWetter(ort).timeout(const Duration(seconds: 6));
    final sonne = sonnenZeiten(j, ort.latitude, ort.longitude);
    final index = beissindex(stunden, j,
        aufgang: sonne.aufgang, untergang: sonne.untergang);
    Stunde? bei(DateTime t) {
      for (final s in stunden) {
        if (s.zeit.year == t.year &&
            s.zeit.month == t.month &&
            s.zeit.day == t.day &&
            s.zeit.hour == t.hour) {
          return s;
        }
      }
      return null;
    }

    String uhr(DateTime t) =>
        '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
    final jetztS = bei(j);
    final vorher = bei(j.subtract(const Duration(hours: 3)));
    final teile = <String>[
      if (index != null)
        'Beißindex heute ${index.wert}/100 (${index.wort}), beste Zeiten '
            '${index.fensterText} Uhr',
      if (jetztS != null)
        'jetzt ${jetztS.temp.round()} °C, Luftdruck ${jetztS.druck.round()} hPa'
            '${vorher == null ? '' : switch (jetztS.druck - vorher.druck) {
                < -1 => ' (fallend)',
                > 1 => ' (steigend)',
                _ => ' (stabil)',
              }}, Wind ${jetztS.wind.round()} km/h, Wolken ${jetztS.wolken.round()} %',
      if (sonne.aufgang != null && sonne.untergang != null)
        'Sonnenaufgang ${uhr(sonne.aufgang!)}, Sonnenuntergang '
            '${uhr(sonne.untergang!)}',
    ];
    return teile.join('; ');
  } catch (e) {
    debugPrint('Petri-Wetter: $e');
    return null;
  }
}
