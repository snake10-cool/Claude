// Java-Finale: 20 Challenges, die nur nacheinander freigeschaltet werden (steigende Schwierigkeit, alles gemischt)
const R = String.raw;
const strip = s => s.replace(/^\n/, '').replace(/\n$/, '');
const prog = (body, imports = '') => `${imports}public class Main {\n    public static void main(String[] args) {\n${strip(body)}\n    }\n}\n`;
const cls = (members, body, imports = '') => `${imports}public class Main {\n${strip(members)}\n\n    public static void main(String[] args) {\n${strip(body)}\n    }\n}\n`;
const file = (classes, body, imports = '') => `${imports}${strip(classes)}\n\npublic class Main {\n    public static void main(String[] args) {\n${strip(body)}\n    }\n}\n`;
const SC = 'import java.util.Scanner;\n\n';
const ALSC = 'import java.util.ArrayList;\nimport java.util.Scanner;\n\n';
const HMSC = 'import java.util.HashMap;\nimport java.util.Scanner;\n\n';
const RUB = (main) => [['Programm kompiliert und läuft', 15], [main, 45], ['Passende Mittel (Schleifen, Methoden, Klassen) sinnvoll eingesetzt', 25], ['Lesbarer Code: gute Namen, saubere Einrückung', 15]];
const LV = ['★☆☆', '★☆☆', '★☆☆', '★★☆', '★★☆', '★★☆', '★★☆', '★★☆', '★★☆', '★★☆', '★★☆', '★★★', '★★★', '★★★', '★★★', '★★★', '★★★', '★★★', '★★★', '★★★'];
const scan = (prompt, line = 'String eingabe = sc.nextLine();') => R`
        Scanner sc = new Scanner(System.in);
        System.out.print("${prompt}");
        ${line}`;

const list = [
  {
    title: 'Temperatur-Tabelle', teaser: 'Eine saubere Umrechnungs-Tabelle von Celsius nach Fahrenheit.', uses: ['for', 'printf'],
    text: ['Lies Start, Ende und Schrittweite (drei Zahlen, je eine Zeile) ein. Gib für jede Celsius-Temperatur von Start bis Ende eine Zeile „C °C = F °F“ aus, F mit einer Nachkommastelle. Formel: F = C × 9 / 5 + 32.'],
    example: '0\n30\n10\n0 °C = 32,0 °F\n10 °C = 50,0 °F\n20 °C = 68,0 °F\n30 °C = 86,0 °F',
    lookup: ['Lektion 4 · for mit Schrittweite `i += schritt`', 'Lektion 2 · `printf("%.1f")` und double-Rechnung'],
    starter: prog(R`
        Scanner sc = new Scanner(System.in);
        int start = sc.nextInt();
        int ende = sc.nextInt();
        int schritt = sc.nextInt();
`, SC),
    solution: prog(R`
        Scanner sc = new Scanner(System.in);
        int start = sc.nextInt();
        int ende = sc.nextInt();
        int schritt = sc.nextInt();
        for (int c = start; c <= ende; c += schritt) {
            System.out.printf("%d °C = %.1f °F%n", c, c * 9 / 5.0 + 32);
        }`, SC),
    tests: [{ name: '0 bis 30', input: ['0', '30', '10'], expect: [{ re: '0 °C = 32[.,]0', label: '0 °C = 32,0 °F' }, { re: '30 °C = 86[.,]0', label: '30 °C = 86,0 °F' }] }, { name: '-5 bis 5', input: ['-5', '5', '5'], expect: [{ re: '-5 °C = 23[.,]0', label: '−5 °C = 23,0 °F' }, { re: '5 °C = 41[.,]0', label: '5 °C = 41,0 °F' }] }],
    main: 'Richtige Werte für alle Zeilen', tip: 'Achtung Ganzzahl-Falle: `c * 9 / 5` rechnet mit int. Schreib `5.0`.',
  },
  {
    title: 'Größter gemeinsamer Teiler', teaser: 'Der älteste Algorithmus der Welt – von Euklid, über 2300 Jahre alt.', uses: ['while', '%', 'Methode'],
    text: ['Schreib eine Methode `static int ggt(int a, int b)` nach dem Euklid-Verfahren: Solange b nicht 0 ist, wird (a, b) zu (b, a % b). Dann ist a der ggT.', 'Lies zwei Zahlen ein und gib „ggT = …“ aus. Bonus: gib auch das kleinste gemeinsame Vielfache aus (a × b / ggT).'],
    example: '48\n18\nggT = 6\nkgV = 144',
    lookup: ['Lektion 6 · Methoden mit Rückgabewert', 'Lektion 4 · while-Schleife', 'Lektion 2 · Modulo %'],
    starter: cls(R`
    // static int ggt(int a, int b) { ... }`, R`
        Scanner sc = new Scanner(System.in);
        int a = sc.nextInt();
        int b = sc.nextInt();
`, SC),
    solution: cls(R`
    static int ggt(int a, int b) {
        while (b != 0) {
            int rest = a % b;
            a = b;
            b = rest;
        }
        return a;
    }`, R`
        Scanner sc = new Scanner(System.in);
        int a = sc.nextInt();
        int b = sc.nextInt();
        int g = ggt(a, b);
        System.out.println("ggT = " + g);
        System.out.println("kgV = " + (a / g * b));`, SC),
    tests: [{ name: '48, 18', input: ['48', '18'], expect: [{ re: 'ggt\\s*=\\s*6\\b', label: 'ggT = 6' }] }, { name: '17, 5', input: ['17', '5'], expect: [{ re: 'ggt\\s*=\\s*1\\b', label: 'ggT = 1' }] }, { name: '100, 75', input: ['100', '75'], expect: [{ re: 'ggt\\s*=\\s*25\\b', label: 'ggT = 25' }] }],
    codeChecks: [{ label: 'Methode ggt(int, int)', re: 'static\\s+int\\s+ggt\\s*\\(\\s*int\\s+\\w+\\s*,\\s*int' }],
    main: 'ggT richtig nach Euklid', tip: 'Merk dir den Rest in einer Hilfsvariable, bevor du a und b überschreibst.',
  },
  {
    title: 'Collatz-Folge', teaser: 'Ein ungelöstes Rätsel der Mathematik: Landet jede Zahl irgendwann bei 1?', uses: ['while', 'if/else', 'Zähler'],
    text: ['Lies eine Zahl n ein. Solange n nicht 1 ist: Ist n gerade, halbiere sie, sonst rechne 3n + 1. Gib die ganze Folge in einer Zeile aus (mit Leerzeichen getrennt), danach „Schritte: …“ und „Höchster Wert: …“.'],
    example: '6\n6 3 10 5 16 8 4 2 1\nSchritte: 8\nHöchster Wert: 16',
    lookup: ['Lektion 4 · while mit Bedingung', 'Lektion 3 · gerade/ungerade mit % 2'],
    starter: prog(scan('', 'int n = sc.nextInt();')),
    solution: prog(R`
        Scanner sc = new Scanner(System.in);
        int n = sc.nextInt();
        int schritte = 0, max = n;
        StringBuilder folge = new StringBuilder("" + n);
        while (n != 1) {
            if (n % 2 == 0) n = n / 2;
            else n = 3 * n + 1;
            schritte++;
            if (n > max) max = n;
            folge.append(" ").append(n);
        }
        System.out.println(folge);
        System.out.println("Schritte: " + schritte);
        System.out.println("Höchster Wert: " + max);`, SC),
    tests: [{ name: '6', input: ['6'], expect: [{ has: '6 3 10 5 16 8 4 2 1', label: 'Folge von 6' }, { re: 'schritte:?\\s*8\\b', label: 'Schritte: 8' }, { re: 'wert:?\\s*16\\b', label: 'Höchster Wert: 16' }] }, { name: '27', input: ['27'], expect: [{ re: 'schritte:?\\s*111\\b', label: 'Schritte: 111' }, { re: 'wert:?\\s*9232\\b', label: 'Höchster Wert: 9232' }] }],
    main: 'Folge, Schritte und Maximum richtig', tip: 'Die 27 braucht 111 Schritte und klettert bis 9232 – ein guter Test für deine Schleife.',
  },
  {
    title: 'Binär-Umwandler', teaser: 'Computer denken in Nullen und Einsen. Wandle Zahlen selbst ins Binärsystem um – ohne fertige Methode.', uses: ['while', '% 2', '/ 2', 'StringBuilder'],
    text: ['Lies eine Zahl ≥ 0 ein und gib sie im Binärsystem aus. Benutze **nicht** `Integer.toBinaryString`: Teile immer wieder durch 2 und sammle die Reste – von hinten nach vorne gelesen ergeben sie die Binärzahl.', 'Gib außerdem aus, wie viele Einsen die Zahl hat.'],
    example: '13\nBinär: 1101\nEinsen: 3',
    lookup: ['Lektion 4 · Quersumme-Muster: % und / in einer Schleife', 'Lektion 7 · StringBuilder `insert(0, …)` oder `reverse()`'],
    starter: prog(scan('', 'int n = sc.nextInt();')),
    solution: prog(R`
        Scanner sc = new Scanner(System.in);
        int n = sc.nextInt();
        StringBuilder sb = new StringBuilder();
        int einsen = 0;
        if (n == 0) sb.append(0);
        while (n > 0) {
            int bit = n % 2;
            if (bit == 1) einsen++;
            sb.insert(0, bit);
            n = n / 2;
        }
        System.out.println("Binär: " + sb);
        System.out.println("Einsen: " + einsen);`, SC),
    tests: [{ name: '13', input: ['13'], expect: [{ re: 'bin(ä|ae)r:?\\s*1101\\b', label: '1101' }, { re: 'einsen:?\\s*3', label: 'Einsen: 3' }] }, { name: '256', input: ['256'], expect: [{ re: '100000000\\b', label: '100000000' }] }, { name: '0', input: ['0'], expect: [{ re: 'bin(ä|ae)r:?\\s*0\\b', label: '0 bleibt 0' }] }],
    codeChecks: [{ label: 'ohne Integer.toBinaryString', re: '^(?![\\s\\S]*toBinaryString)' }],
    main: 'Richtige Binärzahl und Anzahl der Einsen', tip: 'Die Reste kommen in umgekehrter Reihenfolge heraus. `sb.insert(0, bit)` setzt jedes neue Bit vorne an.',
  },
  {
    title: 'Anagramm-Check', teaser: '„Lampe“ und „Palme“ bestehen aus denselben Buchstaben. Erkennt dein Programm das?', uses: ['toCharArray', 'Arrays.sort', 'equals'],
    text: ['Lies zwei Wörter ein. Sie sind **Anagramme**, wenn sie genau dieselben Buchstaben in anderer Reihenfolge enthalten (Groß/klein egal). Gib „Anagramm!“ oder „Kein Anagramm.“ aus.'],
    example: 'Lampe\nPalme\nAnagramm!',
    lookup: ['Lektion 7 · `toLowerCase` und `toCharArray`', 'Lektion 5 · `Arrays.sort` und `Arrays.equals` (oder ein Zähl-Array mit 26 Plätzen)'],
    starter: prog(R`
        Scanner sc = new Scanner(System.in);
        String a = sc.nextLine();
        String b = sc.nextLine();
`, 'import java.util.Arrays;\nimport java.util.Scanner;\n\n'),
    solution: prog(R`
        Scanner sc = new Scanner(System.in);
        char[] a = sc.nextLine().toLowerCase().toCharArray();
        char[] b = sc.nextLine().toLowerCase().toCharArray();
        Arrays.sort(a);
        Arrays.sort(b);
        System.out.println(Arrays.equals(a, b) ? "Anagramm!" : "Kein Anagramm.");`, 'import java.util.Arrays;\nimport java.util.Scanner;\n\n'),
    tests: [{ name: 'Lampe/Palme', input: ['Lampe', 'Palme'], expect: [{ re: '(^|\\s)anagramm!', label: 'Anagramm!' }, { re: 'kein', label: 'nicht „Kein“', not: true }] }, { name: 'Regen/Gerne', input: ['Regen', 'Gerne'], expect: [{ re: 'anagramm!', label: 'Anagramm!' }, { re: 'kein', not: true, label: 'nicht „Kein“' }] }, { name: 'Haus/Maus', input: ['Haus', 'Maus'], expect: [{ re: 'kein anagramm', label: 'Kein Anagramm.' }] }, { name: 'Länge', input: ['abc', 'abcc'], expect: [{ re: 'kein anagramm', label: 'unterschiedliche Länge' }] }],
    main: 'Anagramme richtig erkannt', tip: 'Sortiert man die Buchstaben beider Wörter, müssen bei Anagrammen genau gleiche Arrays herauskommen.',
  },
  {
    title: 'Römische Zahlen', teaser: 'Aus 2026 wird MMXXVI. Bau den Umwandler, den schon die Römer gebraucht hätten.', uses: ['Arrays', 'while', 'StringBuilder'],
    text: ['Lies eine Zahl von 1 bis 3999 ein und gib sie als römische Zahl aus. Tipp: Zwei parallele Arrays helfen – `{1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1}` und `{"M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"}`.'],
    example: '2026\nMMXXVI',
    lookup: ['Lektion 5 · zwei Arrays mit gleichem Index', 'Lektion 4 · while: so lange abziehen, wie es passt'],
    starter: prog(scan('', 'int n = sc.nextInt();')),
    solution: prog(R`
        Scanner sc = new Scanner(System.in);
        int n = sc.nextInt();
        int[] werte = {1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1};
        String[] zeichen = {"M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"};
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < werte.length; i++) {
            while (n >= werte[i]) {
                sb.append(zeichen[i]);
                n -= werte[i];
            }
        }
        System.out.println(sb);`, SC),
    tests: [{ name: '2026', input: ['2026'], expect: [{ re: '\\bMMXXVI\\b', flags: '', label: 'MMXXVI' }] }, { name: '1994', input: ['1994'], expect: [{ re: '\\bMCMXCIV\\b', flags: '', label: 'MCMXCIV' }] }, { name: '4', input: ['4'], expect: [{ re: '\\bIV\\b', flags: '', label: 'IV' }] }],
    main: 'Richtige römische Zahl auch bei 4, 9, 40, 90 …', tip: 'Geh die Werte von groß nach klein durch und zieh jeden so oft ab, wie er hineinpasst.',
  },
  {
    title: 'Häufigstes Wort', teaser: 'Welches Wort kommt in einem Text am öftesten vor? Mit einer HashMap ein Klacks.', uses: ['HashMap', 'split', 'Maximum'],
    text: ['Lies eine Zeile Text ein (Wörter durch Leerzeichen getrennt, Groß/klein egal). Zähle mit einer `HashMap<String, Integer>`, wie oft jedes Wort vorkommt. Gib aus: „Verschiedene Wörter: …“ und „Häufigstes: Wort (N×)“. Bei Gleichstand gewinnt das Wort, das **zuerst** im Text stand.'],
    example: 'der hund und der ball und der baum\nVerschiedene Wörter: 5\nHäufigstes: der (3×)',
    lookup: ['HashMap: `map.put(wort, map.getOrDefault(wort, 0) + 1)` und `map.get(wort)`', 'Lektion 7 · split und toLowerCase', 'Lektion 9 · bestes Element merken'],
    starter: prog(R`
        Scanner sc = new Scanner(System.in);
        String[] woerter = sc.nextLine().toLowerCase().split(" ");
        HashMap<String, Integer> zaehler = new HashMap<>();
`, HMSC),
    solution: prog(R`
        Scanner sc = new Scanner(System.in);
        String[] woerter = sc.nextLine().toLowerCase().split(" ");
        HashMap<String, Integer> zaehler = new HashMap<>();
        for (String w : woerter) {
            zaehler.put(w, zaehler.getOrDefault(w, 0) + 1);
        }
        String best = woerter[0];
        for (String w : woerter) {
            if (zaehler.get(w) > zaehler.get(best)) best = w;
        }
        System.out.println("Verschiedene Wörter: " + zaehler.size());
        System.out.println("Häufigstes: " + best + " (" + zaehler.get(best) + "×)");`, HMSC),
    tests: [{ name: 'der', input: ['der hund und der ball und der baum'], expect: [{ re: 'verschiedene w(ö|oe)rter:?\\s*5', label: '5 verschiedene' }, { re: 'h(ä|ae)ufigstes:?\\s*der\\b[^\\n]*3', label: 'der (3×)' }] }, { name: 'Gleichstand', input: ['Rot Blau rot blau Gelb'], expect: [{ re: 'h(ä|ae)ufigstes:?\\s*rot\\b[^\\n]*2', label: 'rot (2×), weil zuerst' }] }],
    codeChecks: [{ label: 'HashMap verwendet', re: 'HashMap\\s*<\\s*String\\s*,\\s*Integer\\s*>' }],
    main: 'Richtig gezählt und das häufigste Wort gefunden', tip: 'Für den Gleichstand: Geh beim Suchen des Maximums die Wörter in der **Text-Reihenfolge** durch, nicht die HashMap.',
  },
  {
    title: 'Lauflängen-Kodierung', teaser: 'So sparten alte Spiele Speicher: „aaabcc“ wird zu „a3b1c2“. Und zurück!', uses: ['charAt', 'Zähler', 'StringBuilder'],
    text: ['Lies einen Befehl und einen Text ein. Bei „pack“ fasst du gleiche Zeichen in Folge zusammen: „aaabcc“ → „a3b1c2“. Bei „unpack“ machst du das Gegenteil: „a3b1c2“ → „aaabcc“ (die Zahlen sind einstellig).'],
    example: 'pack\nwwwwbbbw\nw4b3w1',
    lookup: ['Lektion 7 · Zeichen vergleichen mit charAt(i) und charAt(i + 1)', 'Lektion 7 · `repeat` und `Character.getNumericValue` bzw. `c - \'0\'`'],
    starter: prog(R`
        Scanner sc = new Scanner(System.in);
        String befehl = sc.nextLine();
        String text = sc.nextLine();
`, SC),
    solution: prog(R`
        Scanner sc = new Scanner(System.in);
        String befehl = sc.nextLine();
        String text = sc.nextLine();
        StringBuilder sb = new StringBuilder();
        if (befehl.equals("pack")) {
            int i = 0;
            while (i < text.length()) {
                char c = text.charAt(i);
                int n = 0;
                while (i < text.length() && text.charAt(i) == c) {
                    n++;
                    i++;
                }
                sb.append(c).append(n);
            }
        } else {
            for (int i = 0; i < text.length(); i += 2) {
                char c = text.charAt(i);
                int n = text.charAt(i + 1) - '0';
                sb.append(String.valueOf(c).repeat(n));
            }
        }
        System.out.println(sb);`, SC),
    tests: [{ name: 'pack', input: ['pack', 'wwwwbbbw'], expect: [{ re: '^w4b3w1$', flags: 'm', label: 'w4b3w1' }] }, { name: 'pack 2', input: ['pack', 'aaabcc'], expect: [{ re: '^a3b1c2$', flags: 'm', label: 'a3b1c2' }] }, { name: 'unpack', input: ['unpack', '#5.3#2'], expect: [{ re: '^#####\\.\\.\\.##$', flags: 'm', label: '#####...##' }] }],
    main: 'pack und unpack richtig', tip: 'Beim Packen: Zähl in einer inneren while-Schleife, solange dasselbe Zeichen kommt.',
  },
  {
    title: 'Matrix drehen', teaser: 'Tetris-Steine drehen sich um 90°. Dreh ein ganzes Zeichen-Gitter im Uhrzeigersinn.', uses: ['2D-Array', 'Index-Rechnung'],
    text: ['Lies die Anzahl der Zeilen und dann die Zeilen eines rechteckigen Gitters ein. Gib es um **90° im Uhrzeigersinn** gedreht aus. Aus einem Gitter mit h Zeilen und b Spalten wird eins mit b Zeilen und h Spalten.'],
    example: '2\nabc\ndef\nda\neb\nfc',
    lookup: ['Lektion 11 · 2D-Arrays', 'Überleg mit Papier: Welches alte Feld landet in neuer Zeile y, Spalte x?'],
    starter: prog(R`
        Scanner sc = new Scanner(System.in);
        int h = Integer.parseInt(sc.nextLine());
        char[][] g = new char[h][];
        for (int y = 0; y < h; y++) g[y] = sc.nextLine().toCharArray();
`, SC),
    solution: prog(R`
        Scanner sc = new Scanner(System.in);
        int h = Integer.parseInt(sc.nextLine());
        char[][] g = new char[h][];
        for (int y = 0; y < h; y++) g[y] = sc.nextLine().toCharArray();
        int b = g[0].length;
        for (int y = 0; y < b; y++) {
            StringBuilder sb = new StringBuilder();
            for (int x = 0; x < h; x++) {
                sb.append(g[h - 1 - x][y]);
            }
            System.out.println(sb);
        }`, SC),
    tests: [{ name: '2×3', input: ['2', 'abc', 'def'], expect: [{ re: '^da\\neb\\nfc$', flags: 'm', label: 'da / eb / fc' }] }, { name: 'Tetris-L', input: ['3', '#.', '#.', '##'], expect: [{ re: '^###\\n#\\.\\.$', flags: 'm', label: '### / #..' }] }],
    main: 'Gitter richtig gedreht', tip: 'Neue Zeile y, Spalte x kommt aus der alten Zeile h − 1 − x, Spalte y.',
  },
  {
    title: 'Bubble Sort selbst gebaut', teaser: 'Sortieren ohne Arrays.sort – und mitzählen, wie viele Tausche es braucht.', uses: ['Arrays', 'verschachtelte Schleifen', 'Tauschen'],
    text: ['Lies eine Zeile mit Zahlen ein (Leerzeichen getrennt). Sortiere sie aufsteigend mit **Bubble Sort**: Geh immer wieder durch das Array und tausche benachbarte Zahlen, die falsch herum stehen. Benutze kein `Arrays.sort`.', 'Gib das sortierte Array aus und „Tausche: …“.'],
    example: '5 1 4 2 8\n1 2 4 5 8\nTausche: 4',
    lookup: ['Lektion 5 · Tauschen mit Hilfsvariable', 'Lektion 4 · verschachtelte Schleifen', 'Lektion 7 · split + parseInt'],
    starter: prog(R`
        Scanner sc = new Scanner(System.in);
        String[] teile = sc.nextLine().split(" ");
        int[] a = new int[teile.length];
        for (int i = 0; i < a.length; i++) a[i] = Integer.parseInt(teile[i]);
`, SC),
    solution: prog(R`
        Scanner sc = new Scanner(System.in);
        String[] teile = sc.nextLine().split(" ");
        int[] a = new int[teile.length];
        for (int i = 0; i < a.length; i++) a[i] = Integer.parseInt(teile[i]);
        int tausche = 0;
        for (int runde = 0; runde < a.length - 1; runde++) {
            for (int i = 0; i < a.length - 1 - runde; i++) {
                if (a[i] > a[i + 1]) {
                    int tmp = a[i];
                    a[i] = a[i + 1];
                    a[i + 1] = tmp;
                    tausche++;
                }
            }
        }
        StringBuilder sb = new StringBuilder();
        for (int x : a) sb.append(x).append(" ");
        System.out.println(sb.toString().trim());
        System.out.println("Tausche: " + tausche);`, SC),
    tests: [{ name: '5 1 4 2 8', input: ['5 1 4 2 8'], expect: [{ re: '^1 2 4 5 8$', flags: 'm', label: '1 2 4 5 8' }, { re: 'tausche:?\\s*4\\b', label: 'Tausche: 4' }] }, { name: 'rückwärts', input: ['4 3 2 1'], expect: [{ re: '^1 2 3 4$', flags: 'm', label: '1 2 3 4' }, { re: 'tausche:?\\s*6\\b', label: 'Tausche: 6' }] }],
    codeChecks: [{ label: 'ohne Arrays.sort', re: '^(?![\\s\\S]*Arrays\\.sort)' }],
    main: 'Richtig sortiert und Tausche gezählt', tip: 'Nach jeder Runde steht die größte Zahl ganz hinten – die innere Schleife darf deshalb jedes Mal einen Schritt kürzer werden.',
  },
  {
    title: 'Binäre Suche', teaser: 'Zahlenraten wie ein Profi: Mit Halbieren findest du jede Zahl in einer sortierten Liste blitzschnell.', uses: ['Arrays', 'while', 'Mitte rechnen'],
    text: ['Die sortierte Liste ist fest: alle Vielfachen von 3 von 3 bis 300 (100 Zahlen). Lies eine gesuchte Zahl ein und such sie mit **binärer Suche**: Schau in die Mitte, und je nachdem ob die Zahl kleiner oder größer ist, such links oder rechts weiter.', 'Gib „Gefunden an Index …“ oder „Nicht gefunden“ aus und „Schritte: …“ (wie oft du in die Mitte geschaut hast).'],
    example: '150\nGefunden an Index 49\nSchritte: 1',
    lookup: ['Lektion 4 · Zahlenraten: die Mitte als bester Tipp', 'Lektion 5 · Arrays'],
    starter: prog(R`
        int[] liste = new int[100];
        for (int i = 0; i < 100; i++) liste[i] = (i + 1) * 3;
        Scanner sc = new Scanner(System.in);
        int ziel = sc.nextInt();
`, SC),
    solution: prog(R`
        int[] liste = new int[100];
        for (int i = 0; i < 100; i++) liste[i] = (i + 1) * 3;
        Scanner sc = new Scanner(System.in);
        int ziel = sc.nextInt();
        int links = 0, rechts = liste.length - 1, schritte = 0, gefunden = -1;
        while (links <= rechts) {
            int mitte = (links + rechts) / 2;
            schritte++;
            if (liste[mitte] == ziel) {
                gefunden = mitte;
                break;
            } else if (liste[mitte] < ziel) {
                links = mitte + 1;
            } else {
                rechts = mitte - 1;
            }
        }
        System.out.println(gefunden >= 0 ? "Gefunden an Index " + gefunden : "Nicht gefunden");
        System.out.println("Schritte: " + schritte);`, SC),
    tests: [{ name: '150', input: ['150'], expect: [{ re: 'index 49', label: 'Index 49' }, { re: 'schritte:?\\s*1\\b', label: 'Schritte: 1' }] }, { name: '3', input: ['3'], expect: [{ re: 'index 0\\b', label: 'Index 0' }, { re: 'schritte:?\\s*6\\b', label: 'Schritte: 6' }] }, { name: '100', input: ['100'], expect: [{ re: 'nicht gefunden', label: 'Nicht gefunden' }, { re: 'schritte:?\\s*[5-7]\\b', label: 'nur wenige Schritte' }] }],
    main: 'Binäre Suche richtig, Schritte gezählt', tip: 'Die Mitte ist `(links + rechts) / 2`. Die Suche endet, wenn links größer als rechts wird.',
  },
  {
    title: 'Tic-Tac-Toe-Schiedsrichter', teaser: 'Drei Zeilen Spielbrett rein – wer hat gewonnen? Zeilen, Spalten und Diagonalen prüfen.', uses: ['2D-Array', 'Methoden', 'Bedingungen'],
    text: ['Lies drei Zeilen mit je drei Zeichen (`X`, `O` oder `.`) ein. Gib aus: „X gewinnt“, „O gewinnt“, „Unentschieden“ (Brett voll, kein Sieger) oder „Läuft noch“.', 'Schreib dafür eine Methode `static boolean gewinnt(char[][] b, char s)`.'],
    example: 'XOX\nOXO\n..X\nX gewinnt',
    lookup: ['Lektion 11 · 2D-Arrays', 'Lektion 6 · Methoden mit boolean-Rückgabe', 'Lektion 3 · && und ||'],
    starter: cls(R`
    // static boolean gewinnt(char[][] b, char s) { ... }`, R`
        Scanner sc = new Scanner(System.in);
        char[][] b = new char[3][];
        for (int y = 0; y < 3; y++) b[y] = sc.nextLine().toCharArray();
`, SC),
    solution: cls(R`
    static boolean gewinnt(char[][] b, char s) {
        for (int i = 0; i < 3; i++) {
            if (b[i][0] == s && b[i][1] == s && b[i][2] == s) return true;
            if (b[0][i] == s && b[1][i] == s && b[2][i] == s) return true;
        }
        if (b[0][0] == s && b[1][1] == s && b[2][2] == s) return true;
        return b[0][2] == s && b[1][1] == s && b[2][0] == s;
    }`, R`
        Scanner sc = new Scanner(System.in);
        char[][] b = new char[3][];
        for (int y = 0; y < 3; y++) b[y] = sc.nextLine().toCharArray();
        boolean voll = true;
        for (char[] z : b) for (char c : z) if (c == '.') voll = false;
        if (gewinnt(b, 'X')) System.out.println("X gewinnt");
        else if (gewinnt(b, 'O')) System.out.println("O gewinnt");
        else if (voll) System.out.println("Unentschieden");
        else System.out.println("Läuft noch");`, SC),
    tests: [{ name: 'Diagonale', input: ['XOX', 'OXO', '..X'], expect: [{ re: 'x gewinnt', label: 'X gewinnt' }] }, { name: 'Spalte O', input: ['XOX', 'XO.', '.O.'], expect: [{ re: 'o gewinnt', label: 'O gewinnt' }] }, { name: 'voll', input: ['XOX', 'XOO', 'OXX'], expect: [{ re: 'unentschieden', label: 'Unentschieden' }] }, { name: 'läuft', input: ['X..', '.O.', '...'], expect: [{ re: 'l(ä|ae)uft noch', label: 'Läuft noch' }] }],
    codeChecks: [{ label: 'Methode gewinnt', re: 'static\\s+boolean\\s+gewinnt\\s*\\(' }],
    main: 'Alle vier Fälle richtig erkannt', tip: 'Eine Schleife über i prüft Zeile i und Spalte i gleichzeitig. Die zwei Diagonalen prüfst du extra.',
  },
  {
    title: 'Sicheres Bankkonto', teaser: 'Ein Konto, das sich nicht überziehen lässt – mit eigener Exception und Kapselung.', uses: ['Klasse', 'private', 'throw', 'try/catch'],
    text: ['Schreib eine Klasse `Konto` mit private `stand` (double), `einzahlen(double)` und `abheben(double)`. Negative Beträge und Abheben über den Stand werfen eine `IllegalArgumentException` mit passender Meldung.', 'Lies Befehle wie „ein 50“, „ab 20“ ein, bis „ende“. Fang Fehler ab und gib die Meldung aus. Am Ende „Kontostand: … €“ mit 2 Nachkommastellen.'],
    example: 'ein 50\nab 80\nNicht genug Geld!\nab 20\nende\nKontostand: 30,00 €',
    lookup: ['Lektion 9 · Kapselung', 'Lektion 11 · throw und try/catch', 'Lektion 7 · split'],
    starter: file(R`
class Konto {
    // private double stand; einzahlen, abheben, getStand
}`, R`
        Scanner sc = new Scanner(System.in);
        Konto k = new Konto();
`, SC),
    solution: file(R`
class Konto {
    private double stand = 0;

    void einzahlen(double betrag) {
        if (betrag <= 0) throw new IllegalArgumentException("Betrag muss positiv sein!");
        stand += betrag;
    }

    void abheben(double betrag) {
        if (betrag <= 0) throw new IllegalArgumentException("Betrag muss positiv sein!");
        if (betrag > stand) throw new IllegalArgumentException("Nicht genug Geld!");
        stand -= betrag;
    }

    double getStand() {
        return stand;
    }
}`, R`
        Scanner sc = new Scanner(System.in);
        Konto k = new Konto();
        while (true) {
            String[] t = sc.nextLine().split(" ");
            if (t[0].equals("ende")) break;
            try {
                double betrag = Double.parseDouble(t[1]);
                if (t[0].equals("ein")) k.einzahlen(betrag);
                else if (t[0].equals("ab")) k.abheben(betrag);
            } catch (IllegalArgumentException e) {
                System.out.println(e.getMessage());
            }
        }
        System.out.printf("Kontostand: %.2f €%n", k.getStand());`, SC),
    tests: [{ name: 'Überziehen', input: ['ein 50', 'ab 80', 'ab 20', 'ende'], expect: [{ re: 'nicht genug', label: 'Meldung beim Überziehen' }, { re: 'kontostand:?\\s*30[.,]00', label: 'Kontostand 30,00' }] }, { name: 'negativ', input: ['ein -5', 'ein 12.5', 'ende'], expect: [{ re: 'positiv|negativ|ungültig', label: 'Meldung bei negativem Betrag' }, { re: 'kontostand:?\\s*12[.,]50', label: 'Kontostand 12,50' }] }],
    codeChecks: [{ label: 'private stand', re: 'private\\s+double\\s+stand' }, { label: 'throw', re: 'throw\\s+new' }, { label: 'try/catch', re: 'catch\\s*\\(' }],
    main: 'Konto schützt sich, Fehler werden abgefangen', tip: 'Die Klasse wirft, main fängt. So bleibt der Kontostand immer gültig, egal was eingegeben wird.',
  },
  {
    title: 'Klammer-Prüfer', teaser: 'Passen alle Klammern ( [ { zusammen? Jeder Compiler macht genau diese Prüfung.', uses: ['ArrayList als Stapel', 'charAt'],
    text: ['Lies eine Zeile ein und prüfe, ob alle Klammern `()`, `[]` und `{}` richtig geschlossen sind – auch in der richtigen Reihenfolge. „([)]“ ist falsch, „{[()]}“ ist richtig. Andere Zeichen ignorierst du.', 'Gib „OK“ oder „Fehler“ aus. Tipp: Merk dir offene Klammern in einer ArrayList wie auf einem **Stapel** – die zuletzt geöffnete muss zuerst geschlossen werden.'],
    example: 'if (a[i] == 3) { x(); }\nOK',
    lookup: ['Lektion 9 · ArrayList: `add`, `get(size() - 1)`, `remove(size() - 1)`', 'Lektion 7 · Zeichen für Zeichen durchgehen'],
    starter: prog(R`
        Scanner sc = new Scanner(System.in);
        String text = sc.nextLine();
        ArrayList<Character> stapel = new ArrayList<>();
`, ALSC),
    solution: prog(R`
        Scanner sc = new Scanner(System.in);
        String text = sc.nextLine();
        ArrayList<Character> stapel = new ArrayList<>();
        boolean ok = true;
        for (int i = 0; i < text.length() && ok; i++) {
            char c = text.charAt(i);
            if (c == '(' || c == '[' || c == '{') {
                stapel.add(c);
            } else if (c == ')' || c == ']' || c == '}') {
                if (stapel.isEmpty()) {
                    ok = false;
                } else {
                    char offen = stapel.remove(stapel.size() - 1);
                    if ((c == ')' && offen != '(') || (c == ']' && offen != '[') || (c == '}' && offen != '{')) ok = false;
                }
            }
        }
        if (!stapel.isEmpty()) ok = false;
        System.out.println(ok ? "OK" : "Fehler");`, ALSC),
    tests: [{ name: 'Code', input: ['if (a[i] == 3) { x(); }'], expect: [{ re: '^OK$', flags: 'm', label: 'OK' }] }, { name: 'verschränkt', input: ['([)]'], expect: [{ re: '^Fehler$', flags: 'm', label: 'Fehler' }] }, { name: 'offen', input: ['{[()]'], expect: [{ re: '^Fehler$', flags: 'm', label: 'Fehler (nicht geschlossen)' }] }, { name: 'zu früh zu', input: [')('], expect: [{ re: '^Fehler$', flags: 'm', label: 'Fehler (zu früh geschlossen)' }] }],
    main: 'Alle Fälle richtig (Reihenfolge, offen, zu früh)', tip: 'Drei Fehlerfälle: falsche Sorte zu, zu schließen ohne offene, und am Ende ist noch etwas offen.',
  },
  {
    title: 'Zeitrechner', teaser: 'Das Rennen startet um 23:45 und dauert 95 Minuten. Wann ist Zieleinlauf?', uses: ['split', '/ und %', 'printf mit führender 0'],
    text: ['Lies eine Uhrzeit „hh:mm“ und eine Dauer in Minuten ein. Gib die Endzeit im Format „hh:mm“ aus (24-Stunden-Uhr, über Mitternacht hinaus). Kommt man in den nächsten Tag, häng „(+1 Tag)“ an – oder „(+N Tage)“.'],
    example: '23:45\n95\n01:20 (+1 Tag)',
    lookup: ['Lektion 7 · split(":")', 'Lektion 2 · / und % für Stunden und Minuten', 'printf: `%02d` für führende Null'],
    starter: prog(R`
        Scanner sc = new Scanner(System.in);
        String zeit = sc.nextLine();
        int dauer = Integer.parseInt(sc.nextLine());
`, SC),
    solution: prog(R`
        Scanner sc = new Scanner(System.in);
        String[] t = sc.nextLine().split(":");
        int dauer = Integer.parseInt(sc.nextLine());
        int minuten = Integer.parseInt(t[0]) * 60 + Integer.parseInt(t[1]) + dauer;
        int tage = minuten / (24 * 60);
        minuten = minuten % (24 * 60);
        System.out.printf("%02d:%02d", minuten / 60, minuten % 60);
        if (tage == 1) System.out.print(" (+1 Tag)");
        else if (tage > 1) System.out.print(" (+" + tage + " Tage)");
        System.out.println();`, SC),
    tests: [{ name: 'Mitternacht', input: ['23:45', '95'], expect: [{ re: '01:20', label: '01:20' }, { re: '\\+1 tag', label: '(+1 Tag)' }] }, { name: 'gleicher Tag', input: ['08:05', '10'], expect: [{ re: '08:15', label: '08:15' }, { re: 'tag', label: 'kein Tageswechsel', not: true }] }, { name: '3 Tage', input: ['12:00', '4320'], expect: [{ re: '12:00', label: '12:00' }, { re: '\\+3 tage', label: '(+3 Tage)' }] }],
    main: 'Endzeit und Tageswechsel richtig', tip: 'Rechne alles in Minuten seit Mitternacht um, addier die Dauer und zerleg dann wieder mit / und %.',
  },
  {
    title: 'Game of Life', teaser: 'Zellen leben, sterben und werden geboren – berechne eine Generation von Conways berühmtem Spiel.', uses: ['2D-Array', 'Nachbarn zählen', 'neues Array'],
    text: ['Lies die Anzahl der Zeilen und das Gitter ein (`#` lebt, `.` tot). Berechne **eine** neue Generation: Eine lebende Zelle mit 2 oder 3 lebenden Nachbarn überlebt, sonst stirbt sie. Eine tote Zelle mit genau 3 lebenden Nachbarn wird lebendig. Außerhalb des Gitters ist alles tot.', 'Wichtig: Die neue Generation kommt in ein **neues** Array – sonst verfälschst du die Zählung.'],
    example: '3\n...\n###\n...\n.#.\n.#.\n.#.',
    lookup: ['Challenge „Minesweeper-Hinweise“ · Nachbarn zählen', 'Lektion 11 · 2D-Arrays'],
    starter: prog(R`
        Scanner sc = new Scanner(System.in);
        int h = Integer.parseInt(sc.nextLine());
        char[][] alt = new char[h][];
        for (int y = 0; y < h; y++) alt[y] = sc.nextLine().toCharArray();
`, SC),
    solution: prog(R`
        Scanner sc = new Scanner(System.in);
        int h = Integer.parseInt(sc.nextLine());
        char[][] alt = new char[h][];
        for (int y = 0; y < h; y++) alt[y] = sc.nextLine().toCharArray();
        int b = alt[0].length;
        for (int y = 0; y < h; y++) {
            StringBuilder sb = new StringBuilder();
            for (int x = 0; x < b; x++) {
                int n = 0;
                for (int dy = -1; dy <= 1; dy++) {
                    for (int dx = -1; dx <= 1; dx++) {
                        if (dx == 0 && dy == 0) continue;
                        int ny = y + dy, nx = x + dx;
                        if (ny >= 0 && ny < h && nx >= 0 && nx < b && alt[ny][nx] == '#') n++;
                    }
                }
                boolean lebt = alt[y][x] == '#';
                sb.append((lebt && (n == 2 || n == 3)) || (!lebt && n == 3) ? '#' : '.');
            }
            System.out.println(sb);
        }`, SC),
    tests: [{ name: 'Blinker', input: ['3', '...', '###', '...'], expect: [{ re: '^\\.#\\.\\n\\.#\\.\\n\\.#\\.$', flags: 'm', label: 'Blinker dreht sich' }] }, { name: 'Block bleibt', input: ['4', '....', '.##.', '.##.', '....'], expect: [{ re: '^\\.\\.\\.\\.\\n\\.##\\.\\n\\.##\\.\\n\\.\\.\\.\\.$', flags: 'm', label: 'Block bleibt gleich' }] }],
    main: 'Neue Generation nach allen Regeln richtig', tip: 'Zähl bei den Nachbarn die Zelle selbst nicht mit (dx = 0 und dy = 0 überspringen).',
  },
  {
    title: 'Punkt vor Strich', teaser: 'Ein Taschenrechner, der „2 + 3 * 4“ richtig mit 14 beantwortet – nicht mit 20.', uses: ['ArrayList', 'split', 'zwei Durchgänge'],
    text: ['Lies einen Ausdruck ein, in dem Zahlen und Rechenzeichen (+ − * /) durch Leerzeichen getrennt sind, z. B. „2 + 3 * 4 - 6 / 2“. Rechne mit ganzen Zahlen und beachte **Punkt vor Strich**. Gib „= Ergebnis“ aus.', 'Idee: Zwei Durchgänge. Im ersten rechnest du alle * und / aus und ersetzt sie durch ihr Ergebnis, im zweiten die + und −.'],
    example: '2 + 3 * 4 - 6 / 2\n= 11',
    lookup: ['Lektion 9 · ArrayList: `set` und `remove` (rückwärts denken!)', 'Lektion 7 · split und parseInt'],
    starter: prog(R`
        Scanner sc = new Scanner(System.in);
        String[] teile = sc.nextLine().split(" ");
        ArrayList<String> t = new ArrayList<>();
        for (String s : teile) t.add(s);
`, ALSC),
    solution: prog(R`
        Scanner sc = new Scanner(System.in);
        String[] teile = sc.nextLine().split(" ");
        ArrayList<String> t = new ArrayList<>();
        for (String s : teile) t.add(s);
        int i = 1;
        while (i < t.size()) {
            String op = t.get(i);
            if (op.equals("*") || op.equals("/")) {
                int a = Integer.parseInt(t.get(i - 1)), b = Integer.parseInt(t.get(i + 1));
                int r = op.equals("*") ? a * b : a / b;
                t.set(i - 1, "" + r);
                t.remove(i + 1);
                t.remove(i);
            } else {
                i += 2;
            }
        }
        int ergebnis = Integer.parseInt(t.get(0));
        for (int k = 1; k < t.size(); k += 2) {
            int z = Integer.parseInt(t.get(k + 1));
            if (t.get(k).equals("+")) ergebnis += z;
            else ergebnis -= z;
        }
        System.out.println("= " + ergebnis);`, ALSC),
    tests: [{ name: 'gemischt', input: ['2 + 3 * 4 - 6 / 2'], expect: [{ re: '=\\s*11\\b', label: '= 11' }] }, { name: 'nur Strich', input: ['10 - 3 - 2'], expect: [{ re: '=\\s*5\\b', label: '= 5 (von links nach rechts)' }] }, { name: 'Kette', input: ['2 * 3 * 4 + 1'], expect: [{ re: '=\\s*25\\b', label: '= 25' }] }],
    main: 'Punkt vor Strich und links-nach-rechts richtig', tip: 'Wenn du * oder / ausrechnest, bleibt der Index i gleich – an der Stelle steht danach das nächste Rechenzeichen.',
  },
  {
    title: 'Kürzester Weg', teaser: 'Wie viele Schritte braucht man mindestens durchs Labyrinth? Die Breitensuche weiß es.', uses: ['2D-Array', 'ArrayList als Warteschlange', 'Breitensuche'],
    text: ['Lies ein Labyrinth ein (`#` Wand, `.` Weg, `S` Start, `Z` Ziel). Finde mit einer **Breitensuche** die kleinste Anzahl an Schritten (hoch, runter, links, rechts) von S nach Z und gib „Kürzester Weg: N Schritte“ aus – oder „Kein Weg“.', 'Breitensuche: Ein `int[][] dist` merkt sich für jedes Feld die Schritte (−1 = noch unbekannt). Eine Liste dient als Warteschlange: Nimm vorne ein Feld heraus und trag alle unbekannten freien Nachbarn mit dist + 1 hinten ein.'],
    example: '4\nS.#.\n..#Z\n#...\n....\nKürzester Weg: 6 Schritte',
    lookup: ['Lektion 11 · Bewegung und Kollision', 'Lektion 9 · ArrayList: `add` hinten, `remove(0)` vorne'],
    starter: prog(R`
        Scanner sc = new Scanner(System.in);
        int h = Integer.parseInt(sc.nextLine());
        char[][] m = new char[h][];
        for (int y = 0; y < h; y++) m[y] = sc.nextLine().toCharArray();
`, ALSC),
    solution: prog(R`
        Scanner sc = new Scanner(System.in);
        int h = Integer.parseInt(sc.nextLine());
        char[][] m = new char[h][];
        for (int y = 0; y < h; y++) m[y] = sc.nextLine().toCharArray();
        int b = m[0].length;
        int[][] dist = new int[h][b];
        ArrayList<Integer> warte = new ArrayList<>();
        for (int y = 0; y < h; y++) {
            for (int x = 0; x < b; x++) {
                dist[y][x] = -1;
                if (m[y][x] == 'S') {
                    dist[y][x] = 0;
                    warte.add(y * b + x);
                }
            }
        }
        int[] dx = {1, -1, 0, 0};
        int[] dy = {0, 0, 1, -1};
        int antwort = -1;
        while (!warte.isEmpty()) {
            int p = warte.remove(0);
            int x = p % b, y = p / b;
            if (m[y][x] == 'Z') {
                antwort = dist[y][x];
                break;
            }
            for (int r = 0; r < 4; r++) {
                int nx = x + dx[r], ny = y + dy[r];
                if (nx >= 0 && nx < b && ny >= 0 && ny < h && m[ny][nx] != '#' && dist[ny][nx] == -1) {
                    dist[ny][nx] = dist[y][x] + 1;
                    warte.add(ny * b + nx);
                }
            }
        }
        System.out.println(antwort >= 0 ? "Kürzester Weg: " + antwort + " Schritte" : "Kein Weg");`, ALSC),
    tests: [{ name: '4×4', input: ['4', 'S.#.', '..#Z', '#...', '....'], expect: [{ re: 'k(ü|ue)rzester weg:?\\s*6', label: '6 Schritte' }] }, { name: 'versperrt', input: ['3', 'S#.', '##.', '..Z'], expect: [{ re: 'kein weg', label: 'Kein Weg' }] }, { name: 'gerade', input: ['1', 'S...Z'], expect: [{ re: 'weg:?\\s*4', label: '4 Schritte' }] }],
    main: 'Kürzeste Schrittzahl richtig, auch ohne Weg', tip: 'Eine Position (x, y) passt als eine Zahl in die Liste: `y * breite + x`. Zurück geht es mit `% breite` und `/ breite`.',
  },
  {
    title: 'Turnier-Tabelle', teaser: 'Spielergebnisse rein, fertige Tabelle raus – mit Punkten, Toren und richtiger Sortierung.', uses: ['Klasse', 'HashMap oder ArrayList', 'Sortieren', 'printf'],
    text: ['Lies Spielergebnisse wie „Lena 3 1 Tom“ ein (Lena gegen Tom, 3:1), bis „ende“. Sieg = 3 Punkte, Unentschieden = 1 Punkt.', 'Gib eine Tabelle aus, sortiert nach Punkten, bei Gleichstand nach Tordifferenz: „1. Lena 6 P (+4)“. Schreib dafür eine Klasse `Team` mit name, punkte, tore, gegentore.'],
    example: 'Lena 3 1 Tom\nTom 2 2 Mia\nMia 0 2 Lena\nende\n1. Lena 6 P (+4)\n2. Tom 1 P (-2)\n3. Mia 1 P (-2)',
    lookup: ['Lektion 8 · Klassen', 'Finale · Bubble Sort (zum Sortieren nach zwei Kriterien)', 'Lektion 9 · Objekt in einer Liste suchen'],
    starter: file(R`
class Team {
    String name;
    int punkte, tore, gegentore;

    Team(String name) {
        this.name = name;
    }
}`, R`
        Scanner sc = new Scanner(System.in);
        ArrayList<Team> teams = new ArrayList<>();
`, ALSC),
    solution: file(R`
class Team {
    String name;
    int punkte, tore, gegentore;

    Team(String name) {
        this.name = name;
    }

    int diff() {
        return tore - gegentore;
    }

    boolean besserAls(Team o) {
        if (punkte != o.punkte) return punkte > o.punkte;
        return diff() > o.diff();
    }
}`, R`
        Scanner sc = new Scanner(System.in);
        ArrayList<Team> teams = new ArrayList<>();
        while (true) {
            String zeile = sc.nextLine();
            if (zeile.equals("ende")) break;
            String[] t = zeile.split(" ");
            Team a = null, b = null;
            for (Team x : teams) {
                if (x.name.equals(t[0])) a = x;
                if (x.name.equals(t[3])) b = x;
            }
            if (a == null) { a = new Team(t[0]); teams.add(a); }
            if (b == null) { b = new Team(t[3]); teams.add(b); }
            int ta = Integer.parseInt(t[1]), tb = Integer.parseInt(t[2]);
            a.tore += ta; a.gegentore += tb;
            b.tore += tb; b.gegentore += ta;
            if (ta > tb) a.punkte += 3;
            else if (tb > ta) b.punkte += 3;
            else { a.punkte++; b.punkte++; }
        }
        for (int i = 0; i < teams.size(); i++) {
            for (int j = 0; j < teams.size() - 1 - i; j++) {
                if (teams.get(j + 1).besserAls(teams.get(j))) {
                    Team tmp = teams.get(j);
                    teams.set(j, teams.get(j + 1));
                    teams.set(j + 1, tmp);
                }
            }
        }
        for (int i = 0; i < teams.size(); i++) {
            Team t = teams.get(i);
            System.out.printf("%d. %s %d P (%+d)%n", i + 1, t.name, t.punkte, t.diff());
        }`, ALSC),
    tests: [{ name: 'drei Spiele', input: ['Lena 3 1 Tom', 'Tom 2 2 Mia', 'Mia 0 2 Lena', 'ende'], expect: [{ re: '^1\\. lena 6 p \\(\\+4\\)', flags: 'im', label: '1. Lena 6 P (+4)' }, { re: '(tom|mia) 1 p \\(-2\\)', label: 'Tom und Mia 1 P (−2)' }] }, { name: 'Tordifferenz', input: ['A 5 0 B', 'B 1 0 C', 'C 1 0 A', 'ende'], expect: [{ re: '^1\\. a 3 p \\(\\+4\\)', flags: 'im', label: '1. A (bessere Tordifferenz)' }, { re: '^3\\. b 3 p \\(-4\\)', flags: 'im', label: '3. B (−4)' }] }],
    codeChecks: [{ label: 'Klasse Team', re: 'class\\s+Team' }],
    main: 'Punkte, Tore und Sortierung richtig', tip: 'Schreib in Team eine Methode `besserAls(Team o)`. Dann kannst du mit Bubble Sort ganz normal sortieren.',
  },
  {
    title: 'Endgegner: Rennen-Auswertung', teaser: 'Das letzte Level: Werte ein ganzes Multiplayer-Rennen aus – Runden, Bestzeiten, Strafen und Endstand.', uses: ['Klassen', 'Listen', 'Methoden', 'Exceptions', 'Sortieren', 'printf'],
    text: ['Ein Rennen im Jump’n’Run hat 3 Runden. Lies Zeilen wie „Mia 41.2 39.8 40.5“ ein (Name und drei Rundenzeiten in Sekunden), bis „ende“. Zeilen mit falschem Format (zu wenige Zahlen oder keine Zahl) meldest du mit „Ungültig: …“ und überspringst sie.', 'Zusätzlich gibt es Strafen: „strafe Mia 5“ addiert 5 Sekunden zur Gesamtzeit von Mia (falls es sie gibt).', 'Am Ende: Rangliste nach Gesamtzeit „1. Mia 126,5 s (beste Runde 39,8)“, danach „Schnellste Runde: Name (Zeit s)“ über alle Fahrer.'],
    example: 'Mia 41.2 39.8 40.5\nTom 40.0 40.1 42.0\nLea 40 x 41\nUngültig: Lea 40 x 41\nstrafe Tom 3\nende\n1. Mia 121,5 s (beste Runde 39,8)\n2. Tom 125,1 s (beste Runde 40,0)\nSchnellste Runde: Mia (39,8 s)',
    lookup: ['Lektion 9 · Bestenliste mit Klasse und Liste', 'Lektion 11 · try/catch für NumberFormatException und ArrayIndexOutOfBoundsException', 'Finale · Bubble Sort'],
    starter: file(R`
class Fahrer {
    // name, drei Rundenzeiten (double[]), strafe
}`, R`
        Scanner sc = new Scanner(System.in);
        ArrayList<Fahrer> fahrer = new ArrayList<>();
`, ALSC),
    solution: file(R`
class Fahrer {
    String name;
    double[] runden;
    double strafe = 0;

    Fahrer(String name, double[] runden) {
        this.name = name;
        this.runden = runden;
    }

    double gesamt() {
        double s = strafe;
        for (double r : runden) s += r;
        return s;
    }

    double beste() {
        double b = runden[0];
        for (double r : runden) if (r < b) b = r;
        return b;
    }
}`, R`
        Scanner sc = new Scanner(System.in);
        ArrayList<Fahrer> fahrer = new ArrayList<>();
        while (true) {
            String zeile = sc.nextLine();
            if (zeile.equals("ende")) break;
            String[] t = zeile.split(" ");
            try {
                if (t[0].equals("strafe")) {
                    for (Fahrer f : fahrer) {
                        if (f.name.equals(t[1])) f.strafe += Double.parseDouble(t[2]);
                    }
                    continue;
                }
                if (t.length != 4) throw new IllegalArgumentException();
                double[] r = new double[3];
                for (int i = 0; i < 3; i++) r[i] = Double.parseDouble(t[i + 1]);
                fahrer.add(new Fahrer(t[0], r));
            } catch (IllegalArgumentException | ArrayIndexOutOfBoundsException e) {
                System.out.println("Ungültig: " + zeile);
            }
        }
        for (int i = 0; i < fahrer.size(); i++) {
            for (int j = 0; j < fahrer.size() - 1 - i; j++) {
                if (fahrer.get(j + 1).gesamt() < fahrer.get(j).gesamt()) {
                    Fahrer tmp = fahrer.get(j);
                    fahrer.set(j, fahrer.get(j + 1));
                    fahrer.set(j + 1, tmp);
                }
            }
        }
        Fahrer schnellster = null;
        for (int i = 0; i < fahrer.size(); i++) {
            Fahrer f = fahrer.get(i);
            System.out.printf("%d. %s %.1f s (beste Runde %.1f)%n", i + 1, f.name, f.gesamt(), f.beste());
            if (schnellster == null || f.beste() < schnellster.beste()) schnellster = f;
        }
        if (schnellster != null) System.out.printf("Schnellste Runde: %s (%.1f s)%n", schnellster.name, schnellster.beste());`, ALSC),
    tests: [
      { name: 'Rennen mit Strafe', input: ['Mia 41.2 39.8 40.5', 'Tom 40.0 40.1 42.0', 'Lea 40 x 41', 'strafe Tom 3', 'ende'], expect: [{ re: '^1\\. mia 121[.,]5', flags: 'im', label: '1. Mia 121,5 s' }, { re: '^2\\. tom 125[.,]1', flags: 'im', label: '2. Tom 125,1 s (mit Strafe)' }, { re: 'ung(ü|ue)ltig:? lea', label: 'Lea ungültig' }, { re: 'schnellste runde:?\\s*mia\\s*\\(39[.,]8', label: 'Schnellste Runde: Mia (39,8 s)' }] },
      { name: 'Strafe dreht Reihenfolge', input: ['Ben 30 30 30', 'Ida 31 31 31', 'strafe Ben 5', 'Max 20 20', 'ende'], expect: [{ re: '^1\\. ida 93[.,]0', flags: 'im', label: '1. Ida 93,0 s' }, { re: '^2\\. ben 95[.,]0', flags: 'im', label: '2. Ben 95,0 s' }, { re: 'ung(ü|ue)ltig:? max', label: 'Max ungültig (zu wenige Runden)' }, { re: 'schnellste runde:?\\s*ben', label: 'Schnellste Runde: Ben' }] },
    ],
    codeChecks: [{ label: 'Klasse Fahrer', re: 'class\\s+Fahrer' }, { label: 'try/catch', re: 'catch\\s*\\(' }],
    rubric: [['Programm kompiliert und läuft', 10], ['Klasse mit gesamt() und beste()', 20], ['Ungültige Zeilen sicher abgefangen', 15], ['Strafen richtig angerechnet', 15], ['Rangliste richtig sortiert und formatiert', 25], ['Schnellste Runde', 15]],
    tip: 'Bau es Schritt für Schritt: erst einlesen und ausgeben, dann sortieren, dann Strafen, ganz zum Schluss die Fehlerbehandlung.',
  },
];

export default list.map((c, i) => ({
  id: 'f' + String(i + 1).padStart(2, '0'),
  nr: i + 1,
  level: LV[i] + ' Finale ' + (i + 1) + '/20',
  req: c.req || ['Ausgabe genau wie im Beispiel', 'Alle Tests bestehen', 'Lösung mit den Mitteln aus dem Kurs'],
  rubric: c.rubric || RUB(c.main),
  ...c,
}));
