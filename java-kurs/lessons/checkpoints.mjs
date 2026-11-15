// Zwischen-Challenges nach Lektion 7, 9, 10 und 11 (Transfer-Aufgaben, so nie im Video gezeigt)
const R = String.raw;
const strip = s => s.replace(/^\n/, '').replace(/\n$/, '');
const prog = (body, imports = '') => `${imports}public class Main {\n    public static void main(String[] args) {\n${strip(body)}\n    }\n}\n`;
const file = (classes, body, imports = '') => `${imports}${strip(classes)}\n\npublic class Main {\n    public static void main(String[] args) {\n${strip(body)}\n    }\n}\n`;
const SC = 'import java.util.Scanner;\n\n';
const ALSC = 'import java.util.ArrayList;\nimport java.util.Scanner;\n\n';

export default [
  {
    id: 'c7', after: 7, level: '★★☆ mittel', title: 'Palindrom-Prüfer',
    teaser: '„Lagerregal“ liest sich rückwärts gleich. Dein Programm erkennt solche Wörter und sogar ganze Sätze.',
    uses: ['charAt', 'toLowerCase', 'Schleife', 'boolean'],
    text: ['Lies eine Zeile ein und prüfe, ob sie ein **Palindrom** ist – also vorwärts und rückwärts gleich gelesen wird. Groß- und Kleinschreibung und Leerzeichen zählen dabei nicht.', 'Gib „Palindrom!“ oder „Kein Palindrom.“ aus.'],
    req: ['Eingabe mit `nextLine()`', 'Groß/klein und Leerzeichen ignorieren', 'Vergleich von vorne und hinten (Schleife oder StringBuilder)', 'Ausgabe „Palindrom!“ bzw. „Kein Palindrom.“'],
    example: 'Text: Trug Tim eine so helle Hose nie mit Gurt\nPalindrom!',
    lookup: ['Lektion 7 · `replace(" ", "")` und `toLowerCase()`', 'Lektion 7 · `charAt(i)` und `charAt(länge - 1 - i)` vergleichen', 'Lektion 7 · `new StringBuilder(text).reverse()`'],
    starter: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Text: ");
        String text = sc.nextLine();
`, SC),
    solution: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Text: ");
        String text = sc.nextLine().replace(" ", "").toLowerCase();
        boolean palindrom = true;
        for (int i = 0; i < text.length() / 2; i++) {
            if (text.charAt(i) != text.charAt(text.length() - 1 - i)) {
                palindrom = false;
                break;
            }
        }
        System.out.println(palindrom ? "Palindrom!" : "Kein Palindrom.");`, SC),
    tests: [
      { name: 'Lagerregal', input: ['Lagerregal'], expect: [{ re: 'palindrom!', label: '„Palindrom!“' }, { re: 'kein', label: 'nicht „Kein“', not: true }] },
      { name: 'Satz', input: ['Trug Tim eine so helle Hose nie mit Gurt'], expect: [{ re: 'palindrom', label: '„Palindrom!“' }, { re: 'kein', label: 'nicht „Kein“', not: true }] },
      { name: 'Hallo', input: ['Hallo'], expect: [{ re: 'kein palindrom', label: '„Kein Palindrom.“' }] },
    ],
    rubric: [['Programm kompiliert und läuft', 15], ['Leerzeichen und Groß/klein ignoriert', 25], ['Vergleich richtig', 40], ['Klare Ausgabe', 10], ['Lesbarer Code', 10]],
    tip: 'Mach den Text zuerst „sauber“ (keine Leerzeichen, alles klein). Dann vergleichst du Zeichen i mit Zeichen länge − 1 − i.',
  },
  {
    id: 'c8', after: 7, level: '★★☆ mittel', title: 'Wort-Statistik',
    teaser: 'Wie viele Wörter hat ein Satz, welches ist das längste – und wie lang sind die Wörter im Schnitt?',
    uses: ['split', 'length()', 'Maximum', 'double'],
    text: ['Lies einen Satz ein (Wörter durch Leerzeichen getrennt). Gib aus: die Anzahl der Wörter, das **längste** Wort (bei Gleichstand das erste) und die durchschnittliche Wortlänge mit einer Nachkommastelle.'],
    req: ['Satz mit `split(" ")` zerlegen', 'Anzahl der Wörter', 'Längstes Wort (erstes bei Gleichstand)', 'Durchschnittliche Länge mit 1 Nachkommastelle'],
    example: 'Satz: Mario springt über drei grüne Röhren\nWörter: 6\nLängstes: springt\nSchnitt: 5,2',
    lookup: ['Lektion 7 · `split` zerlegt Text in ein Array', 'Lektion 5 · Maximum in einem Array suchen', 'Lektion 2 · `printf("%.1f")` für eine Nachkommastelle'],
    starter: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Satz: ");
        String satz = sc.nextLine();
`, SC),
    solution: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Satz: ");
        String[] woerter = sc.nextLine().split(" ");
        String laengstes = "";
        int summe = 0;
        for (String w : woerter) {
            summe += w.length();
            if (w.length() > laengstes.length()) {
                laengstes = w;
            }
        }
        System.out.println("Wörter: " + woerter.length);
        System.out.println("Längstes: " + laengstes);
        System.out.printf("Schnitt: %.1f%n", (double) summe / woerter.length);`, SC),
    tests: [
      { name: 'Mario', input: ['Mario springt über drei grüne Röhren'], expect: [{ re: 'w(ö|oe)rter:?\\s*6', label: '6 Wörter' }, { re: 'springt', label: 'längstes: springt' }, { re: '5[.,]2', label: 'Schnitt 5,2' }] },
      { name: 'Gleichstand', input: ['ab cd ef'], expect: [{ re: 'l(ä|ae)ngstes:?\\s*ab', label: 'erstes bei Gleichstand: ab' }, { re: '2[.,]0', label: 'Schnitt 2,0' }] },
    ],
    rubric: [['Programm kompiliert und läuft', 15], ['Wörter richtig gezählt', 20], ['Längstes Wort richtig', 30], ['Durchschnitt richtig formatiert', 25], ['Lesbarer Code', 10]],
    tip: 'Ein `>` statt `>=` beim Vergleich sorgt dafür, dass bei Gleichstand das erste Wort gewinnt.',
  },
  {
    id: 'c9', after: 9, level: '★★☆ mittel', title: 'Einkaufszettel',
    teaser: 'Eine kleine Kassen-App: Artikel mit Preis und Menge, Gesamtsumme und der teuerste Posten.',
    uses: ['Klasse', 'private + Getter', 'ArrayList', 'split', 'printf'],
    text: ['Schreib eine Klasse `Artikel` mit private-Feldern `name`, `preis` (double) und `menge` (int), Gettern und einer Methode `double summe()` (preis × menge).', 'Lies Zeilen wie „Milch 1.29 2“ ein, bis „fertig“ kommt. Gib dann jede Position mit ihrer Summe aus, danach „Gesamt: … €“ (2 Nachkommastellen) und „Teuerste Position: Name“.'],
    req: ['Klasse `Artikel` mit private-Feldern, Gettern, `summe()`', '`ArrayList<Artikel>`', 'Zeilen mit `split` und `parseDouble`/`parseInt` zerlegen', 'Gesamtsumme mit 2 Nachkommastellen', 'Teuerste Position'],
    example: 'Milch 1.29 2\nPizza 4.99 1\nÄpfel 0.45 6\nfertig\nMilch: 2,58 €\nPizza: 4,99 €\nÄpfel: 2,70 €\nGesamt: 10,27 €\nTeuerste Position: Pizza',
    lookup: ['Lektion 9 · Listen von Objekten und Kapselung', 'Lektion 7 · `split` und `Double.parseDouble`', 'Lektion 9 · „bestes Objekt merken“ (Bestenliste)'],
    starter: file(R`
class Artikel {
    // private Felder, Konstruktor, Getter, summe()
}`, R`
        Scanner sc = new Scanner(System.in);
        ArrayList<Artikel> zettel = new ArrayList<>();
`, ALSC),
    solution: file(R`
class Artikel {
    private String name;
    private double preis;
    private int menge;

    Artikel(String name, double preis, int menge) {
        this.name = name;
        this.preis = preis;
        this.menge = menge;
    }

    public String getName() { return name; }
    public double getPreis() { return preis; }
    public int getMenge() { return menge; }

    double summe() {
        return preis * menge;
    }
}`, R`
        Scanner sc = new Scanner(System.in);
        ArrayList<Artikel> zettel = new ArrayList<>();
        while (true) {
            String zeile = sc.nextLine();
            if (zeile.equals("fertig")) break;
            String[] t = zeile.split(" ");
            zettel.add(new Artikel(t[0], Double.parseDouble(t[1]), Integer.parseInt(t[2])));
        }
        double gesamt = 0;
        Artikel teuerste = null;
        for (Artikel a : zettel) {
            System.out.printf("%s: %.2f €%n", a.getName(), a.summe());
            gesamt += a.summe();
            if (teuerste == null || a.summe() > teuerste.summe()) teuerste = a;
        }
        System.out.printf("Gesamt: %.2f €%n", gesamt);
        if (teuerste != null) System.out.println("Teuerste Position: " + teuerste.getName());`, ALSC),
    tests: [
      { name: 'drei Artikel', input: ['Milch 1.29 2', 'Pizza 4.99 1', 'Äpfel 0.45 6', 'fertig'], expect: [{ re: 'gesamt:?\\s*10[.,]27', label: 'Gesamt 10,27' }, { re: 'teuerste[^\\n]*pizza', label: 'teuerste: Pizza' }, { re: '2[.,]70', label: 'Äpfel: 2,70' }] },
      { name: 'Menge zählt', input: ['Kaugummi 0.99 10', 'Buch 8.50 1', 'fertig'], expect: [{ re: 'gesamt:?\\s*18[.,]40', label: 'Gesamt 18,40' }, { re: 'teuerste[^\\n]*kaugummi', label: 'teuerste: Kaugummi (9,90)' }] },
    ],
    codeChecks: [{ label: 'Klasse Artikel', re: 'class\\s+Artikel' }, { label: 'private Felder', re: 'private\\s+\\w+\\s+\\w+\\s*;' }, { label: 'Methode summe()', re: 'double\\s+summe\\s*\\(\\s*\\)' }],
    rubric: [['Programm kompiliert und läuft', 15], ['Klasse mit Kapselung und summe()', 25], ['Einlesen bis „fertig“', 15], ['Summen und Gesamt richtig formatiert', 25], ['Teuerste Position', 20]],
    tip: '`printf("%.2f", wert)` gibt genau zwei Nachkommastellen aus. Die teuerste Position ist die mit der größten `summe()`, nicht dem größten Einzelpreis.',
  },
  {
    id: 'c10', after: 10, level: '★★☆ mittel', title: 'Rennstrecke',
    teaser: 'Auto, Fahrrad und Rakete fahren um die Wette – jedes Fahrzeug rechnet seine Zeit selbst aus.',
    uses: ['abstract', 'extends', '@Override', 'Polymorphie', 'ArrayList'],
    text: ['Schreib eine abstrakte Klasse `Fahrzeug` mit `abstract double tempo()` (km/h) und `abstract String name()`. Unterklassen: `Fahrrad` (20 km/h), `Auto` (120 km/h), `Rakete` (3000 km/h).', 'Lies zuerst die Strecke in km (double), dann eine Zeile mit Kürzeln (f, a, r). Gib für jedes Fahrzeug die Zeit in Minuten mit 1 Nachkommastelle aus und am Ende den Sieger.'],
    req: ['Abstrakte Klasse mit zwei abstrakten Methoden', 'Drei Unterklassen mit `@Override`', '`ArrayList<Fahrzeug>` und Polymorphie', 'Zeit in Minuten = Strecke / Tempo × 60', 'Sieger ausgeben'],
    example: 'Strecke (km): 10\nFahrzeuge: f a\nFahrrad: 30,0 min\nAuto: 5,0 min\nSieger: Auto',
    lookup: ['Lektion 10 · abstrakte Klassen und Power-ups', 'Lektion 9 · Liste von Objekten', 'Lektion 2 · `printf("%.1f")`'],
    starter: file(R`
// abstract class Fahrzeug { ... }`, R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Strecke (km): ");
        double strecke = Double.parseDouble(sc.nextLine());
        System.out.print("Fahrzeuge: ");
        String[] kuerzel = sc.nextLine().split(" ");
`, ALSC),
    solution: file(R`
abstract class Fahrzeug {
    abstract double tempo();
    abstract String name();
}

class Fahrrad extends Fahrzeug {
    @Override double tempo() { return 20; }
    @Override String name() { return "Fahrrad"; }
}

class Auto extends Fahrzeug {
    @Override double tempo() { return 120; }
    @Override String name() { return "Auto"; }
}

class Rakete extends Fahrzeug {
    @Override double tempo() { return 3000; }
    @Override String name() { return "Rakete"; }
}`, R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Strecke (km): ");
        double strecke = Double.parseDouble(sc.nextLine());
        System.out.print("Fahrzeuge: ");
        String[] kuerzel = sc.nextLine().split(" ");
        ArrayList<Fahrzeug> feld = new ArrayList<>();
        for (String k : kuerzel) {
            if (k.equals("f")) feld.add(new Fahrrad());
            else if (k.equals("a")) feld.add(new Auto());
            else if (k.equals("r")) feld.add(new Rakete());
        }
        Fahrzeug sieger = null;
        for (Fahrzeug f : feld) {
            System.out.printf("%s: %.1f min%n", f.name(), strecke / f.tempo() * 60);
            if (sieger == null || f.tempo() > sieger.tempo()) sieger = f;
        }
        if (sieger != null) System.out.println("Sieger: " + sieger.name());`, ALSC),
    tests: [
      { name: '10 km, f a', input: ['10', 'f a'], expect: [{ re: '30[.,]0', label: 'Fahrrad 30,0 min' }, { re: '5[.,]0', label: 'Auto 5,0 min' }, { re: 'sieger:?\\s*auto', label: 'Sieger: Auto' }] },
      { name: '150 km, a r f', input: ['150', 'a r f'], expect: [{ re: '75[.,]0', label: 'Auto 75,0 min' }, { re: '3[.,]0', label: 'Rakete 3,0 min' }, { re: '450[.,]0', label: 'Fahrrad 450,0 min' }, { re: 'sieger:?\\s*rakete', label: 'Sieger: Rakete' }] },
    ],
    codeChecks: [{ label: 'abstract class Fahrzeug', re: 'abstract\\s+class\\s+Fahrzeug' }, { label: 'drei Unterklassen', re: 'extends\\s+Fahrzeug[\\s\\S]*extends\\s+Fahrzeug[\\s\\S]*extends\\s+Fahrzeug' }],
    rubric: [['Programm kompiliert und läuft', 15], ['Abstrakte Klasse und Unterklassen', 30], ['Polymorphe Liste', 20], ['Zeiten richtig berechnet und formatiert', 20], ['Sieger richtig', 15]],
    tip: 'Die Zeit in Stunden ist Strecke durch Tempo. Mal 60 ergibt Minuten.',
  },
  {
    id: 'c11', after: 11, level: '★★★ knifflig', title: 'Minesweeper-Hinweise',
    teaser: 'Kennst du Minesweeper? Berechne für jedes Feld, wie viele Minen rundherum liegen.',
    uses: ['2D-Array', 'verschachtelte Schleifen', 'Nachbarn prüfen', 'Grenzen'],
    text: ['Lies zuerst die Anzahl der Zeilen ein, dann die Zeilen des Feldes: `*` ist eine Mine, `.` ist leer.', 'Gib das Feld wieder aus – aber jedes leere Feld wird durch die Anzahl der Minen in den **8 Nachbarfeldern** ersetzt. Minen bleiben `*`.'],
    req: ['Feld als `char[][]` einlesen', 'Für jedes Feld alle 8 Nachbarn prüfen', 'Ränder des Feldes beachten', 'Ausgabe im gleichen Format'],
    example: 'Zeilen: 3\n*...\n..*.\n....\n*211\n12*1\n0111',
    lookup: ['Lektion 11 · 2D-Arrays und Level aus Text', 'Lektion 11 · Grenzen prüfen, bevor man zugreift', 'Lektion 4 · verschachtelte Schleifen: dy und dx von −1 bis 1'],
    starter: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Zeilen: ");
        int n = Integer.parseInt(sc.nextLine());
        char[][] feld = new char[n][];
        for (int y = 0; y < n; y++) {
            feld[y] = sc.nextLine().toCharArray();
        }
`, SC),
    solution: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Zeilen: ");
        int n = Integer.parseInt(sc.nextLine());
        char[][] feld = new char[n][];
        for (int y = 0; y < n; y++) {
            feld[y] = sc.nextLine().toCharArray();
        }
        for (int y = 0; y < n; y++) {
            StringBuilder sb = new StringBuilder();
            for (int x = 0; x < feld[y].length; x++) {
                if (feld[y][x] == '*') {
                    sb.append('*');
                    continue;
                }
                int minen = 0;
                for (int dy = -1; dy <= 1; dy++) {
                    for (int dx = -1; dx <= 1; dx++) {
                        int ny = y + dy, nx = x + dx;
                        if (ny >= 0 && ny < n && nx >= 0 && nx < feld[ny].length && feld[ny][nx] == '*') {
                            minen++;
                        }
                    }
                }
                sb.append(minen);
            }
            System.out.println(sb);
        }`, SC),
    tests: [
      { name: '3×4', input: ['3', '*...', '..*.', '....'], expect: [{ re: '(^|: )\\*211$', flags: 'm', label: 'Zeile 1: *211' }, { re: '^12\\*1$', flags: 'm', label: 'Zeile 2: 12*1' }, { re: '^0111$', flags: 'm', label: 'Zeile 3: 0111' }] },
      { name: 'Ecken', input: ['2', '.*', '*.'], expect: [{ re: '(^|: )2\\*$', flags: 'm', label: 'Zeile 1: 2*' }, { re: '^\\*2$', flags: 'm', label: 'Zeile 2: *2' }] },
    ],
    codeChecks: [{ label: '2D-Array', re: 'char\\s*\\[\\s*\\]\\s*\\[\\s*\\]' }],
    rubric: [['Programm kompiliert und läuft', 15], ['Feld richtig eingelesen', 15], ['Nachbarn richtig gezählt', 35], ['Ränder ohne Absturz', 20], ['Ausgabe im richtigen Format', 15]],
    tip: 'Zwei kleine Schleifen `dy` und `dx` von −1 bis 1 laufen über alle 9 Felder rund um (x, y). Prüf vor dem Zugriff, ob ny und nx im Feld liegen.',
  },
  {
    id: 'c12', after: 11, level: '★★☆ mittel', title: 'Lücken-Detektor',
    teaser: 'Level-Designer aufgepasst: Findet dein Programm die breiteste Lücke im Boden – und ist sie überhaupt springbar?',
    uses: ['Level aus Text', 'Zählen in Folge', 'Maximum'],
    text: ['Lies die Anzahl der Zeilen und dann ein Level ein (`#` ist Boden). Untersuche die **unterste** Zeile: Eine Lücke ist eine Folge von Feldern, die **kein** `#` sind.', 'Gib die breiteste Lücke aus: „Breiteste Lücke: N Felder ab x=…“ (x ist das erste Feld der Lücke). Ist sie höchstens 3 Felder breit, gib „Springbar!“ aus, sonst „Zu breit!“. Gibt es keine Lücke: „Keine Lücke.“'],
    req: ['Level einlesen', 'Nur die unterste Zeile untersuchen', 'Längste Folge ohne `#` und ihren Anfang finden', 'Springbar-Bewertung'],
    example: 'Zeilen: 3\n#..........#\n#....##....#\n###..##^^^##\nBreiteste Lücke: 3 Felder ab x=7\nSpringbar!',
    lookup: ['Lektion 11 · Level aus Text', 'Lektion 5 · Maximum suchen', 'Lektion 4 · Zähler, der bei # wieder auf 0 springt'],
    starter: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Zeilen: ");
        int n = Integer.parseInt(sc.nextLine());
        String[] level = new String[n];
        for (int i = 0; i < n; i++) {
            level[i] = sc.nextLine();
        }
`, SC),
    solution: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Zeilen: ");
        int n = Integer.parseInt(sc.nextLine());
        String[] level = new String[n];
        for (int i = 0; i < n; i++) {
            level[i] = sc.nextLine();
        }
        String boden = level[n - 1];
        int best = 0, bestStart = -1, lauf = 0;
        for (int x = 0; x < boden.length(); x++) {
            if (boden.charAt(x) == '#') {
                lauf = 0;
            } else {
                lauf++;
                if (lauf > best) {
                    best = lauf;
                    bestStart = x - lauf + 1;
                }
            }
        }
        if (best == 0) {
            System.out.println("Keine Lücke.");
        } else {
            System.out.println("Breiteste Lücke: " + best + " Felder ab x=" + bestStart);
            System.out.println(best <= 3 ? "Springbar!" : "Zu breit!");
        }`, SC),
    tests: [
      { name: 'Stacheln', input: ['3', '#..........#', '#....##....#', '###..##^^^##'], expect: [{ re: '3 felder ab x=7', label: '3 Felder ab x=7' }, { re: 'springbar', label: 'Springbar!' }] },
      { name: 'zu breit', input: ['2', '#........#', '##.....###'], expect: [{ re: '5 felder ab x=2', label: '5 Felder ab x=2' }, { re: 'zu breit', label: 'Zu breit!' }] },
      { name: 'keine', input: ['1', '######'], expect: [{ re: 'keine l(ü|ue)cke', label: 'Keine Lücke.' }] },
    ],
    rubric: [['Programm kompiliert und läuft', 15], ['Unterste Zeile richtig untersucht', 15], ['Breiteste Lücke richtig', 35], ['Startposition richtig', 20], ['Bewertung und Sonderfall', 15]],
    tip: 'Ein Zähler `lauf` wächst bei jedem Nicht-#-Feld und springt bei # auf 0 zurück. Immer wenn er einen neuen Rekord erreicht, merkst du dir Länge und Anfang (x − lauf + 1).',
  },
];
