import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase-Zugangsdaten für Teilbar. Sie stehen in der Firebase-Konsole
/// unter Projekteinstellungen → Allgemein → Meine Apps. Sie sind nicht
/// geheim – den Schutz übernehmen die Sicherheitsregeln in
/// `firestore.rules`.
///
/// Solange die Werte leer sind, läuft die App ohne Online-Gruppen
/// (alles andere funktioniert). Anleitung: docs/firebase.md
const _android = FirebaseOptions(
  apiKey: '',
  appId: '',
  messagingSenderId: '',
  projectId: '',
);

/// Windows nutzt die Daten einer Web-App des Projekts.
const _windows = FirebaseOptions(
  apiKey: '',
  appId: '',
  messagingSenderId: '',
  projectId: '',
  authDomain: '',
);

FirebaseOptions get firebaseOptionen =>
    defaultTargetPlatform == TargetPlatform.windows ? _windows : _android;

bool get firebaseKonfiguriert => firebaseOptionen.apiKey.isNotEmpty;
