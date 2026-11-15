// Lektion 12 – Abschlussprojekt: Pixel-Lauf (Konsolen-Jump'n'Run)
const R = String.raw;
const strip = s => s.replace(/^\n/, '').replace(/\n$/, '');
const SC = 'import java.util.Scanner;\n\n';

const KARTE = R`
        String[] karte = {
            "################",
            "#              #",
            "#     o    o  Z#",
            "#    ###  ###  #",
            "#@  o   ^^   ###",
            "################"
        };`;

const LEVEL = R`
class Level {
    char[][] feld;
    int startX, startY;

    Level(String[] zeilen) {
        feld = new char[zeilen.length][];
        for (int y = 0; y < zeilen.length; y++) {
            feld[y] = zeilen[y].toCharArray();
            for (int x = 0; x < feld[y].length; x++) {
                if (feld[y][x] == '@') {
                    startX = x;
                    startY = y;
                    feld[y][x] = ' ';
                }
            }
        }
    }

    boolean istFest(int x, int y) {
        if (y < 0 || y >= feld.length || x < 0 || x >= feld[y].length) {
            return true;
        }
        return feld[y][x] == '#';
    }

    char get(int x, int y) {
        return feld[y][x];
    }

    void leeren(int x, int y) {
        feld[y][x] = ' ';
    }
}`;

const SPIELER_KOPF = R`
class Spieler {
    int x, y;
    int sprung = 0;

    Spieler(int x, int y) {
        this.x = x;
        this.y = y;
    }

    boolean aufBoden(Level lv) {
        return lv.istFest(x, y + 1);
    }
`;

const UPDATE = R`
    void update(Level lv, String eingabe) {
        if (eingabe.contains("a") && !lv.istFest(x - 1, y)) x--;
        if (eingabe.contains("d") && !lv.istFest(x + 1, y)) x++;
        if (eingabe.contains("w") && aufBoden(lv)) sprung = 2;
        if (sprung > 0) {
            if (!lv.istFest(x, y - 1)) {
                y--;
                sprung--;
            } else {
                sprung = 0;
            }
        } else if (!aufBoden(lv)) {
            y++;
        }
    }
}`;

const ZEICHNE = R`
    static void zeichne(Level lv, Spieler s) {
        for (int y = 0; y < lv.feld.length; y++) {
            StringBuilder sb = new StringBuilder();
            for (int x = 0; x < lv.feld[y].length; x++) {
                if (x == s.x && y == s.y) sb.append('@');
                else sb.append(lv.feld[y][x]);
            }
            System.out.println(sb);
        }
    }`;

const mainCls = (members, body) => `public class Main {\n${strip(members)}\n\n    public static void main(String[] args) {\n${strip(body)}\n    }\n}\n`;
const all = (classes, members, body, imports = '') => `${imports}${classes.map(strip).join('\n\n')}\n\n${mainCls(members, body)}`;

// Teil 1: einfache Spielschleife – am Ende die Position
const LOOP1 = KARTE + R`
        Level lv = new Level(karte);
        Spieler s = new Spieler(lv.startX, lv.startY);
        Scanner sc = new Scanner(System.in);
        while (sc.hasNextLine()) {
            String eingabe = sc.nextLine();
            if (eingabe.equals("q")) break;
            s.update(lv, eingabe);
        }
        zeichne(lv, s);
        System.out.println("Position: " + s.x + "," + s.y);`;

const FULL_MAIN = KARTE + R`
        Level lv = new Level(karte);
        Spieler s = new Spieler(lv.startX, lv.startY);
        Scanner sc = new Scanner(System.in);
        int leben = 3, muenzen = 0, tick = 0;
        while (sc.hasNextLine()) {
            String eingabe = sc.nextLine();
            if (eingabe.equals("q")) break;
            s.update(lv, eingabe);
            tick++;
            char c = lv.get(s.x, s.y);
            if (c == 'o') {
                muenzen++;
                lv.leeren(s.x, s.y);
            } else if (c == '^') {
                leben--;
                System.out.println("Autsch! Noch " + leben + " Leben.");
                if (leben == 0) {
                    System.out.println("Game Over nach " + tick + " Ticks.");
                    return;
                }
                s = new Spieler(lv.startX, lv.startY);
            } else if (c == 'Z') {
                zeichne(lv, s);
                System.out.println("Ziel nach " + tick + " Ticks mit " + muenzen + " Münzen!");
                return;
            }
        }
        zeichne(lv, s);
        System.out.println("Spiel beendet. Münzen: " + muenzen);`;

const WIN = ['d', 'd', 'd', 'd', 'd', 'd', 'wd', 'd', 'd', 'd', 'd', 'd', 'wd'];

const lesson = {
  id: 'java-12', nr: 12,
  title: 'Abschlussprojekt: Pixel-Lauf',
  sub: 'Alles zusammen: ein Jump’n’Run in der Konsole – mit Schwerkraft, Sprüngen, Münzen, Stacheln und Ziel.',
  outro: 'Geschafft – du hast ein komplettes Spiel in Java programmiert! Schwerkraft, Kollision, Spielschleife und Level aus Text: Genau diese Ideen baust du als Nächstes im Browser nach, mit JavaScript, Grafik und Mitspielern. Weiter geht’s in den Classics mit JavaScript.',
  chapters: [
    {
      title: 'Das Projekt',
      steps: [
        { t: 'Lektion 12', h: 'Pixel-Lauf', sub: 'Dein Java-Abschlussprojekt', say: 'Servus und willkommen zum Finale des Java-Teils! Heute baust du ein echtes **Jump’n’Run** – noch in der Konsole, aber mit allem, was dazugehört: Schwerkraft, Springen, Münzen, Stacheln und ein Ziel.' },
        { layout: 'visual', visual: { kind: 'code', title: 'So sieht das Level aus', code: '################\n#              #\n#     o    o  Z#\n#    ###  ###  #\n#@  o   ^^   ###\n################', note: '`@` Spieler · `#` Wand/Boden · `o` Münze · `^` Stacheln · `Z` Ziel' }, say: 'Das ist unser Level, gezeichnet als Text. Der Spieler startet links unten. Über die Stacheln muss er springen, und oben warten Münzen und das Ziel.' },
        { layout: 'visual', visual: { kind: 'flow', dir: 'row', title: 'Ein Tick der Spielschleife', items: [{ h: 'Eingabe', p: 'a, d, w oder wd' }, { h: 'Update', p: 'laufen, springen, fallen' }, { h: 'Prüfen', p: 'Münze? Stachel? Ziel?' }, { h: 'Zeichnen', p: 'Feld ausgeben', cls: 'good' }], gap: 1.0 }, say: 'Jedes Spiel läuft in einer Schleife. Ein Durchgang heißt **Tick** oder Frame: Eingabe lesen, alles bewegen, Ereignisse prüfen, zeichnen. Bei uns ist ein Tick eine eingegebene Zeile. Im Browser werden es später 60 Ticks pro Sekunde.' },
        { layout: 'visual', visual: { kind: 'boxes', title: 'Drei Klassen', vars: [{ type: 'class', name: 'Level', value: 'Karte, istFest()' }, { type: 'class', name: 'Spieler', value: 'x, y, sprung, update()' }, { type: 'class', name: 'Main', value: 'Spielschleife, zeichne()' }], note: 'Jede Klasse hat **eine** Aufgabe – so bleibt das Projekt übersichtlich.' }, say: 'Wir teilen das Projekt in drei Klassen auf. Das Level kennt die Karte. Der Spieler kennt seine Position und weiß, wie er sich bewegt. Und Main hält alles in der Spielschleife zusammen.' },
      ],
    },
    {
      title: 'Die Klasse Level',
      steps: [
        { t: 'Kapitel 2', h: 'Die Klasse Level', sub: 'Karte laden und fragen: Ist hier Boden?', after: 'code' },
        { layout: 'code', console: 'clear', code: all([LEVEL], '', KARTE + R`
        Level lv = new Level(karte);
        System.out.println("Start: " + lv.startX + "," + lv.startY);
        System.out.println("Boden unter dem Start? " + lv.istFest(1, 5));
        System.out.println("Luft über dem Start? " + !lv.istFest(1, 3));
        System.out.println("Außerhalb der Karte? " + lv.istFest(99, 2));`), hl: ['Level(String[] zeilen)', '        }\n    }', 0], say: 'Der Konstruktor kennst du fast schon aus Lektion 11: Er macht aus Text-Zeilen ein `char[][]`. Neu: Er sucht dabei das `@`, merkt sich die Startposition und ersetzt es durch ein Leerzeichen.' },
        { hl: ['boolean istFest', 'return feld[y][x] ==', 1], say: 'Die wichtigste Methode heißt `istFest`: Ist an dieser Stelle etwas, durch das man nicht durchkommt? Außerhalb der Karte zählt alles als fest – so kann der Spieler nie hinausfallen.' },
        { run: true, say: 'Start bei 1,4. Darunter ist Boden, darüber Luft, und außerhalb ist alles fest. Mit dieser einen Methode können wir Laufen, Fallen und Springen bauen.' },
      ],
    },
    {
      title: 'Schwerkraft & Springen',
      steps: [
        { t: 'Kapitel 3', h: 'Schwerkraft & Springen', sub: 'Die Physik in drei Regeln', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Die Physik von Pixel-Lauf', items: ['**Laufen:** `a`/`d` bewegt nach links/rechts – wenn dort nichts Festes ist', '**Springen:** `w` geht nur **auf dem Boden** und gibt 2 Ticks Schwung nach oben', '**Schwerkraft:** Ohne Schwung und ohne Boden fällt der Spieler 1 Feld pro Tick', 'Kombinierbar: `wd` springt nach rechts'], gap: 1.0 }, say: 'Unsere Physik hat drei Regeln. Laufen, Springen mit Schwung, und Schwerkraft. Echte Spiele rechnen mit Geschwindigkeiten und Pixeln, aber die Idee ist genau dieselbe.' },
        { layout: 'code', console: 'clear', code: all([LEVEL, SPIELER_KOPF + UPDATE], '', KARTE + R`
        Level lv = new Level(karte);
        Spieler s = new Spieler(lv.startX, lv.startY);
        String[] eingaben = {"w", ".", ".", "."};
        for (String e : eingaben) {
            s.update(lv, e);
            System.out.println(e + " -> y=" + s.y + ", Boden: " + s.aufBoden(lv));
        }`), hl: ['void update', 'sprung = 2;'], say: 'Hier die Methode `update`. Zuerst die waagrechte Bewegung: Nur wenn neben dem Spieler nichts Festes ist, darf er dorthin.' },
        { hl: ['if (sprung > 0)', 'y++;', 1], say: 'Dann die senkrechte: Hat der Spieler noch Sprung-Schwung, geht es ein Feld nach oben – außer er stößt sich den Kopf. Sonst gilt die Schwerkraft: Kein Boden unter den Füßen? Dann ein Feld runter.' },
        { run: true, say: 'Schau dir die y-Werte an: Hoch auf 3, hoch auf 2, dann fällt er zurück auf 3 und landet auf 4. Ein kompletter Sprung in vier Ticks!' },
        { quiz: { id: 'l12-q1', q: 'Warum darf man nur springen, wenn `aufBoden` true ist?', options: ['Sonst wäre der Code zu langsam', 'Sonst könnte man in der Luft immer weiter springen und fliegen', 'Weil Java das so verlangt', 'Damit die Münzen funktionieren'], correct: 1, explain: 'Ohne diese Prüfung könnte man mit w, w, w … endlos nach oben fliegen.' } },
      ],
    },
    {
      title: 'Die Spielschleife',
      steps: [
        { t: 'Kapitel 4', h: 'Die Spielschleife', sub: 'Alles zusammenstecken', after: 'code' },
        { layout: 'code', console: 'clear', code: all([LEVEL, SPIELER_KOPF + UPDATE], ZEICHNE, LOOP1, SC), hl: ['static void zeichne', 'System.out.println(sb);', 2], say: '`zeichne` geht das Feld Zeile für Zeile durch. Wo der Spieler steht, kommt ein `@` hin, sonst die Kachel aus dem Level.' },
        { hl: ['Level lv = new Level', 'Position:'], say: 'Und die Spielschleife: Solange es Eingaben gibt, lesen wir eine Zeile und rufen `update` auf. Am Ende zeichnen wir das Feld. Wir spielen das mal mit sechs Schritten nach rechts und einem Sprung über die Stacheln.' },
        { run: true, input: ['d', 'd', 'd', 'd', 'd', 'd', 'wd', 'd', 'd'], say: 'Der Spieler ist über die Stacheln gesprungen und steht jetzt auf der rechten Plattform. Die Münzen und Stacheln haben aber noch keine Wirkung – das ist dein Job.' },
      ],
    },
    {
      title: 'Projekt Teil 1: Physik',
      steps: [
        { t: 'Projekt Teil 1', h: 'Die Physik', sub: 'Jetzt bist du dran!', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Teil 1: Schreib update() selbst', items: ['Level, zeichne() und die Spielschleife sind fertig', 'Schreib in `Spieler` die Methode `update(Level lv, String eingabe)`', 'Laufen mit a/d, Springen mit w (nur auf dem Boden, 2 Ticks Schwung)', 'Schwerkraft: 1 Feld pro Tick nach unten'], gap: 0.9 }, say: 'Erster Teil des Projekts: Du schreibst die Physik. Ohne nachzuschauen – du hast alle Regeln gerade gesehen.' },
        {
          task: {
            id: 'l12-physik', nr: 1, title: 'Projekt Teil 1: Physik',
            level: 'Projekt',
            text: ['Im Startcode sind die Klasse `Level`, die Methode `zeichne` und die Spielschleife fertig. In der Klasse `Spieler` fehlt die Methode `update(Level lv, String eingabe)`.', 'Regeln: Enthält die Eingabe „a“ oder „d“, geht der Spieler ein Feld nach links bzw. rechts, falls dort nichts Festes ist. Enthält sie „w“ und der Spieler steht auf dem Boden, bekommt er `sprung = 2`. Danach: Ist `sprung > 0`, geht er ein Feld hoch (falls frei, sonst wird sprung 0) und sprung sinkt um 1. Sonst fällt er ein Feld, wenn unter ihm kein Boden ist.'],
            req: ['Methode `update(Level lv, String eingabe)` in `Spieler`', 'Laufen mit Kollision', 'Springen nur auf dem Boden', 'Schwung nach oben und Kopfstoß', 'Schwerkraft'],
            example: 'Eingaben: w . . .\n… (Feld) …\nPosition: 1,4',
            starter: all([LEVEL, SPIELER_KOPF + R`
    void update(Level lv, String eingabe) {
        // Schreib hier die Physik: laufen, springen, Schwung, Schwerkraft
    }
}`], ZEICHNE, LOOP1, SC),
            solution: all([LEVEL, SPIELER_KOPF + UPDATE], ZEICHNE, LOOP1, SC),
            tests: [
              { name: 'laufen', input: ['d', 'd', 'd'], expect: [{ re: 'position:?\\s*4\\s*,\\s*4', label: 'nach 3× d: 4,4' }] },
              { name: 'Wand links', input: ['a', 'a', 'd'], expect: [{ re: 'position:?\\s*2\\s*,\\s*4', label: 'Wand blockiert: 2,4' }] },
              { name: 'Sprung-Höhepunkt', input: ['w', '.'], expect: [{ re: 'position:?\\s*1\\s*,\\s*2', label: 'nach w und einem Tick: 1,2' }] },
              { name: 'Landung', input: ['w', '.', '.', '.'], expect: [{ re: 'position:?\\s*1\\s*,\\s*4', label: 'wieder gelandet: 1,4' }] },
              { name: 'kein Doppelsprung', input: ['w', 'w', 'w'], expect: [{ re: 'position:?\\s*1\\s*,\\s*3', label: 'kein Fliegen: 1,3' }] },
              { name: 'auf die Plattform', input: ['d', 'd', 'wd', 'd', 'd', 'd'], expect: [{ re: 'position:?\\s*6\\s*,\\s*2', label: 'auf der Plattform: 6,2' }] },
            ],
            codeChecks: [{ label: 'Methode update(Level, String)', re: 'void\\s+update\\s*\\(\\s*Level\\s+\\w+\\s*,\\s*String\\s+\\w+\\s*\\)' }, { label: 'istFest benutzt', re: 'istFest\\s*\\(' }, { label: 'aufBoden benutzt', re: 'aufBoden\\s*\\(' }],
            rubric: [['Programm kompiliert und läuft', 15], ['Laufen mit Kollision', 20], ['Springen nur vom Boden', 20], ['Schwung nach oben inkl. Kopfstoß', 20], ['Schwerkraft', 15], ['Sauberer, lesbarer Code', 10]],
            tip: 'Arbeite die Regeln von oben nach unten ab, genau in dieser Reihenfolge: erst waagrecht, dann „springen?“, dann „Schwung oder fallen?“. Teste mit kleinen Eingaben wie „w“ und „.“.',
            lookup: 'Kapitel „Schwerkraft & Springen“ in dieser Lektion; `contains` aus Lektion 7.',
          },
        },
        { layout: 'code', console: 'clear', code: all([LEVEL, SPIELER_KOPF + UPDATE], '', KARTE + R`
        Level lv = new Level(karte);
        Spieler s = new Spieler(lv.startX, lv.startY);
        String[] eingaben = {"w", "w", "w"};
        for (String e : eingaben) {
            s.update(lv, e);
        }
        System.out.println("y = " + s.y);`), run: true, hl: ['aufBoden(lv)) sprung', 'aufBoden(lv)) sprung'], say: 'Abgegeben! Siehst du, wie wichtig die Bedingung `aufBoden` in der markierten Zeile ist? Nach dreimal w ist der Spieler schon wieder auf dem Weg nach unten, bei y = 3 – fliegen geht nicht.' },
      ],
    },
    {
      title: 'Münzen, Stacheln, Ziel',
      steps: [
        { t: 'Kapitel 6', h: 'Münzen, Stacheln, Ziel', sub: 'Das Spiel bekommt Regeln', after: 'code' },
        { layout: 'code', console: 'clear', code: all([LEVEL, SPIELER_KOPF + UPDATE], ZEICHNE, FULL_MAIN, SC), hl: ["if (c == 'o')", 'lv.leeren'], say: 'Jetzt kommen die Spielregeln dazu. Nach jedem update schauen wir, auf welcher Kachel der Spieler steht. Eine Münze wird eingesammelt und aus dem Level gelöscht.' },
        { hl: ["else if (c == '^')", 'new Spieler(lv.startX'], say: 'Stacheln kosten ein Leben. Danach startet der Spieler neu am Anfang – wir erzeugen einfach ein **neues** Spieler-Objekt. Bei null Leben ist Game Over.' },
        { hl: ["else if (c == 'Z')", 'return;'], say: 'Und beim Ziel ist das Spiel gewonnen. Wir spielen den schnellsten Weg durch: 13 Ticks.' },
        { run: true, input: WIN, say: 'Ziel erreicht nach 13 Ticks mit zwei Münzen! Und weißt du was? Das ist die Grundstruktur **jedes** Jump’n’Runs. Im Browser wird nur alles flüssiger und bunter.' },
        { quiz: { id: 'l12-q2', q: 'Warum löschen wir eine Münze mit `lv.leeren(x, y)` aus dem Level?', options: ['Damit das Level kleiner wird', 'Damit man dieselbe Münze nicht mehrmals einsammeln kann', 'Weil Münzen sonst fallen', 'Damit der Spieler schneller wird'], correct: 1, explain: 'Bliebe das o stehen, würde jeder Tick auf diesem Feld noch eine Münze zählen.' } },
      ],
    },
    {
      title: 'Projekt Teil 2: Das ganze Spiel',
      steps: [
        { t: 'Projekt Teil 2', h: 'Das ganze Spiel', sub: 'Dein eigenes Level', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Teil 2: Mach ein echtes Spiel daraus', items: ['Zeichne ein **eigenes Level** (mind. 20 breit, 7 hoch) mit Münzen, Stacheln und Ziel', 'Spielregeln: Münzen, 3 Leben mit Neustart, Game Over, Ziel', 'Neu: **Punkte** = Münzen × 100 + Bonus für Schnelligkeit', 'Gib nach dem Ziel eine Wertung aus'], gap: 0.9 }, say: 'Letzte Aufgabe des Java-Teils: Bau daraus dein eigenes Spiel – mit eigenem Level und Punktewertung. Wie du die Punkte berechnest, darfst du selbst festlegen.' },
        {
          task: {
            id: 'l12-spiel', nr: 2, title: 'Projekt Teil 2: Das ganze Spiel',
            level: 'Projekt',
            text: ['Ergänze die Spielschleife um die Regeln: Münze `o` einsammeln (und aus dem Level löschen), Stacheln `^` kosten ein Leben und setzen den Spieler an den Start zurück, bei 0 Leben „Game Over“, beim Ziel `Z` „Ziel!“ mit Anzahl Ticks und Münzen.', 'Zeichne dazu ein **eigenes** Level: mindestens 20 Zeichen breit und 7 Zeilen hoch, mit mindestens 3 Münzen, Stacheln und einem Ziel, das man mit Springen erreichen kann.', 'Berechne am Ende Punkte: Münzen × 100 plus ein Zeitbonus deiner Wahl (z. B. 1000 − 20 × Ticks, mindestens 0). Damit die Tests dein Level nicht kennen müssen: Bei der Eingabe „test“ als **erster** Zeile benutze das Level aus Teil 1.'],
            req: ['Eigenes Level (≥ 20 × 7) mit Münzen, Stacheln, Ziel', 'Münzen zählen und löschen', '3 Leben, Neustart am Start, Game Over', 'Ziel mit Ticks, Münzen und Punkten', 'Erste Eingabe „test“ → Level aus Teil 1'],
            example: 'test\nd\n…\nwd\nZiel nach 13 Ticks mit 2 Münzen!\nPunkte: 940',
            starter: all([LEVEL, SPIELER_KOPF + UPDATE], ZEICHNE, KARTE + R`
        String[] meinLevel = {
            // Zeichne hier dein eigenes Level (mind. 20 breit, 7 hoch)
            "####################",
            "#@                Z#",
            "####################"
        };
        Scanner sc = new Scanner(System.in);
        String erste = sc.nextLine();
        Level lv = new Level(erste.equals("test") ? karte : meinLevel);
        Spieler s = new Spieler(lv.startX, lv.startY);
        // Spielschleife mit Münzen, Stacheln, Leben, Ziel und Punkten
`, SC),
            solution: all([LEVEL, SPIELER_KOPF + UPDATE], ZEICHNE, KARTE + R`
        String[] meinLevel = {
            "########################",
            "#                      #",
            "#          o o     o  Z#",
            "#     o   #####   ######",
            "#    ###          #    #",
            "#@  o    ^^^   o  #    #",
            "########################"
        };
        Scanner sc = new Scanner(System.in);
        String erste = sc.nextLine();
        Level lv = new Level(erste.equals("test") ? karte : meinLevel);
        Spieler s = new Spieler(lv.startX, lv.startY);
        int leben = 3, muenzen = 0, tick = 0;
        while (sc.hasNextLine()) {
            String eingabe = sc.nextLine();
            if (eingabe.equals("q")) break;
            s.update(lv, eingabe);
            tick++;
            char c = lv.get(s.x, s.y);
            if (c == 'o') {
                muenzen++;
                lv.leeren(s.x, s.y);
            } else if (c == '^') {
                leben--;
                System.out.println("Autsch! Noch " + leben + " Leben.");
                if (leben == 0) {
                    System.out.println("Game Over nach " + tick + " Ticks.");
                    return;
                }
                s = new Spieler(lv.startX, lv.startY);
            } else if (c == 'Z') {
                zeichne(lv, s);
                int bonus = Math.max(0, 1000 - 20 * tick);
                System.out.println("Ziel nach " + tick + " Ticks mit " + muenzen + " Münzen!");
                System.out.println("Punkte: " + (muenzen * 100 + bonus));
                return;
            }
        }
        zeichne(lv, s);
        System.out.println("Spiel beendet. Münzen: " + muenzen);`, SC),
            tests: [
              { name: 'Testlevel gewinnen', input: ['test', ...WIN], expect: [{ re: 'ziel', label: 'Ziel erkannt' }, { re: '\\b13\\b', label: '13 Ticks' }, { re: '\\b2\\b[^\\n]*m(ü|ue)nzen|m(ü|ue)nzen:?\\s*2\\b', label: '2 Münzen' }, { re: 'punkte', label: 'Punkte ausgegeben' }] },
              { name: 'Stacheln', input: ['test', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'q'], expect: [{ re: 'autsch|leben', label: 'Treffer gemeldet' }, { re: 'ziel', label: 'kein Ziel', not: true }, { re: 'game over', label: 'noch kein Game Over', not: true }] },
              { name: 'Game Over', input: ['test', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd'], expect: [{ re: 'game over', label: '„Game Over“ nach drei Treffern' }] },
            ],
            codeChecks: [{ label: 'eigenes Level meinLevel (≥ 7 Zeilen)', re: 'meinLevel\\s*=\\s*\\{(\\s*"[^"\\n]{20,}"\\s*,){6,}' }, { label: 'Münzen gelöscht', re: 'leeren\\s*\\(' }, { label: 'Punkte berechnet', re: 'punkte|Punkte' }, { label: 'Neustart am Start', re: 'new\\s+Spieler\\s*\\(\\s*lv\\.startX|\\.x\\s*=\\s*lv\\.startX' }],
            rubric: [['Programm kompiliert und läuft', 10], ['Eigenes, spielbares Level mit allen Elementen', 20], ['Münzen zählen und löschen', 15], ['Stacheln, Leben, Neustart, Game Over', 20], ['Ziel mit Ticks und Münzen', 15], ['Punkteberechnung mit Zeitbonus', 10], ['Sauberer Aufbau und gute Namen', 10]],
            tip: 'Starte mit der Spielschleife aus Kapitel 6 und teste mit „test“. Erst wenn das Testlevel klappt, zeichnest du dein eigenes Level und spielst es mit der Eingabe von Hand durch.',
            lookup: 'Kapitel „Münzen, Stacheln, Ziel“; Level als Text aus Lektion 11.',
          },
        },
        { layout: 'visual', visual: { kind: 'html', html: '<div class="big" data-s="0.2"><div class="big-main">Java: geschafft!</div><div class="big-sub">12 Lektionen · Variablen bis Vererbung · ein eigenes Spiel</div></div>' }, say: 'Abgegeben – und damit hast du den kompletten Java-Teil geschafft! Du kannst jetzt richtig programmieren.' },
        { layout: 'visual', visual: { kind: 'flow', dir: 'row', title: 'Wie es weitergeht', items: [{ h: 'Classics', p: 'JavaScript, HTML, CSS, Node.js' }, { h: 'Unser Game', p: 'Canvas, Physik, Level, Multiplayer' }, { h: 'Finale', p: 'Dein Multiplayer-Jump’n’Run', cls: 'good' }], gap: 1.1 }, say: 'Als Nächstes lernst du JavaScript – die Sprache des Browsers. Vieles kennst du schon aus Java. Und im Reiter „Unser Game“ baust du Schritt für Schritt das Multiplayer-Jump’n’Run. Bis gleich!' },
      ],
    },
  ],
};

// Markierungen über Textstellen statt Zeilennummern: hl: [anfang, ende, zusatzZeilen]
let cur = '';
for (const ch of lesson.chapters) for (const st of ch.steps) {
  if (st.code !== undefined) cur = st.code;
  if (st.hl && typeof st.hl[0] === 'string') {
    const L = cur.split('\n');
    const find = (txt, from) => { if (txt.includes('\n')) { const parts = txt.split('\n'); for (let k = from; k < L.length; k++) if (parts.every((p, j) => L[k + j] !== undefined && L[k + j].startsWith(p))) return k + parts.length - 1; return -1; } return L.findIndex((l, k) => k >= from && l.includes(txt)); };
    const a = find(st.hl[0], 0), b = find(st.hl[1] || st.hl[0], Math.max(a, 0));
    if (a < 0 || b < 0) throw new Error('Markierung nicht gefunden: ' + st.hl.join(' … '));
    st.hl = [a + 1, b + 1 + (st.hl[2] || 0)];
  }
}

export default lesson;
