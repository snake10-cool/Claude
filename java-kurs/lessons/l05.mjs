// Lektion 5 – Arrays
const R = String.raw;
const prog = (body, imports = '') => `${imports}public class Main {\n    public static void main(String[] args) {\n${body.replace(/^\n/, '').replace(/\n$/, '')}\n    }\n}\n`;
const AR = 'import java.util.Arrays;\n\n';

export default {
  id: 'java-05', nr: 5,
  title: 'Arrays',
  sub: 'Viele Werte in einer Variable: Arrays anlegen, durchlaufen, Summe, Durchschnitt und Maximum finden.',
  outro: 'Mit Arrays verwaltest du ganze Listen von Werten – und mit Schleifen wertest du sie in wenigen Zeilen aus. Als Nächstes kommen eigene Methoden.',
  playground: prog(R`
        int[] zahlen = {4, 8, 15, 16, 23, 42};
        int summe = 0;
        for (int z : zahlen) {
            summe += z;
        }
        System.out.println("Summe: " + summe);`),
  chapters: [
    {
      title: 'Warum Arrays?',
      steps: [
        { t: 'Lektion 5', h: 'Arrays', sub: 'Viele Werte in einer einzigen Variable', say: 'Servus! Stell dir vor, du willst die Noten einer ganzen Klasse speichern. Dreißig Variablen namens `note1`, `note2`, `note3` … ? Viel zu umständlich. Dafür gibt es **Arrays**.' },
        { layout: 'visual', visual: { kind: 'boxes', title: 'Ein Array ist eine Reihe von Fächern', vars: [{ type: '[0]', name: 'noten[0]', value: '2' }, { type: '[1]', name: 'noten[1]', value: '1' }, { type: '[2]', name: 'noten[2]', value: '3' }, { type: '[3]', name: 'noten[3]', value: '1' }, { type: '[4]', name: 'noten[4]', value: '4' }], gap: 0.5, note: 'Alle Fächer haben **denselben Typ**. Gezählt wird ab **0**!', noteAt: 3 }, say: 'Ein Array ist wie eine Reihe nummerierter Fächer unter **einem** Namen. Jedes Fach hat eine Nummer, den **Index**. Ganz wichtig: Java fängt bei **0** an zu zählen.' },
      ],
    },
    {
      title: 'Arrays anlegen',
      steps: [
        { t: 'Kapitel 2', h: 'Arrays anlegen', sub: 'und auf einzelne Fächer zugreifen', after: 'code' },
        { layout: 'code', console: 'clear', code: prog(R`
        int[] noten = {2, 1, 3, 1, 4};
        System.out.println(noten[0]);
        System.out.println(noten[2]);
        System.out.println("Anzahl: " + noten.length);`), hl: [3, 3], say: 'So legst du ein Array mit Startwerten an: Typ mit eckigen Klammern, Name, und die Werte in geschweiften Klammern. Mit `noten[0]` holst du das erste Fach.' },
        { run: true, hl: [6, 6], say: '`noten[0]` ist 2, `noten[2]` ist 3. Und `noten.length` sagt dir, wie viele Fächer das Array hat – hier 5. Achtung: `length` ohne Klammern!' },
        { console: 'clear', code: prog(R`
        double[] preise = new double[3];
        preise[0] = 4.99;
        preise[1] = 1.50;
        preise[2] = preise[0] + preise[1];
        System.out.println(Arrays.toString(preise));`, AR), hl: [5, 8], say: 'Kennst du die Werte noch nicht, legst du ein leeres Array mit fester Größe an: `new double[3]`. Am Anfang steht in jedem Fach 0. Dann befüllst du es Fach für Fach.' },
        { run: true, hl: [9, 9], say: 'Mit `Arrays.toString` gibst du das ganze Array auf einmal aus. Dafür brauchst du oben `import java.util.Arrays;`.' },
        { console: 'clear', code: prog(R`
        int[] noten = {2, 1, 3, 1, 4};
        System.out.println(noten[5]);`), hl: [4, 4], say: 'Was passiert, wenn du auf Fach 5 zugreifst? Das Array hat 5 Fächer – also die Nummern 0 bis 4.' },
        { run: true, expectError: true, say: 'Absturz: **ArrayIndexOutOfBoundsException**. Das Fach 5 gibt es nicht. Das ist einer der häufigsten Fehler überhaupt – der letzte Index ist immer `length - 1`.' },
        { quiz: { id: 'l5-q1', q: 'Ein Array hat `length` 8. Welcher Index ist der letzte?', options: ['8', '7', '9', '0'], correct: 1, explain: 'Gezählt wird ab 0, also gehen die Indizes von 0 bis 7. Der letzte Index ist immer `length - 1`.' } },
      ],
    },
    {
      title: 'Arrays durchlaufen',
      steps: [
        { t: 'Kapitel 3', h: 'Arrays + Schleifen', sub: 'Das perfekte Team', after: 'code' },
        { layout: 'code', console: 'clear', code: prog(R`
        int[] noten = {2, 1, 3, 1, 4};
        for (int i = 0; i < noten.length; i++) {
            System.out.println("Test " + (i + 1) + ": Note " + noten[i]);
        }`), hl: [4, 6], say: 'Richtig stark werden Arrays mit Schleifen. Die for-Schleife läuft von 0 bis `noten.length - 1` – also genau über alle Fächer.' },
        { run: true, say: 'Jedes Fach wird einmal besucht. Und weil die Schleife `noten.length` benutzt, funktioniert sie auch, wenn das Array größer oder kleiner wird.' },
        { console: 'clear', code: prog(R`
        int[] noten = {2, 1, 3, 1, 4};
        int summe = 0;
        int beste = noten[0];
        for (int note : noten) {
            summe += note;
            if (note < beste) {
                beste = note;
            }
        }
        double schnitt = (double) summe / noten.length;
        System.out.println("Durchschnitt: " + schnitt);
        System.out.println("Beste Note: " + beste);`), hl: [6, 11], say: 'Die **for-each-Schleife** ist noch kürzer: `for (int note : noten)` heißt „für jede Note im Array“. Damit bilden wir die Summe und suchen gleichzeitig die beste Note.' },
        { run: true, hl: [12, 14], say: 'Summe durch Anzahl ergibt den Durchschnitt – mit `(double)`, damit die Ganzzahl-Falle nicht zuschlägt. Bei österreichischen Noten ist die beste die **kleinste** Zahl.' },
        { quiz: { id: 'l5-q2', q: 'Was macht `for (String name : namen)`?', options: ['Es zählt die Namen', 'Es geht jeden Eintrag im Array `namen` der Reihe nach durch', 'Es sortiert die Namen', 'Es erstellt ein neues Array'], correct: 1, explain: 'Die for-each-Schleife besucht jedes Element genau einmal. In `name` steckt bei jedem Durchlauf das aktuelle Element.' } },
      ],
    },
    {
      title: 'Aufgabe: Fang-Auswertung',
      steps: [
        { t: 'Aufgabe 1', h: 'Fang-Auswertung', sub: 'Jetzt bist du dran!', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Aufgabe: Fang-Auswertung', items: ['Speichere die Längen deiner Fische (in cm) in einem `int`-Array', 'Gib alle Längen aus', 'Berechne **Durchschnitt**, **längsten** und **kürzesten** Fisch', 'Zähle, wie viele Fische das Schonmaß von **40 cm** erreichen'], gap: 0.9 }, say: 'Jetzt bist du dran! Werte deinen Angeltag mit einem Array aus. Du brauchst Schleifen, Summe, Maximum, Minimum und einen Zähler.' },
        {
          task: {
            id: 'l5-fang', nr: 1, title: 'Fang-Auswertung',
            text: ['Du hast heute sieben Fische gefangen. Ihre Längen in Zentimetern: 34, 52, 41, 28, 67, 45, 39. Speichere sie in einem `int`-Array.', 'Gib dann eine Auswertung aus: alle Längen, den Durchschnitt (als Kommazahl), den längsten und den kürzesten Fisch und wie viele Fische mindestens 40 cm lang sind (das Schonmaß – kleinere müssen zurück ins Wasser).'],
            req: ['Ein `int`-Array mit den 7 Längen', 'Eine Schleife über das Array', 'Durchschnitt als Kommazahl (≈ 43.71)', 'Längster (67) und kürzester (28) Fisch', 'Anzahl der Fische ab 40 cm (4)'],
            example: 'Längen: [34, 52, 41, 28, 67, 45, 39]\nDurchschnitt: 43.714285714285715 cm\nLängster Fisch: 67 cm\nKürzester Fisch: 28 cm\nMindestens 40 cm: 4 Fische',
            starter: prog(R`
        int[] laengen = {34, 52, 41, 28, 67, 45, 39};
        // Deine Auswertung

`, AR),
            solution: prog(R`
        int[] laengen = {34, 52, 41, 28, 67, 45, 39};
        int summe = 0;
        int max = laengen[0];
        int min = laengen[0];
        int erlaubt = 0;
        for (int l : laengen) {
            summe += l;
            if (l > max) max = l;
            if (l < min) min = l;
            if (l >= 40) erlaubt++;
        }
        double schnitt = (double) summe / laengen.length;
        System.out.println("Längen: " + Arrays.toString(laengen));
        System.out.println("Durchschnitt: " + schnitt + " cm");
        System.out.println("Längster Fisch: " + max + " cm");
        System.out.println("Kürzester Fisch: " + min + " cm");
        System.out.println("Mindestens 40 cm: " + erlaubt + " Fische");`, AR),
            tests: [{ name: 'Auswertung stimmt', input: [], expect: [{ re: '43[.,]7', label: 'Durchschnitt ≈ 43.7' }, { has: '67', label: 'längster Fisch 67' }, { has: '28', label: 'kürzester Fisch 28' }, { re: '\\b4\\b[^\\n]*(fisch|stück)|(mindestens|ab|über)[^\\n]*\\b4\\b', label: '4 Fische ab 40 cm' }] }],
            codeChecks: [{ label: 'int-Array verwendet', re: 'int\\s*\\[\\s*\\]\\s*\\w+' }, { label: 'Schleife über das Array', re: 'for\\s*\\(' }],
            rubric: [['Programm kompiliert und läuft', 15], ['Array richtig angelegt und mit einer Schleife durchlaufen', 25], ['Durchschnitt als Kommazahl richtig', 20], ['Längster und kürzester Fisch richtig', 25], ['Zähler für Fische ab 40 cm richtig', 15]],
            tip: 'Starte Maximum und Minimum mit dem ersten Wert des Arrays (`laengen[0]`) – nicht mit 0, sonst wird das Minimum falsch.',
          },
        },
        { layout: 'code', console: 'clear', code: prog(R`
        int[] laengen = {34, 52, 41, 28, 67, 45, 39};
        int summe = 0;
        int max = laengen[0];
        int min = laengen[0];
        int erlaubt = 0;
        for (int l : laengen) {
            summe += l;
            if (l > max) max = l;
            if (l < min) min = l;
            if (l >= 40) erlaubt++;
        }
        double schnitt = (double) summe / laengen.length;
        System.out.println("Längen: " + Arrays.toString(laengen));
        System.out.println("Durchschnitt: " + schnitt + " cm");
        System.out.println("Längster Fisch: " + max + " cm");
        System.out.println("Kürzester Fisch: " + min + " cm");
        System.out.println("Mindestens 40 cm: " + erlaubt + " Fische");`, AR), run: true, hl: [10, 15], say: 'Abgegeben! So könnte es aussehen: eine einzige Schleife, die alles auf einmal erledigt – Summe, Maximum, Minimum und Zähler. Petri Heil!' },
      ],
    },
    {
      title: 'Sortieren & Suchen',
      steps: [
        { t: 'Kapitel 5', h: 'Sortieren & Suchen', sub: 'Ordnung ins Array bringen', after: 'code' },
        { layout: 'code', console: 'clear', code: prog(R`
        int[] punkte = {320, 870, 150, 990, 410};
        Arrays.sort(punkte);
        System.out.println(Arrays.toString(punkte));
        System.out.println("Höchster Wert: " + punkte[punkte.length - 1]);`, AR), hl: [4, 6], say: 'Mit `Arrays.sort` sortierst du ein Array mit einem einzigen Befehl – aufsteigend, vom kleinsten zum größten Wert. Danach steht das Maximum ganz hinten.' },
        { run: true, say: 'Sortiert! Und weil das Maximum jetzt am Ende steht, holen wir es mit `punkte[punkte.length - 1]`.' },
        { console: 'clear', code: prog(R`
        int[] punkte = {320, 870, 150, 990, 410};
        int gesucht = 410;
        int position = -1;
        for (int i = 0; i < punkte.length; i++) {
            if (punkte[i] == gesucht) {
                position = i;
                break;
            }
        }
        if (position >= 0) {
            System.out.println(gesucht + " gefunden an Index " + position);
        } else {
            System.out.println(gesucht + " nicht gefunden");
        }`), hl: [5, 11], say: 'Und so **suchst** du einen Wert: Geh das Array durch, bis du ihn findest. Mit `break` hörst du auf, sobald er gefunden ist. Bleibt die Position -1, war er nicht drin.' },
        { run: true, say: '410 steht an Index 4 – also im fünften Fach. Dieses Muster nennt man **lineare Suche**.' },
        { quiz: { id: 'l5-q3', q: 'Was steht nach `Arrays.sort` in `zahlen[0]`?', options: ['die größte Zahl', 'die kleinste Zahl', 'die erste Zahl von vorher', 'die Länge des Arrays'], correct: 1, explain: '`Arrays.sort` sortiert aufsteigend. Ganz vorne – bei Index 0 – steht danach die kleinste Zahl.' } },
      ],
    },
    {
      title: 'Aufgabe: Highscore-Liste',
      steps: [
        { t: 'Aufgabe 2', h: 'Highscore-Liste', sub: 'Arrays mit Eingabe', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Aufgabe 2: Highscore-Liste', items: ['Lies **5 Punktestände** mit dem Scanner in ein Array ein', 'Sortiere sie und gib sie aus', 'Gib den **Highscore** aus', 'Lies eine Zahl ein und sag, ob sie in der Liste vorkommt'], gap: 0.9 }, say: 'Letzte Aufgabe für heute: eine **Highscore-Liste**. Diesmal kommen die Werte vom Benutzer – du füllst das Array mit einer Schleife und dem Scanner.' },
        {
          task: {
            id: 'l5-highscore', nr: 2, title: 'Highscore-Liste',
            text: ['Lies fünf Punktestände (ganze Zahlen) mit dem Scanner ein und speichere sie in einem Array der Größe 5.', 'Sortiere das Array, gib es aus und nenne den Highscore (den größten Wert). Danach liest das Programm eine weitere Zahl ein und sagt, ob dieser Punktestand in der Liste vorkommt.'],
            req: ['Ein `int`-Array der Größe 5, befüllt mit einer Schleife und `nextInt()`', 'Sortieren mit `Arrays.sort`', 'Ausgabe der sortierten Liste und des Highscores', 'Eine Suche: „… ist in der Liste“ oder „… ist nicht in der Liste“'],
            example: 'Punkte 1: 320\nPunkte 2: 870\nPunkte 3: 150\nPunkte 4: 990\nPunkte 5: 410\nSortiert: [150, 320, 410, 870, 990]\nHighscore: 990\nWelchen Punktestand suchst du? 410\n410 ist in der Liste.',
            starter: prog(R`
        Scanner sc = new Scanner(System.in);
        int[] punkte = new int[5];
        // Werte einlesen, sortieren, Highscore, Suche

`, 'import java.util.Arrays;\nimport java.util.Scanner;\n\n'),
            solution: prog(R`
        Scanner sc = new Scanner(System.in);
        int[] punkte = new int[5];
        for (int i = 0; i < punkte.length; i++) {
            System.out.print("Punkte " + (i + 1) + ": ");
            punkte[i] = sc.nextInt();
        }
        Arrays.sort(punkte);
        System.out.println("Sortiert: " + Arrays.toString(punkte));
        System.out.println("Highscore: " + punkte[punkte.length - 1]);
        System.out.print("Welchen Punktestand suchst du? ");
        int gesucht = sc.nextInt();
        boolean gefunden = false;
        for (int p : punkte) {
            if (p == gesucht) {
                gefunden = true;
                break;
            }
        }
        if (gefunden) {
            System.out.println(gesucht + " ist in der Liste.");
        } else {
            System.out.println(gesucht + " ist nicht in der Liste.");
        }`, 'import java.util.Arrays;\nimport java.util.Scanner;\n\n'),
            tests: [
              { name: 'Wert vorhanden', input: ['320', '870', '150', '990', '410', '410'], expect: [{ re: '150\\D+320\\D+410\\D+870\\D+990', label: 'sortierte Liste' }, { re: 'highscore[^\\n]*990|990[^\\n]*highscore', label: 'Highscore 990' }, { re: '410[^\\n]*(ist in|gefunden|vorhanden|enthalten)', label: '410 wird gefunden' }] },
              { name: 'Wert fehlt', input: ['5', '3', '9', '1', '7', '4'], expect: [{ re: '1\\D+3\\D+5\\D+7\\D+9', label: 'sortierte Liste' }, { re: '4[^\\n]*(nicht)', label: '4 wird nicht gefunden' }] },
            ],
            codeChecks: [{ label: 'Arrays.sort verwendet', re: 'Arrays\\.sort\\s*\\(' }, { label: 'Array mit Größe 5', re: 'new\\s+int\\s*\\[\\s*5\\s*\\]' }],
            rubric: [['Programm kompiliert und läuft', 15], ['Array mit Schleife und Scanner befüllt', 25], ['Sortiert und Highscore richtig', 25], ['Suche liefert richtig „in der Liste“ / „nicht in der Liste“', 25], ['Verständliche Ausgabe', 10]],
            tip: 'Nach `Arrays.sort` steht der größte Wert bei `punkte[punkte.length - 1]`.',
          },
        },
        { layout: 'code', console: 'clear', code: prog(R`
        Scanner sc = new Scanner(System.in);
        int[] punkte = new int[5];
        for (int i = 0; i < punkte.length; i++) {
            System.out.print("Punkte " + (i + 1) + ": ");
            punkte[i] = sc.nextInt();
        }
        Arrays.sort(punkte);
        System.out.println("Sortiert: " + Arrays.toString(punkte));
        System.out.println("Highscore: " + punkte[punkte.length - 1]);
        System.out.print("Welchen Punktestand suchst du? ");
        int gesucht = sc.nextInt();
        boolean gefunden = false;
        for (int p : punkte) {
            if (p == gesucht) {
                gefunden = true;
                break;
            }
        }
        if (gefunden) {
            System.out.println(gesucht + " ist in der Liste.");
        } else {
            System.out.println(gesucht + " ist nicht in der Liste.");
        }`, 'import java.util.Arrays;\nimport java.util.Scanner;\n\n'), run: true, input: ['320', '870', '150', '990', '410', '410'], hl: [7, 11], say: 'Abgegeben! So könnte es aussehen: Eine Schleife füllt das Array, `Arrays.sort` sortiert, und eine zweite Schleife sucht den Wert.' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Das kannst du jetzt', items: ['Arrays anlegen: `{…}` oder `new int[5]`', 'Zugriff mit Index ab **0**, `length` für die Größe', 'Arrays mit `for` und for-each durchlaufen', 'Summe, Durchschnitt, Maximum und Minimum finden', '`Arrays.toString` für die Ausgabe'], gap: 0.7 }, say: 'Das war Lektion 5! Mit Arrays und Schleifen kannst du jetzt ganze Datenmengen auswerten. Als Nächstes lernst du, eigene **Methoden** zu schreiben.' },
      ],
    },
  ],
};
