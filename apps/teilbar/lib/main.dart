import 'package:app_basis/app_basis.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'daten/datenbank.dart';
import 'dienste.dart';
import 'firebase_options.dart';
import 'sync/firestore_speicher.dart';
import 'sync/sync_motor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('de');
  db = AppDatenbank.oeffnen();
  await designModus.laden();
  await profil.laden();
  await BewertungsBitte.appGestartet();
  kauf.starten();
  void werbungAnpassen() =>
      werbung.aus = kauf.gekauft || kauf.besitzt('werbefrei');
  kauf.addListener(werbungAnpassen);
  werbungAnpassen();

  if (firebaseKonfiguriert) {
    try {
      await Firebase.initializeApp(options: firebaseOptionen);
      sync = SyncMotor(db, FirestoreSpeicher());
      // Nicht warten: ohne Internet startet die App trotzdem sofort.
      sync!.starten().catchError((Object e) => debugPrint('Sync: $e'));
    } catch (e) {
      debugPrint('Firebase nicht gestartet: $e');
    }
  }

  runApp(const TeilbarApp());
  werbung.starten();
}
