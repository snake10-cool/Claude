// Kursplan, Lernziel und Transfer-Challenges (Aufgaben, die so nie gezeigt wurden – lösbar mit Lektion 1–5)
const R = String.raw;
const prog = (body, imports = '') => `${imports}public class Main {\n    public static void main(String[] args) {\n${body.replace(/^\n/, '').replace(/\n$/, '')}\n    }\n}\n`;
const SC = 'import java.util.Scanner;\n\n';
const RS = 'import java.util.Random;\nimport java.util.Scanner;\n\n';
const lines = n => Array.from({ length: n }, (_, i) => String(i + 1));

export default {
  goal: 'Am Ende von **12 Lektionen** baust du ein eigenes **Abschlussprojekt** – zum Beispiel Tic-Tac-Toe gegen den Computer oder eine Fangbuch-App für deine Fische. Dafür lernst du alles, was ein Java-Programm im ersten Lernjahr (Schule, HTL, Uni-Einstieg) ausmacht: von Variablen über Schleifen bis zu eigenen Klassen und Objekten.',
  canDo: [
    { h: '🎮 Konsolen-Spiele', p: 'Tic-Tac-Toe, Galgenmännchen, Schiffe versenken, Zahlenraten mit Highscore' },
    { h: '📋 Verwaltungs-Programme', p: 'Fangbuch, Notenverwaltung, Einkaufsliste – mit eigenen Klassen und Listen' },
    { h: '🧮 Rechner & Auswertungen', p: 'Statistiken, Tabellen, Umrechner, Prüfungen von Eingaben' },
    { h: '🚀 Sprungbrett', p: 'Die Grundlage für Android-Apps, Minecraft-Plugins und den Informatik-Unterricht' },
  ],
  plan: [
    { nr: 1, title: 'Hallo Java!', what: 'erstes Programm, Ausgaben, Fehler lesen' },
    { nr: 2, title: 'Variablen & Datentypen', what: 'Werte speichern und rechnen' },
    { nr: 3, title: 'Eingaben & Entscheidungen', what: 'Scanner, if/else, logische Operatoren' },
    { nr: 4, title: 'Schleifen', what: 'while, for, Zufall – dein erstes Spiel' },
    { nr: 5, title: 'Arrays', what: 'viele Werte, sortieren, suchen' },
    { nr: 6, title: 'Methoden', what: 'Eigene Befehle schreiben: Parameter, Rückgabewerte, Code sinnvoll aufteilen.' },
    { nr: 7, title: 'Strings im Detail', what: 'Text zerlegen und prüfen: charAt, substring, Palindrome, Passwort-Prüfer.' },
    { nr: 8, title: 'Klassen & Objekte', what: 'Eigene Datentypen wie Fisch oder Spieler – mit Konstruktor und Methoden.' },
    { nr: 9, title: 'ArrayList & Kapselung', what: 'Listen, die wachsen, und private Attribute mit Gettern – die Fangbuch-Verwaltung.' },
    { nr: 10, title: 'Vererbung', what: 'Gemeinsames in Oberklassen: Tiere, Spielfiguren, überschriebene Methoden.' },
    { nr: 11, title: 'Spielfelder & Fehlerbehandlung', what: '2D-Arrays für Spielbretter und try/catch für falsche Eingaben.' },
    { nr: 12, title: 'Abschlussprojekt', what: 'Tic-Tac-Toe gegen den Computer oder eine Fangbuch-App – du entscheidest.' },
  ],
  playground: prog(R`
        // Probier hier alles aus, was du gelernt hast
        for (int i = 1; i <= 3; i++) {
            System.out.println("Hallo zum " + i + ". Mal!");
        }`),
  challenges: [
    {
      id: 'c1', level: '★☆☆ leicht', title: 'FizzBuzz',
      teaser: 'Das berühmteste Einstellungs-Rätsel für Programmierer: Zahlen von 1 bis 100 – aber mit einem Dreh.',
      uses: ['for', '%', 'else if'],
      text: ['Gib die Zahlen von 1 bis 100 aus, jede in einer eigenen Zeile. Aber: Ist die Zahl durch 3 teilbar, gib stattdessen „Fizz“ aus. Ist sie durch 5 teilbar, „Buzz“. Ist sie durch 3 **und** 5 teilbar, „FizzBuzz“.', 'Das Spiel wird gern bei Bewerbungsgesprächen verwendet – viele stolpern über die Reihenfolge der Bedingungen.'],
      req: ['100 Zeilen Ausgabe', 'Vielfache von 3 → `Fizz`, von 5 → `Buzz`, von beiden → `FizzBuzz`', 'Alle anderen Zahlen werden normal ausgegeben'],
      example: '1\n2\nFizz\n4\nBuzz\nFizz\n7\n…\n14\nFizzBuzz\n16',
      lookup: ['Lektion 2 · Rechnen: `zahl % 3 == 0` heißt „durch 3 teilbar“', 'Lektion 3 · else if: Die erste passende Bedingung gewinnt – was muss also zuerst geprüft werden?', 'Lektion 4 · die for-Schleife von 1 bis 100'],
      starter: prog(R`
        // FizzBuzz von 1 bis 100
`),
      solution: prog(R`
        for (int i = 1; i <= 100; i++) {
            if (i % 15 == 0) {
                System.out.println("FizzBuzz");
            } else if (i % 3 == 0) {
                System.out.println("Fizz");
            } else if (i % 5 == 0) {
                System.out.println("Buzz");
            } else {
                System.out.println(i);
            }
        }`),
      tests: [{ name: 'FizzBuzz 1–100', input: [], expect: [
        { re: '^1$', flags: 'm', label: '1 wird ausgegeben' }, { re: '^Fizz$', flags: 'm', label: 'Fizz bei Vielfachen von 3' }, { re: '^Buzz$', flags: 'm', label: 'Buzz bei Vielfachen von 5' },
        { re: '^FizzBuzz$', flags: 'm', label: 'FizzBuzz bei 15, 30, …' }, { re: '^98$', flags: 'm', label: 'normale Zahlen bis 100' },
        { re: '^15$', flags: 'm', not: true, label: '15 erscheint nicht als Zahl' }, { re: '^(Fizz|Buzz)\\n(?=16)', flags: 'm', not: true, label: 'bei 15 kommt FizzBuzz (nicht nur Fizz)' }] }],
      codeChecks: [{ label: 'Schleife verwendet', re: '\\bfor\\b|\\bwhile\\b' }, { label: 'Modulo % verwendet', re: '%' }],
      rubric: [['Programm kompiliert und läuft', 20], ['Alle Zahlen 1 bis 100 in eigener Zeile', 20], ['Fizz und Buzz richtig', 30], ['FizzBuzz richtig (Reihenfolge der Bedingungen)', 30]],
      tip: 'Prüfe die strengste Bedingung (durch 3 und 5) zuerst – sonst landet 15 schon bei „Fizz“.',
    },
    {
      id: 'c2', level: '★★☆ mittel', title: 'Primzahl-Detektor',
      teaser: 'Ist 91 eine Primzahl? Dein Programm findet es heraus – für jede Zahl.',
      uses: ['Scanner', 'Schleife', '%', 'boolean', 'break'],
      text: ['Eine **Primzahl** ist eine Zahl größer als 1, die nur durch 1 und sich selbst teilbar ist (2, 3, 5, 7, 11, …).', 'Lies eine ganze Zahl ein und gib aus, ob sie eine Primzahl ist. Achtung: 1 ist keine Primzahl, 2 schon.'],
      req: ['Zahl mit dem Scanner einlesen', 'Mit einer Schleife nach Teilern suchen', 'Ausgabe „… ist eine Primzahl“ oder „… ist keine Primzahl“', 'Richtig auch für 1, 2 und z. B. 91 (= 7 · 13)'],
      example: 'Zahl: 97\n97 ist eine Primzahl.',
      lookup: ['Lektion 2 · `%`: Ist der Rest 0, ist die Zahl teilbar', 'Lektion 4 · Zählen mit Bedingung und `break`', 'Idee: Merk dir in einer `boolean`-Variable, ob du einen Teiler gefunden hast'],
      starter: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Zahl: ");
        int n = sc.nextInt();
        // Ist n eine Primzahl?
`, SC),
      solution: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Zahl: ");
        int n = sc.nextInt();
        boolean prim = n >= 2;
        for (int t = 2; t * t <= n; t++) {
            if (n % t == 0) {
                prim = false;
                break;
            }
        }
        if (prim) {
            System.out.println(n + " ist eine Primzahl.");
        } else {
            System.out.println(n + " ist keine Primzahl.");
        }`, SC),
      tests: [
        { name: '97 (Primzahl)', input: ['97'], expect: [{ re: 'prim', label: 'Primzahl erkannt' }, { re: 'kein|nicht', not: true, label: 'nicht fälschlich „keine“' }] },
        { name: '2 (kleinste Primzahl)', input: ['2'], expect: [{ re: 'prim', label: '2 ist Primzahl' }, { re: 'kein|nicht', not: true, label: '2 ist nicht „keine“' }] },
        { name: '91 (= 7 · 13)', input: ['91'], expect: [{ re: 'kein|nicht', label: '91 ist keine Primzahl' }] },
        { name: '1 (keine Primzahl)', input: ['1'], expect: [{ re: 'kein|nicht', label: '1 ist keine Primzahl' }] },
        { name: '12', input: ['12'], expect: [{ re: 'kein|nicht', label: '12 ist keine Primzahl' }] },
      ],
      codeChecks: [{ label: 'Schleife verwendet', re: '\\bfor\\b|\\bwhile\\b' }, { label: 'Modulo % verwendet', re: '%' }],
      rubric: [['Programm kompiliert und läuft', 15], ['Eingabe mit Scanner', 10], ['Richtige Teilersuche mit Schleife und %', 35], ['Sonderfälle 1 und 2 richtig', 20], ['Klare Ausgabe', 20]],
      tip: 'Du musst nur Teiler von 2 bis n − 1 prüfen. Profis hören schon bei der Wurzel von n auf.',
    },
    {
      id: 'c3', level: '★★☆ mittel', title: 'Quersumme',
      teaser: 'Wie zerlegt man 4711 in seine Ziffern – ohne Text, nur mit Rechnen?',
      uses: ['while', '% 10', '/ 10'],
      text: ['Die **Quersumme** ist die Summe aller Ziffern einer Zahl: 4711 → 4 + 7 + 1 + 1 = 13.', 'Lies eine positive ganze Zahl ein und gib ihre Quersumme aus. Der Trick: Du brauchst nur `%` und `/` – keine Strings.'],
      req: ['Zahl mit dem Scanner einlesen', 'Ziffern mit `% 10` und `/ 10` in einer Schleife abarbeiten', 'Quersumme ausgeben'],
      example: 'Zahl: 4711\nQuersumme: 13',
      lookup: ['Lektion 2 · Ganzzahl-Division: `4711 % 10` ist 1 (letzte Ziffer), `4711 / 10` ist 471 (Ziffer abgeschnitten)', 'Lektion 4 · while: Wiederhole, solange die Zahl größer als 0 ist', 'Lektion 4 · Muster „Summe bilden“'],
      starter: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Zahl: ");
        int n = sc.nextInt();
        // Quersumme berechnen
`, SC),
      solution: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Zahl: ");
        int n = sc.nextInt();
        int summe = 0;
        while (n > 0) {
            summe += n % 10;
            n = n / 10;
        }
        System.out.println("Quersumme: " + summe);`, SC),
      tests: [
        { name: '4711', input: ['4711'], expect: [{ re: '\\b13\\b', label: 'Quersumme 13' }] },
        { name: '999999', input: ['999999'], expect: [{ re: '\\b54\\b', label: 'Quersumme 54' }] },
        { name: '1000', input: ['1000'], expect: [{ re: '\\b1\\b', label: 'Quersumme 1' }] },
        { name: '7', input: ['7'], expect: [{ re: '\\b7\\b', label: 'Quersumme 7' }] },
      ],
      codeChecks: [{ label: 'Schleife verwendet', re: '\\bwhile\\b|\\bfor\\b' }, { label: '% 10 verwendet', re: '%\\s*10' }],
      rubric: [['Programm kompiliert und läuft', 15], ['Eingabe mit Scanner', 10], ['Ziffern richtig mit % und / zerlegt', 45], ['Richtiges Ergebnis für alle Zahlen', 30]],
      tip: 'Spiel es auf Papier durch: 4711 → Rest 1, weiter mit 471 → Rest 1, weiter mit 47 → …',
    },
    {
      id: 'c4', level: '★★☆ mittel', title: 'Würfel-Statistik',
      teaser: 'Ist der Zufall fair? Würfle 6000-mal und zeichne ein Balkendiagramm aus Sternen.',
      uses: ['Random', 'Array als Zähler', 'verschachtelte Schleifen', 'printf'],
      text: ['Würfle 6000-mal mit `Random` und zähle, wie oft jede Augenzahl von 1 bis 6 kommt. Benutze dafür ein **Array als Zähler**: Fach 3 zählt zum Beispiel die Dreier.', 'Gib dann für jede Augenzahl die Anzahl aus und dahinter einen Balken: ein Stern pro 100 Würfe.'],
      req: ['6000 Würfe mit `Random`', 'Ein `int`-Array zählt die Augenzahlen', 'Sechs Zeilen: Augenzahl, Anzahl und Sterne-Balken', 'Ein Stern pro 100 Würfe'],
      example: '1:  987 *********\n2: 1013 **********\n3: 1002 **********\n4:  998 *********\n5: 1021 **********\n6:  979 *********',
      lookup: ['Lektion 5 · Arrays: `anzahl[wurf]++` erhöht genau das Fach für diese Augenzahl', 'Lektion 4 · Zufall: `nextInt(6) + 1` und verschachtelte Schleifen für die Sterne', 'Lektion 3 · printf mit `%4d` für saubere Spalten'],
      starter: prog(R`
        Random zufall = new Random();
        // Würfeln, zählen, Balken ausgeben
`, 'import java.util.Random;\n\n'),
      solution: prog(R`
        Random zufall = new Random();
        int[] anzahl = new int[7];
        for (int i = 0; i < 6000; i++) {
            anzahl[zufall.nextInt(6) + 1]++;
        }
        for (int augen = 1; augen <= 6; augen++) {
            System.out.printf("%d: %4d ", augen, anzahl[augen]);
            for (int s = 0; s < anzahl[augen] / 100; s++) {
                System.out.print("*");
            }
            System.out.println();
        }`, 'import java.util.Random;\n\n'),
      tests: [{ name: 'Sechs Balken', input: [], expect: [1, 2, 3, 4, 5, 6].map(z => ({ re: `^\\s*${z}\\D[^\\n]*\\d+[^\\n]*\\*{5,}`, flags: 'm', label: `Zeile für ${z} mit Anzahl und Sternen` })) }],
      codeChecks: [{ label: 'int-Array als Zähler', re: 'int\\s*\\[\\s*\\]' }, { label: 'Würfel mit nextInt(6)', re: 'nextInt\\s*\\(\\s*6\\s*\\)' }],
      rubric: [['Programm kompiliert und läuft', 15], ['6000 Würfe richtig gezählt (Array als Zähler)', 40], ['Sechs Zeilen mit Augenzahl und Anzahl', 20], ['Sterne-Balken richtig (1 Stern pro 100)', 25]],
      tip: 'Mach das Array 7 Fächer groß und benutze nur die Fächer 1 bis 6 – dann passt die Augenzahl direkt als Index.',
    },
    {
      id: 'c5', level: '★★★ knifflig', title: 'Schere, Stein, Papier',
      teaser: 'Drei Runden gegen den Computer – mit Punktestand und Sieger.',
      uses: ['Scanner', 'String-Array', 'Random', 'equals', '&& ||'],
      text: ['Spiel drei Runden „Schere, Stein, Papier“ gegen den Computer. Der Spieler tippt `schere`, `stein` oder `papier`, der Computer wählt zufällig.', 'Schere schlägt Papier, Stein schlägt Schere, Papier schlägt Stein. Nach jeder Runde zeigt das Programm die Wahl des Computers und wer den Punkt bekommt. Am Ende: Endstand und Sieger.'],
      req: ['Drei Runden mit einer Schleife', 'Computer wählt zufällig aus einem `String`-Array', 'Vergleich der Texte mit `equals`', 'Richtiger Punkt in jeder Runde (oder unentschieden)', 'Endstand und Gesamtsieger'],
      example: 'Runde 1 – schere, stein oder papier? stein\nComputer: schere\nPunkt für dich!\n…\nEndstand 2:1\nDu hast gewonnen!',
      lookup: ['Lektion 3 · Strings vergleichen: immer `equals`, nie `==`', 'Lektion 5 · `String[] wahl = {"schere", "stein", "papier"};` und `wahl[zufall.nextInt(3)]`', 'Lektion 3 · `&&` und `||` kombinieren – Klammern helfen beim Lesen'],
      starter: prog(R`
        Scanner sc = new Scanner(System.in);
        Random zufall = new Random();
        String[] wahl = {"schere", "stein", "papier"};
        // Drei Runden spielen
`, RS),
      solution: prog(R`
        Scanner sc = new Scanner(System.in);
        Random zufall = new Random();
        String[] wahl = {"schere", "stein", "papier"};
        int ich = 0, pc = 0;
        for (int runde = 1; runde <= 3; runde++) {
            System.out.print("Runde " + runde + " – schere, stein oder papier? ");
            String du = sc.next();
            String comp = wahl[zufall.nextInt(3)];
            System.out.println("Computer: " + comp);
            if (du.equals(comp)) {
                System.out.println("Unentschieden!");
            } else if ((du.equals("schere") && comp.equals("papier")) || (du.equals("stein") && comp.equals("schere")) || (du.equals("papier") && comp.equals("stein"))) {
                System.out.println("Punkt für dich!");
                ich++;
            } else {
                System.out.println("Punkt für den Computer!");
                pc++;
            }
        }
        System.out.println("Endstand " + ich + ":" + pc);
        if (ich > pc) {
            System.out.println("Du hast gewonnen!");
        } else if (pc > ich) {
            System.out.println("Du hast verloren!");
        } else {
            System.out.println("Unentschieden!");
        }`, RS),
      tests: [
        { name: 'Drei Runden spielen', input: ['stein', 'papier', 'schere'], expect: [{ re: '(schere|stein|papier)', label: 'Wahl des Computers wird angezeigt' }, { re: 'gewonnen|verloren|unentschieden', label: 'Ergebnis am Ende' }, { re: '\\d\\s*:\\s*\\d|\\d\\s+zu\\s+\\d', label: 'Endstand' }] },
        { name: 'Nochmal (anderer Zufall)', input: ['papier', 'papier', 'papier'], expect: [{ re: 'gewonnen|verloren|unentschieden', label: 'Ergebnis am Ende' }] },
      ],
      codeChecks: [{ label: 'Texte mit equals verglichen', re: '\\.equals\\s*\\(' }, { label: 'Zufall mit Random', re: 'nextInt\\s*\\(\\s*3\\s*\\)' }, { label: 'Schleife für die Runden', re: '\\bfor\\b|\\bwhile\\b' }],
      rubric: [['Programm kompiliert und läuft', 15], ['Drei Runden mit Eingabe und Zufallswahl', 20], ['Gewinner jeder Runde richtig bestimmt (alle Kombinationen)', 35], ['Punkte gezählt, Endstand und Sieger richtig', 20], ['Verständliche Ausgabe', 10]],
      tip: 'Schreib dir zuerst die drei Fälle auf, in denen DU gewinnst. Alles andere ist entweder unentschieden oder ein Punkt für den Computer.',
    },
    {
      id: 'c6', level: '★★★ knifflig', title: 'Sternen-Pyramide',
      teaser: 'Aus dem Dreieck aus Lektion 4 wird eine echte, mittige Pyramide – für jede Höhe.',
      uses: ['Scanner', 'verschachtelte Schleifen', 'Muster rechnen'],
      text: ['Lies eine Höhe ein und zeichne eine **mittige Pyramide** aus Sternen. Bei Höhe 4 sieht sie so aus:', '`   *` · `  ***` · ` *****` · `*******` – jede Zeile hat zwei Sterne mehr und ein Leerzeichen weniger davor.'],
      req: ['Höhe mit dem Scanner einlesen', 'Jede Zeile: erst Leerzeichen, dann Sterne', 'Zeile z hat `h − z` Leerzeichen und `2·z − 1` Sterne', 'Funktioniert für jede Höhe'],
      example: 'Höhe: 4\n   *\n  ***\n *****\n*******',
      lookup: ['Lektion 4 · Verschachtelte Schleifen: das Sternen-Dreieck', 'Tipp: Zähl bei Höhe 4 nach – wie viele Leerzeichen und Sterne hat Zeile 1, 2, 3, 4?', 'Lektion 1 · `print` bleibt in der Zeile, `println` beendet sie'],
      starter: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Höhe: ");
        int h = sc.nextInt();
        // Pyramide zeichnen
`, SC),
      solution: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Höhe: ");
        int h = sc.nextInt();
        for (int zeile = 1; zeile <= h; zeile++) {
            for (int s = 0; s < h - zeile; s++) {
                System.out.print(" ");
            }
            for (int k = 0; k < 2 * zeile - 1; k++) {
                System.out.print("*");
            }
            System.out.println();
        }`, SC),
      tests: [
        { name: 'Höhe 3', input: ['3'], expect: [{ re: ' {2}\\*[ \\t]*\\n \\*{3}[ \\t]*\\n\\*{5}[ \\t]*(\\n|$)', label: 'Pyramide der Höhe 3' }] },
        { name: 'Höhe 5', input: ['5'], expect: [{ re: ' {4}\\*[ \\t]*\\n {3}\\*{3}[ \\t]*\\n {2}\\*{5}[ \\t]*\\n \\*{7}[ \\t]*\\n\\*{9}[ \\t]*(\\n|$)', label: 'Pyramide der Höhe 5' }] },
        { name: 'Höhe 1', input: ['1'], expect: [{ re: '(^|[^*])\\*[ \\t]*(\\n|$)', label: 'ein einzelner Stern' }, { re: '\\*\\*', not: true, label: 'nicht mehr als ein Stern' }] },
      ],
      codeChecks: [{ label: 'verschachtelte Schleifen', re: 'for\\s*\\([^)]*\\)[\\s\\S]*for\\s*\\(' }],
      rubric: [['Programm kompiliert und läuft', 15], ['Eingabe der Höhe', 10], ['Richtige Anzahl Sterne pro Zeile', 30], ['Richtige Anzahl Leerzeichen (mittig)', 30], ['Funktioniert für beliebige Höhen', 15]],
      tip: 'Zeichne erst nur die Sterne (2·z − 1), ohne Leerzeichen. Wenn das stimmt, kommen die Leerzeichen davor.',
    },
  ],
};
