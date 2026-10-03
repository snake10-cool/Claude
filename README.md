# Meine Apps

Android-Apps, gebaut mit Flutter, für Google Play.

| App | Ordner | Inhalt |
|---|---|---|
| 🎣 **Austro Angler** | `apps/austro_angler` | Angel-App für Bezirk Braunau und Umgebung (Innviertel und Flachgau) mit Community |
| 🦊 **Lernfuchs** (Arbeitsname, pausiert) | `apps/lernapp` | Lern-App für Volksschule 1–4 und Mittelschule 1–4 |

## Testversion holen

Nach jeder Änderung baut GitHub automatisch die **PC-Version** (Tab **Actions**, ca. 8 Minuten). Die Android-Version gibt es nur auf Wunsch: Actions → "Apps bauen" → Run workflow → Häkchen bei "android". Danach liegen alle Dateien unter **Releases → Testversion**:

| Datei | Für |
|---|---|
| `AustroAngler.apk` | Android-Handy |
| `AustroAngler-Setup.exe` | Windows-PC (Installation mit Startmenü- und Desktop-Symbol) |
| `AustroAngler-Windows.zip` | Windows-PC ohne Installation: entpacken und `AustroAngler.exe` starten |

Beim ersten Start am PC zeigt Windows eventuell "Der Computer wurde durch Windows geschützt", weil die App noch nicht signiert ist. Dann auf **Weitere Informationen → Trotzdem ausführen** klicken.

### Am Handy

1. Nach jeder Änderung baut GitHub die Apps automatisch (Tab **Actions**, dauert ca. 10 Minuten).
2. Danach im Repo auf **Releases → Testversion** gehen.
3. `AustroAngler.apk` antippen und herunterladen.
4. Die Datei öffnen. Android fragt beim ersten Mal, ob der Browser Apps installieren darf: erlauben.

## 🎣 Austro Angler – was drin ist

**Ohne Konto (funktioniert immer):**
- **Gewässer**: 22 Gewässer rund um Braunau, sortiert nach Entfernung. Dabei sind kleine Bäche (Enknach, Mattig, Schwemmbach, Mühlheimer Ache, Antiesen), Teiche und Baggerseen (Enknach-Teiche, Baggersee Pfaffstätt, Kühbach), die Innviertler Seen, der Inn und die Salzburger Seen. Jedes Gewässer hat Preise, Kartenverkauf, Wetter und Mondphase.
- **Karte**: alle Gewässer auf der Karte. Lange drücken speichert einen eigenen Angelplatz, der immer privat auf dem Handy bleibt.
- **Fangbuch**: Fänge mit Statistik. Es warnt bei Schonzeit oder wenn ein Fisch unter dem Brittelmaß liegt, und zwar für das Bundesland des Fangs.
- **Fischlexikon**: 31 Fischarten mit Schonzeit und Brittelmaß für OÖ und Salzburg.
- **Schonzeit-Kalender**: Monatsübersicht, welcher Fisch wann offen ist.
- **Prüfungstrainer** mit 37 Fragen und **Knoten-Anleitungen**.

**Mit Konto (sobald Firebase eingerichtet ist):**
- Registrieren mit E-Mail, Passwort und einzigartigem **@Namen** (z. B. `@hechtjaeger99`).
- **Freunde** über ihren @Namen hinzufügen. Im Tab **Community → Freunde** erscheinen dann ihre neuesten Fänge, und ein Antippen öffnet ihr Profil.
- **Preis ergänzen** bei jedem Gewässer: Der Admin prüft den Vorschlag, nach der Freigabe sehen ihn alle sofort, ohne App-Update.
- Fänge in der Cloud, mit **Foto**, und auf allen Geräten verfügbar.
- Fänge sind **standardmäßig öffentlich**, lassen sich aber pro Fang auf privat stellen.
- **Community**: Feed mit den neuesten Fängen, "Petri Heil!"-Knopf, **Rangliste** (meiste Fänge, meiste Petri Heil, größter Fisch) und **Rekorde** pro Fischart.
- **Wünsche**: Nutzer schicken Wünsche für die App und sehen, ob sie geplant oder erledigt sind und was geantwortet wurde.
- **Administrator** `snakejoni10@yahoo.com`: sieht alle Wünsche, Preisvorschläge und Meldungen, gibt Preise frei, kann antworten, den Status setzen und unpassende Fänge entfernen. Das klappt erst, wenn die **E-Mail-Adresse bestätigt** ist, also nach Registrierung mit dieser Adresse den Link in der Bestätigungs-Mail anklicken.
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
