# Teilbar: Online-Gruppen einrichten (Firebase)

Ohne diese Schritte funktioniert Teilbar komplett, nur **Online-Gruppen** (Live-Sync
zwischen Handys) sind aus. Dauer: ca. 15 Minuten, kostenlos (Spark-Tarif).

1. **Projekt anlegen:** https://console.firebase.google.com → „Projekt hinzufügen“ →
   Name `teilbar` → Google Analytics **aus**.
2. **Android-App hinzufügen:** Projektübersicht → Android-Symbol →
   Paketname **`com.snake10.teilbar`** → Registrieren. Die Datei
   `google-services.json` herunterladen, aber **nicht** ins Projekt legen – wir
   brauchen nur die Werte daraus:
   - `apiKey` = `client[0].api_key[0].current_key`
   - `appId` = `client[0].client_info.mobilesdk_app_id`
   - `messagingSenderId` = `project_info.project_number`
   - `projectId` = `project_info.project_id`
3. Diese vier Werte in **`lib/firebase_options.dart`** bei `_android` eintragen.
   (Für Windows optional eine Web-App anlegen und die Werte bei `_windows` eintragen.)
4. **Anmeldung:** Build → Authentication → Loslegen → Anbieter **Anonym** aktivieren.
5. **Datenbank:** Build → Firestore Database → Datenbank erstellen →
   Standort **europe-west3 (Frankfurt)** → im Produktionsmodus starten.
6. **Regeln:** Firestore → Regeln → Inhalt von `firestore.rules` einfügen →
   Veröffentlichen.
7. Neue Version bauen (Push auf GitHub reicht) – in Gruppen erscheint dann
   „Online teilen“.

## So funktioniert der Sync

- Alles wird zuerst lokal gespeichert (funktioniert auch ohne Internet).
- Online-Gruppen laden Änderungen automatisch hoch, sobald Internet da ist.
- Bei gleichzeitigen Änderungen gewinnt die neueste.
- Beitreten: 6-stelliger Code oder QR-Code (Gruppe → Mitglieder).
- Die Regeln erlauben nur Mitgliedern Zugriff auf die Daten ihrer Gruppe.
