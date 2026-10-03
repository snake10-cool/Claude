# Meine Apps

Android-Apps, gebaut mit Flutter, für Google Play.

| App | Ordner | Inhalt |
|---|---|---|
| 🎣 **Austro Angler** | `apps/austro_angler` | Angel-App für ganz Österreich mit Community |
| 🦊 **Lernfuchs** (Arbeitsname, pausiert) | `apps/lernapp` | Lern-App für Volksschule 1–4 und Mittelschule 1–4 |

## Testversion aufs Handy holen (ohne PC)

1. Nach jeder Änderung baut GitHub die Apps automatisch (Tab **Actions**, dauert ca. 10 Minuten).
2. Danach im Repo auf **Releases → Testversion** gehen.
3. `AustroAngler.apk` antippen und herunterladen.
4. Die Datei öffnen. Android fragt beim ersten Mal, ob der Browser Apps installieren darf: erlauben.

## 🎣 Austro Angler – was drin ist

**Ohne Konto (funktioniert immer):**
- **Gewässer**: 29 Gewässer in allen 9 Bundesländern mit Preisen, Kartenverkauf und Suche. Pro Gewässer gibt es aktuelles Wetter, Luftdruck, Sonnenauf- und -untergang und die Mondphase. Dazu "Was brauche ich zum Fischen?" für jedes Bundesland.
- **Karte**: alle Gewässer auf der Karte. Lange drücken speichert einen eigenen Angelplatz, der immer privat auf dem Handy bleibt.
- **Fangbuch**: Fänge mit Statistik. Es warnt bei Schonzeit oder wenn ein Fisch unter dem Brittelmaß liegt, und zwar für das Bundesland des Fangs.
- **Fischlexikon**: 19 Fischarten mit Schonzeit und Brittelmaß für alle 9 Bundesländer.
- **Schonzeit-Kalender**: Monatsübersicht, welcher Fisch wann offen ist.
- **Prüfungstrainer** mit 37 Fragen und **Knoten-Anleitungen**.

**Mit Konto (sobald Firebase eingerichtet ist):**
- Registrieren mit E-Mail, Passwort und öffentlichem Nutzernamen.
- Fänge in der Cloud, mit **Foto**, und auf allen Geräten verfügbar.
- Fänge sind **standardmäßig öffentlich**, lassen sich aber pro Fang auf privat stellen.
- **Community**: Feed mit den neuesten Fängen, "Petri Heil!"-Knopf und **Rekorde** pro Fischart.
- **Melden**: falsche Gewässer-Infos, neue Gewässer und unpassende Fänge. Die Meldungen landen in Firestore unter `meldungen`.
- **Konto löschen** mit allen Daten (Pflicht für den Play Store).

Daten bearbeiten: `apps/austro_angler/lib/data/`. Wo nichts gefunden wurde, steht in der App "unbekannt – bitte prüfen".

## 🔥 Firebase einrichten (geht auch am Handy, ca. 10 Minuten)

1. **console.firebase.google.com** öffnen, am besten in der Desktop-Ansicht des Browsers, und mit dem Google-Konto anmelden.
2. **Projekt hinzufügen**: Name `austro-angler`, Google Analytics kann aus bleiben.
3. **Build → Authentication → Jetzt starten**, dann unter "Anmeldemethode" **E-Mail/Passwort** aktivieren.
4. **Build → Firestore Database → Datenbank erstellen**: Standort `europe-west` (EU), dann den **Produktionsmodus** wählen.
5. In Firestore auf **Regeln** gehen, den ganzen Inhalt von [`apps/austro_angler/firestore.rules`](apps/austro_angler/firestore.rules) einfügen und **Veröffentlichen**.
6. In der **Projektübersicht → App hinzufügen → Android**:
   - Paketname: `com.snake10.austroangler`
   - SHA-1 wird **nicht** gebraucht
   - Die Datei `google-services.json` herunterladen
7. Den Inhalt von `google-services.json` an Claude schicken. Claude trägt die Werte in `lib/firebase_options.dart` ein. Diese Werte sind nicht geheim, den Schutz übernehmen die Regeln aus Schritt 5.

Alles läuft im **kostenlosen Spark-Tarif**, eine Kreditkarte ist nicht nötig. Fotos werden deshalb verkleinert direkt in Firestore gespeichert, nicht in Cloud Storage.

## Nächste Schritte

1. Firebase einrichten (siehe oben).
2. Testen und die Gewässerdaten prüfen lassen.
3. **Google-Play-Konto** (25 $ einmalig, unter 18 über die Eltern).
4. **Upload-Schlüssel und AAB-Datei** für den Play Store.
5. **Datenschutzerklärung** (Pflicht, weil es Konten und öffentliche Inhalte gibt).
6. Später: Premium-Abo, mehr Gewässer, Moderation der Meldungen.
