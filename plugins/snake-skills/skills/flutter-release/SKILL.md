---
name: flutter-release
description: Macht eine Flutter-Android-App fertig für Google Play (Version, Signatur, App Bundle, Store-Texte). Verwenden bei Release, Veröffentlichung, Play Store oder AAB.
---

# Flutter-Release für Google Play

Gehe diese Liste durch und hake jeden Punkt ab. Was nicht geprüft werden kann, als offen melden.

1. **Version** in `pubspec.yaml` erhöhen (`version: 1.2.0+12`, die Zahl nach dem `+` muss bei jedem Upload größer werden).
2. **App-ID** (`applicationId` in `android/app/build.gradle(.kts)`) ist eindeutig und ändert sich nie wieder.
3. **Signatur:** Upload-Keystore und `key.properties` existieren und stehen in `.gitignore`. Niemals Passwörter oder Keystores committen oder ausgeben.
4. **Berechtigungen** im `AndroidManifest.xml` auf das Nötige beschränken.
5. **Analyse und Tests:** `flutter analyze` und `flutter test` laufen ohne Fehler.
6. **Bauen:** `flutter build appbundle --release`. Die Datei liegt unter `build/app/outputs/bundle/release/app-release.aab`.
7. **Store-Eintrag:** Kurzbeschreibung (max. 80 Zeichen), lange Beschreibung, Screenshots, Icon 512×512, Feature-Grafik 1024×500, Datenschutzerklärung (URL), Fragebogen zur Datensicherheit.
8. **Test-Track:** Erst intern oder geschlossen testen, dann Produktion.
