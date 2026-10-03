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

  void _laden() {
    faenge.addAll(_liste('faenge').map(Fang.fromJson));
    faenge.sort((a, b) => b.datum.compareTo(a.datum));
    spots.addAll(_liste('spots').map(Spot.fromJson));
    final land = _prefs.getString('bundesland');
    bundesland = Bundesland.values.firstWhere(
      (b) => b.name == land,
      orElse: () => Bundesland.ooe,
    );
    besteQuizPunkte = _prefs.getInt('besteQuizPunkte') ?? 0;
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
    bundesland = land;
    notifyListeners();
    await _prefs.setString('bundesland', land.name);
  }

  Future<void> quizErgebnis(int punkte) async {
    if (punkte <= besteQuizPunkte) return;
    besteQuizPunkte = punkte;
    notifyListeners();
    await _prefs.setInt('besteQuizPunkte', punkte);
  }
}
