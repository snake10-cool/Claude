import 'package:firebase_core/firebase_core.dart';

/// Firebase-Zugangsdaten für die Online-Rangliste. Sie stehen in der
/// Firebase-Konsole unter Projekteinstellungen → Allgemein → Meine Apps
/// (Android-App `com.snake10.buecherwurm`). Sie sind nicht geheim – den
/// Schutz übernehmen die Sicherheitsregeln in `firestore.rules`.
/// Anleitung: `docs/firebase.md`.
///
/// Solange die Werte leer sind, läuft die App ohne Konto; die Rangliste
/// funktioniert dann nur über Punkte-Codes.
const firebaseOptionen = FirebaseOptions(
  apiKey: '',
  appId: '',
  messagingSenderId: '',
  projectId: '',
);

bool get firebaseKonfiguriert =>
    firebaseOptionen.apiKey.isNotEmpty && firebaseOptionen.appId.isNotEmpty;
