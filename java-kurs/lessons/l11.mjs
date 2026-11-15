// Lektion 11 – Spielfelder & Fehlerbehandlung
const R = String.raw;
const prog = (body, imports = '') => `${imports}public class Main {\n    public static void main(String[] args) {\n${body.replace(/^\n/, '').replace(/\n$/, '')}\n    }\n}\n`;
const cls = (members, mainBody, imports = '') => `${imports}public class Main {\n${members.replace(/^\n/, '').replace(/\n$/, '')}\n\n    public static void main(String[] args) {\n${mainBody.replace(/^\n/, '').replace(/\n$/, '')}\n    }\n}\n`;
const SC = 'import java.util.Scanner;\n\n';

const LEVEL = R`
        String[] level = {
            "##########",
            "#@...#...#",
            "#.##.#.#.#",
            "#....#.#Z#",
            "##.....#.#",
            "##########"
        };`;

export default {
  id: 'java-11', nr: 11,
  title: 'Spielfelder & Fehlerbehandlung',
  sub: '2D-Arrays als Spielwelt, Bewegung mit Kollision – und Programme, die bei falschen Eingaben nicht abstürzen.',
  outro: 'Ein Spielfeld aus Kacheln, Kollision mit Wänden und robuste Eingaben: Genau diese Ideen stecken auch in unserem Jump’n’Run. In Lektion 12 baust du dein Java-Abschlussprojekt.',
  chapters: [
    {
      title: 'Zweidimensionale Arrays',
      steps: [
        { t: 'Lektion 11', h: 'Spielfelder', sub: 'und Fehlerbehandlung', say: 'Servus! Fast jedes 2D-Spiel besteht aus einem **Gitter aus Kacheln**: Wand, Boden, Münze, Ziel. Heute lernst du, solche Spielfelder zu bauen – mit zweidimensionalen Arrays.' },
        { layout: 'visual', visual: { kind: 'html', html: '<h4>Ein Gitter: Zeile und Spalte</h4><table class="vt grid-demo"><thead><tr><th></th>' + [0, 1, 2, 3].map(i => `<th>Spalte ${i}</th>`).join('') + '</tr></thead><tbody>' + [['#', '#', '#', '#'], ['#', '@', '.', '#'], ['#', '.', 'Z', '#']].map((r, y) => `<tr data-s="${0.4 + y * 0.6}"><th>Zeile ${y}</th>${r.map(c => `<td><code>${c}</code></td>`).join('')}</tr>`).join('') + '</tbody></table><p class="vnote" data-s="2.4"><code>feld[1][1]</code> ist der Spieler <code>@</code>, <code>feld[2][2]</code> das Ziel <code>Z</code>. Zuerst die Zeile, dann die Spalte.</p>' }, say: 'Ein 2D-Array ist ein Array aus Arrays: Jede Zeile ist selbst ein Array. Du greifst mit zwei Indizes zu – zuerst die **Zeile**, dann die **Spalte**.' },
        { layout: 'code', console: 'clear', code: prog(R`
        char[][] feld = new char[3][5];
        for (int y = 0; y < feld.length; y++) {
            for (int x = 0; x < feld[y].length; x++) {
                feld[y][x] = '.';
            }
        }
        feld[1][2] = '@';
        for (int y = 0; y < feld.length; y++) {
            for (int x = 0; x < feld[y].length; x++) {
                System.out.print(feld[y][x]);
            }
            System.out.println();
        }`), hl: [3, 8], say: '`new char[3][5]` macht 3 Zeilen mit je 5 Spalten. Zum Füllen brauchst du **zwei verschachtelte Schleifen**: außen die Zeilen y, innen die Spalten x.' },
        { run: true, hl: [10, 15], say: 'Ausgeben geht genauso: Zeichen für Zeichen, und nach jeder Zeile ein Zeilenumbruch. `feld.length` ist die Anzahl Zeilen, `feld[y].length` die Breite.' },
        { quiz: { id: 'l11-q1', q: '`int[][] a = new int[4][7];` – Was ist `a[0].length`?', options: ['4', '7', '28', '0'], correct: 1, explain: 'a hat 4 Zeilen, und jede Zeile a[0] … a[3] ist ein Array mit 7 Einträgen.' } },
      ],
    },
    {
      title: 'Level aus Text',
      steps: [
        { t: 'Kapitel 2', h: 'Level aus Text', sub: 'So bauen echte Spiele ihre Welten', after: 'code' },
        { layout: 'code', console: 'clear', code: prog(LEVEL + R`
        char[][] feld = new char[level.length][];
        for (int y = 0; y < level.length; y++) {
            feld[y] = level[y].toCharArray();
        }
        int muenzen = 0;
        for (int y = 0; y < feld.length; y++) {
            for (int x = 0; x < feld[y].length; x++) {
                if (feld[y][x] == '.') muenzen++;
            }
        }
        System.out.println("Breite " + feld[0].length + ", Höhe " + feld.length + ", Punkte: " + muenzen);`), hl: [2, 9], say: 'Level von Hand mit Schleifen zu bauen ist mühsam. Viel besser: Du **zeichnest** das Level als Text. Jedes Zeichen ist eine Kachel. `#` ist Wand, `.` ist Weg, `@` der Spieler, `Z` das Ziel.' },
        { hl: [10, 13], say: 'Mit `toCharArray` wird jede Text-Zeile zu einer Zeile im Spielfeld. Jetzt kannst du jede Kachel einzeln lesen und ändern.' },
        { run: true, say: 'Das Spielfeld ist 10 breit und 6 hoch. Genau so – mit Text-Zeilen – werden wir auch die Level im Jump’n’Run speichern.' },
      ],
    },
    {
      title: 'Bewegung & Kollision',
      steps: [
        { t: 'Kapitel 3', h: 'Bewegen und Kollidieren', sub: 'Erst prüfen, dann laufen', after: 'code' },
        { layout: 'code', console: 'clear', code: cls(R`
    static boolean frei(char[][] feld, int x, int y) {
        if (y < 0 || y >= feld.length || x < 0 || x >= feld[y].length) {
            return false;
        }
        return feld[y][x] != '#';
    }`, LEVEL + R`
        char[][] feld = new char[level.length][];
        for (int y = 0; y < level.length; y++) feld[y] = level[y].toCharArray();
        int px = 1, py = 1;
        String zuege = "ddssaa";
        for (int i = 0; i < zuege.length(); i++) {
            char z = zuege.charAt(i);
            int nx = px, ny = py;
            if (z == 'w') ny--;
            if (z == 's') ny++;
            if (z == 'a') nx--;
            if (z == 'd') nx++;
            if (frei(feld, nx, ny)) {
                px = nx;
                py = ny;
            } else {
                System.out.println("Bumm! Wand bei " + nx + "," + ny);
            }
        }
        System.out.println("Spieler steht bei " + px + "," + py);`), hl: [22, 32], say: 'Das wichtigste Muster jeder Spiel-Bewegung: Berechne zuerst die **neue** Position nx, ny. Dann prüfe, ob sie frei ist. Nur dann bewegst du den Spieler wirklich.' },
        { hl: [2, 7], say: 'Die Methode `frei` prüft zwei Dinge: Liegt die Position überhaupt im Feld? Und ist dort keine Wand? Die Reihenfolge ist wichtig – erst die Grenzen, sonst gibt es eine Exception.' },
        { run: true, say: 'Zweimal rechts, dann wollte er runter – aber da war eine Wand. Diese Kollisionsprüfung wirst du in unserem Spiel wiedersehen, nur mit Pixeln statt Kästchen.' },
      ],
    },
    {
      title: 'Aufgabe: Labyrinth',
      steps: [
        { t: 'Aufgabe 1', h: 'Labyrinth', sub: 'Jetzt bist du dran!', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Aufgabe 1: Labyrinth-Spiel', items: ['Das Level ist vorgegeben (String-Array)', 'Lies Züge mit w, a, s, d ein – einer pro Zeile', 'Wände blockieren; zeichne das Feld nach jedem Zug', 'Erreicht der Spieler **Z**: „Ziel erreicht in N Zügen!“', '„q“ beendet das Spiel'], gap: 0.9 }, say: 'Jetzt baust du ein echtes kleines Spiel: ein Labyrinth, durch das du dich mit w, a, s, d bewegst.' },
        {
          task: {
            id: 'l11-labyrinth', nr: 1, title: 'Labyrinth-Spiel',
            text: ['Das Level aus dem Startcode wird in ein `char[][]` umgewandelt. Der Spieler startet beim `@`.', 'Lies in einer Schleife Züge ein (`w` hoch, `s` runter, `a` links, `d` rechts). Ist das Zielfeld eine Wand, bleibt der Spieler stehen. Zähle nur gültige Züge. Nach jedem Zug zeichnest du das Feld neu.', 'Steht der Spieler auf `Z`, gib „Ziel erreicht in N Zügen!“ aus und beende das Spiel. Bei `q` endet es mit „Aufgegeben.“'],
            req: ['Level als `char[][]`', 'Bewegung mit w/a/s/d und Kollision mit `#`', 'Nur gültige Züge zählen', 'Feld nach jedem Zug ausgeben', 'Ziel erkennen und Anzahl der Züge ausgeben'],
            example: 'Zug: d\n##########\n#.@..#...#\n...\nZiel erreicht in 15 Zügen!',
            starter: prog(LEVEL + R`
        char[][] feld = new char[level.length][];
        for (int y = 0; y < level.length; y++) {
            feld[y] = level[y].toCharArray();
        }
        Scanner sc = new Scanner(System.in);
        // Startposition suchen, dann Züge lesen
`, SC),
            solution: cls(R`
    static void zeichne(char[][] feld) {
        for (char[] zeile : feld) {
            System.out.println(new String(zeile));
        }
    }`, LEVEL + R`
        char[][] feld = new char[level.length][];
        for (int y = 0; y < level.length; y++) {
            feld[y] = level[y].toCharArray();
        }
        Scanner sc = new Scanner(System.in);
        int px = 0, py = 0;
        for (int y = 0; y < feld.length; y++) {
            for (int x = 0; x < feld[y].length; x++) {
                if (feld[y][x] == '@') {
                    px = x;
                    py = y;
                }
            }
        }
        int zuege = 0;
        while (true) {
            System.out.print("Zug: ");
            String z = sc.nextLine();
            if (z.equals("q")) {
                System.out.println("Aufgegeben.");
                break;
            }
            int nx = px, ny = py;
            if (z.equals("w")) ny--;
            else if (z.equals("s")) ny++;
            else if (z.equals("a")) nx--;
            else if (z.equals("d")) nx++;
            if (feld[ny][nx] == '#') {
                System.out.println("Da ist eine Wand!");
                continue;
            }
            if (nx == px && ny == py) continue;
            zuege++;
            boolean ziel = feld[ny][nx] == 'Z';
            feld[py][px] = '.';
            feld[ny][nx] = '@';
            px = nx;
            py = ny;
            zeichne(feld);
            if (ziel) {
                System.out.println("Ziel erreicht in " + zuege + " Zügen!");
                break;
            }
        }`, SC),
            tests: [
              { name: 'kürzester Weg', input: ['s', 's', 'd', 'd', 'd', 's', 'd', 'd', 'w', 'w', 'w', 'd', 'd', 's', 's'], expect: [{ re: 'ziel erreicht in 15', label: 'Ziel erreicht in 15 Zügen' }] },
              { name: 'gegen die Wand', input: ['w', 'a', 'd', 'q'], expect: [{ re: 'aufgegeben', label: '„Aufgegeben.“' }, { re: '#\\.@\\.\\.#', label: 'Feld zeigt den Spieler nach dem Zug' }, { re: 'ziel erreicht', label: 'kein Ziel', not: true }] },
              { name: 'Wände zählen nicht', input: ['w', 'w', 's', 's', 'd', 'd', 'd', 's', 'd', 'd', 'w', 'w', 'w', 'd', 'd', 's', 's'], expect: [{ re: 'ziel erreicht in 15', label: 'Wand-Versuche zählen nicht: 15 Züge' }] },
            ],
            codeChecks: [{ label: '2D-Array char[][]', re: 'char\\s*\\[\\s*\\]\\s*\\[\\s*\\]' }, { label: 'Wand-Prüfung', re: "'#'" }, { label: 'Ziel-Prüfung', re: "'Z'" }],
            rubric: [['Programm kompiliert und läuft', 15], ['Startposition gefunden und Bewegung mit w/a/s/d', 25], ['Kollision mit Wänden', 20], ['Feld nach jedem Zug gezeichnet', 15], ['Ziel und Zug-Zähler richtig, q beendet', 25]],
            tip: 'Speicher die Position in `px` und `py`. Beim Bewegen: altes Feld auf `.` setzen, neues Feld auf `@`. Prüf aber **vorher**, ob das neue Feld `Z` ist – sonst überschreibst du das Ziel.',
          },
        },
        { layout: 'code', console: 'clear', code: prog(R`
        char[][] feld = { "#.Z".toCharArray() };
        int px = 1, py = 0;
        int nx = 2, ny = 0;
        boolean ziel = feld[ny][nx] == 'Z';
        feld[py][px] = '.';
        feld[ny][nx] = '@';
        System.out.println(new String(feld[0]) + " -> Ziel? " + ziel);`), run: true, hl: [5, 7], say: 'Abgegeben! Der Knackpunkt: Erst schauen, was auf dem neuen Feld liegt, dann den Spieler dorthin setzen. Sonst ist das Z weg, bevor du es bemerkst.' },
      ],
    },
    {
      title: 'Exceptions abfangen',
      steps: [
        { t: 'Kapitel 5', h: 'Fehlerbehandlung', sub: 'try und catch', after: 'code' },
        { layout: 'code', console: 'clear', code: prog(R`
        String eingabe = "zwölf";
        int zahl = Integer.parseInt(eingabe);
        System.out.println(zahl * 2);`), run: true, expectError: true, say: 'Was passiert, wenn jemand statt einer Zahl ein Wort eintippt? Das Programm stürzt mit einer **NumberFormatException** ab. In einem Spiel wäre das ärgerlich.' },
        { code: prog(R`
        String[] eingaben = {"12", "zwölf", "7"};
        for (String e : eingaben) {
            try {
                int zahl = Integer.parseInt(e);
                System.out.println(zahl + " mal 2 = " + zahl * 2);
            } catch (NumberFormatException ex) {
                System.out.println("\"" + e + "\" ist keine Zahl!");
            }
        }
        System.out.println("Programm läuft weiter.");`), console: 'clear', hl: [4, 9], say: 'Mit `try` sagst du: „Versuch das mal.“ Geht es schief, springt Java in den `catch`-Block – statt abzustürzen. In den Klammern steht, welchen Fehler du abfängst.' },
        { run: true, say: 'Das Wort wurde abgefangen, und das Programm läuft einfach weiter. Alles nach der fehlerhaften Zeile im try-Block wird dabei übersprungen.' },
        { layout: 'split', visual: { kind: 'table', title: 'Häufige Exceptions', head: ['Exception', 'wann?'], rows: [['`NumberFormatException`', 'Text ist keine Zahl'], ['`ArrayIndexOutOfBoundsException`', 'Index außerhalb des Arrays'], ['`NullPointerException`', 'Zugriff über null'], ['`ArithmeticException`', 'Ganzzahl durch 0'], ['`InputMismatchException`', 'nextInt bekommt keinen int']], gap: 0.6 }, code: prog(R`
        int[] werte = {1, 2, 3};
        try {
            System.out.println(werte[5]);
        } catch (ArrayIndexOutOfBoundsException ex) {
            System.out.println("Gibt es nicht: " + ex.getMessage());
        } finally {
            System.out.println("finally läuft immer");
        }`), run: true, console: 'clear', say: 'Hier die häufigsten Exceptions. Mit `getMessage` bekommst du die Fehlermeldung, und ein `finally`-Block läuft **immer** – ob ein Fehler passiert ist oder nicht.' },
        { quiz: { id: 'l11-q2', q: 'Was gibt dieser Code aus? `try { int x = 5 / 0; System.out.print("A"); } catch (ArithmeticException e) { System.out.print("B"); } System.out.print("C");`', options: ['AC', 'BC', 'ABC', 'B'], correct: 1, explain: 'Die Division wirft sofort eine Exception, A wird übersprungen. Der catch-Block gibt B aus, danach geht es mit C weiter.' } },
      ],
    },
    {
      title: 'Selbst Exceptions werfen',
      steps: [
        { t: 'Kapitel 6', h: 'throw', sub: 'Fehler selbst melden', after: 'code' },
        { layout: 'code', console: 'clear', code: cls(R`
    static int levelNummer(String text) {
        int n = Integer.parseInt(text);
        if (n < 1 || n > 8) {
            throw new IllegalArgumentException("Level " + n + " gibt es nicht");
        }
        return n;
    }`, R`
        String[] tests = {"3", "12", "abc"};
        for (String t : tests) {
            try {
                System.out.println("Starte Level " + levelNummer(t));
            } catch (NumberFormatException e) {
                System.out.println("Keine Zahl: " + t);
            } catch (IllegalArgumentException e) {
                System.out.println(e.getMessage());
            }
        }`), hl: [4, 6], say: 'Du kannst auch selbst Exceptions **werfen**, mit `throw new …`. So meldet eine Methode: „Mit diesem Wert kann ich nicht arbeiten.“ Wer sie aufruft, muss sich darum kümmern.' },
        { run: true, hl: [16, 20], say: 'Mehrere catch-Blöcke fangen verschiedene Fehler unterschiedlich ab. Achtung: Die speziellere Exception muss zuerst kommen – NumberFormatException ist nämlich eine Unterklasse von IllegalArgumentException. Vererbung, du erinnerst dich!' },
        { quiz: { id: 'l11-q3', q: 'Wann sollte man eine Exception abfangen?', options: ['Immer, um jeden Absturz zu verstecken', 'Wenn man sinnvoll darauf reagieren kann, z. B. nochmal fragen', 'Nie, Abstürze sind normal', 'Nur in der main-Methode'], correct: 1, explain: 'Fang Fehler dort ab, wo du etwas Sinnvolles tun kannst. Einfach alles zu verschlucken versteckt echte Bugs.' } },
      ],
    },
    {
      title: 'Aufgabe: Robuste Eingabe',
      steps: [
        { t: 'Aufgabe 2', h: 'Robuste Eingabe', sub: 'Programme, die nicht abstürzen', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Aufgabe 2: Robuster Rundenzähler', items: ['Methode `int leseZahl(String text)` – wirft bei negativen Zahlen eine `IllegalArgumentException`', 'Lies Rundenzeiten in Sekunden ein, bis „stop“', 'Fang Wörter und negative Zahlen mit try/catch ab', 'Am Ende: Anzahl gültiger Runden, Gesamtzeit, Fehler'], gap: 0.9 }, say: 'Letzte Aufgabe dieser Lektion: ein Rundenzähler, der mit jedem Unsinn klarkommt, den man eintippt.' },
        {
          task: {
            id: 'l11-robust', nr: 2, title: 'Robuster Rundenzähler',
            text: ['Schreib eine Methode `static int leseZahl(String text)`, die den Text mit `Integer.parseInt` umwandelt und bei einer negativen Zahl `throw new IllegalArgumentException("negativ")` macht.', 'In main liest du Zeilen ein, bis „stop“ kommt. Jede Zeile gibst du an `leseZahl`. Fang `NumberFormatException` („Keine Zahl!“) und `IllegalArgumentException` („Zeit darf nicht negativ sein!“) getrennt ab.', 'Am Ende gibst du aus: „Runden: …“, „Gesamt: … s“ und „Fehler: …“.'],
            req: ['Methode `leseZahl` mit `throw`', 'try/catch mit zwei catch-Blöcken in der richtigen Reihenfolge', 'Schleife bis „stop“', 'Zähler für Runden, Gesamtzeit und Fehler'],
            example: '45\nschnell\n-3\n50\nstop\nKeine Zahl!\nZeit darf nicht negativ sein!\nRunden: 2\nGesamt: 95 s\nFehler: 2',
            starter: cls(R`
    // static int leseZahl(String text) { ... }`, R`
        Scanner sc = new Scanner(System.in);
        // Zeilen lesen bis "stop"
`, SC),
            solution: cls(R`
    static int leseZahl(String text) {
        int n = Integer.parseInt(text);
        if (n < 0) {
            throw new IllegalArgumentException("negativ");
        }
        return n;
    }`, R`
        Scanner sc = new Scanner(System.in);
        int runden = 0, gesamt = 0, fehler = 0;
        while (true) {
            String zeile = sc.nextLine();
            if (zeile.equals("stop")) break;
            try {
                int zeit = leseZahl(zeile);
                runden++;
                gesamt += zeit;
            } catch (NumberFormatException e) {
                System.out.println("Keine Zahl!");
                fehler++;
            } catch (IllegalArgumentException e) {
                System.out.println("Zeit darf nicht negativ sein!");
                fehler++;
            }
        }
        System.out.println("Runden: " + runden);
        System.out.println("Gesamt: " + gesamt + " s");
        System.out.println("Fehler: " + fehler);`, SC),
            tests: [
              { name: 'gemischt', input: ['45', 'schnell', '-3', '50', 'stop'], expect: [{ re: 'runden:?\\s*2\\b', label: 'Runden: 2' }, { re: 'gesamt:?\\s*95', label: 'Gesamt: 95' }, { re: 'fehler:?\\s*2\\b', label: 'Fehler: 2' }, { re: 'keine zahl', label: '„Keine Zahl!“' }, { re: 'negativ', label: 'Meldung für negative Zahl' }] },
              { name: 'nur gültig', input: ['10', '20', '30', 'stop'], expect: [{ re: 'runden:?\\s*3\\b', label: 'Runden: 3' }, { re: 'gesamt:?\\s*60', label: 'Gesamt: 60' }, { re: 'fehler:?\\s*0\\b', label: 'Fehler: 0' }] },
            ],
            codeChecks: [{ label: 'throw new IllegalArgumentException', re: 'throw\\s+new\\s+IllegalArgumentException' }, { label: 'catch NumberFormatException', re: 'catch\\s*\\(\\s*NumberFormatException' }, { label: 'catch IllegalArgumentException', re: 'catch\\s*\\(\\s*IllegalArgumentException' }, { label: 'Methode leseZahl', re: 'static\\s+int\\s+leseZahl\\s*\\(\\s*String' }],
            rubric: [['Programm kompiliert und läuft', 15], ['leseZahl mit parseInt und throw', 25], ['Zwei catch-Blöcke in richtiger Reihenfolge', 25], ['Schleife bis stop', 10], ['Zähler und Ausgabe richtig', 25]],
            tip: 'Fängst du zuerst `IllegalArgumentException` ab, landet auch jede NumberFormatException dort – und der Compiler beschwert sich über den zweiten Block. Also: speziell vor allgemein.',
          },
        },
        { layout: 'code', console: 'clear', code: cls(R`
    static int leseZahl(String text) {
        int n = Integer.parseInt(text);
        if (n < 0) throw new IllegalArgumentException("negativ");
        return n;
    }`, R`
        try {
            leseZahl("-3");
        } catch (NumberFormatException e) {
            System.out.println("Keine Zahl!");
        } catch (IllegalArgumentException e) {
            System.out.println("Fehler: " + e.getMessage());
        }`), run: true, say: 'Abgegeben! Mit eigenen Exceptions und try/catch hält dein Programm jetzt jedem Tipp-Unsinn stand.' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Das kannst du jetzt', items: ['2D-Arrays anlegen, füllen und ausgeben', 'Level aus Text-Zeilen laden', 'Bewegung mit Kollisionsprüfung', 'Exceptions mit `try` / `catch` / `finally` abfangen', 'Eigene Exceptions mit `throw` werfen'], gap: 0.7 }, say: 'Das war Lektion 11! Jetzt hast du alles beisammen für dein Java-Abschlussprojekt in Lektion 12.' },
      ],
    },
  ],
};
