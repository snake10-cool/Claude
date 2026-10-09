# Austro Angler in den Google Play Store bringen

Alles, was die App selbst braucht, ist fertig. Was noch fehlt, geht nur mit
deinem Google-Konto.

## Checkliste

| # | Schritt | Wer |
|---|---------|-----|
| 1 | ~~Impressum und Datenschutz: Name und Adresse eintragen~~ ✅ erledigt | du + Claude |
| 2 | ~~Google-Play-Entwicklerkonto anlegen~~ ✅ erledigt | du |
| 3 | GitHub-Secrets für den Upload-Schlüssel anlegen (siehe unten) | du |
| 4 | App in der Play Console anlegen, Texte und Bilder aus diesem Ordner einfügen | du |
| 5 | Geschlossener Test: **mindestens 12 Tester, 14 Tage lang** (Pflicht für neue private Konten) | du + Freunde |
| 6 | Abo „Premium“ in der Play Console anlegen, dann baut Claude Google Play Billing ein | du + Claude |
| 7 | Produktion beantragen und veröffentlichen | du |

## Upload-Schlüssel (Signierung)

Google Play nimmt nur signierte App-Pakete (AAB). Claude hat einen
Upload-Schlüssel erzeugt (`austro-angler-upload.jks`) und ihn dir zusammen
mit dem Passwort geschickt.

1. **Datei und Passwort gut aufheben** (z. B. auf einem USB-Stick und im
   Passwort-Manager). Nie öffentlich teilen. Geht er verloren, kann man über
   den Play-Support einen neuen Upload-Schlüssel beantragen. Das dauert aber.
2. GitHub → Repository → **Settings → Secrets and variables → Actions →
   New repository secret**:
   - `ANDROID_KEYSTORE_BASE64` = Inhalt von `ANDROID_KEYSTORE_BASE64.txt`
   - `ANDROID_KEYSTORE_PASSWORT` = Inhalt von `ANDROID_KEYSTORE_PASSWORT.txt`
3. Ab dem nächsten Build liegt im Test-Release zusätzlich
   **`AustroAngler-PlayStore.aab`**. Diese Datei lädst du in der Play Console
   hoch. Die normale `AustroAngler.apk` bleibt zum Testen wie bisher.
4. In der Play Console **„Play App-Signatur“** aktiviert lassen (Standard).

Fingerabdruck des Upload-Schlüssels:
`SHA-256 26:39:BC:52:EE:29:C3:01:21:FA:61:92:D7:ED:DB:23:9E:D2:65:BD:F3:97:79:11:EB:8E:AE:8C:95:F0:DE:24`

## Links für die Play Console

- Datenschutzerklärung: https://austro-angler-202495bd.web.app/datenschutz
- Konto löschen: https://austro-angler-202495bd.web.app/konto-loeschen
- Website: https://austro-angler-202495bd.web.app
- E-Mail: info.kaiserschmarrn@gmx.at
- Entwicklername: Kaiserschmarrn Apps

Die Seiten liegen in `hosting/`. Ändern: `python3 seiten.py` in `hosting/`,
danach veröffentlicht Claude sie neu auf Firebase Hosting.

## Store-Eintrag

**App-Name** (max. 30): `Austro Angler – Angeln in AT`

**Kurzbeschreibung** (max. 80):
`22.000 Gewässer, Fangbuch & Schonzeiten für Angler in ganz Österreich`

**Kategorie:** Sport · **Tags:** Angeln, Fischen, Outdoor

**Ausführliche Beschreibung** (max. 4000):

```
Austro Angler ist die Angel-App für ganz Österreich – mit Schwerpunkt Bezirk Braunau, Innviertel und Salzburger Flachgau. Ohne Werbung, ohne Standortverfolgung.

🎣 GEWÄSSER
• Über 22.000 Flüsse, Bäche, Seen und Teiche in ganz Österreich – filtern nach Bundesland, Bezirk und Ort
• Geprüfte Gewässer rund um Braunau mit Lizenz, Kartenverkauf und Preisen
• Wetter, Beißzeit-Prognose, Sonnenauf- und -untergang, Abfluss und Wassertemperatur
• Angelgeschäfte mit Adresse und Öffnungszeiten
• Bewertungen, Preise und Infos aus der Community (vom Admin geprüft)
• Heimatort selbst wählen und nach Entfernung sortieren – ohne GPS
• Offline-Karte: angesehene Kartenausschnitte gehen auch ohne Netz

📖 FANGBUCH
• Fänge mit Foto, kurzem Video, Länge, Gewicht, Köder, Ausrüstung, Datum und Uhrzeit
• Länge per Foto messen, Wetter zur Fangzeit automatisch
• Eigene Angelplätze auf der Karte – immer privat
• Statistik, Rekorde, Abzeichen, Wochen-Challenges und PDF-Export
• Fangstatistik fürs Revier als PDF zum Abgeben
• „Dein Angeljahr“ – Jahresrückblick zum Teilen

🐟 FISCHLEXIKON
• 83 Fischarten Österreichs mit Bild und Merkmalen – suchen und filtern
• Bestimmungshilfe: „Welcher Fisch ist das?“
• Bei jedem Fisch: alle Gewässer, wo es ihn gibt – sicher oder nur typisch
• Schonzeiten und Brittelmaße, Schonzeit-Countdown, Kalender und Erinnerung
• Jungangler-Modus mit Angel-Wörterbuch

🎓 FISCHERPRÜFUNG
• Übungsfragen und Prüfungsmodus mit Zeitlimit
• Die wichtigsten Angelknoten mit Bildern

👥 COMMUNITY
• Feed mit „Petri Heil“, Kommentaren und Fang-Geschichten
• Profile mit Statistik und Abzeichen, Freundschaftsanfragen
• Gemeinsame Angeltage mit Fahrgemeinschaften und Unwetter-Warnung
• Monats-Challenge, Rangliste und Vereins-Rangliste
• Melden und Blockieren für eine faire Community

📱 WIDGET
• Beißzeit und Wetter an deinem Heimatort direkt am Startbildschirm

⭐ PREMIUM
Die Grundfunktionen sind gratis. Mit Premium (3,99 € im Monat oder 29,99 € im Jahr, 7 Tage gratis testen) bekommst du Extras wie die Beißzeit für die nächsten Tage, Statistik mit Wetter-Auswertung, Wasserführungs-Verlauf, PDF-Export und den Prüfungsmodus.

Alle Angaben ohne Gewähr – es gelten immer das Landesfischereigesetz und die Lizenzbedingungen des Reviers.
```

**Bilder** (in `docs/store/`):
- App-Symbol 512 × 512: `icon-512.png`
- Feature-Grafik 1024 × 500: `feature-grafik.png`
- Screenshots (1080 × 1920, fertig): `docs/store/screenshots/1_gewaesser.png`
  bis `8_einfuehrung.png` – in dieser Reihenfolge hochladen. Neu erzeugen:
  `flutter test screenshots/store_test.dart --update-goldens`. Im Fangbuch
  stehen Beispiel-Fänge.

## Fragebögen in der Play Console

### Datensicherheit (Data safety)

- Werden Daten erhoben oder geteilt? **Ja, erhoben. Nicht geteilt.**
  (Firebase ist ein Auftragsverarbeiter und zählt nicht als „Teilen“.)
- Daten werden bei der Übertragung verschlüsselt: **Ja**
- Nutzer können die Löschung beantragen: **Ja** (in der App und per Link oben)

| Datentyp | Erhoben | Pflicht? | Zweck |
|----------|---------|----------|-------|
| Persönliche Infos → E-Mail-Adresse | ja | Pflicht | Kontoverwaltung |
| Persönliche Infos → Nutzer-IDs (@Name, ID) | ja | Pflicht | App-Funktionen, Kontoverwaltung |
| Fotos und Videos → Fotos | ja | optional | App-Funktionen |
| Fotos und Videos → Videos (mit Ton) | ja | optional | App-Funktionen |
| Nachrichten → andere Nachrichten in der App (Kommentare) | ja | optional | App-Funktionen |
| Von Nutzern erstellte Inhalte (Fänge, Geschichten, Bewertungen, Wünsche, Wassertemperaturen, Fahrgemeinschaften, Verein) | ja | optional | App-Funktionen |
| Standort | **nein** (Orte werden selbst ausgewählt, nicht per GPS) | – | – |
| App-Aktivität, Absturzberichte, Geräte-IDs | **nein** | – | – |

### Einstufung des Inhalts (IARC)

- Kategorie: **Referenz, Nachrichten oder Bildung** bzw. „Alle anderen App-Typen“
- Gewalt: nein (Fische fangen ist keine Gewalt im Sinne von IARC). Blut: nein
- **Nutzer können interagieren / Inhalte teilen: Ja** (Feed, Kommentare)
- Teilt Standort mit anderen: nein
- Digitale Käufe: ja (Abo, sobald Billing eingebaut ist)
- Erwartetes Ergebnis: PEGI 3 bzw. USK 0, mit Hinweis „Nutzerinteraktion“

### Zielgruppe

- Zielalter: **ab 13** (13–15, 16–17, 18+). Nicht „unter 13“ wählen, sonst
  gelten die strengen Familienrichtlinien.
- App spricht Kinder nicht besonders an: **ja**

### Weitere Angaben

- Werbung: **Nein**
- App-Zugriff: Die App braucht ein Konto → Test-Zugangsdaten für die Prüfer
  angeben (ein eigenes Testkonto anlegen, z. B. `pruefer.austroangler@…`).
- Behörden-App: nein · Finanzfunktionen: nein · Gesundheit: nein
- Nachrichten-App: nein

## Geschlossener Test (12 Tester, 14 Tage)

1. Play Console → Testen → **Geschlossener Test** → Track anlegen.
2. E-Mail-Liste mit mindestens 12 Gmail-Adressen (Freunde, Familie, Verein).
3. AAB hochladen, Test-Link an alle schicken. Alle müssen beitreten und die
   App aus dem Play Store installieren.
4. **14 Tage am Stück** mindestens 12 aktive Tester. Danach Produktion
   beantragen und die Fragen zum Test beantworten.

Tipp: Im SAC Mattig oder Schalchner Angler Club fragen. Angler testen gern.

## Abo (Google Play Billing)

Der Code ist fertig (`lib/services/abo.dart`, Bildschirm `Mehr → ⭐ Premium`).
In der Play Console unter **Monetarisieren → Abos** anlegen:

| Produkt-ID | Name | Basis-Abo | Preis | Angebot |
|------------|------|-----------|-------|---------|
| `premium_monat` | Premium Monat | monatlich, verlängert sich automatisch | 3,99 € | 7 Tage kostenloser Test |
| `premium_jahr` | Premium Jahr | jährlich, verlängert sich automatisch | 29,99 € | 7 Tage kostenloser Test |

Die IDs müssen genau so heißen. Danach testen mit „Lizenztestern“
(Play Console → Einstellungen → Lizenztests), dann zahlt man nichts.

**Zum Start:** In `lib/services/abo.dart` `premiumPflicht = true` setzen –
dann sind die ⭐-Funktionen nur noch mit Abo oder Challenge-Gewinn offen.
Bis dahin ist alles für alle frei.
