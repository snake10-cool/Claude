import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase-Zugangsdaten. Sie stehen in der Firebase-Konsole unter
/// Projekteinstellungen → Allgemein → Meine Apps. Sie sind nicht geheim –
/// den Schutz übernehmen die Sicherheitsregeln in `firestore.rules`.
///
/// Solange die Werte leer sind, läuft die App ohne Online-Funktionen.
const _android = FirebaseOptions(
  apiKey: 'AIzaSyCM_Y2UqxFRnLdBVpDJAzCUoTZltZyOJik',
  appId: '1:914404478547:android:dfa419e8f4fbe931ac00a6',
  messagingSenderId: '914404478547',
  projectId: 'austro-angler-202495bd',
);

/// Windows nutzt die Daten der Web-App des Projekts.
const _windows = FirebaseOptions(
  apiKey: 'AIzaSyBLmDOQ0D88kWLveUr7SCh9SmGghMvcQxs',
  appId: '1:914404478547:web:acc309690683c05fac00a6',
  messagingSenderId: '914404478547',
  projectId: 'austro-angler-202495bd',
  authDomain: 'austro-angler-202495bd.firebaseapp.com',
);

FirebaseOptions get firebaseOptionen =>
    defaultTargetPlatform == TargetPlatform.windows ? _windows : _android;

bool get firebaseKonfiguriert => firebaseOptionen.apiKey.isNotEmpty;
