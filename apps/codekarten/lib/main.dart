import 'dart:convert';

import 'package:app_basis/app_basis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'daten/datenbank.dart';
import 'dienste.dart';

/// Eingebaute Stapel in der Reihenfolge der Anzeige.
const eingebauteStapel = [
  'java_grundlagen',
  'java_profi',
  'python_grundlagen',
  'dart_grundlagen',
  'javascript_grundlagen',
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('de');
  db = AppDatenbank.oeffnen();
  await designModus.laden();
  await lernen.laden();
  await BewertungsBitte.appGestartet();
  await stapelAktualisieren();
  kauf.starten();
  // Werbung nur, wenn nichts gekauft wurde.
  void werbungAnpassen() => werbung.aus = kauf.gekauft;
  kauf.addListener(werbungAnpassen);
  werbungAnpassen();
  runApp(const CodekartenApp());
  werbung.starten();
}

/// Spielt die Stapel aus den Assets ein (neue Karten kommen bei Updates
/// automatisch dazu, der Lernstand bleibt).
Future<void> stapelAktualisieren() async {
  for (final (i, id) in eingebauteStapel.indexed) {
    final text = await rootBundle.loadString('assets/stapel/$id.json');
    await db.stapelEinspielen(jsonDecode(text) as Map<String, dynamic>, i);
  }
}
