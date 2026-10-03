# Meine Apps

Android-Apps, gebaut mit Flutter, für Google Play.

| App | Ordner | Inhalt |
|---|---|---|
| 🎣 **Austro Angler** | `apps/austro_angler` | Angel-App für Bezirk Braunau und Umgebung (Innviertel und Flachgau) mit Community |
| 🦊 **Lernfuchs** (Arbeitsname, pausiert) | `apps/lernapp` | Lern-App für Volksschule 1–4 und Mittelschule 1–4 |

## Testversion holen

Nach jeder Änderung baut GitHub automatisch die **Handy-Version (APK)** (Tab **Actions**, ca. 8 Minuten). Die PC-Version gibt es auf Wunsch: Actions → "Apps bauen" → Run workflow → "pc" oder "beide". Danach liegen alle Dateien unter **Releases → Testversion**:

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

## 🔥 Firebase

Projekt: **austro-angler-202495bd** (Konto u3206495666@gmail.com), Konsole: https://console.firebase.google.com/project/austro-angler-202495bd

Schon eingerichtet:
- Firestore-Datenbank (europe-west3, Frankfurt)
- Sicherheitsregeln aus `apps/austro_angler/firestore.rules`. Nach Änderungen müssen sie neu veröffentlicht werden.
- Android-App (`com.snake10.austroangler`) und PC-App (Web-App-Daten)

E-Mail/Passwort-Anmeldung ist aktiv.

Alles läuft im **kostenlosen Spark-Tarif**. Fotos werden deshalb verkleinert direkt in Firestore gespeichert.

## ⭐ Abo (beschlossen, kommt mit dem Play-Store-Start)

- **3,99 € im Monat oder 29,99 € im Jahr**, davor 7 Tage gratis testen. Es gibt keinen Gründer-Bonus.
- **Gratis bleiben:** Gewässer, Preise, Karte, Wetter, Lexikon, Schonzeiten, Fangbuch, die ganze Community, Knoten, Checkliste und der Prüfungstrainer.
- **Premium (⭐):** Beißzeit für die nächsten Tage, Statistik-Auswertungen, Wasserführungs-Verlauf, Schonzeit-Wecker ohne Limit, PDF-Export, unbegrenzte Fotos, Prüfungsmodus und besondere Abzeichen.
- **Monats-Challenge:** Der Gewinner bekommt 1 Monat Premium. Der Admin vergibt den Gewinn in der App, gespeichert wird er in `premium/{uid}`.
- Bis zum Start sind alle ⭐-Funktionen für alle freigeschaltet.

## 🚀 Play-Store-Start (Version 1.0)

Fertig: App-Icon, Splash-Screen, Melden und Blockieren, Webseiten
([Datenschutz](https://austro-angler-202495bd.web.app/datenschutz),
[Nutzungsbedingungen](https://austro-angler-202495bd.web.app/nutzungsbedingungen),
[Konto löschen](https://austro-angler-202495bd.web.app/konto-loeschen),
[Impressum](https://austro-angler-202495bd.web.app/impressum)),
Store-Texte, Feature-Grafik und die AAB-Signierung im Build.

**Anleitung mit allen Schritten:** [`apps/austro_angler/docs/play-store.md`](apps/austro_angler/docs/play-store.md)

Offen (geht nur mit dir bzw. deinen Eltern):
1. Name und Adresse für das Impressum
2. Google-Play-Entwicklerkonto (25 $, über die Eltern)
3. GitHub-Secrets `ANDROID_KEYSTORE_BASE64` und `ANDROID_KEYSTORE_PASSWORT`
4. Geschlossener Test mit 12 Testern für 14 Tage
5. Abo in der Play Console anlegen, danach baut Claude Google Play Billing ein
