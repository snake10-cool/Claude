import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/lehrplan.dart';

/// Speichert Klasse, Sterne pro Thema und die Lern-Serie lokal.
class Fortschritt extends ChangeNotifier {
  Fortschritt(this._prefs);

  static Future<Fortschritt> laden() async =>
      Fortschritt(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  Stufe? get stufe {
    final name = _prefs.getString('stufe');
    for (final s in Stufe.values) {
      if (s.name == name) return s;
    }
    return null;
  }

  Future<void> stufeSetzen(Stufe s) async {
    await _prefs.setString('stufe', s.name);
    notifyListeners();
  }

  /// 0–3 Sterne für das beste Ergebnis in einem Thema.
  int sterne(String themaId) => _prefs.getInt('sterne_$themaId') ?? 0;

  static int sterneFuer(int richtig, int gesamt) {
    final anteil = richtig / gesamt;
    if (anteil >= 0.9) return 3;
    if (anteil >= 0.7) return 2;
    if (anteil >= 0.5) return 1;
    return 0;
  }

  /// Tage in Folge, an denen gelernt wurde.
  int get serie {
    final letzter = _prefs.getString('letzterTag');
    if (letzter == null) return 0;
    final abstand = _heute().difference(DateTime.parse(letzter)).inDays;
    return abstand <= 1 ? _prefs.getInt('serie') ?? 0 : 0;
  }

  Future<void> rundeBeendet(String themaId, int richtig, int gesamt) async {
    final neu = sterneFuer(richtig, gesamt);
    if (neu > sterne(themaId)) await _prefs.setInt('sterne_$themaId', neu);

    final heute = _heute();
    final letzter = _prefs.getString('letzterTag');
    if (letzter == null ||
        heute.difference(DateTime.parse(letzter)).inDays > 1) {
      await _prefs.setInt('serie', 1);
    } else if (heute.difference(DateTime.parse(letzter)).inDays == 1) {
      await _prefs.setInt('serie', (_prefs.getInt('serie') ?? 0) + 1);
    }
    await _prefs.setString('letzterTag', heute.toIso8601String());
    notifyListeners();
  }

  DateTime _heute() {
    final n = DateTime.now();
    return DateTime.utc(n.year, n.month, n.day);
  }
}
