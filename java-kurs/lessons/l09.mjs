// Lektion 9 – ArrayList & Kapselung
const R = String.raw;
const prog = (body, imports = '') => `${imports}public class Main {\n    public static void main(String[] args) {\n${body.replace(/^\n/, '').replace(/\n$/, '')}\n    }\n}\n`;
const file = (classes, mainBody, imports = '') => `${imports}${classes.replace(/^\n/, '').replace(/\n$/, '')}\n\npublic class Main {\n    public static void main(String[] args) {\n${mainBody.replace(/^\n/, '').replace(/\n$/, '')}\n    }\n}\n`;
const AL = 'import java.util.ArrayList;\n\n';
const ALSC = 'import java.util.ArrayList;\nimport java.util.Scanner;\n\n';

export default {
  id: 'java-09', nr: 9,
  title: 'ArrayList & Kapselung',
  sub: 'Listen, die wachsen und schrumpfen – und Objekte, die ihre Daten selbst beschützen.',
  outro: 'Listen von Objekten sind das Rückgrat jedes Spiels: alle Gegner, alle Münzen, alle Spieler im Rennen. Und mit private und Gettern bleiben deine Objekte immer in einem gültigen Zustand. In Lektion 10 geht es um Vererbung.',
  chapters: [
    {
      title: 'Listen statt Arrays',
      steps: [
        { t: 'Lektion 9', h: 'ArrayList & Kapselung', sub: 'Flexible Listen und sichere Objekte', say: 'Servus! Arrays haben einen Haken: Ihre Größe steht fest. In einem Spiel kommen aber ständig Münzen dazu und Gegner verschwinden. Dafür gibt es die **ArrayList**.' },
        { layout: 'split', visual: { kind: 'compare', left: { title: 'Array', code: 'String[] items = new String[3];\nitems[0] = "Schwert";\n// Platz 4? Geht nicht!', note: 'feste Größe' }, right: { title: 'ArrayList', code: 'ArrayList<String> items = new ArrayList<>();\nitems.add("Schwert");\nitems.add("Schild"); // wächst mit', note: 'wächst und schrumpft', cls: 'good' } }, say: 'Ein Array ist wie ein Eierkarton mit fester Anzahl Plätze. Eine ArrayList ist wie ein Rucksack: Du kannst jederzeit etwas hineingeben oder herausnehmen.' },
        { layout: 'code', console: 'clear', code: prog(R`
        ArrayList<String> items = new ArrayList<>();
        items.add("Schwert");
        items.add("Schild");
        items.add("Trank");
        System.out.println(items);
        System.out.println(items.size());
        System.out.println(items.get(1));`, AL), hl: [1, 4], say: 'Die ArrayList musst du importieren. In spitzen Klammern steht, was hineinkommt – hier Strings. Mit `add` fügst du hinten etwas an.' },
        { run: true, hl: [7, 9], say: 'Mit `println` siehst du die ganze Liste in eckigen Klammern. `size()` ist die Anzahl, `get(1)` holt das Element an Index 1 – wieder zählt man ab 0.' },
      ],
    },
    {
      title: 'Ändern, Entfernen, Durchlaufen',
      steps: [
        { t: 'Kapitel 2', h: 'Die wichtigsten Befehle', sub: 'add, set, remove, contains', after: 'code' },
        { layout: 'split', visual: { kind: 'table', title: 'ArrayList-Befehle', head: ['Befehl', 'macht'], rows: [['`add(x)`', 'hinten anfügen'], ['`add(i, x)`', 'an Stelle i einfügen'], ['`get(i)`', 'Element an Stelle i'], ['`set(i, x)`', 'Stelle i ersetzen'], ['`remove(i)` / `remove(x)`', 'entfernen'], ['`contains(x)`', 'ist x drin?'], ['`size()`', 'Anzahl']], gap: 0.5 }, code: prog(R`
        ArrayList<String> items = new ArrayList<>();
        items.add("Schwert");
        items.add("Trank");
        items.add(0, "Karte");
        items.set(2, "Supertrank");
        items.remove("Schwert");
        System.out.println(items);
        System.out.println(items.contains("Karte"));`, AL), console: 'clear', say: 'Hier die wichtigsten Befehle auf einen Blick. Schauen wir, was mit der Liste passiert.' },
        { run: true, say: 'Karte kam vorne dazu, der Trank wurde zum Supertrank, das Schwert ist weg. Beim Entfernen rücken alle Elemente dahinter automatisch nach.' },
        { layout: 'code', console: 'clear', code: prog(R`
        ArrayList<Integer> punkte = new ArrayList<>();
        punkte.add(120);
        punkte.add(80);
        punkte.add(200);
        int summe = 0;
        for (int p : punkte) {
            summe += p;
        }
        System.out.println("Summe: " + summe);`, AL), hl: [2, 2], say: 'Für Zahlen schreibst du `Integer` statt `int` in die spitzen Klammern – das ist die Objekt-Version von int. Für double nimmst du `Double`. Durchlaufen geht wie beim Array mit der for-each-Schleife.' },
        { run: true, say: 'Summe 400. Java packt die Zahlen automatisch ein und aus, du merkst davon kaum etwas.' },
        { quiz: { id: 'l9-q1', q: 'Eine Liste ist [A, B, C]. Was ist sie nach `remove(0)`?', options: ['[A, B]', '[B, C]', '[null, B, C]', '[A, C]'], correct: 1, explain: 'remove(0) entfernt das Element an Index 0, die anderen rücken nach vorne.' } },
      ],
    },
    {
      title: 'Aufgabe: Inventar',
      steps: [
        { t: 'Aufgabe 1', h: 'Inventar', sub: 'Jetzt bist du dran!', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Aufgabe 1: Inventar mit Befehlen', items: ['Lies so lange Befehle ein, bis „ende“ kommt', '`nimm X` – X ins Inventar (höchstens 5 Dinge!)', '`wirf X` – X entfernen (oder Meldung, falls nicht da)', '`zeige` – Inventar ausgeben'], gap: 0.9 }, say: 'Deine Aufgabe: ein Inventar, wie in einem Abenteuerspiel. Es wird über Text-Befehle gesteuert.' },
        {
          task: {
            id: 'l9-inventar', nr: 1, title: 'Inventar mit Befehlen',
            text: ['Lies in einer Schleife Zeilen mit `nextLine()` ein, bis „ende“ eingegeben wird. Befehle:', '`nimm Name` fügt einen Gegenstand hinzu – ist das Inventar schon voll (5 Dinge), gib „Inventar voll!“ aus. `wirf Name` entfernt ihn – gibt es ihn nicht, gib „Hast du nicht.“ aus. `zeige` gibt das Inventar und die Anzahl aus.'],
            req: ['`ArrayList<String>` als Inventar', 'Schleife bis „ende“', 'Befehle mit `startsWith` / `substring` (oder `split`) erkennen', 'Grenze 5 und Meldung „Hast du nicht.“'],
            example: '> nimm Schwert\n> nimm Trank\n> wirf Schild\nHast du nicht.\n> zeige\n[Schwert, Trank] (2/5)\n> ende',
            starter: prog(R`
        Scanner sc = new Scanner(System.in);
        ArrayList<String> inventar = new ArrayList<>();
        // Befehle lesen, bis "ende"
`, ALSC),
            solution: prog(R`
        Scanner sc = new Scanner(System.in);
        ArrayList<String> inventar = new ArrayList<>();
        while (true) {
            System.out.print("> ");
            String zeile = sc.nextLine();
            if (zeile.equals("ende")) {
                break;
            } else if (zeile.startsWith("nimm ")) {
                if (inventar.size() >= 5) {
                    System.out.println("Inventar voll!");
                } else {
                    inventar.add(zeile.substring(5));
                }
            } else if (zeile.startsWith("wirf ")) {
                if (!inventar.remove(zeile.substring(5))) {
                    System.out.println("Hast du nicht.");
                }
            } else if (zeile.equals("zeige")) {
                System.out.println(inventar + " (" + inventar.size() + "/5)");
            } else {
                System.out.println("Unbekannter Befehl");
            }
        }`, ALSC),
            tests: [
              { name: 'nimm, wirf, zeige', input: ['nimm Schwert', 'nimm Trank', 'nimm Karte', 'wirf Trank', 'wirf Schild', 'zeige', 'ende'], expect: [{ re: 'schwert[^\\n]*karte', label: 'zeige: Schwert und Karte' }, { re: '\\[[^\\]]*trank', label: 'Trank wurde entfernt', not: true }, { re: 'hast du nicht', label: '„Hast du nicht.“' }] },
              { name: 'voll', input: ['nimm A', 'nimm B', 'nimm C', 'nimm D', 'nimm E', 'nimm F', 'zeige', 'ende'], expect: [{ re: 'voll', label: '„Inventar voll!“' }, { re: '\\bF\\b', label: 'F nicht im Inventar', not: true, flags: '' }] },
            ],
            codeChecks: [{ label: 'ArrayList<String>', re: 'ArrayList\\s*<\\s*String\\s*>' }, { label: 'Schleife', re: '\\bwhile\\b|\\bfor\\b|\\bdo\\b' }, { label: 'equals statt == für Befehle', re: '\\.equals(IgnoreCase)?\\s*\\(' }],
            rubric: [['Programm kompiliert und läuft', 15], ['Schleife bis „ende“', 15], ['nimm mit Grenze 5', 25], ['wirf mit Meldung', 25], ['zeige mit Anzahl', 20]],
            tip: '`"nimm Schwert".substring(5)` ist „Schwert“. Und `remove(text)` gibt true oder false zurück – damit weißt du sofort, ob es den Gegenstand gab.',
          },
        },
        { layout: 'code', console: 'clear', code: prog(R`
        ArrayList<String> inventar = new ArrayList<>();
        inventar.add("Schwert");
        String befehl = "wirf Schild";
        if (!inventar.remove(befehl.substring(5))) {
            System.out.println("Hast du nicht.");
        }`, AL), run: true, hl: [5, 7], say: 'Abgegeben! Ein schöner Trick aus der Lösung: `remove` meldet zurück, ob es geklappt hat. So brauchst du kein extra `contains`.' },
      ],
    },
    {
      title: 'Listen von Objekten',
      steps: [
        { t: 'Kapitel 4', h: 'Listen von Objekten', sub: 'Alle Gegner in einer Liste', after: 'code' },
        { layout: 'code', console: 'clear', code: file(R`
class Muenze {
    int x;
    boolean gesammelt;

    Muenze(int x) {
        this.x = x;
    }
}`, R`
        ArrayList<Muenze> muenzen = new ArrayList<>();
        for (int i = 1; i <= 5; i++) {
            muenzen.add(new Muenze(i * 10));
        }
        int spielerX = 30;
        for (Muenze m : muenzen) {
            if (m.x == spielerX) {
                m.gesammelt = true;
            }
        }
        for (Muenze m : muenzen) {
            System.out.print(m.gesammelt ? "x " : "o ");
        }`, AL), hl: [11, 14], say: 'Jetzt kommt alles zusammen: Eine Liste aus **eigenen Objekten**. Hier legen wir fünf Münzen an verschiedene Positionen.' },
        { run: true, hl: [16, 20], say: 'Der Spieler steht bei x = 30 und sammelt genau diese Münze ein. Genau so wird unser Spiel später jedes Bild prüfen: Für jede Münze – berührt der Spieler sie?' },
        { code: file(R`
class Muenze {
    int x;
    boolean gesammelt;

    Muenze(int x) {
        this.x = x;
    }
}`, R`
        ArrayList<Muenze> muenzen = new ArrayList<>();
        for (int i = 1; i <= 5; i++) {
            muenzen.add(new Muenze(i * 10));
        }
        for (int i = muenzen.size() - 1; i >= 0; i--) {
            if (muenzen.get(i).x <= 20) {
                muenzen.remove(i);
            }
        }
        System.out.println("Übrig: " + muenzen.size());`, AL), console: 'clear', hl: [14, 18], say: 'Wichtig beim Entfernen während des Durchlaufens: Geh die Liste **von hinten** durch. Sonst rücken Elemente nach und du überspringst welche. In einer for-each-Schleife darfst du gar nichts entfernen.' },
        { run: true, say: 'Zwei Münzen entfernt, drei übrig. Merk dir: Entfernen in einer Schleife – immer rückwärts.' },
      ],
    },
    {
      title: 'Kapselung',
      steps: [
        { t: 'Kapitel 5', h: 'Kapselung', sub: 'private, Getter und Setter', after: 'code' },
        { layout: 'code', console: 'clear', code: file(R`
class Spieler {
    String name;
    int leben;
}`, R`
        Spieler s = new Spieler();
        s.name = "Mia";
        s.leben = -50;
        System.out.println(s.name + " hat " + s.leben + " Leben");`), hl: [9, 9], say: 'Ein Problem: Jeder kann die Felder einfach ändern – auch auf völlig unsinnige Werte wie minus 50 Leben. Bei großen Programmen passiert das schneller, als man denkt.' },
        { run: true, say: 'Minus 50 Leben. Das sollte nie passieren dürfen. Die Lösung heißt **Kapselung**: Das Objekt passt selbst auf seine Daten auf.' },
        { code: file(R`
class Spieler {
    private String name;
    private int leben;

    Spieler(String name) {
        this.name = name;
        this.leben = 3;
    }

    public int getLeben() {
        return leben;
    }

    public void setLeben(int leben) {
        if (leben >= 0 && leben <= 9) {
            this.leben = leben;
        }
    }

    public String getName() {
        return name;
    }
}`, R`
        Spieler s = new Spieler("Mia");
        s.setLeben(-50);
        System.out.println(s.getName() + " hat " + s.getLeben() + " Leben");
        s.setLeben(5);
        System.out.println(s.getName() + " hat " + s.getLeben() + " Leben");`), console: 'clear', hl: [2, 3], say: 'Mit `private` sind die Felder von außen unsichtbar. Nur Code **in der Klasse** darf sie anfassen.' },
        { hl: [10, 18], say: 'Zum Lesen gibt es einen **Getter**, zum Ändern einen **Setter**. Der Setter kann prüfen, ob der neue Wert erlaubt ist – unsinnige Werte werden einfach ignoriert.' },
        { run: true, say: 'Die minus 50 wurden abgewiesen, die 5 angenommen. Probier mal im Code `s.leben = 7;` in main – dann meldet Java einen Fehler, weil das Feld private ist.' },
        { quiz: { id: 'l9-q2', q: 'Warum macht man Felder `private`?', options: ['Damit das Programm schneller läuft', 'Damit nur die Klasse selbst sie ändern kann und ungültige Werte verhindert', 'Damit man sie nicht ausgeben kann', 'Weil Java das verlangt'], correct: 1, explain: 'Kapselung schützt das Objekt: Änderungen gehen nur über Methoden, die prüfen können.' } },
      ],
    },
    {
      title: 'Aufgabe: Bestenliste',
      steps: [
        { t: 'Aufgabe 2', h: 'Bestenliste', sub: 'Objekte, Liste, Kapselung', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Aufgabe 2: Bestenliste', items: ['Klasse `Eintrag` mit **private** `name` und `zeit` (Sekunden, double) + Gettern', 'Lies Einträge „Name Zeit“ ein, bis „fertig“', 'Gib alle Einträge aus und dann den **Schnellsten**', 'Bonus: ungültige Zeiten (≤ 0) ablehnen'], gap: 0.9 }, say: 'Zweite Aufgabe – und die passt perfekt zu unserem Rennspiel: eine Bestenliste mit Laufzeiten.' },
        {
          task: {
            id: 'l9-bestenliste', nr: 2, title: 'Bestenliste',
            text: ['Schreib eine Klasse `Eintrag` mit den private-Feldern `name` (String) und `zeit` (double, in Sekunden), einem Konstruktor und den Gettern `getName()` und `getZeit()`.', 'In main liest du Zeilen wie „Mia 42.5“ ein, bis „fertig“ kommt. Zerlege jede Zeile mit `split(" ")` und `Double.parseDouble`. Zeiten ≤ 0 lehnst du mit „Ungültige Zeit“ ab.', 'Am Ende gibst du alle Einträge aus und dann „Schnellste: Name (Zeit s)“.'],
            req: ['Klasse `Eintrag` mit private-Feldern und Gettern', '`ArrayList<Eintrag>`', 'Zeilen mit `split` zerlegen', 'Ungültige Zeiten ablehnen', 'Den schnellsten Eintrag finden und ausgeben'],
            example: 'Mia 42.5\nTom 39.8\nLea -3\nUngültige Zeit\nfertig\nMia: 42.5 s\nTom: 39.8 s\nSchnellste: Tom (39.8 s)',
            starter: file(R`
class Eintrag {
    // private Felder, Konstruktor, Getter
}`, R`
        Scanner sc = new Scanner(System.in);
        ArrayList<Eintrag> liste = new ArrayList<>();
        // Zeilen lesen bis "fertig"
`, ALSC),
            solution: file(R`
class Eintrag {
    private String name;
    private double zeit;

    Eintrag(String name, double zeit) {
        this.name = name;
        this.zeit = zeit;
    }

    public String getName() {
        return name;
    }

    public double getZeit() {
        return zeit;
    }
}`, R`
        Scanner sc = new Scanner(System.in);
        ArrayList<Eintrag> liste = new ArrayList<>();
        while (true) {
            String zeile = sc.nextLine();
            if (zeile.equals("fertig")) break;
            String[] teile = zeile.split(" ");
            double zeit = Double.parseDouble(teile[1]);
            if (zeit <= 0) {
                System.out.println("Ungültige Zeit");
            } else {
                liste.add(new Eintrag(teile[0], zeit));
            }
        }
        Eintrag beste = null;
        for (Eintrag e : liste) {
            System.out.println(e.getName() + ": " + e.getZeit() + " s");
            if (beste == null || e.getZeit() < beste.getZeit()) {
                beste = e;
            }
        }
        if (beste != null) {
            System.out.println("Schnellste: " + beste.getName() + " (" + beste.getZeit() + " s)");
        }`, ALSC),
            tests: [
              { name: 'drei Läufer', input: ['Mia 42.5', 'Tom 39.8', 'Lea 44.0', 'fertig'], expect: [{ re: 'schnellste[^\\n]*tom', label: 'Schnellste: Tom' }, { re: '39[.,]8', label: 'Zeit 39.8' }, { re: 'mia[^\\n]*42[.,]5', label: 'Mia wird aufgelistet' }] },
              { name: 'ungültig', input: ['Ben 50', 'Ida -1', 'Max 0', 'fertig'], expect: [{ re: 'ung(ü|ue)ltig', label: '„Ungültige Zeit“' }, { re: 'schnellste[^\\n]*ben', label: 'Schnellste: Ben' }, { re: 'schnellste[^\\n]*(ida|max)', label: 'ungültige Zeiten zählen nicht', not: true }] },
            ],
            codeChecks: [{ label: 'Klasse Eintrag', re: 'class\\s+Eintrag' }, { label: 'private Felder', re: 'private\\s+(String|double)\\s+\\w+\\s*;[\\s\\S]*private\\s+(String|double)\\s+\\w+\\s*;' }, { label: 'Getter getZeit()', re: 'double\\s+getZeit\\s*\\(\\s*\\)' }, { label: 'ArrayList<Eintrag>', re: 'ArrayList\\s*<\\s*Eintrag\\s*>' }, { label: 'split', re: '\\.split\\s*\\(' }],
            rubric: [['Programm kompiliert und läuft', 15], ['Klasse mit private-Feldern und Gettern', 25], ['Einlesen und Zerlegen mit split', 20], ['Ungültige Zeiten abgelehnt', 15], ['Alle Einträge und Schnellste richtig ausgegeben', 25]],
            tip: 'Zum Finden des Schnellsten: Merk dir das bisher beste **Objekt** in einer Variable (am Anfang `null`) und vergleich jede Zeit mit `beste.getZeit()`.',
          },
        },
        { layout: 'code', console: 'clear', code: file(R`
class Eintrag {
    private String name;
    private double zeit;

    Eintrag(String name, double zeit) {
        this.name = name;
        this.zeit = zeit;
    }

    public String getName() { return name; }
    public double getZeit() { return zeit; }
}`, R`
        ArrayList<Eintrag> liste = new ArrayList<>();
        liste.add(new Eintrag("Mia", 42.5));
        liste.add(new Eintrag("Tom", 39.8));
        Eintrag beste = null;
        for (Eintrag e : liste) {
            if (beste == null || e.getZeit() < beste.getZeit()) beste = e;
        }
        System.out.println("Schnellste: " + beste.getName());`, AL), run: true, hl: [18, 21], say: 'Abgegeben! Das Muster „bestes Objekt merken“ funktioniert genauso wie das Minimum aus Lektion 5 – nur dass du dir statt einer Zahl ein ganzes Objekt merkst.' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Das kannst du jetzt', items: ['`ArrayList` anlegen, füllen, ändern und leeren', 'Mit `Integer` und `Double` Zahlen in Listen speichern', 'Listen von **eigenen Objekten** verwalten', 'Beim Entfernen in Schleifen rückwärts laufen', 'Felder mit `private`, Gettern und Settern schützen'], gap: 0.7 }, say: 'Das war Lektion 9! In Lektion 10 lernst du Vererbung: Wie verschiedene Gegner vieles gemeinsam haben und trotzdem unterschiedlich sein können.' },
      ],
    },
  ],
};
