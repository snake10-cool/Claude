import 'package:firebase_core/firebase_core.dart';

/// Firebase-Zugangsdaten der Android-App.
///
/// Diese Werte stehen in der Firebase-Konsole unter
/// Projekteinstellungen → Allgemein → Meine Apps → Android-App
/// (oder in der Datei google-services.json). Sie sind nicht geheim –
/// den Schutz übernehmen die Sicherheitsregeln in `firestore.rules`.
///
/// Solange die Werte leer sind, läuft die App ohne Online-Funktionen.
const firebaseOptionen = FirebaseOptions(
  apiKey: '',
  appId: '',
  messagingSenderId: '',
  projectId: '',
);

bool get firebaseKonfiguriert => firebaseOptionen.apiKey.isNotEmpty;
