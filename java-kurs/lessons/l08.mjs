// Lektion 8 – Klassen & Objekte
const R = String.raw;
const file = (classes, mainBody, imports = '') => `${imports}${classes.replace(/^\n/, '').replace(/\n$/, '')}\n\npublic class Main {\n    public static void main(String[] args) {\n${mainBody.replace(/^\n/, '').replace(/\n$/, '')}\n    }\n}\n`;
const SC = 'import java.util.Scanner;\n\n';

const FIGUR = R`
class Spielfigur {
    String name;
    int leben;
    int x;

    Spielfigur(String name, int leben) {
        this.name = name;
        this.leben = leben;
        this.x = 0;
    }

    void laufen(int schritte) {
        x += schritte;
    }

    void treffer() {
        leben--;
    }

    boolean istAmLeben() {
        return leben > 0;
    }

    public String toString() {
        return name + " (x=" + x + ", Leben=" + leben + ")";
    }
}`;

export default {
  id: 'java-08', nr: 8,
  title: 'Klassen & Objekte',
  sub: 'Eigene Datentypen bauen: Bauplan, Konstruktor, Eigenschaften und Methoden.',
  outro: 'Klassen sind das Herz von Java – und auch in JavaScript wirst du sie wiedersehen. Jede Spielfigur, jede Plattform und jeder Gegner in unserem Game wird ein Objekt sein. In Lektion 9 sammelst du viele Objekte in Listen.',
  chapters: [
    {
      title: 'Bauplan und Objekt',
      steps: [
        { t: 'Lektion 8', h: 'Klassen & Objekte', sub: 'Deine eigenen Datentypen', say: 'Servus! Heute kommt das Wichtigste an Java: **Klassen**. Bisher hattest du nur `int`, `String` und Co. Jetzt baust du dir eigene Typen – zum Beispiel eine Spielfigur.' },
        { layout: 'visual', visual: { kind: 'flow', dir: 'row', title: 'Eine Klasse ist ein Bauplan', items: [{ h: 'Klasse Spielfigur', p: 'Bauplan: name, leben, x' }, { h: 'Objekt mario', p: 'name="Mario", leben=3' }, { h: 'Objekt luigi', p: 'name="Luigi", leben=5', cls: 'good' }], gap: 1.1 }, say: 'Eine Klasse ist ein **Bauplan**. Sie sagt: Jede Spielfigur hat einen Namen, Leben und eine Position. Aus dem Bauplan baust du beliebig viele **Objekte** – jedes mit eigenen Werten.' },
        { layout: 'code', console: 'clear', code: file(R`
class Spielfigur {
    String name;
    int leben;
}`, R`
        Spielfigur mario = new Spielfigur();
        mario.name = "Mario";
        mario.leben = 3;
        System.out.println(mario.name + " hat " + mario.leben + " Leben");`), hl: [1, 4], say: 'So sieht die einfachste Klasse aus: Das Wort `class`, ein Name mit großem Anfangsbuchstaben, und darin die **Eigenschaften** – man sagt auch Attribute oder Felder.' },
        { hl: [9, 11], say: 'Mit `new Spielfigur()` baust du ein neues Objekt. Über den Punkt erreichst du seine Eigenschaften: `mario.name`, `mario.leben`. Den Punkt kennst du schon von `sc.nextInt()` oder `text.length()`.' },
        { run: true, say: 'Mario hat 3 Leben. Diese Klasse steht in derselben Datei vor `Main` – nur `Main` hat `public` davor.' },
        { quiz: { id: 'l8-q1', q: 'Was erzeugt ein neues Objekt?', options: ['class Spielfigur', 'Spielfigur s;', 'new Spielfigur()', 's.name = "Mario"'], correct: 2, explain: '`new` baut ein neues Objekt nach dem Bauplan. `Spielfigur s;` legt nur eine leere Variable an.' } },
      ],
    },
    {
      title: 'Konstruktor & this',
      steps: [
        { t: 'Kapitel 2', h: 'Der Konstruktor', sub: 'Objekte direkt richtig einrichten', after: 'code' },
        { layout: 'code', console: 'clear', code: file(R`
class Spielfigur {
    String name;
    int leben;

    Spielfigur(String name, int leben) {
        this.name = name;
        this.leben = leben;
    }
}`, R`
        Spielfigur mario = new Spielfigur("Mario", 3);
        Spielfigur luigi = new Spielfigur("Luigi", 5);
        System.out.println(mario.name + ": " + mario.leben);
        System.out.println(luigi.name + ": " + luigi.leben);`), hl: [5, 8], say: 'Jedes Feld einzeln setzen ist mühsam. Dafür gibt es den **Konstruktor**: Er heißt genau wie die Klasse, hat keinen Rückgabetyp und läuft automatisch bei `new`.' },
        { hl: [6, 7], say: '`this` bedeutet „dieses Objekt hier“. `this.name` ist das Feld, `name` allein ist der Parameter. So kann beides gleich heißen, ohne dass Java durcheinanderkommt.' },
        { run: true, hl: [14, 15], say: 'Zwei Objekte, zwei verschiedene Werte. Jedes Objekt hat seine **eigenen** Kästchen für name und leben.' },
      ],
    },
    {
      title: 'Methoden in Objekten',
      steps: [
        { t: 'Kapitel 3', h: 'Objekte können etwas tun', sub: 'Methoden ohne static', after: 'code' },
        { layout: 'code', console: 'clear', code: file(FIGUR, R`
        Spielfigur mario = new Spielfigur("Mario", 3);
        mario.laufen(5);
        mario.treffer();
        System.out.println(mario);
        System.out.println(mario.istAmLeben());`), hl: [13, 23], say: 'Objekte haben nicht nur Daten, sondern auch **Verhalten**. Diese Methoden stehen in der Klasse und haben **kein** `static`. Sie arbeiten mit den Feldern genau des Objekts, auf dem du sie aufrufst.' },
        { hl: [25, 27], say: 'Die Methode `toString` ist besonders: Wenn du ein Objekt mit `println` ausgibst, ruft Java sie automatisch auf. Ohne sie würdest du nur etwas wie `Spielfigur@1b6d3586` sehen.' },
        { run: true, say: 'Mario ist 5 Felder gelaufen, hat einen Treffer kassiert und lebt noch. Jetzt weißt du auch, was `static` heißt: Eine `static`-Methode gehört zur **Klasse**, eine normale Methode gehört zu einem **Objekt**.' },
        { layout: 'split', visual: { kind: 'compare', left: { title: 'static – gehört zur Klasse', code: 'Math.max(3, 7)\nInteger.parseInt("42")', note: 'Aufruf über den **Klassennamen**' }, right: { title: 'ohne static – gehört zum Objekt', code: 'mario.laufen(5)\ntext.length()', note: 'Aufruf über ein **Objekt**', cls: 'good' } }, say: 'Merk dir: `Math.max` brauchst du kein Objekt – das ist static. `mario.laufen` braucht ein konkretes Objekt, denn es ändert genau Marios Position.' },
        { quiz: { id: 'l8-q2', q: 'Zwei Objekte a und b sind Spielfiguren. Was passiert bei `a.treffer();`?', options: ['Beide verlieren ein Leben', 'Nur a verliert ein Leben', 'Nur b verliert ein Leben', 'Fehler, weil treffer nicht static ist'], correct: 1, explain: 'Die Methode arbeitet nur mit dem Objekt, auf dem sie aufgerufen wird.' } },
      ],
    },
    {
      title: 'Aufgabe: Spielfigur',
      steps: [
        { t: 'Aufgabe 1', h: 'Deine Spielfigur', sub: 'Jetzt bist du dran!', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Aufgabe 1: Klasse Held', items: ['Felder: `name`, `leben`, `muenzen`', 'Konstruktor mit name; startet mit 3 Leben und 0 Münzen', 'Methoden: `sammle(int anzahl)`, `treffer()`, `istAmLeben()`, `toString()`', 'Bei 100 Münzen: +1 Leben und Münzen wieder auf 0'], gap: 0.9 }, say: 'Jetzt baust du deinen eigenen Helden – mit einer kleinen Spielregel, die du aus vielen Jump’n’Runs kennst: Hundert Münzen geben ein Extraleben.' },
        {
          task: {
            id: 'l8-held', nr: 1, title: 'Klasse Held',
            text: ['Schreib eine Klasse `Held` mit den Feldern `name` (String), `leben` (int) und `muenzen` (int). Der Konstruktor bekommt nur den Namen; jeder Held startet mit 3 Leben und 0 Münzen.', 'Methoden: `sammle(int anzahl)` erhöht die Münzen – erreicht er 100 oder mehr, bekommt er ein Leben dazu und 100 Münzen werden abgezogen. `treffer()` zieht ein Leben ab. `istAmLeben()` gibt zurück, ob leben > 0 ist. `toString()` gibt z. B. „Lena: 4 Leben, 20 Münzen“ zurück.', 'Teste in main: Held „Lena“ sammelt 70 und dann 50 Münzen, bekommt 2 Treffer, dann gibst du ihn aus.'],
            req: ['Klasse `Held` mit drei Feldern', 'Konstruktor mit `this`', 'Methoden `sammle`, `treffer`, `istAmLeben`, `toString`', 'Extraleben-Regel bei 100 Münzen', 'Test in main (Ergebnis: 2 Leben, 20 Münzen)'],
            example: 'Lena: 2 Leben, 20 Münzen\nLebt noch: true',
            starter: file(R`
class Held {
    // Felder, Konstruktor und Methoden
}`, R`
        // Held lena = new Held("Lena");
`),
            solution: file(R`
class Held {
    String name;
    int leben;
    int muenzen;

    Held(String name) {
        this.name = name;
        this.leben = 3;
        this.muenzen = 0;
    }

    void sammle(int anzahl) {
        muenzen += anzahl;
        if (muenzen >= 100) {
            leben++;
            muenzen -= 100;
        }
    }

    void treffer() {
        leben--;
    }

    boolean istAmLeben() {
        return leben > 0;
    }

    public String toString() {
        return name + ": " + leben + " Leben, " + muenzen + " Münzen";
    }
}`, R`
        Held lena = new Held("Lena");
        lena.sammle(70);
        lena.sammle(50);
        lena.treffer();
        lena.treffer();
        System.out.println(lena);
        System.out.println("Lebt noch: " + lena.istAmLeben());`),
            tests: [{ name: 'Lena', input: [], expect: [{ re: 'lena', label: 'Name „Lena“' }, { re: '\\b2\\b[^\\n]*leben|leben[^\\n]*\\b2\\b', label: '2 Leben' }, { re: '\\b20\\b', label: '20 Münzen' }, { re: 'true', label: 'lebt noch: true' }] }],
            codeChecks: [{ label: 'Klasse Held', re: 'class\\s+Held' }, { label: 'Konstruktor Held(String …)', re: 'Held\\s*\\(\\s*String\\s+\\w+\\s*\\)\\s*\\{' }, { label: 'this verwendet', re: 'this\\.' }, { label: 'toString', re: 'String\\s+toString\\s*\\(' }, { label: 'Methode sammle(int)', re: 'void\\s+sammle\\s*\\(\\s*int' }],
            rubric: [['Programm kompiliert und läuft', 15], ['Klasse mit Feldern und Konstruktor', 25], ['Methoden sammle, treffer, istAmLeben', 25], ['Extraleben-Regel richtig', 15], ['toString und Test in main', 20]],
            tip: 'Schreib die Klasse über `public class Main`. Wenn Java „cannot find symbol“ meldet, prüf, ob du die Methode im Objekt aufrufst: `lena.sammle(70)`.',
          },
        },
        { layout: 'code', console: 'clear', code: file(R`
class Held {
    String name;
    int leben = 3;
    int muenzen = 0;

    Held(String name) {
        this.name = name;
    }

    void sammle(int anzahl) {
        muenzen += anzahl;
        if (muenzen >= 100) {
            leben++;
            muenzen -= 100;
        }
    }
}`, R`
        Held lena = new Held("Lena");
        lena.sammle(70);
        lena.sammle(50);
        System.out.println(lena.leben + " Leben, " + lena.muenzen + " Münzen");`), run: true, hl: [3, 4], say: 'Abgegeben! Kleiner Profi-Trick: Startwerte kannst du auch direkt beim Feld hinschreiben, wie `int leben = 3;`. Dann muss der Konstruktor sich nur um den Namen kümmern.' },
      ],
    },
    {
      title: 'Objekte sind Referenzen',
      steps: [
        { t: 'Kapitel 5', h: 'Referenzen', sub: 'Zwei Variablen, ein Objekt', after: 'code' },
        { layout: 'code', console: 'clear', code: file(R`
class Box {
    int wert;
}`, R`
        Box a = new Box();
        a.wert = 1;
        Box b = a;
        b.wert = 99;
        System.out.println(a.wert);
        Box c = null;
        System.out.println(c == null);`), hl: [8, 11], say: 'Ganz wichtig: Eine Objekt-Variable enthält nicht das Objekt selbst, sondern einen **Verweis** darauf. `Box b = a;` kopiert nur den Verweis – a und b zeigen auf **dasselbe** Objekt.' },
        { run: true, say: 'Deshalb ist `a.wert` jetzt auch 99! Anders als bei `int`. Und `null` heißt: Die Variable zeigt auf gar nichts.' },
        { code: file(R`
class Box {
    int wert;
}`, R`
        Box c = null;
        System.out.println(c.wert);`), run: true, expectError: true, console: 'clear', say: 'Greifst du über `null` auf etwas zu, kracht es mit der berühmten **NullPointerException**. Wenn du die siehst: Irgendwo hast du vergessen, `new` aufzurufen.' },
        { quiz: { id: 'l8-q3', q: '`Held a = new Held("A"); Held b = a; b.leben = 0;` – Was ist danach `a.leben`?', options: ['3', '0', 'null', 'Fehler'], correct: 1, explain: 'a und b zeigen auf dasselbe Objekt. Änderst du es über b, siehst du die Änderung auch über a.' } },
      ],
    },
    {
      title: 'Aufgabe: Würfel-Klasse',
      steps: [
        { t: 'Aufgabe 2', h: 'Würfel-Klasse', sub: 'Objekte mit eigenem Zufall', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Aufgabe 2: Klasse Wuerfel', items: ['Feld `seiten` und ein `Random`', 'Konstruktor `Wuerfel(int seiten, long seed)`', 'Methode `int wuerfeln()` – Zahl von 1 bis seiten', 'main: lies seiten und Anzahl ein, würfle, gib Summe und größten Wurf aus'], gap: 0.9 }, say: 'Zweite Aufgabe: Ein Würfel als Objekt. Damit man die Ergebnisse prüfen kann, bekommt der Zufall einen festen Startwert, einen Seed.' },
        {
          task: {
            id: 'l8-wuerfel', nr: 2, title: 'Klasse Wuerfel',
            text: ['Schreib eine Klasse `Wuerfel` mit einem Feld `seiten` und einem Feld `Random zufall`. Der Konstruktor `Wuerfel(int seiten, long seed)` setzt beides (`new Random(seed)`).', 'Die Methode `wuerfeln()` gibt eine Zahl von 1 bis `seiten` zurück (`zufall.nextInt(seiten) + 1`).', 'In main liest du die Seitenzahl und die Anzahl der Würfe ein, erzeugst einen Würfel mit Seed 42, würfelst so oft, gibst jeden Wurf aus und am Ende „Summe: …“ und „Größter Wurf: …“.'],
            req: ['Klasse `Wuerfel` mit Konstruktor `(int seiten, long seed)`', 'Methode `wuerfeln()` mit Rückgabe 1 bis seiten', 'Eingabe von Seiten und Anzahl', 'Summe und größten Wurf ausgeben'],
            example: 'Seiten: 6\nWürfe: 5\n3 4 1 3 1\nSumme: 12\nGrößter Wurf: 4',
            starter: file(R`
class Wuerfel {
    // Felder, Konstruktor, wuerfeln()
}`, R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Seiten: ");
        int seiten = sc.nextInt();
        System.out.print("Würfe: ");
        int anzahl = sc.nextInt();
        // Wuerfel w = new Wuerfel(seiten, 42);
`, 'import java.util.Random;\nimport java.util.Scanner;\n\n'),
            solution: file(R`
class Wuerfel {
    int seiten;
    Random zufall;

    Wuerfel(int seiten, long seed) {
        this.seiten = seiten;
        this.zufall = new Random(seed);
    }

    int wuerfeln() {
        return zufall.nextInt(seiten) + 1;
    }
}`, R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Seiten: ");
        int seiten = sc.nextInt();
        System.out.print("Würfe: ");
        int anzahl = sc.nextInt();
        Wuerfel w = new Wuerfel(seiten, 42);
        int summe = 0, max = 0;
        for (int i = 0; i < anzahl; i++) {
            int wurf = w.wuerfeln();
            System.out.print(wurf + " ");
            summe += wurf;
            if (wurf > max) max = wurf;
        }
        System.out.println();
        System.out.println("Summe: " + summe);
        System.out.println("Größter Wurf: " + max);`, 'import java.util.Random;\nimport java.util.Scanner;\n\n'),
            tests: [
              { name: 'W6, 5 Würfe', input: ['6', '5'], expect: [{ re: 'summe:?\\s*12\\b', label: 'Summe 12 (Seed 42)' }, { re: 'gr(ö|oe)(ß|ss)te[rn]?\\s*wurf:?\\s*4\\b', label: 'größter Wurf 4' }] },
              { name: 'W20, 3 Würfe', input: ['20', '3'], expect: [{ re: 'summe:?\\s*24\\b', label: 'Summe 24 (Seed 42)' }, { re: 'wurf:?\\s*11\\b', label: 'größter Wurf 11' }] },
            ],
            codeChecks: [{ label: 'Klasse Wuerfel', re: 'class\\s+Wuerfel' }, { label: 'Konstruktor (int, long)', re: 'Wuerfel\\s*\\(\\s*int\\s+\\w+\\s*,\\s*long\\s+\\w+\\s*\\)' }, { label: 'Methode wuerfeln()', re: 'int\\s+wuerfeln\\s*\\(\\s*\\)' }, { label: 'new Random(seed)', re: 'new\\s+Random\\s*\\(\\s*\\w+\\s*\\)' }],
            rubric: [['Programm kompiliert und läuft', 15], ['Klasse Wuerfel mit Konstruktor und Random-Feld', 30], ['wuerfeln liefert 1 bis seiten', 20], ['Schleife, Summe und Maximum richtig', 25], ['Saubere Ausgabe', 10]],
            tip: 'Das `Random`-Objekt ist selbst ein Feld deines Würfels. Erzeuge es im Konstruktor, nicht in `wuerfeln()` – sonst kommt mit demselben Seed immer dieselbe Zahl.',
          },
        },
        { layout: 'code', console: 'clear', code: file(R`
class Wuerfel {
    int seiten;
    Random zufall;

    Wuerfel(int seiten, long seed) {
        this.seiten = seiten;
        this.zufall = new Random(seed);
    }

    int wuerfeln() {
        return zufall.nextInt(seiten) + 1;
    }
}`, R`
        Wuerfel w6 = new Wuerfel(6, 42);
        Wuerfel w20 = new Wuerfel(20, 7);
        System.out.println(w6.wuerfeln() + " und " + w20.wuerfeln());`, 'import java.util.Random;\n\n'), run: true, say: 'Abgegeben! Und jetzt siehst du die Stärke von Objekten: Ein W6 und ein W20 aus demselben Bauplan, jeder mit eigenen Seiten und eigenem Zufall.' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Das kannst du jetzt', items: ['Klassen als **Bauplan** schreiben', 'Objekte mit `new` erzeugen', 'Konstruktoren und `this` verwenden', 'Methoden ohne `static` – sie gehören zum Objekt', '`toString`, Referenzen und `null` verstehen'], gap: 0.7 }, say: 'Das war Lektion 8! Du denkst jetzt in Objekten. In Lektion 9 lernst du, viele Objekte in einer Liste zu verwalten – und wie man sie vor falschen Werten schützt.' },
      ],
    },
  ],
};
