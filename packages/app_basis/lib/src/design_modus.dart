import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Hell, Dunkel oder wie das System. Die Wahl wird gespeichert.
class DesignModus extends ChangeNotifier {
  static const _schluessel = 'design_modus';

  ThemeMode _modus = ThemeMode.system;
  ThemeMode get modus => _modus;

  Future<void> laden() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_schluessel);
    _modus = ThemeMode.values.firstWhere(
      (m) => m.name == name,
      orElse: () => ThemeMode.system,
    );
    notifyListeners();
  }

  Future<void> setzen(ThemeMode modus) async {
    _modus = modus;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_schluessel, modus.name);
  }
}
