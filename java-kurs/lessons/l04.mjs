// Lektion 4 – Schleifen
const R = String.raw;
const prog = (body, imports = '') => `${imports}public class Main {\n    public static void main(String[] args) {\n${body.replace(/^\n/, '').replace(/\n$/, '')}\n    }\n}\n`;
const SC = 'import java.util.Scanner;\n\n';

export default {
  id: 'java-04', nr: 4,
  title: 'Schleifen',
  sub: 'Dinge wiederholen mit while, for und do-while – plus Zufallszahlen und dein erstes echtes Spiel.',
  outro: 'Mit Schleifen kann dein Programm Dinge tausendfach wiederholen – und mit Zufallszahlen hast du dein erstes Spiel gebaut. In Lektion 5 lernst du Arrays: viele Werte in einer einzigen Variable.',
  playground: prog(R`
        for (int i = 1; i <= 5; i++) {
            System.out.println("Runde " + i);
        }`),
  chapters: [
    {
      title: 'Warum Schleifen?',
      steps: [
        { t: 'Lektion 4', h: 'Schleifen', sub: 'Wiederholen, ohne alles hundertmal hinzuschreiben', say: 'Servus! Stell dir vor, du sollst hundertmal „Ich darf nicht schwätzen“ ausgeben. Hundert Zeilen `println`? Viel zu mühsam. Dafür gibt es **Schleifen**.' },
        { layout: 'code', console: 'clear', code: prog(R`
        System.out.println("Hallo!");
        System.out.println("Hallo!");
        System.out.println("Hallo!");
        System.out.println("Hallo!");
        System.out.println("Hallo!");`), hl: [3, 7], say: 'So würde es ohne Schleife aussehen: Fünfmal dieselbe Zeile. Bei hundert oder tausend Wiederholungen wäre das völlig verrückt.' },
        { code: prog(R`
        for (int i = 0; i < 5; i++) {
            System.out.println("Hallo!");
        }`), hl: [3, 5], run: true, say: 'Mit einer Schleife sind es nur drei Zeilen – egal ob fünfmal oder eine Million Mal. Schauen wir uns an, wie das funktioniert.' },
      ],
    },
    {
      title: 'Die while-Schleife',
      steps: [
        { t: 'Kapitel 2', h: 'while', sub: 'Solange etwas stimmt, wiederhole', after: 'split' },
        { layout: 'split', console: 'clear', visual: { kind: 'flow', items: [{ h: 'Bedingung prüfen', p: '`countdown > 0` ?', cls: 'hot' }, { h: '✅ true → Block ausführen', p: 'ausgeben, dann `countdown--`', cls: 'ok' }, { h: '↩ zurück nach oben', p: 'und wieder prüfen' }, { h: '❌ false → fertig', p: 'weiter nach der Schleife' }], gap: 1.0 }, code: prog(R`
        int countdown = 5;
        while (countdown > 0) {
            System.out.println(countdown + " ...");
            countdown--;
        }
        System.out.println("Abheben! 🚀");`), hl: [4, 7], say: 'Die einfachste Schleife ist `while`. Sie heißt auf Deutsch „solange“: **Solange** die Bedingung true ist, wird der Block wiederholt.' },
        { hl: [6, 6], say: 'Ganz wichtig ist diese Zeile: `countdown--` macht den Wert bei jedem Durchlauf kleiner. Irgendwann ist er 0 – dann ist die Bedingung false und die Schleife endet.' },
        { layout: 'all', run: true, say: '5, 4, 3, 2, 1 – und abheben! Nach dem letzten Durchlauf ist `countdown` 0. Die Bedingung stimmt nicht mehr, also geht es nach der Schleife weiter.' },
        { layout: 'split', visual: { kind: 'big', text: '⚠️ Endlosschleife', sub: 'Vergisst du `countdown--`, bleibt die Bedingung für immer true – das Programm hört nie auf.' }, hl: [6, 6], say: 'Achtung: Würdest du `countdown--` vergessen, wäre die Bedingung für immer erfüllt. Das ist eine **Endlosschleife** – das Programm hängt. Hier im Kurs kannst du sie mit dem Stopp-Knopf beenden.' },
        { quiz: { id: 'l4-q1', q: 'Wie oft wird „Hi“ ausgegeben?\n`int i = 0;`\n`while (i < 3) { System.out.println("Hi"); i++; }`', options: ['2-mal', '3-mal', '4-mal', 'unendlich oft'], correct: 1, explain: 'i ist 0, 1 und 2 – bei diesen Werten stimmt `i < 3`. Bei i = 3 ist Schluss. Also dreimal.' } },
      ],
    },
    {
      title: 'Die for-Schleife',
      steps: [
        { t: 'Kapitel 3', h: 'for', sub: 'Die Zählschleife', after: 'split' },
        { layout: 'split', console: 'clear', visual: { kind: 'table', title: 'Die drei Teile der for-Schleife', head: ['Teil', 'Beispiel', 'Wann?'], rows: [['Start', '`int i = 1`', 'einmal am Anfang'], ['Bedingung', '`i <= 5`', 'vor jedem Durchlauf'], ['Schritt', '`i++`', 'nach jedem Durchlauf']], gap: 0.9 }, code: prog(R`
        for (int i = 1; i <= 5; i++) {
            System.out.println("Runde " + i);
        }`), hl: [3, 3], say: 'Weil man so oft zählt, gibt es eine Kurzform: die `for`-Schleife. Sie packt alles in eine Zeile: den **Start**, die **Bedingung** und den **Schritt**.' },
        { layout: 'all', run: true, say: 'i startet bei 1, die Schleife läuft, solange i höchstens 5 ist, und nach jeder Runde wird i um eins erhöht. Die Variable `i` kannst du im Block benutzen.' },
        { layout: 'code', console: 'clear', code: prog(R`
        for (int i = 10; i >= 0; i -= 2) {
            System.out.print(i + " ");
        }
        System.out.println();`), hl: [3, 3], say: 'Du kannst auch rückwärts oder in größeren Schritten zählen: Hier von 10 hinunter auf 0, immer in Zweierschritten.' },
        { run: true, say: '10, 8, 6, 4, 2, 0. Mit `print` statt `println` landet alles in einer Zeile.' },
        { console: 'clear', code: prog(R`
        int summe = 0;
        for (int i = 1; i <= 100; i++) {
            summe += i;
        }
        System.out.println("1 + 2 + ... + 100 = " + summe);`), hl: [3, 6], say: 'Ein klassisches Muster: **Aufsummieren**. Wir starten mit einer Summe von 0 und addieren in jedem Durchlauf die aktuelle Zahl dazu.' },
        { run: true, say: '5050! Das soll der berühmte Mathematiker Gauß als Schüler im Kopf ausgerechnet haben. Java schafft es in einer Millisekunde.' },
        { quiz: { id: 'l4-q2', q: 'Was gibt `for (int i = 0; i < 4; i++) System.out.print(i);` aus?', options: ['1234', '0123', '01234', '4'], correct: 1, explain: 'i startet bei 0, und bei 4 ist Schluss (weil `i < 4`). Also 0, 1, 2, 3.' } },
      ],
    },
    {
      title: 'Zählen mit Bedingung',
      steps: [
        { t: 'Kapitel 4', h: 'Schleife + if', sub: 'Zählen, filtern, suchen', after: 'code' },
        { layout: 'code', console: 'clear', code: prog(R`
        int gerade = 0;
        for (int zahl = 1; zahl <= 20; zahl++) {
            if (zahl % 2 == 0) {
                gerade++;
                System.out.print(zahl + " ");
            }
        }
        System.out.println();
        System.out.println("Gerade Zahlen: " + gerade);`), hl: [5, 8], say: 'Richtig stark werden Schleifen mit `if` darin. Hier zählen wir, wie viele gerade Zahlen es von 1 bis 20 gibt. Erinnerst du dich? Bei geraden Zahlen ist der Rest durch 2 gleich 0.' },
        { run: true, say: 'Zehn gerade Zahlen. Das Muster „Zähler auf 0 setzen, in der Schleife hochzählen“ wirst du noch sehr oft brauchen.' },
        { console: 'clear', code: prog(R`
        for (int i = 1; i <= 15; i++) {
            if (i == 13) {
                continue;   // die 13 überspringen
            }
            if (i % 7 == 0 && i > 10) {
                System.out.println("Gefunden: " + i);
                break;      // Schleife sofort beenden
            }
            System.out.print(i + " ");
        }`), hl: [4, 10], say: 'Zwei nützliche Befehle: `continue` überspringt den Rest des aktuellen Durchlaufs, `break` beendet die ganze Schleife sofort.' },
        { run: true, say: 'Die Zahlen laufen durch, bis die erste Zahl über 10 gefunden ist, die durch 7 teilbar ist: 14. Dann bricht `break` ab – deshalb wird die 13 hier gar nicht erst erreicht.' },
      ],
    },
    {
      title: 'do-while',
      steps: [
        { t: 'Kapitel 5', h: 'do-while', sub: 'Erst machen, dann prüfen', after: 'code' },
        { layout: 'code', console: 'clear', code: prog(R`
        Scanner sc = new Scanner(System.in);
        int zahl;
        do {
            System.out.print("Zahl zwischen 1 und 10: ");
            zahl = sc.nextInt();
        } while (zahl < 1 || zahl > 10);
        System.out.println("Danke! Du hast " + zahl + " gewählt.");`, SC), hl: [7, 10], say: 'Bei `do-while` steht die Bedingung am **Ende**. Der Block läuft also mindestens einmal. Perfekt für Eingaben: Frag so lange nach, bis die Eingabe passt.' },
        { run: true, input: ['15', '0', '7'], say: 'Der Benutzer tippt zuerst 15, dann 0 – beides ungültig, also wird nochmal gefragt. Erst die 7 passt, und das Programm geht weiter.' },
        { quiz: { id: 'l4-q3', q: 'Was ist der Unterschied zwischen while und do-while?', options: ['do-while ist schneller', 'do-while führt den Block mindestens einmal aus', 'while kann keine Bedingung haben', 'Es gibt keinen Unterschied'], correct: 1, explain: 'do-while prüft die Bedingung erst am Ende – der Block läuft also immer mindestens einmal. Bei while kann es sein, dass er gar nicht läuft.' } },
      ],
    },
    {
      title: 'Schleifen in Schleifen',
      steps: [
        { t: 'Kapitel 6', h: 'Verschachtelte Schleifen', sub: 'Schleifen in Schleifen', after: 'code' },
        { layout: 'code', console: 'clear', code: prog(R`
        for (int zeile = 1; zeile <= 3; zeile++) {
            for (int spalte = 1; spalte <= 5; spalte++) {
                System.out.print("* ");
            }
            System.out.println();
        }`), hl: [3, 8], say: 'Eine Schleife kann in einer anderen stecken. Die **äußere** zählt die Zeilen, die **innere** die Sterne in jeder Zeile.' },
        { run: true, say: 'Für jede der 3 Zeilen läuft die innere Schleife 5-mal. Das ergibt 15 Sterne in einem Rechteck. Das `println` nach der inneren Schleife beendet jede Zeile.' },
        { console: 'clear', code: prog(R`
        for (int zeile = 1; zeile <= 5; zeile++) {
            for (int spalte = 1; spalte <= zeile; spalte++) {
                System.out.print("* ");
            }
            System.out.println();
        }`), hl: [4, 4], say: 'Kleiner Trick mit großer Wirkung: Läuft die innere Schleife nur bis `zeile` statt bis 5, wird jede Zeile einen Stern länger.' },
        { run: true, say: 'Ein Dreieck! Mit verschachtelten Schleifen kannst du Muster, Tabellen und Spielfelder bauen.' },
      ],
    },
    {
      title: 'Aufgabe: Einmaleins',
      steps: [
        { t: 'Aufgabe 1', h: 'Das große Einmaleins', sub: 'Jetzt bist du dran!', after: 'visual' },
        { layout: 'visual', visual: { kind: 'code', title: 'So soll der Anfang aussehen:', code: '   1   2   3   4   5   6   7   8   9  10\n   2   4   6   8  10  12  14  16  18  20\n   3   6   9  12  15  18  21  24  27  30\n ...', note: 'Tipp: `printf("%4d", zahl)` gibt jede Zahl 4 Zeichen breit aus – so stehen die Spalten sauber untereinander.', noteAt: 1.4 }, say: 'Jetzt bist du dran! Gib das ganze Einmaleins von 1 bis 10 als Tabelle aus. Du brauchst zwei verschachtelte Schleifen.' },
        {
          task: {
            id: 'l4-einmaleins', nr: 1, title: 'Das große Einmaleins',
            text: ['Gib das Einmaleins von 1 bis 10 als Tabelle aus: 10 Zeilen mit je 10 Zahlen. In Zeile 3 stehen also 3, 6, 9 … 30.', 'Damit die Spalten schön untereinander stehen, nimm `System.out.printf("%4d", zahl)` – das macht jede Zahl 4 Zeichen breit.'],
            req: ['Zwei verschachtelte `for`-Schleifen', '10 Zeilen mit je 10 Zahlen (zeile * spalte)', 'Nach jeder Zeile ein Zeilenumbruch', 'Saubere Spalten, z. B. mit `printf("%4d", …)`'],
            example: '   1   2   3   4   5   6   7   8   9  10\n   2   4   6   8  10  12  14  16  18  20\n   3   6   9  12  15  18  21  24  27  30\n   …\n  10  20  30  40  50  60  70  80  90 100',
            starter: prog(R`
        // Zwei Schleifen: außen die Zeilen, innen die Spalten

`),
            solution: prog(R`
        for (int zeile = 1; zeile <= 10; zeile++) {
            for (int spalte = 1; spalte <= 10; spalte++) {
                System.out.printf("%4d", zeile * spalte);
            }
            System.out.println();
        }`),
            tests: [{ name: 'Einmaleins-Tabelle', input: [], expect: [{ re: '^\\s*1\\s+2\\s+3\\s+4\\s+5\\s+6\\s+7\\s+8\\s+9\\s+10\\s*$', flags: 'm', label: 'erste Zeile 1 … 10' }, { re: '^\\s*3\\s+6\\s+9\\s+12\\s+15\\s+18\\s+21\\s+24\\s+27\\s+30\\s*$', flags: 'm', label: 'dritte Zeile 3 … 30' }, { re: '^\\s*10\\s+20\\s+30\\s+40\\s+50\\s+60\\s+70\\s+80\\s+90\\s+100\\s*$', flags: 'm', label: 'letzte Zeile 10 … 100' }] }],
            codeChecks: [{ label: 'verschachtelte for-Schleifen', re: 'for\\s*\\([^)]*\\)[\\s\\S]*for\\s*\\(' }],
            rubric: [['Programm kompiliert und läuft', 20], ['Verschachtelte Schleifen richtig eingesetzt', 30], ['Alle 100 Werte stimmen (10 × 10)', 35], ['Saubere Tabelle mit Zeilenumbrüchen', 15]],
            tip: 'Wenn alles in einer langen Zeile landet, fehlt das `System.out.println();` nach der inneren Schleife.',
          },
        },
        { layout: 'code', console: 'clear', code: prog(R`
        for (int zeile = 1; zeile <= 10; zeile++) {
            for (int spalte = 1; spalte <= 10; spalte++) {
                System.out.printf("%4d", zeile * spalte);
            }
            System.out.println();
        }`), run: true, say: 'Abgegeben! So könnte es aussehen: Die innere Schleife füllt eine Zeile, `printf("%4d")` sorgt für saubere Spalten, und `println()` beendet jede Zeile.' },
      ],
    },
    {
      title: 'Zufallszahlen',
      steps: [
        { t: 'Kapitel 8', h: 'Zufall', sub: 'Würfeln mit Java', after: 'code' },
        { layout: 'code', console: 'clear', code: prog(R`
        Random zufall = new Random();
        int wurf = zufall.nextInt(6) + 1;
        System.out.println("Du hast eine " + wurf + " gewürfelt!");`, 'import java.util.Random;\n\n'), hl: [6, 6], say: 'Für Spiele brauchst du Zufall. Den liefert die Klasse `Random`. `nextInt(6)` gibt eine Zufallszahl von 0 bis 5 – mit `+ 1` wird daraus ein Würfel von 1 bis 6.' },
        { console: 'clear', code: prog(R`
        Random zufall = new Random(42);   // fester Startwert -> immer gleiche Folge
        for (int i = 1; i <= 10; i++) {
            System.out.print((zufall.nextInt(6) + 1) + " ");
        }
        System.out.println();`, 'import java.util.Random;\n\n'), hl: [5, 5], say: 'Kleiner Profi-Trick: Gibst du `new Random` eine Zahl mit, kommen bei jedem Start dieselben „Zufallszahlen“. Das ist praktisch zum Testen. Hier würfeln wir zehnmal.' },
        { run: true, say: 'Zehn Würfe in einer Schleife. Ohne die 42 in den Klammern wären die Zahlen bei jedem Start anders.' },
        { quiz: { id: 'l4-q4', q: 'Welcher Ausdruck liefert eine Zufallszahl von 1 bis 100?', options: ['`zufall.nextInt(100)`', '`zufall.nextInt(100) + 1`', '`zufall.nextInt(101)`', '`zufall.nextInt(1, 100)`'], correct: 1, explain: '`nextInt(100)` liefert 0 bis 99. Mit `+ 1` werden daraus 1 bis 100.' } },
      ],
    },
    {
      title: 'Aufgabe: Zahlenraten',
      steps: [
        { t: 'Aufgabe 2', h: 'Zahlenraten', sub: 'Dein erstes echtes Spiel', after: 'visual' },
        { layout: 'visual', visual: { kind: 'code', title: 'So könnte dein Spiel aussehen:', code: 'Ich denke an eine Zahl von 1 bis 100.\nDein Tipp: 50\nZu groß!\nDein Tipp: 25\nZu klein!\nDein Tipp: 37\nRichtig! Du hast 3 Versuche gebraucht.' }, say: 'Jetzt baust du dein erstes echtes Spiel: **Zahlenraten**! Der Computer denkt sich eine Zahl aus, und der Spieler rät so lange, bis er sie trifft.' },
        {
          task: {
            id: 'l4-zahlenraten', nr: 2, title: 'Zahlenraten',
            text: ['Der Computer wählt eine Zufallszahl von 1 bis 100. Der Spieler rät so lange, bis er die Zahl trifft.', 'Nach jedem Tipp sagt das Programm „Zu klein!“ oder „Zu groß!“. Am Ende verrät es, wie viele Versuche gebraucht wurden.'],
            req: ['Zufallszahl von 1 bis 100 mit `Random`', 'Tipps mit dem `Scanner` einlesen', 'Eine Schleife, die läuft, bis die Zahl erraten ist', 'Hinweise „Zu klein!“ und „Zu groß!“', 'Versuche zählen und am Ende ausgeben'],
            example: 'Ich denke an eine Zahl von 1 bis 100.\nDein Tipp: 50\nZu groß!\nDein Tipp: 25\nZu klein!\nDein Tipp: 37\nRichtig! Du hast 3 Versuche gebraucht.',
            starter: prog(R`
        Scanner sc = new Scanner(System.in);
        Random zufall = new Random();
        int geheim = zufall.nextInt(100) + 1;
        System.out.println("Ich denke an eine Zahl von 1 bis 100.");
        // Dein Spiel

`, 'import java.util.Random;\nimport java.util.Scanner;\n\n'),
            solution: prog(R`
        Scanner sc = new Scanner(System.in);
        Random zufall = new Random();
        int geheim = zufall.nextInt(100) + 1;
        System.out.println("Ich denke an eine Zahl von 1 bis 100.");
        int tipp = 0;
        int versuche = 0;
        while (tipp != geheim) {
            System.out.print("Dein Tipp: ");
            tipp = sc.nextInt();
            versuche++;
            if (tipp < geheim) {
                System.out.println("Zu klein!");
            } else if (tipp > geheim) {
                System.out.println("Zu groß!");
            }
        }
        System.out.println("Richtig! Du hast " + versuche + " Versuche gebraucht.");`, 'import java.util.Random;\nimport java.util.Scanner;\n\n'),
            tests: [
              { name: 'Raten von 1 aufwärts (findet jede Zahl)', input: Array.from({ length: 100 }, (_, i) => String(i + 1)), expect: [{ re: 'richtig|erraten|geschafft|gewonnen|treffer', label: 'Meldung bei richtiger Zahl' }, { re: '\\d+\\s*(versuch|tipp|mal)', label: 'Anzahl der Versuche' }] },
              { name: 'Raten von 100 abwärts (Hinweis „zu groß“)', input: Array.from({ length: 100 }, (_, i) => String(100 - i)), expect: [{ re: 'richtig|erraten|geschafft|gewonnen|treffer', label: 'Meldung bei richtiger Zahl' }] },
            ],
            codeChecks: [{ label: 'Random verwendet', re: 'new\\s+Random\\s*\\(' }, { label: 'Schleife verwendet', re: '\\bwhile\\b|\\bfor\\b' }, { label: 'Hinweise zu klein / zu groß', re: 'zu\\s+klein[\\s\\S]*zu\\s+gro|zu\\s+gro[\\s\\S]*zu\\s+klein', flags: 'i' }],
            rubric: [['Programm kompiliert und läuft', 15], ['Zufallszahl von 1 bis 100', 15], ['Schleife läuft genau bis zum richtigen Tipp', 30], ['Hinweise zu klein / zu groß stimmen', 25], ['Versuche werden gezählt und ausgegeben', 15]],
            tip: 'Zum Testen kannst du die geheime Zahl kurz mit `System.out.println(geheim);` ausgeben – vor dem Abgeben wieder löschen!',
          },
        },
        { layout: 'code', console: 'clear', code: prog(R`
        Scanner sc = new Scanner(System.in);
        Random zufall = new Random(7);
        int geheim = zufall.nextInt(100) + 1;
        System.out.println("Ich denke an eine Zahl von 1 bis 100.");
        int tipp = 0;
        int versuche = 0;
        while (tipp != geheim) {
            System.out.print("Dein Tipp: ");
            tipp = sc.nextInt();
            versuche++;
            if (tipp < geheim) {
                System.out.println("Zu klein!");
            } else if (tipp > geheim) {
                System.out.println("Zu groß!");
            }
        }
        System.out.println("Richtig! Du hast " + versuche + " Versuche gebraucht.");`, 'import java.util.Random;\nimport java.util.Scanner;\n\n'), hl: [11, 21], say: 'Abgegeben! Hier eine mögliche Lösung. Die while-Schleife läuft, solange der Tipp nicht stimmt. Für das Video haben wir einen festen Startwert genommen.' },
        { run: true, input: ['50', '25', '37'], say: 'Mit der klugen Strategie – immer die Mitte raten – klappt es hier schon nach 3 Versuchen. So findest du jede Zahl von 1 bis 100 in höchstens 7 Versuchen. Das nennt man **binäre Suche**.' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Das kannst du jetzt', items: ['Wiederholen mit `while` und `do-while`', 'Zählen mit der `for`-Schleife', 'Muster: Summe bilden und Treffer zählen', '`break` und `continue`', 'Verschachtelte Schleifen für Tabellen und Muster', 'Zufallszahlen mit `Random`'], gap: 0.7 }, say: 'Das war Lektion 4 – und du hast dein erstes Spiel gebaut! In Lektion 5 lernst du **Arrays**: Damit speicherst du viele Werte in einer einzigen Variable.' },
      ],
    },
  ],
};
