import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bundesland.dart';
import '../models/fang.dart';

/// Speichert alle Daten lokal auf dem Handy.
class Speicher extends ChangeNotifier {
  Speicher(this._prefs) {
    _laden();
  }

  static Future<Speicher> oeffnen() async =>
      Speicher(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  final List<Fang> faenge = [];
  final List<Spot> spots = [];
  Bundesland bundesland = Bundesland.ooe;
  int besteQuizPunkte = 0;

  /// Filter im Gewässer-Tab ('' = alle).
  String bezirk = 'Braunau';
  String gemeinde = '';

  /// Selbst gewählter Heimatort (kein GPS): "Land|Bezirk|Gemeinde".
  String heimat = '';
  double? heimatLat;
  double? heimatLon;

  /// Einfachere Texte und Erklärungen für Kinder und Anfänger.
  bool jungangler = false;

  /// Fische für den Schonzeit-Countdown.
  List<String> lieblingsfische = const ['hecht', 'zander', 'bachforelle',
    'karpfen'];

  /// Erledigte Wochen-Challenges, z. B. "2026-40".
  List<String> erledigteChallenges = const [];

  String get heimatName => heimat.isEmpty ? '' : heimat.split('|').last;

  void _laden() {
    faenge.addAll(_liste('faenge').map(Fang.fromJson));
    faenge.sort((a, b) => b.datum.compareTo(a.datum));
    spots.addAll(_liste('spots').map(Spot.fromJson));
    bundesland =
        Bundesland.ausName(_prefs.getString('bundesland')) ?? Bundesland.ooe;
    besteQuizPunkte = _prefs.getInt('besteQuizPunkte') ?? 0;
    bezirk = _prefs.getString('bezirk') ??
        (bundesland == Bundesland.ooe ? 'Braunau' : '');
    gemeinde = _prefs.getString('gemeinde') ?? '';
    heimat = _prefs.getString('heimat') ?? '';
    heimatLat = _prefs.getDouble('heimatLat');
    heimatLon = _prefs.getDouble('heimatLon');
    jungangler = _prefs.getBool('jungangler') ?? false;
    lieblingsfische =
        _prefs.getStringList('lieblingsfische') ?? lieblingsfische;
    erledigteChallenges = _prefs.getStringList('challenges') ?? const [];
  }

  Future<void> heimatSetzen(String wert, double lat, double lon) async {
    heimat = wert;
    heimatLat = lat;
    heimatLon = lon;
    notifyListeners();
    await _prefs.setString('heimat', wert);
    await _prefs.setDouble('heimatLat', lat);
    await _prefs.setDouble('heimatLon', lon);
  }

  Future<void> heimatLoeschen() async {
    heimat = '';
    heimatLat = null;
    heimatLon = null;
    notifyListeners();
    await _prefs.remove('heimat');
    await _prefs.remove('heimatLat');
    await _prefs.remove('heimatLon');
  }

  Future<void> junganglerSetzen(bool an) async {
    jungangler = an;
    notifyListeners();
    await _prefs.setBool('jungangler', an);
  }

  Future<void> lieblingsfischUmschalten(String id) async {
    final neu = [...lieblingsfische];
    neu.contains(id) ? neu.remove(id) : neu.add(id);
    lieblingsfische = neu;
    notifyListeners();
    await _prefs.setStringList('lieblingsfische', neu);
  }

  Future<void> challengeErledigt(String schluessel) async {
    if (erledigteChallenges.contains(schluessel)) return;
    erledigteChallenges = [...erledigteChallenges, schluessel];
    notifyListeners();
    await _prefs.setStringList('challenges', erledigteChallenges);
  }

  List<Map<String, dynamic>> _liste(String key) {
    final roh = _prefs.getString(key);
    if (roh == null) return [];
    return (jsonDecode(roh) as List).cast<Map<String, dynamic>>();
  }

  Future<void> _speichern(String key, List<dynamic> items) => _prefs.setString(
        key,
        jsonEncode(items.map((e) => e.toJson()).toList()),
      );

  String neueId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> fangSpeichern(Fang fang) async {
    faenge.removeWhere((f) => f.id == fang.id);
    faenge.add(fang);
    faenge.sort((a, b) => b.datum.compareTo(a.datum));
    notifyListeners();
    await _speichern('faenge', faenge);
  }

  Future<void> fangLoeschen(String id) async {
    faenge.removeWhere((f) => f.id == id);
    notifyListeners();
    await _speichern('faenge', faenge);
  }

  /// Nach dem Hochladen ins Konto.
  Future<void> lokaleFaengeLeeren() async {
    faenge.clear();
    notifyListeners();
    await _prefs.remove('faenge');
  }

  Future<void> spotSpeichern(Spot spot) async {
    spots.add(spot);
    notifyListeners();
    await _speichern('spots', spots);
  }

  Future<void> spotLoeschen(String id) async {
    spots.removeWhere((s) => s.id == id);
    notifyListeners();
    await _speichern('spots', spots);
  }

  Future<void> bundeslandSetzen(Bundesland land) async {
    if (land != bundesland) {
      bezirk = '';
      gemeinde = '';
      await _prefs.setString('bezirk', '');
      await _prefs.setString('gemeinde', '');
    }
    bundesland = land;
    notifyListeners();
    await _prefs.setString('bundesland', land.name);
  }

  Future<void> ortSetzen({required String bezirk, String gemeinde = ''}) async {
    this.bezirk = bezirk;
    this.gemeinde = gemeinde;
    notifyListeners();
    await _prefs.setString('bezirk', bezirk);
    await _prefs.setString('gemeinde', gemeinde);
  }

  Future<void> quizErgebnis(int punkte) async {
    if (punkte <= besteQuizPunkte) return;
    besteQuizPunkte = punkte;
    notifyListeners();
    await _prefs.setInt('besteQuizPunkte', punkte);
  }
}
