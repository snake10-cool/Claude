import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/katalog.dart';
import '../models/buch.dart';
import 'empfehlung.dart';

/// Ein Mitspieler in der Rangliste, eingelesen über seinen Punkte-Code.
class Freund {
  const Freund(this.name, this.punkte, this.bewiesen, this.datum);

  final String name;
  final int punkte;

  /// Bücher, deren Quiz bestanden wurde.
  final int bewiesen;
  final DateTime datum;

  Map<String, dynamic> toJson() =>
      {'n': name, 'p': punkte, 'b': bewiesen, 'd': datum.toIso8601String()};

  factory Freund.ausJson(Map<String, dynamic> j) => Freund(
        j['n'] as String,
        j['p'] as int,
        j['b'] as int,
        DateTime.tryParse(j['d'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Alles, was die App lokal speichert.
class Speicher extends ChangeNotifier {
  Speicher(this._prefs) {
    name = _prefs.getString('name') ?? '';
    einrichtungFertig = _prefs.getBool('einrichtungFertig') ?? false;
    ehrenwort = _prefs.getBool('ehrenwort') ?? false;
    antworten = {
      for (final MapEntry(:key, :value) in _json('antworten', {}).entries)
        key: List<String>.from(value as List),
    };
    eintraege = {
      for (final MapEntry(:key, :value) in _json('eintraege', {}).entries)
        key: Eintrag.ausJson(value as Map<String, dynamic>),
    };
    eigeneBuecher = [
      for (final j in _json('eigeneBuecher', []) as List)
        Buch.eigenesAusJson(j as Map<String, dynamic>),
    ];
    quiz = {
      for (final MapEntry(:key, :value) in _json('quiz', {}).entries)
        key: QuizErgebnis.ausJson(value as Map<String, dynamic>),
    };
    freunde = [
      for (final j in _json('freunde', []) as List)
        Freund.ausJson(j as Map<String, dynamic>),
    ];
    vorlieben = {
      for (final MapEntry(:key, :value) in _json('vorlieben', {}).entries)
        key: (value as num).toDouble(),
    };
    geprueft = {...(_json('geprueft', []) as List).cast<String>()};
    pausierteQuizze = {
      for (final MapEntry(:key, :value) in _json('pausierteQuizze', {}).entries)
        key: value as Map<String, dynamic>,
    };
  }

  static Future<Speicher> laden() async =>
      Speicher(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  late String name;
  late bool einrichtungFertig;
  late bool ehrenwort;
  late Map<String, List<String>> antworten;
  late Map<String, Eintrag> eintraege;
  late List<Buch> eigeneBuecher;
  late Map<String, QuizErgebnis> quiz;
  late List<Freund> freunde;

  /// Aus „Bücher gegeneinander": Merkmal → -1 (mag ich nicht) … +1.
  late Map<String, double> vorlieben;

  /// Beim Abhaken als „nicht gelesen" markierte Bücher (werden nicht mehr gefragt).
  late Set<String> geprueft;

  /// Angefangene Quizze zum Weitermachen: Buch-ID → Zustand.
  late Map<String, Map<String, dynamic>> pausierteQuizze;

  // ───────── Fortschritt speichern ─────────

  /// Angefangener Fragebogen (Antworten + aktuelle Frage) oder null.
  (Map<String, List<String>>, int)? get fragebogenEntwurf {
    final j = _json('fragebogenEntwurf', {}) as Map;
    if (j.isEmpty) return null;
    return (
      {
        for (final MapEntry(:key, :value) in (j['antworten'] as Map).entries)
          key as String: List<String>.from(value as List),
      },
      j['index'] as int,
    );
  }

  Future<void> fragebogenEntwurfSpeichern(Map<String, List<String>> antworten, int index) =>
      _prefs.setString('fragebogenEntwurf', jsonEncode({'antworten': antworten, 'index': index}));

  Future<void> fragebogenEntwurfLoeschen() => _prefs.remove('fragebogenEntwurf');

  Future<void> quizPausieren(String buchId, Map<String, dynamic> zustand) {
    pausierteQuizze[buchId] = zustand;
    return _speichern('pausierteQuizze', pausierteQuizze);
  }

  Future<void> quizFortsetzungLoeschen(String buchId) {
    pausierteQuizze.remove(buchId);
    return _speichern('pausierteQuizze', pausierteQuizze);
  }

  // ───────── Leseziel, Lese-Tage ─────────

  /// Bücher pro Jahr, 0 = kein Ziel.
  int get jahresziel => _prefs.getInt('jahresziel') ?? 0;

  Future<void> jahreszielSetzen(int ziel) async {
    await _prefs.setInt('jahresziel', ziel);
    notifyListeners();
  }

  int gelesenImJahr(int jahr) =>
      eintraege.values.where((e) => e.status == Status.gelesen && e.datum.year == jahr).length;

  /// Tage (yyyy-mm-dd), an denen gelesen wurde – für die Lese-Serie.
  Set<String> get leseTage => {...(_json('leseTage', []) as List).cast<String>()};

  static String tagSchluessel(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Wird nach jedem neuen Lese-Tag aufgerufen (plant die Erinnerung neu).
  VoidCallback? nachLeseTag;

  Future<void> leseTagMerken([DateTime? tag]) async {
    final schluessel = tagSchluessel(tag ?? DateTime.now());
    final tage = leseTage;
    if (tage.contains(schluessel)) return;
    await _speichern('leseTage', (tage..add(schluessel)).toList()..sort());
    nachLeseTag?.call();
  }

  /// Lese-Minuten pro Buch (Lese-Timer).
  int leseMinuten(String buchId) => _prefs.getInt('minuten_$buchId') ?? 0;
  int get leseMinutenGesamt =>
      _prefs.getKeys().where((k) => k.startsWith('minuten_')).fold(0, (s, k) => s + (_prefs.getInt(k) ?? 0));

  Future<void> leseZeitHinzufuegen(String buchId, int minuten) async {
    if (minuten <= 0) return;
    await _prefs.setInt('minuten_$buchId', leseMinuten(buchId) + minuten);
    await leseTagMerken();
    notifyListeners();
  }

  bool get heuteGelesen => leseTage.contains(tagSchluessel(DateTime.now()));

  /// Seite setzen (beim Lesen); zählt auch als Lese-Tag.
  Future<void> seiteSetzen(String buchId, int seite) async {
    final e = eintraege[buchId];
    if (e == null) return;
    e.seite = seite;
    await _prefs.setString('eintraege', jsonEncode(eintraege));
    await leseTagMerken();
  }

  // ───────── Abhaken ─────────

  bool get sterneBeimAbhaken => _prefs.getBool('sterneBeimAbhaken') ?? false;

  Future<void> sterneBeimAbhakenSetzen(bool an) async {
    await _prefs.setBool('sterneBeimAbhaken', an);
    notifyListeners();
  }

  /// Ja: als gelesen eintragen. Nein: merken, damit es nicht wieder kommt.
  Future<void> abhaken(String buchId, bool gelesen) async {
    if (gelesen) {
      geprueft.remove(buchId);
      if (eintraege[buchId]?.status != Status.gelesen) {
        eintraege[buchId] = Eintrag(
          status: Status.gelesen,
          sterne: eintraege[buchId]?.sterne ?? 0,
          format: lieblingsFormat == 1 ? Format.gehoert : Format.gelesen,
        );
      }
      await _prefs.setString('geprueft', jsonEncode(geprueft.toList()));
      await _speichern('eintraege', eintraege);
    } else {
      geprueft.add(buchId);
      if (eintraege[buchId]?.status == Status.gelesen) eintraege.remove(buchId);
      await _prefs.setString('eintraege', jsonEncode(eintraege));
      await _speichern('geprueft', geprueft.toList());
    }
  }

  /// Schon beantwortet (gelesen, abgebrochen, „nicht gelesen")?
  bool abgehakt(String buchId) =>
      geprueft.contains(buchId) ||
      const {Status.gelesen, Status.abgebrochen}.contains(eintraege[buchId]?.status);

  dynamic _json(String key, Object leer) {
    final text = _prefs.getString(key);
    if (text == null) return leer;
    try {
      return jsonDecode(text);
    } catch (_) {
      return leer;
    }
  }

  Future<void> _speichern(String key, Object wert) async {
    await _prefs.setString(key, jsonEncode(wert));
    notifyListeners();
  }

  // ───────── Bücher ─────────

  List<Buch> get alleBuecher => [...katalog, ...eigeneBuecher];

  Buch? buch(String id) {
    final k = katalogBuch(id);
    if (k != null) return k;
    for (final b in eigeneBuecher) {
      if (b.id == id) return b;
    }
    return null;
  }

  Future<void> eintragSetzen(String buchId, Eintrag e) {
    eintraege[buchId] = e;
    return _speichern('eintraege', eintraege);
  }

  Future<void> eintragEntfernen(String buchId) {
    eintraege.remove(buchId);
    return _speichern('eintraege', eintraege);
  }

  Future<Buch> eigenesBuchAnlegen(
    String titel,
    String autor,
    int seiten, {
    int jahr = 0,
    Set<String> tags = const {},
    Zielgruppe zielgruppe = Zielgruppe.erwachsene,
    String beschreibung = 'Selbst hinzugefügt.',
    String? coverUrl,
    String? isbn,
  }) async {
    final buch = Buch(
      id: 'eigen_${DateTime.now().microsecondsSinceEpoch}',
      titel: titel,
      autor: autor,
      jahr: jahr,
      seiten: seiten,
      zielgruppe: zielgruppe,
      tags: tags,
      beschreibung: beschreibung,
      eigenes: true,
      coverUrl: coverUrl,
      isbn: isbn,
    );
    eigeneBuecher.add(buch);
    await _speichern('eigeneBuecher', [for (final b in eigeneBuecher) b.toJson()]);
    return buch;
  }

  // ───────── Profil ─────────

  Future<void> nameSetzen(String neu) async {
    name = neu.trim();
    await _prefs.setString('name', name);
    notifyListeners();
  }

  Future<void> antwortenSetzen(Map<String, List<String>> neu) {
    antworten = neu;
    return _speichern('antworten', antworten);
  }

  Future<void> einrichtungAbschliessen() async {
    einrichtungFertig = true;
    await _prefs.setBool('einrichtungFertig', true);
    notifyListeners();
  }

  Future<void> ehrenwortGeben() async {
    ehrenwort = true;
    await _prefs.setBool('ehrenwort', true);
    notifyListeners();
  }

  List<Empfehlung> get empfehlungen => empfehlen(
        antworten: antworten,
        eintraege: eintraege,
        buecher: alleBuecher,
        vorlieben: vorlieben,
      );

  /// Ergebnis von „Bücher gegeneinander" übernehmen: Vorlieben fließen
  /// (gemittelt mit früheren Vergleichen) ins Leseprofil, unbewertete Bücher
  /// bekommen Sterne aus der Gesamtbewertung.
  Future<void> vergleichUebernehmen(Map<String, double> neu, Map<String, int> sterne) async {
    neu.forEach((tag, wert) {
      final alt = vorlieben[tag];
      vorlieben[tag] = alt == null ? wert : (alt + wert) / 2;
    });
    sterne.forEach((id, s) {
      final e = eintraege[id];
      if (e != null && e.sterne == 0) e.sterne = s;
    });
    await _prefs.setInt('vergleiche', (_prefs.getInt('vergleiche') ?? 0) + 1);
    await _prefs.setString('eintraege', jsonEncode(eintraege));
    await _speichern('vorlieben', vorlieben);
  }

  int get vergleiche => _prefs.getInt('vergleiche') ?? 0;

  /// 0 = Lesen, 1 = Hören, 2 = beides.
  int get lieblingsFormat => antwortWert(antworten, 'format') ?? 0;

  // ───────── Quiz & Wettbewerb ─────────

  int get punkte => quiz.values.fold(0, (s, q) => s + q.punkte);
  int get gelesen => eintraege.values.where((e) => e.status == Status.gelesen).length;
  int get bewiesen => quiz.values.where((q) => q.bestanden).length;

  /// Speichert nur den ersten Versuch. Bestanden heißt: Das Buch kommt als
  /// gelesen in die Bibliothek, falls es noch nicht drin ist.
  Future<bool> quizBeendet(String buchId, QuizErgebnis ergebnis) async {
    if (quiz.containsKey(buchId)) return false;
    quiz[buchId] = ergebnis;
    await leseTagMerken();
    if (ergebnis.bestanden && eintraege[buchId]?.status != Status.gelesen) {
      final alt = eintraege[buchId];
      eintraege[buchId] = Eintrag(
        status: Status.gelesen,
        sterne: alt?.sterne ?? 0,
        format: alt?.format ?? Format.gelesen,
        notiz: alt?.notiz ?? '',
      );
      await _prefs.setString('eintraege', jsonEncode(eintraege));
    }
    await _speichern('quiz', quiz);
    return true;
  }

  static const _codePrefix = 'BW1-';

  /// Code zum Teilen mit Freunden, z. B. per WhatsApp.
  String get meinCode => _codePrefix +
      base64Url.encode(utf8.encode(jsonEncode(
          Freund(name, punkte, bewiesen, DateTime.now()).toJson())));

  /// Liest den Code eines Freundes ein. Ein neuerer Code mit gleichem Namen
  /// ersetzt den alten. Gibt bei ungültigem Code null zurück.
  Future<Freund?> codeEinlesen(String code) async {
    final rein = code.trim();
    final start = rein.indexOf(_codePrefix);
    if (start < 0) return null;
    Freund freund;
    try {
      final daten = rein.substring(start + _codePrefix.length).split(RegExp(r'\s')).first;
      freund = Freund.ausJson(
          jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(daten)))) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
    if (freund.name.isEmpty) return null;
    freunde.removeWhere((f) => f.name == freund.name);
    freunde.add(freund);
    await _speichern('freunde', freunde);
    return freund;
  }

  Future<void> freundEntfernen(String freundName) {
    freunde.removeWhere((f) => f.name == freundName);
    return _speichern('freunde', freunde);
  }

  Future<void> allesLoeschen() async {
    await _prefs.clear();
    name = '';
    einrichtungFertig = false;
    ehrenwort = false;
    antworten = {};
    eintraege = {};
    eigeneBuecher = [];
    quiz = {};
    freunde = [];
    vorlieben = {};
    geprueft = {};
    pausierteQuizze = {};
    notifyListeners();
  }
}
