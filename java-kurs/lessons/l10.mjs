// Lektion 10 – Vererbung
const R = String.raw;
const file = (classes, mainBody, imports = '') => `${imports}${classes.replace(/^\n/, '').replace(/\n$/, '')}\n\npublic class Main {\n    public static void main(String[] args) {\n${mainBody.replace(/^\n/, '').replace(/\n$/, '')}\n    }\n}\n`;
const AL = 'import java.util.ArrayList;\n\n';

const GEGNER = R`
class Gegner {
    String name;
    int leben;

    Gegner(String name, int leben) {
        this.name = name;
        this.leben = leben;
    }

    void schaden(int wert) {
        leben -= wert;
        if (leben < 0) leben = 0;
    }

    String angriff() {
        return name + " greift an!";
    }
}`;

export default {
  id: 'java-10', nr: 10,
  title: 'Vererbung',
  sub: 'Gemeinsames einmal schreiben, Unterschiede gezielt überschreiben – extends, super und Polymorphie.',
  outro: 'Mit Vererbung baust du Familien von Klassen: Gegner, Plattformen, Power-ups. Genau so ist auch unser Spiel aufgebaut. In Lektion 11 bringen wir Spielfelder auf den Bildschirm und machen Programme robust gegen falsche Eingaben.',
  chapters: [
    {
      title: 'Die Idee',
      steps: [
        { t: 'Lektion 10', h: 'Vererbung', sub: 'Klassen, die von anderen lernen', say: 'Servus! In einem Spiel gibt es viele Gegner-Arten: Schleime, Fledermäuse, Drachen. Alle haben Namen und Leben, aber jeder greift anders an. Wie schreibt man das, ohne alles mehrfach zu kopieren? Mit **Vererbung**.' },
        { layout: 'visual', visual: { kind: 'flow', title: 'Eine Klassen-Familie', items: [{ h: 'Gegner', p: 'name, leben, schaden(), angriff()' }, { h: 'Schleim extends Gegner', p: 'erbt alles + teilt sich' }, { h: 'Drache extends Gegner', p: 'erbt alles + speit Feuer', cls: 'good' }], gap: 1.1 }, say: 'Die Oberklasse `Gegner` enthält alles, was **alle** Gegner gemeinsam haben. Die Unterklassen erben das automatisch und fügen nur noch ihre Besonderheiten hinzu.' },
        { layout: 'code', console: 'clear', code: file(GEGNER + '\n\n' + R`
class Schleim extends Gegner {
    Schleim() {
        super("Schleim", 3);
    }
}`, R`
        Schleim s = new Schleim();
        s.schaden(1);
        System.out.println(s.name + ": " + s.leben);
        System.out.println(s.angriff());`), hl: [21, 25], say: 'Mit `extends` sagst du: Ein Schleim **ist ein** Gegner. Im Konstruktor ruft `super(...)` den Konstruktor der Oberklasse auf – der setzt Name und Leben.' },
        { run: true, say: 'Die Klasse Schleim ist nur fünf Zeilen lang, kann aber schon alles: Sie hat einen Namen, Leben, kann Schaden nehmen und angreifen – alles geerbt.' },
        { quiz: { id: 'l10-q1', q: 'Was bedeutet `class Drache extends Gegner`?', options: ['Gegner erbt von Drache', 'Drache erbt alles von Gegner', 'Drache und Gegner sind dieselbe Klasse', 'Drache darf Gegner nicht benutzen'], correct: 1, explain: 'Drache ist die Unterklasse und bekommt alle Felder und Methoden von Gegner.' } },
      ],
    },
    {
      title: 'Überschreiben',
      steps: [
        { t: 'Kapitel 2', h: 'Methoden überschreiben', sub: '@Override', after: 'code' },
        { layout: 'code', console: 'clear', code: file(GEGNER + '\n\n' + R`
class Drache extends Gegner {
    int feuer;

    Drache() {
        super("Drache", 20);
        this.feuer = 5;
    }

    @Override
    String angriff() {
        return name + " speit Feuer! (" + feuer + " Schaden)";
    }
}`, R`
        Gegner g = new Gegner("Ratte", 1);
        Drache d = new Drache();
        System.out.println(g.angriff());
        System.out.println(d.angriff());`), hl: [29, 32], say: 'Der Drache soll anders angreifen. Also schreibt er die Methode `angriff` einfach neu – das nennt man **Überschreiben**. `@Override` ist ein Hinweis an Java: „Ich will hier wirklich eine geerbte Methode ersetzen.“' },
        { run: true, say: 'Die Ratte nutzt die normale Version, der Drache seine eigene. Außerdem hat der Drache ein zusätzliches Feld `feuer`, das normale Gegner nicht haben.' },
        { code: file(GEGNER + '\n\n' + R`
class Ritter extends Gegner {
    Ritter() {
        super("Ritter", 8);
    }

    @Override
    void schaden(int wert) {
        super.schaden(wert / 2);
    }
}`, R`
        Ritter r = new Ritter();
        r.schaden(6);
        System.out.println(r.name + ": " + r.leben);`), console: 'clear', hl: [27, 29], say: 'Mit `super.methode()` rufst du in einer überschriebenen Methode die **alte** Version auf. Der Ritter hat eine Rüstung: Er nimmt nur halben Schaden, den Rest erledigt die normale schaden-Methode.' },
        { run: true, say: '6 Schaden, halbiert auf 3 – der Ritter hat noch 5 Leben. So musst du die Logik nicht kopieren, sondern ergänzt sie nur.' },
      ],
    },
    {
      title: 'Polymorphie',
      steps: [
        { t: 'Kapitel 3', h: 'Polymorphie', sub: 'Viele Gestalten, eine Liste', after: 'code' },
        { layout: 'code', console: 'clear', code: file(GEGNER + '\n\n' + R`
class Schleim extends Gegner {
    Schleim() { super("Schleim", 3); }

    @Override
    String angriff() { return "Schleim blubbert dich an."; }
}

class Drache extends Gegner {
    Drache() { super("Drache", 20); }

    @Override
    String angriff() { return "Drache speit Feuer!"; }
}`, R`
        ArrayList<Gegner> welle = new ArrayList<>();
        welle.add(new Schleim());
        welle.add(new Drache());
        welle.add(new Gegner("Ratte", 1));
        for (Gegner g : welle) {
            System.out.println(g.angriff());
        }`, AL), hl: [37, 40], say: 'Jetzt das Geniale: Weil ein Schleim **ein** Gegner ist, darf er in eine `ArrayList<Gegner>`. Der Drache auch. Alle verschiedenen Gegner stecken in **einer** Liste.' },
        { run: true, hl: [41, 43], say: 'Und beim Durchlaufen ruft Java automatisch die **richtige** Version von `angriff` auf – je nachdem, was das Objekt wirklich ist. Das heißt **Polymorphie**: viele Gestalten, ein Aufruf.' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Warum ist das so stark?', items: ['Die Spielschleife kennt nur `Gegner`', 'Neue Gegner-Art? Neue Klasse – **die Schleife bleibt gleich**', 'Jeder Gegner entscheidet selbst, wie er sich verhält', 'In unserem Game: alle Objekte in **einer** Liste, jedes Bild `update()` und `draw()`'], gap: 0.9 }, say: 'Genau so funktionieren Spiele: Die Spielschleife geht alle Objekte durch und ruft bei jedem dieselben Methoden auf. Was dabei passiert, entscheidet jedes Objekt selbst.' },
        { quiz: { id: 'l10-q2', q: '`Gegner g = new Drache();` – Welche angriff()-Methode läuft bei `g.angriff()`?', options: ['Die von Gegner, weil die Variable vom Typ Gegner ist', 'Die von Drache, weil das Objekt ein Drache ist', 'Beide nacheinander', 'Gar keine – Fehler'], correct: 1, explain: 'Entscheidend ist das echte Objekt, nicht der Typ der Variable. Das ist Polymorphie.' } },
      ],
    },
    {
      title: 'Aufgabe: Gegner-Welle',
      steps: [
        { t: 'Aufgabe 1', h: 'Gegner-Welle', sub: 'Jetzt bist du dran!', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Aufgabe 1: Gegner-Welle', items: ['Oberklasse `Gegner` mit name, leben, `schaden(int)`, `angriff()` (gibt Schaden als int zurück)', '`Fledermaus`: 2 Leben, Angriff 1', '`Golem`: 10 Leben, Angriff 3, nimmt **nur halben** Schaden', 'main: Held mit 20 Leben kämpft gegen eine Welle in einer `ArrayList<Gegner>`'], gap: 0.9 }, say: 'Deine Aufgabe: Bau eine kleine Gegner-Familie und lass deinen Helden gegen eine ganze Welle kämpfen.' },
        {
          task: {
            id: 'l10-welle', nr: 1, title: 'Gegner-Welle',
            text: ['Schreib eine Oberklasse `Gegner` mit `name`, `leben`, einem Konstruktor, `void schaden(int wert)` und `int angriff()` (Standard: 1 Schaden).', 'Unterklassen: `Fledermaus` (2 Leben, Angriff 1) und `Golem` (10 Leben, `angriff()` gibt 3 zurück, `schaden` halbiert den Wert und ruft `super.schaden` auf).', 'In main: Eine `ArrayList<Gegner>` mit Fledermaus, Golem, Fledermaus. Der Held hat 20 Leben und macht 4 Schaden pro Schlag. Kämpf die Gegner der Reihe nach: Held schlägt, dann greift der Gegner an, wenn er noch lebt – bis er besiegt ist. Gib aus, wann ein Gegner besiegt ist, und am Ende die Leben des Helden.'],
            req: ['Oberklasse `Gegner` und zwei Unterklassen mit `extends`', '`super(...)` im Konstruktor', '`@Override` von `angriff` und `schaden`', '`ArrayList<Gegner>` und Kampf-Schleife', 'Ausgabe: Held hat am Ende 8 Leben'],
            example: 'Fledermaus besiegt!\nGolem besiegt!\nFledermaus besiegt!\nHeld hat noch 8 Leben',
            starter: file(R`
class Gegner {
    // name, leben, Konstruktor, schaden(int), angriff()
}

// class Fledermaus extends Gegner { ... }
// class Golem extends Gegner { ... }`, R`
        int held = 20;
        // ArrayList<Gegner> welle = new ArrayList<>();
`, AL),
            solution: file(R`
class Gegner {
    String name;
    int leben;

    Gegner(String name, int leben) {
        this.name = name;
        this.leben = leben;
    }

    void schaden(int wert) {
        leben -= wert;
    }

    int angriff() {
        return 1;
    }
}

class Fledermaus extends Gegner {
    Fledermaus() {
        super("Fledermaus", 2);
    }
}

class Golem extends Gegner {
    Golem() {
        super("Golem", 10);
    }

    @Override
    int angriff() {
        return 3;
    }

    @Override
    void schaden(int wert) {
        super.schaden(wert / 2);
    }
}`, R`
        int held = 20;
        ArrayList<Gegner> welle = new ArrayList<>();
        welle.add(new Fledermaus());
        welle.add(new Golem());
        welle.add(new Fledermaus());
        for (Gegner g : welle) {
            while (g.leben > 0) {
                g.schaden(4);
                if (g.leben > 0) {
                    held -= g.angriff();
                }
            }
            System.out.println(g.name + " besiegt!");
        }
        System.out.println("Held hat noch " + held + " Leben");`, AL),
            tests: [{ name: 'Welle', input: [], expect: [{ re: 'fledermaus besiegt', label: 'Fledermaus besiegt' }, { re: 'golem besiegt', label: 'Golem besiegt' }, { re: 'noch\\s*8\\b|\\b8\\s*leben', label: 'Held hat noch 8 Leben' }] }],
            codeChecks: [{ label: 'class Fledermaus extends Gegner', re: 'class\\s+Fledermaus\\s+extends\\s+Gegner' }, { label: 'class Golem extends Gegner', re: 'class\\s+Golem\\s+extends\\s+Gegner' }, { label: 'super(...) im Konstruktor', re: 'super\\s*\\(' }, { label: 'super.schaden', re: 'super\\s*\\.\\s*schaden' }, { label: 'ArrayList<Gegner>', re: 'ArrayList\\s*<\\s*Gegner\\s*>' }],
            rubric: [['Programm kompiliert und läuft', 15], ['Oberklasse und zwei Unterklassen mit super', 25], ['angriff und schaden richtig überschrieben', 25], ['Kampf-Schleife über ArrayList<Gegner>', 20], ['Richtiges Endergebnis (8 Leben)', 15]],
            tip: 'Rechne den Golem nach: 4 Schaden halbiert sind 2. Er braucht also 5 Schläge und schlägt 4-mal zurück (beim 5. ist er schon besiegt). Das sind 12 Schaden – die Fledermäuse sterben schon beim ersten Schlag.',
          },
        },
        { layout: 'code', console: 'clear', code: file(GEGNER.replace('String angriff() {\n        return name + " greift an!";\n    }', 'int angriff() {\n        return 1;\n    }') + '\n\n' + R`
class Golem extends Gegner {
    Golem() { super("Golem", 10); }

    @Override
    int angriff() { return 3; }

    @Override
    void schaden(int wert) { super.schaden(wert / 2); }
}`, R`
        Gegner g = new Golem();
        g.schaden(4);
        System.out.println(g.name + ": " + g.leben + " Leben, Angriff " + g.angriff());`), run: true, say: 'Abgegeben! Obwohl die Variable vom Typ Gegner ist, verhält sich der Golem wie ein Golem: halber Schaden, starker Angriff. Polymorphie in Aktion.' },
      ],
    },
    {
      title: 'Abstrakte Klassen & Object',
      steps: [
        { t: 'Kapitel 5', h: 'Abstrakte Klassen', sub: 'Baupläne, die man nicht direkt bauen kann', after: 'code' },
        { layout: 'code', console: 'clear', code: file(R`
abstract class Form {
    String name;

    Form(String name) { this.name = name; }

    abstract double flaeche();

    public String toString() {
        return name + " mit Fläche " + flaeche();
    }
}

class Rechteck extends Form {
    double b, h;
    Rechteck(double b, double h) { super("Rechteck"); this.b = b; this.h = h; }

    @Override
    double flaeche() { return b * h; }
}

class Kreis extends Form {
    double r;
    Kreis(double r) { super("Kreis"); this.r = r; }

    @Override
    double flaeche() { return Math.round(Math.PI * r * r * 10) / 10.0; }
}`, R`
        Form[] formen = { new Rechteck(3, 4), new Kreis(1) };
        for (Form f : formen) {
            System.out.println(f);
        }`), hl: [1, 6], say: 'Manchmal ist die Oberklasse nur eine Idee: Es gibt keine „Form an sich“, nur Rechtecke und Kreise. Dann machst du die Klasse `abstract`. Eine abstrakte Methode hat keinen Inhalt – jede Unterklasse **muss** sie schreiben.' },
        { run: true, say: 'Jede Form berechnet ihre Fläche selbst, aber `toString` ist nur einmal geschrieben. `new Form()` würde übrigens nicht gehen – von abstrakten Klassen gibt es keine Objekte.' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Gut zu wissen', items: ['Jede Klasse erbt automatisch von **Object** – daher kommen `toString()` und `equals()`', 'Java erlaubt nur **eine** Oberklasse pro Klasse', '`instanceof` prüft, ob ein Objekt zu einer Klasse gehört', '`protected`: sichtbar für Unterklassen'], gap: 0.9 }, say: 'Noch ein paar Fakten: Ganz oben in jeder Familie steht die Klasse `Object`. Deshalb hat jedes Objekt ein `toString`. Und eine Klasse kann in Java nur von **einer** anderen erben.' },
        { quiz: { id: 'l10-q3', q: 'Was passiert bei `new Form()`, wenn Form abstract ist?', options: ['Ein leeres Objekt wird erzeugt', 'Compiler-Fehler', 'Es wird automatisch ein Kreis', 'Laufzeitfehler beim Aufruf von flaeche()'], correct: 1, explain: 'Von abstrakten Klassen kann man keine Objekte erzeugen – das merkt schon der Compiler.' } },
      ],
    },
    {
      title: 'Aufgabe: Power-ups',
      steps: [
        { t: 'Aufgabe 2', h: 'Power-ups', sub: 'Abstrakte Klasse für Spiel-Items', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Aufgabe 2: Power-ups', items: ['Klasse `Spieler` mit `leben`, `tempo`, `punkte`', 'abstrakte Klasse `PowerUp` mit `abstract void anwenden(Spieler s)` und `beschreibung()`', '`Herz` (+1 Leben), `Turbo` (tempo × 2), `Stern` (+500 Punkte)', 'Lies Kürzel ein (h, t, s), wende sie an, gib den Spieler aus'], gap: 0.9 }, say: 'Letzte Aufgabe dieser Lektion: Power-ups! Jedes Item macht etwas anderes mit dem Spieler.' },
        {
          task: {
            id: 'l10-powerups', nr: 2, title: 'Power-ups',
            text: ['Schreib eine Klasse `Spieler` mit `leben = 3`, `tempo = 1` und `punkte = 0` und eine **abstrakte** Klasse `PowerUp` mit `abstract void anwenden(Spieler s)` und `abstract String beschreibung()`.', 'Unterklassen: `Herz` (+1 Leben), `Turbo` (tempo verdoppeln), `Stern` (+500 Punkte).', 'In main liest du eine Zeile mit Kürzeln ein, z. B. „h t s t“. Für jedes Kürzel erzeugst du das passende Power-up, gibst seine Beschreibung aus und wendest es an. Am Ende: „Leben: 4, Tempo: 4, Punkte: 500“.'],
            req: ['`abstract class PowerUp` mit zwei abstrakten Methoden', 'Drei Unterklassen mit `@Override`', 'Variable vom Typ `PowerUp` (Polymorphie)', 'Kürzel mit `split` zerlegen', 'Richtige Endwerte'],
            example: 'Kürzel: h t s t\nHerz: +1 Leben\nTurbo: doppeltes Tempo\nStern: +500 Punkte\nTurbo: doppeltes Tempo\nLeben: 4, Tempo: 4, Punkte: 500',
            starter: file(R`
class Spieler {
    int leben = 3;
    int tempo = 1;
    int punkte = 0;
}

// abstract class PowerUp { ... }`, R`
        Scanner sc = new Scanner(System.in);
        Spieler sp = new Spieler();
        System.out.print("Kürzel: ");
        String[] kuerzel = sc.nextLine().split(" ");
`, 'import java.util.Scanner;\n\n'),
            solution: file(R`
class Spieler {
    int leben = 3;
    int tempo = 1;
    int punkte = 0;
}

abstract class PowerUp {
    abstract void anwenden(Spieler s);
    abstract String beschreibung();
}

class Herz extends PowerUp {
    @Override
    void anwenden(Spieler s) { s.leben++; }

    @Override
    String beschreibung() { return "Herz: +1 Leben"; }
}

class Turbo extends PowerUp {
    @Override
    void anwenden(Spieler s) { s.tempo *= 2; }

    @Override
    String beschreibung() { return "Turbo: doppeltes Tempo"; }
}

class Stern extends PowerUp {
    @Override
    void anwenden(Spieler s) { s.punkte += 500; }

    @Override
    String beschreibung() { return "Stern: +500 Punkte"; }
}`, R`
        Scanner sc = new Scanner(System.in);
        Spieler sp = new Spieler();
        System.out.print("Kürzel: ");
        String[] kuerzel = sc.nextLine().split(" ");
        for (String k : kuerzel) {
            PowerUp p = null;
            if (k.equals("h")) p = new Herz();
            else if (k.equals("t")) p = new Turbo();
            else if (k.equals("s")) p = new Stern();
            if (p != null) {
                System.out.println(p.beschreibung());
                p.anwenden(sp);
            }
        }
        System.out.println("Leben: " + sp.leben + ", Tempo: " + sp.tempo + ", Punkte: " + sp.punkte);`, 'import java.util.Scanner;\n\n'),
            tests: [
              { name: 'h t s t', input: ['h t s t'], expect: [{ re: 'leben:?\\s*4', label: 'Leben 4' }, { re: 'tempo:?\\s*4', label: 'Tempo 4' }, { re: 'punkte:?\\s*500\\b', label: 'Punkte 500' }] },
              { name: 's s h x', input: ['s s h x'], expect: [{ re: 'leben:?\\s*4', label: 'Leben 4' }, { re: 'tempo:?\\s*1\\b', label: 'Tempo 1' }, { re: 'punkte:?\\s*1000', label: 'Punkte 1000' }] },
            ],
            codeChecks: [{ label: 'abstract class PowerUp', re: 'abstract\\s+class\\s+PowerUp' }, { label: 'abstrakte Methode anwenden', re: 'abstract\\s+void\\s+anwenden' }, { label: 'drei Unterklassen', re: 'extends\\s+PowerUp[\\s\\S]*extends\\s+PowerUp[\\s\\S]*extends\\s+PowerUp' }, { label: 'Variable vom Typ PowerUp', re: 'PowerUp\\s+\\w+\\s*=' }],
            rubric: [['Programm kompiliert und läuft', 15], ['Abstrakte Klasse richtig aufgebaut', 25], ['Drei Unterklassen mit passender Wirkung', 25], ['Polymorphe Verwendung über PowerUp-Variable', 20], ['Eingabe zerlegt und Endwerte richtig', 15]],
            tip: 'Leg in der Schleife eine Variable `PowerUp p = null;` an und weise ihr je nach Kürzel ein `new Herz()`, `new Turbo()` … zu. Danach rufst du einfach `p.anwenden(sp)` auf – egal welches es ist.',
          },
        },
        { layout: 'code', console: 'clear', code: file(R`
class Spieler {
    int punkte = 0;
}

abstract class PowerUp {
    abstract void anwenden(Spieler s);
}

class Stern extends PowerUp {
    @Override
    void anwenden(Spieler s) { s.punkte += 500; }
}`, R`
        Spieler sp = new Spieler();
        PowerUp p = new Stern();
        p.anwenden(sp);
        p.anwenden(sp);
        System.out.println(sp.punkte);`), run: true, say: 'Abgegeben! Die main-Methode kennt nur `PowerUp` und `anwenden`. Willst du ein neues Item – einen Pilz, einen Magneten –, schreibst du nur eine neue Klasse.' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Das kannst du jetzt', items: ['Unterklassen mit `extends` bilden', 'Konstruktoren der Oberklasse mit `super(...)` aufrufen', 'Methoden mit `@Override` überschreiben und mit `super.` ergänzen', '**Polymorphie**: verschiedene Objekte in einer Liste', 'Abstrakte Klassen als gemeinsamen Bauplan'], gap: 0.7 }, say: 'Das war Lektion 10 – du kennst jetzt die großen Ideen der objektorientierten Programmierung. In Lektion 11 bauen wir Spielfelder und machen Programme robust.' },
      ],
    },
  ],
};
