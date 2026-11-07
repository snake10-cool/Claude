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
        { layout: 'visual', visual: { kind: 'bullets', title: 'Das kannst du jetzt', items: ['Arrays anlegen: `{…}` oder `new int[5]`', 'Zugriff mit Index ab **0**, `length` für die Größe', 'Arrays mit `for` und for-each durchlaufen', 'Summe, Durchschnitt, Maximum und Minimum finden', '`Arrays.toString` für die Ausgabe'], gap: 0.7 }, say: 'Das war Lektion 5! Mit Arrays und Schleifen kannst du jetzt ganze Datenmengen auswerten. Als Nächstes lernst du, eigene **Methoden** zu schreiben.' },
      ],
    },
  ],
};
