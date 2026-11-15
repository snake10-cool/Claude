# Katalog-Korrekturen ohne App-Update

Die App lädt beim Start die Firestore-Sammlung **`buchkorrekturen`** und wendet
sie auf den Katalog an. Änderungen sind sofort bei allen Nutzern sichtbar
(nach dem nächsten App-Start, meist schon vorher).

Schreiben darf nur der Admin (siehe `firestore.rules`).

## So geht's (Firebase-Konsole → Firestore)

1. Sammlung `buchkorrekturen` öffnen (beim ersten Mal anlegen).
2. Dokument hinzufügen. **Dokument-ID = Buch-ID**, z. B.
   `x_woodwalkersjeffreysgrossechance` (steht in `lib/data/katalog*.dart`
   bzw. im Wikidata-Paket als `wd_Q…`).
3. Nur die Felder eintragen, die sich ändern sollen:

| Feld | Typ | Wirkung |
|---|---|---|
| `titel`, `autor`, `beschreibung`, `coverUrl`, `isbn` | string | ersetzt den Wert |
| `jahr`, `seiten`, `minAlter` | number | ersetzt den Wert |
| `zielgruppe` | string | `kinder`, `jugend` oder `erwachsene` |
| `tags` | array (string) | ersetzt alle Tags |
| `ausblenden` | boolean | `true` = Buch verschwindet aus der App |
| `neu` | boolean | `true` + `titel` + `autor` = **neues Buch**, das es im Katalog noch nicht gibt |

## Quizfragen ohne Update

Laufen schon über die Sammlung `quizfragen` (Freigabe von Vorschlägen im
Admin-Bereich der App). Felder: `buchId`, `buchTitel`, `frage`, `antworten`
(4 Stück, die richtige zuerst). Die App lädt höchstens 5000 davon.
