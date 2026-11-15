// Lektion 7 – Strings im Detail
const R = String.raw;
const prog = (body, imports = '') => `${imports}public class Main {\n    public static void main(String[] args) {\n${body.replace(/^\n/, '').replace(/\n$/, '')}\n    }\n}\n`;
const cls = (members, mainBody, imports = '') => `${imports}public class Main {\n${members.replace(/^\n/, '').replace(/\n$/, '')}\n\n    public static void main(String[] args) {\n${mainBody.replace(/^\n/, '').replace(/\n$/, '')}\n    }\n}\n`;
const SC = 'import java.util.Scanner;\n\n';

export default {
  id: 'java-07', nr: 7,
  title: 'Strings im Detail',
  sub: 'Texte zerlegen, durchsuchen, vergleichen und umbauen – Zeichen für Zeichen.',
  outro: 'Texte sind überall: Namen, Chat-Nachrichten, Level-Dateien. Mit charAt, substring, split und StringBuilder hast du jetzt das Werkzeug dafür. In Lektion 8 baust du deine ersten eigenen Klassen.',
  chapters: [
    {
      title: 'Ein String ist eine Kette',
      steps: [
        { t: 'Lektion 7', h: 'Strings im Detail', sub: 'Texte Zeichen für Zeichen', say: 'Servus! Mit Strings arbeitest du schon seit Lektion 1. Heute schauen wir hinein: Ein String ist eine **Kette aus einzelnen Zeichen**, und du kannst jedes davon erreichen.' },
        { layout: 'visual', visual: { kind: 'html', html: '<div class="chars-demo"><h4>"PIXEL" im Speicher</h4><div class="boxes">' + ['P', 'I', 'X', 'E', 'L'].map((c, i) => `<div class="box" data-s="${0.3 + i * 0.4}"><div class="box-type">char</div><div class="box-val">\'${c}\'</div><div class="box-name">Index ${i}</div></div>`).join('') + '</div><p class="vnote" data-s="2.5">Wie bei Arrays: Der erste Index ist <b>0</b>, der letzte ist <b>length() − 1</b>.</p></div>' }, say: 'Stell dir den Text „PIXEL“ als fünf Kästchen vor. Jedes Kästchen ist ein `char` und hat eine Nummer, den Index. Genau wie bei Arrays beginnt die Zählung bei 0.' },
        { layout: 'code', console: 'clear', code: prog(R`
        String wort = "PIXEL";
        System.out.println(wort.length());
        System.out.println(wort.charAt(0));
        System.out.println(wort.charAt(4));
        System.out.println(wort.charAt(wort.length() - 1));`), hl: [3, 6], say: '`length()` gibt die Anzahl der Zeichen zurück – mit runden Klammern, anders als bei Arrays. `charAt(i)` holt das Zeichen an Position i.' },
        { run: true, say: 'Länge 5, erstes Zeichen P, letztes L. Der Trick `wort.length() - 1` funktioniert für jedes Wort, egal wie lang.' },
        { code: prog(R`
        String wort = "PIXEL";
        System.out.println(wort.charAt(5));`), run: true, expectError: true, console: 'clear', say: 'Und wenn du zu weit greifst? Dann gibt es eine `StringIndexOutOfBoundsException`. Index 5 gibt es bei fünf Zeichen nicht.' },
      ],
    },
    {
      title: 'Zeichen für Zeichen',
      steps: [
        { t: 'Kapitel 2', h: 'Durch einen Text laufen', sub: 'for-Schleife + charAt', after: 'code' },
        { layout: 'code', console: 'clear', code: prog(R`
        String text = "Super Mario";
        int vokale = 0;
        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            if (c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u') {
                vokale++;
            }
        }
        System.out.println("Vokale: " + vokale);`), hl: [5, 10], say: 'Das wichtigste Muster dieser Lektion: Eine for-Schleife von 0 bis `length()`, und darin holst du dir mit `charAt` jedes Zeichen einzeln.' },
        { run: true, say: 'Fünf Vokale: u, e, a, i und o. Zeichen vergleichst du übrigens mit `==` und **einfachen** Anführungszeichen.' },
        { layout: 'split', visual: { kind: 'table', title: 'Nützliche Character-Methoden', head: ['Methode', 'Ergebnis für \'7\'', 'für \'b\''], rows: [['`Character.isDigit(c)`', 'true', 'false'], ['`Character.isLetter(c)`', 'false', 'true'], ['`Character.isUpperCase(c)`', 'false', 'false'], ['`Character.toUpperCase(c)`', '\'7\'', '\'B\'']], gap: 0.7 }, say: 'Die Klasse `Character` hat praktische Helfer: Ist das Zeichen eine Ziffer? Ein Buchstabe? Großgeschrieben? Und sie kann Zeichen umwandeln.' },
        { layout: 'code', console: 'clear', code: prog(R`
        String code = "Lvl3-Boss42";
        int ziffern = 0, gross = 0;
        for (int i = 0; i < code.length(); i++) {
            char c = code.charAt(i);
            if (Character.isDigit(c)) ziffern++;
            if (Character.isUpperCase(c)) gross++;
        }
        System.out.println("Ziffern: " + ziffern + ", Großbuchstaben: " + gross);`), run: true, say: 'Drei Ziffern, zwei Großbuchstaben. Genau so prüft eine Webseite, ob dein Passwort sicher genug ist – das baust du gleich selbst.' },
        { quiz: { id: 'l7-q1', q: 'Was gibt `"Java".charAt(1)` zurück?', options: ['\'J\'', '\'a\'', '\'v\'', 'Einen Fehler'], correct: 1, explain: 'Index 0 ist J, Index 1 ist das erste a.' } },
      ],
    },
    {
      title: 'Aufgabe: Passwort-Checker',
      steps: [
        { t: 'Aufgabe 1', h: 'Passwort-Checker', sub: 'Jetzt bist du dran!', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Aufgabe 1: Passwort-Checker', items: ['Lies ein Passwort ein', 'Prüfe: mindestens **8 Zeichen**, mindestens eine **Ziffer**, mindestens ein **Großbuchstabe**', 'Gib aus, was fehlt', 'Und am Ende: „Stark“, „Mittel“ oder „Schwach“'], gap: 0.9 }, say: 'Deine Aufgabe: ein Passwort-Checker. Drei Regeln, und am Ende eine Bewertung.' },
        {
          task: {
            id: 'l7-passwort', nr: 1, title: 'Passwort-Checker',
            text: ['Lies ein Passwort mit dem Scanner ein (`nextLine`). Prüfe drei Regeln: mindestens 8 Zeichen lang, mindestens eine Ziffer, mindestens ein Großbuchstabe.', 'Für jede verletzte Regel gibst du einen Hinweis aus (z. B. „Zu kurz“, „Keine Ziffer“, „Kein Großbuchstabe“). Am Ende: alle 3 erfüllt → „Stark“, 2 erfüllt → „Mittel“, sonst → „Schwach“.'],
            req: ['Eingabe mit `nextLine()`', 'Schleife über alle Zeichen mit `charAt`', '`Character.isDigit` und `Character.isUpperCase` (oder eigene Vergleiche)', 'Hinweise pro verletzter Regel und Bewertung Stark/Mittel/Schwach'],
            example: 'Passwort: geheim1\nZu kurz\nKein Großbuchstabe\nSchwach',
            starter: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Passwort: ");
        String pw = sc.nextLine();
        // Prüfe hier die drei Regeln
`, SC),
            solution: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Passwort: ");
        String pw = sc.nextLine();
        boolean ziffer = false, gross = false;
        for (int i = 0; i < pw.length(); i++) {
            char c = pw.charAt(i);
            if (Character.isDigit(c)) ziffer = true;
            if (Character.isUpperCase(c)) gross = true;
        }
        int punkte = 0;
        if (pw.length() >= 8) punkte++; else System.out.println("Zu kurz");
        if (ziffer) punkte++; else System.out.println("Keine Ziffer");
        if (gross) punkte++; else System.out.println("Kein Großbuchstabe");
        if (punkte == 3) {
            System.out.println("Stark");
        } else if (punkte == 2) {
            System.out.println("Mittel");
        } else {
            System.out.println("Schwach");
        }`, SC),
            tests: [
              { name: 'stark', input: ['Mario2026!'], expect: [{ re: 'stark', label: '„Stark“' }, { re: 'zu kurz|keine ziffer|kein gro', label: 'keine Hinweise', not: true }] },
              { name: 'mittel', input: ['supermario7'], expect: [{ re: 'mittel', label: '„Mittel“' }, { re: 'gro(ß|ss)buchstabe', label: 'Hinweis Großbuchstabe' }] },
              { name: 'schwach', input: ['abc'], expect: [{ re: 'schwach', label: '„Schwach“' }, { re: 'kurz', label: 'Hinweis „zu kurz“' }, { re: 'ziffer', label: 'Hinweis Ziffer' }] },
            ],
            codeChecks: [{ label: 'charAt in einer Schleife', re: 'for\\s*\\([\\s\\S]*charAt|while[\\s\\S]*charAt' }, { label: 'Länge geprüft', re: 'length\\s*\\(\\s*\\)\\s*(>=|<|>|<=)\\s*\\d' }],
            rubric: [['Programm kompiliert und läuft', 15], ['Länge richtig geprüft', 15], ['Ziffer und Großbuchstabe mit Schleife erkannt', 30], ['Hinweise für verletzte Regeln', 20], ['Bewertung Stark / Mittel / Schwach richtig', 20]],
            tip: 'Nimm zwei boolean-Variablen `hatZiffer` und `hatGross`, die am Anfang false sind. In der Schleife setzt du sie auf true, sobald du so ein Zeichen findest.',
          },
        },
        { layout: 'code', console: 'clear', code: prog(R`
        String pw = "supermario7";
        boolean ziffer = false, gross = false;
        for (int i = 0; i < pw.length(); i++) {
            char c = pw.charAt(i);
            if (Character.isDigit(c)) ziffer = true;
            if (Character.isUpperCase(c)) gross = true;
        }
        System.out.println(ziffer + " " + gross);`), run: true, say: 'Abgegeben! Das Herzstück: zwei Merker-Variablen, die in der Schleife auf true springen. Dieses „Flag“-Muster brauchst du ständig.' },
      ],
    },
    {
      title: 'Teile und Suche',
      steps: [
        { t: 'Kapitel 4', h: 'Ausschneiden & Suchen', sub: 'substring, indexOf, contains', after: 'code' },
        { layout: 'code', console: 'clear', code: prog(R`
        String mail = "luigi@pilz.at";
        int at = mail.indexOf('@');
        System.out.println(at);
        System.out.println(mail.substring(0, at));
        System.out.println(mail.substring(at + 1));
        System.out.println(mail.contains(".at"));`), hl: [3, 7], say: '`indexOf` sucht ein Zeichen oder Wort und gibt die Position zurück – oder -1, wenn es nicht vorkommt. `substring(von, bis)` schneidet ein Stück heraus. Achtung: Das Zeichen bei `bis` ist **nicht** mehr dabei.' },
        { run: true, say: 'Das @ steht bei Index 5. Davor steht der Name, dahinter die Domain. Mit `substring(at + 1)` ohne zweite Zahl geht es bis zum Ende.' },
        { layout: 'split', visual: { kind: 'table', title: 'Text-Werkzeuge', head: ['Methode', 'Beispiel', 'Ergebnis'], rows: [['`toUpperCase()`', '`"go".toUpperCase()`', '"GO"'], ['`trim()`', '`"  hi ".trim()`', '"hi"'], ['`replace(a, b)`', '`"1-2-3".replace("-", "+")`', '"1+2+3"'], ['`startsWith(s)`', '`"Level 2".startsWith("Lev")`', 'true'], ['`repeat(n)`', '`"=".repeat(5)`', '"====="']], gap: 0.6 }, code: prog(R`
        String eingabe = "  Hallo Welt  ";
        System.out.println("[" + eingabe.trim().toUpperCase() + "]");`), run: true, console: 'clear', say: 'Noch mehr Werkzeuge. Wichtig: Strings ändern sich **nie** selbst. Jede Methode gibt einen **neuen** String zurück – den musst du speichern oder gleich benutzen.' },
      ],
    },
    {
      title: 'Vergleichen & Zerlegen',
      steps: [
        { t: 'Kapitel 5', h: 'equals und split', sub: 'Die zwei wichtigsten Fallen und Tricks', after: 'code' },
        { layout: 'split', visual: { kind: 'compare', left: { title: 'Falsch: ==', code: 'if (eingabe == "ja") {\n    // klappt oft NICHT\n}', note: '`==` prüft, ob es **dasselbe Objekt** ist', cls: 'bad' }, right: { title: 'Richtig: equals', code: 'if (eingabe.equals("ja")) {\n    // klappt immer\n}', note: '`equals` vergleicht den **Inhalt**', cls: 'good' } }, say: 'Die berühmteste Java-Falle: Strings nie mit `==` vergleichen! Das prüft nur, ob es dasselbe Objekt im Speicher ist. Für den Inhalt nimmst du `equals` – oder `equalsIgnoreCase`, wenn Groß und Klein egal sein sollen.' },
        { layout: 'code', console: 'clear', code: prog(R`
        String zeile = "Mario;3;1200";
        String[] teile = zeile.split(";");
        String name = teile[0];
        int leben = Integer.parseInt(teile[1]);
        int punkte = Integer.parseInt(teile[2]);
        System.out.println(name + " hat " + leben + " Leben und " + punkte + " Punkte");`), hl: [3, 6], say: '`split` zerlegt einen Text an einem Trennzeichen in ein String-Array. Mit `Integer.parseInt` machst du aus einem Text-Teil wieder eine Zahl. So speichern viele Spiele ihre Daten.' },
        { run: true, say: 'Aus einer einzigen Zeile werden drei saubere Werte. Genau so werden wir später Level aus Text-Zeilen laden.' },
        { quiz: { id: 'l7-q2', q: 'Was ergibt `"a,b,,c".split(",").length`?', options: ['3', '4', '5', '2'], correct: 1, explain: 'Die Teile sind "a", "b", "" und "c" – auch der leere Teil in der Mitte zählt.' } },
      ],
    },
    {
      title: 'StringBuilder',
      steps: [
        { t: 'Kapitel 6', h: 'StringBuilder', sub: 'Texte Stück für Stück bauen', after: 'code' },
        { layout: 'code', console: 'clear', code: prog(R`
        StringBuilder sb = new StringBuilder();
        for (int i = 1; i <= 5; i++) {
            sb.append(i);
            if (i < 5) sb.append(" > ");
        }
        System.out.println(sb.toString());
        System.out.println(new StringBuilder("Lagerfeuer").reverse());`), hl: [2, 7], say: 'Willst du einen Text in einer Schleife zusammenbauen, nimm einen `StringBuilder`. Mit `append` hängst du hinten etwas an, mit `toString` bekommst du am Ende den fertigen String.' },
        { run: true, say: 'Und `reverse` dreht den Text um – praktisch für Palindrom-Checks. Der StringBuilder ist schneller als ständiges `+`, weil er nicht jedes Mal einen neuen String erzeugt.' },
        { layout: 'code', console: 'clear', code: prog(R`
        char c = 'a';
        c++;
        System.out.println(c);
        int abstand = 'd' - 'a';
        System.out.println(abstand);
        char neu = (char) ('a' + (('y' - 'a' + 3) % 26));
        System.out.println(neu);`), hl: [6, 7], say: 'Ein letzter Trick: Hinter jedem char steckt eine Zahl. Du kannst damit rechnen! `\'d\' - \'a\'` ist 3. Und mit Modulo 26 kannst du im Alphabet „im Kreis“ verschieben.' },
        { run: true, say: 'Aus y wird mit Verschiebung 3 ein b – es geht hinten wieder von vorne los. Das ist die Grundlage einer uralten Geheimschrift, die du jetzt baust.' },
        { quiz: { id: 'l7-q3', q: 'Was gibt `(char) (\'a\' + 2)` aus?', options: ['a2', 'c', '99', 'b'], correct: 1, explain: '\'a\' + 2 ist die Zahl 99, und der Cast macht daraus wieder das Zeichen \'c\'.' } },
      ],
    },
    {
      title: 'Aufgabe: Geheimschrift',
      steps: [
        { t: 'Aufgabe 2', h: 'Geheimschrift', sub: 'Die Caesar-Verschlüsselung', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Aufgabe 2: Caesar-Verschlüsselung', items: ['Lies einen Text und eine Verschiebung ein', 'Jeder Kleinbuchstabe rückt um die Verschiebung weiter: a→d, b→e … y→b', 'Alles andere (Leerzeichen, Ziffern …) bleibt gleich', 'Baue das Ergebnis mit einem **StringBuilder**'], gap: 0.9 }, say: 'Julius Caesar soll so seine Nachrichten verschlüsselt haben: Jeder Buchstabe rückt ein paar Stellen weiter.' },
        {
          task: {
            id: 'l7-caesar', nr: 2, title: 'Geheimschrift (Caesar)',
            text: ['Lies zuerst einen Text (`nextLine`) und dann eine Verschiebung (`nextInt`) ein. Verschiebe jeden Kleinbuchstaben a–z um diese Anzahl im Alphabet; nach z geht es bei a weiter. Alle anderen Zeichen bleiben unverändert.', 'Baue das Ergebnis mit einem StringBuilder und gib es aus. Bonus: Großbuchstaben auch verschieben.'],
            req: ['Text mit `nextLine()`, Verschiebung mit `nextInt()`', 'Schleife über alle Zeichen', 'Rechnen mit chars und `% 26`', '`StringBuilder` für das Ergebnis'],
            example: 'Text: hallo welt\nVerschiebung: 3\nkdoor zhow',
            starter: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Text: ");
        String text = sc.nextLine();
        System.out.print("Verschiebung: ");
        int k = sc.nextInt();
        // verschlüssle hier
`, SC),
            solution: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Text: ");
        String text = sc.nextLine();
        System.out.print("Verschiebung: ");
        int k = sc.nextInt();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            if (c >= 'a' && c <= 'z') {
                sb.append((char) ('a' + (c - 'a' + k) % 26));
            } else if (c >= 'A' && c <= 'Z') {
                sb.append((char) ('A' + (c - 'A' + k) % 26));
            } else {
                sb.append(c);
            }
        }
        System.out.println(sb.toString());`, SC),
            tests: [
              { name: 'hallo welt / 3', input: ['hallo welt', '3'], expect: [{ has: 'kdoor zhow', label: '„kdoor zhow“' }] },
              { name: 'xyz! / 2', input: ['xyz!', '2'], expect: [{ has: 'zab!', label: 'Wrap-around: „zab!“' }] },
              { name: 'jump 2026 / 1', input: ['jump 2026', '1'], expect: [{ has: 'kvnq 2026', label: 'Ziffern bleiben: „kvnq 2026“' }] },
            ],
            codeChecks: [{ label: 'StringBuilder verwendet', re: 'StringBuilder' }, { label: 'Modulo 26', re: '%\\s*26' }, { label: 'charAt in Schleife', re: 'charAt' }],
            rubric: [['Programm kompiliert und läuft', 15], ['Kleinbuchstaben richtig verschoben', 30], ['Wrap-around nach z mit % 26', 20], ['Andere Zeichen bleiben gleich', 15], ['StringBuilder sauber eingesetzt', 20]],
            tip: 'Rechne in drei Schritten: Position im Alphabet `c - \'a\'` (0–25), dann `+ k` und `% 26`, dann wieder `\'a\' +` und als char casten.',
          },
        },
        { layout: 'code', console: 'clear', code: prog(R`
        String text = "xyz!";
        int k = 2;
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            if (c >= 'a' && c <= 'z') {
                sb.append((char) ('a' + (c - 'a' + k) % 26));
            } else {
                sb.append(c);
            }
        }
        System.out.println(sb);`), run: true, hl: [7, 9], say: 'Abgegeben! Die Zeile mit `% 26` ist der ganze Zauber: Position ausrechnen, verschieben, im Kreis bleiben, zurück in ein Zeichen.' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Das kannst du jetzt', items: ['Zeichen mit `charAt` lesen und mit `length()` durchlaufen', 'Mit `substring`, `indexOf`, `contains` Texte zerlegen', 'Strings richtig mit `equals` vergleichen', 'Mit `split` und `Integer.parseInt` Daten einlesen', 'Texte mit `StringBuilder` bauen und mit chars rechnen'], gap: 0.7 }, say: 'Das war Lektion 7! Nächstes Mal wird es groß: Du baust eigene Klassen und Objekte – zum Beispiel eine Spielfigur.' },
      ],
    },
  ],
};
