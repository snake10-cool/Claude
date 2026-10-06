import 'package:app_basis/app_basis.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'daten/datenbank.dart';
import 'dienste.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('de');
  db = AppDatenbank.oeffnen();
  await designModus.laden();
  await BewertungsBitte.appGestartet();
  // Käufe im Hintergrund prüfen, damit der Start nicht wartet.
  kauf.starten();
  runApp(const DruckkasseApp());
}
