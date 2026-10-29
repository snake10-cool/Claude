# Online-Rangliste einrichten (Firebase)

Die App funktioniert ohne Firebase. Die Rangliste läuft dann über Punkte-Codes.
Für Konten, @Namen und die Rangliste „Freunde / Weltweit" braucht Bücherwurm ein
**eigenes** Firebase-Projekt. Es ist getrennt von Austro Angler, damit sich die
Konten der beiden Apps nicht vermischen. Alles läuft im kostenlosen Spark-Tarif.

Dauer: etwa 10 Minuten, nur mit dem Google-Konto (u3206495666@gmail.com).

## 1. Projekt anlegen

1. https://console.firebase.google.com öffnen → **Projekt hinzufügen**.
2. Name: `buecherwurm`. Google Analytics wird nicht gebraucht und kann aus bleiben.

## 2. Anmeldung mit E-Mail einschalten

**Build → Authentication → Jetzt starten → Anmeldemethode → E-Mail/Passwort**
→ aktivieren → Speichern.

## 3. Datenbank anlegen

**Build → Firestore Database → Datenbank erstellen**
- Standort: `europe-west3 (Frankfurt)`
- Im **Produktionsmodus** starten

Danach Tab **Regeln** öffnen, den ganzen Inhalt von
[`apps/buecherwurm/firestore.rules`](../firestore.rules) einfügen →
**Veröffentlichen**.

## 4. Android-App registrieren

**Projektübersicht → Android-Symbol (App hinzufügen)**
- Android-Paketname: `com.snake10.buecherwurm`
- App-Nickname: `Bücherwurm`
- Die SHA-1-Angabe ist nicht nötig.

→ **App registrieren** → `google-services.json` herunterladen. Die weiteren
Schritte im Assistenten kannst du überspringen.

## 5. Daten an Claude geben

Schick Claude den Inhalt von `google-services.json` oder lade die Datei hoch.
Claude trägt diese 4 Werte in `lib/firebase_options.dart` ein:

| In `google-services.json` | In `firebase_options.dart` |
|---|---|
| `client[0].api_key[0].current_key` | `apiKey` |
| `client[0].client_info.mobilesdk_app_id` | `appId` |
| `project_info.project_number` | `messagingSenderId` |
| `project_info.project_id` | `projectId` |

Die Werte sind nicht geheim. Geschützt wird die Datenbank durch die Regeln aus Schritt 3.

## Was online gespeichert wird

- `spieler/{uid}`: @Name, Punkte, bewiesene und gelesene Bücher (öffentlich lesbar)
- `spieler/{uid}/freunde`: die eigene Freundesliste (nur für einen selbst sichtbar)
- `namen/{name}`: sorgt dafür, dass jeder @Name nur einmal vergeben wird

Bücher, Bewertungen, Notizen und der Fragebogen bleiben **nur auf dem Handy**.
„Konto löschen" in der App entfernt alles Online-Gespeicherte. Das ist Pflicht für den Play Store.
