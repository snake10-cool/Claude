# Codekarten – Play Store

Paket-ID: `com.snake10.codekarten` · Kategorie: **Bildung**

## Store-Eintrag (Deutsch)

**Titel (max. 30):** `Codekarten: Programmieren lernen`

**Kurzbeschreibung (max. 80):**
`Java, Python, Dart & JavaScript lernen mit Karteikarten und Code-Snippets.`

**Beschreibung:**

```
Lerne Programmieren in 10 Minuten am Tag – mit Karteikarten, die sich deinem Gedächtnis anpassen.

🧠 LERNEN, DAS HÄNGEN BLEIBT
Codekarten nutzt Spaced Repetition (wie Anki): Karten, die du gut kannst, kommen seltener, schwierige öfter. So lernst du mit wenig Zeit nachhaltig.

💻 ECHTER CODE STATT TROCKENER THEORIE
• Begriffe: Was ist eine Klasse, ein Lambda, ein Stream?
• „Was gibt dieser Code aus?“ – trainiert, Code im Kopf auszuführen
• Lückentext im Code – die richtige Methode, der richtige Operator
• Jede Code-Karte wurde mit dem echten Compiler geprüft

📚 STAPEL
• Java Grundlagen – gratis, über 70 Karten
• Java Profi: OOP, Collections, Streams, Records, Exceptions
• Python Grundlagen
• Dart & Flutter Basics
• JavaScript Grundlagen
• Eigene Stapel und Karten erstellen

🔥 DRANBLEIBEN
Tagesziel, Serie (Streak) und Statistik mit 30-Tage-Verlauf.

📋 DEINE SNIPPET-SAMMLUNG
Speichere Code mit Syntax-Hervorhebung, Tags und Suche. Kopieren mit einem Tipp. Aus jeder Lernkarte wird mit einem Tipp ein Snippet, und aus jedem Snippet eine Lernkarte.

🔓 FREISCHALTEN
Zusatzstapel einzeln kaufen, mit dem Abo „Alles“ alle bekommen, oder per freiwilligem Video 24 Stunden gratis testen.
```

**Suchbegriffe:** Programmieren lernen, Java, Python, JavaScript, Dart, Flutter, Karteikarten, Coding, Informatik, Spaced Repetition.

## Produkte in der Play Console

| Produkt-ID | Art | Preis-Vorschlag |
|---|---|---|
| `paket_java_profi` | Einmalkauf | 2,99 € |
| `paket_python` | Einmalkauf | 2,99 € |
| `paket_dart` | Einmalkauf | 2,99 € |
| `paket_javascript` | Einmalkauf | 2,99 € |
| `alles_monat` | Abo monatlich | 1,99 € |
| `alles_jahr` | Abo jährlich | 12,99 € |

Danach in `lib/dienste.dart` `kaufPflicht: true` setzen.

## AdMob

1. In AdMob eine App „Codekarten“ anlegen und zwei Anzeigenblöcke erstellen: **Banner** und **Belohnung** (Belohnung: 1 „Freischaltung“).
2. App-ID in `android/app/src/main/AndroidManifest.xml` eintragen (statt der Test-ID).
3. Block-IDs in `lib/dienste.dart`: `WerbeIds(banner: '…', belohnung: '…', nurTest: false)`.
4. **Erst nach dem Play-Store-Start.** Vorher immer Test-Anzeigen.

## Datensicherheit

| Frage | Antwort |
|---|---|
| Erhebt die App Daten? | **Ja, durch Werbung (AdMob):** Geräte-IDs (Werbe-ID), ungefährer Standort, App-Interaktionen. Zweck: Werbung, Analyse. Weitergabe an Google. |
| Lerndaten / Snippets | Bleiben auf dem Gerät, werden nicht erhoben. |
| Verschlüsselt übertragen | Ja (AdMob nutzt HTTPS) |
| Daten löschen | App deinstallieren; Werbe-ID in den Android-Einstellungen zurücksetzen |
| Enthält Werbung | **Ja** |

## Inhaltsbewertung

Keine problematischen Inhalte. **PEGI 3 / USK 0**. Zielgruppe: **13+** (wegen Werbung keine Kinder-Zielgruppe angeben, sonst gelten die Familien-Richtlinien).

## Geschlossener Test

Warum Tester täglich öffnen: **Tagesziel und Streak** (🔥). Bitte an Tester: „Lerne jeden Tag 20 Karten und halte deine Serie.“

## Antrag auf Produktionszugriff (Vorlage)

> **Tester:** Freunde, Mitschüler und Leute, die gerade programmieren lernen.
>
> **Nutzung:** Tägliche Lernrunden (Tagesziel 20 Karten), Streak, Snippets gespeichert, eigene Karten erstellt, Zusatzstapel per Video freigeschaltet.
>
> **Feedback und Änderungen:** *(hier eintragen)*
>
> **Zielgruppe:** Jugendliche und Erwachsene, die Programmieren lernen (Schule, Studium, Selbststudium).
>
> **Besonderheit:** Code-Karten sind mit echten Compilern geprüft; Lernkarten und Snippets in einer App.
