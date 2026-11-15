// Lektion 6 – Methoden
const R = String.raw;
const cls = (members, mainBody, imports = '') => `${imports}public class Main {\n${members.replace(/^\n/, '').replace(/\n$/, '')}\n\n    public static void main(String[] args) {\n${mainBody.replace(/^\n/, '').replace(/\n$/, '')}\n    }\n}\n`;
const prog = (body, imports = '') => `${imports}public class Main {\n    public static void main(String[] args) {\n${body.replace(/^\n/, '').replace(/\n$/, '')}\n    }\n}\n`;

export default {
  id: 'java-06', nr: 6,
  title: 'Methoden',
  sub: 'Eigene Befehle schreiben: Code einmal schreiben, oft benutzen – mit Parametern und Rückgabewerten.',
  outro: 'Mit Methoden zerlegst du große Programme in kleine, verständliche Teile. Genau so arbeiten Profis – und genau so bauen wir später auch das Spiel. In Lektion 7 geht es um Texte im Detail.',
  chapters: [
    {
      title: 'Warum Methoden?',
      steps: [
        { t: 'Lektion 6', h: 'Methoden', sub: 'Deine eigenen Befehle', say: 'Servus! Bisher stand dein ganzer Code in der main-Methode. Bei großen Programmen wird das schnell unübersichtlich. Heute lernst du, eigene Befehle zu bauen: **Methoden**.' },
        { layout: 'code', console: 'clear', code: prog(R`
        System.out.println("==============");
        System.out.println("  LEVEL 1");
        System.out.println("==============");
        System.out.println("Los geht's!");
        System.out.println("==============");
        System.out.println("  LEVEL 2");
        System.out.println("==============");`), hl: [3, 9], say: 'Schau dir das an: Der Rahmen um die Überschrift steht immer wieder gleich im Code. Willst du ihn ändern, musst du jede Stelle einzeln anpassen. Das ist mühsam und fehleranfällig.' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Eine Methode ist ein eigener Befehl', items: ['Du schreibst den Code **einmal**', 'Du gibst ihm einen **Namen**', 'Du rufst ihn auf, **so oft du willst**', 'Ändern musst du ihn nur an **einer** Stelle'], gap: 0.9 }, say: 'Eine Methode ist ein Stück Code mit einem Namen. Du schreibst sie einmal und rufst sie dann so oft auf, wie du willst. `println` ist übrigens auch nur eine Methode – jemand anderes hat sie geschrieben.' },
      ],
    },
    {
      title: 'Die erste eigene Methode',
      steps: [
        { t: 'Kapitel 2', h: 'Die erste Methode', sub: 'void und der Aufruf', after: 'code' },
        { layout: 'code', console: 'clear', code: cls(R`
    static void trennlinie() {
        System.out.println("==============");
    }`, R`
        trennlinie();
        System.out.println("  LEVEL 1");
        trennlinie();`), hl: [2, 4], say: 'So sieht eine Methode aus: `static void`, dann der Name mit runden Klammern, und in geschweiften Klammern steht, was sie tun soll. Sie steht **in der Klasse**, aber **außerhalb** der main-Methode.' },
        { hl: [7, 9], say: 'In der main-Methode rufst du sie einfach mit ihrem Namen und Klammern auf: `trennlinie();`. Java springt dann in die Methode, führt sie aus und kommt wieder zurück.' },
        { run: true, say: 'Zweimal aufgerufen, zweimal ausgeführt. `void` heißt übrigens „leer“: Die Methode macht etwas, gibt aber nichts zurück. Was `static` bedeutet, lernst du in Lektion 8.' },
        { quiz: { id: 'l6-q1', q: 'Wo muss eine eigene Methode stehen?', options: ['In der main-Methode', 'In der Klasse, aber außerhalb von main', 'Außerhalb der Klasse', 'In einer eigenen Datei'], correct: 1, explain: 'Methoden stehen nebeneinander in der Klasse. Eine Methode in einer anderen Methode geht in Java nicht.' } },
      ],
    },
    {
      title: 'Parameter',
      steps: [
        { t: 'Kapitel 3', h: 'Parameter', sub: 'Methoden Werte mitgeben', after: 'code' },
        { layout: 'code', console: 'clear', code: cls(R`
    static void ueberschrift(String text) {
        System.out.println("==============");
        System.out.println("  " + text);
        System.out.println("==============");
    }`, R`
        ueberschrift("LEVEL 1");
        ueberschrift("BOSS-KAMPF");`), hl: [2, 2], say: 'Richtig praktisch wird es mit **Parametern**. In die runden Klammern schreibst du eine Variable: `String text`. Beim Aufruf gibst du einen Wert mit, und der landet in dieser Variable.' },
        { run: true, hl: [9, 10], say: 'Dieselbe Methode, zwei verschiedene Überschriften. Der Wert in den Klammern beim Aufruf heißt **Argument**, die Variable in der Methode heißt **Parameter**.' },
        { console: 'clear', code: cls(R`
    static void sterne(int anzahl, char zeichen) {
        for (int i = 0; i < anzahl; i++) {
            System.out.print(zeichen);
        }
        System.out.println();
    }`, R`
        sterne(5, '*');
        sterne(10, '#');
        sterne(3, '~');`), hl: [2, 2], say: 'Eine Methode kann auch mehrere Parameter haben, durch Beistriche getrennt. Beim Aufruf müssen Anzahl, Reihenfolge und Typen genau passen.' },
        { run: true, say: 'Fünf Sterne, zehn Rauten, drei Wellen. Mit Parametern wird eine Methode flexibel.' },
      ],
    },
    {
      title: 'Rückgabewerte',
      steps: [
        { t: 'Kapitel 4', h: 'return', sub: 'Methoden, die etwas zurückgeben', after: 'code' },
        { layout: 'code', console: 'clear', code: cls(R`
    static int quadrat(int zahl) {
        return zahl * zahl;
    }`, R`
        int a = quadrat(7);
        System.out.println(a);
        System.out.println(quadrat(3) + quadrat(4));`), hl: [2, 4], say: 'Manche Methoden sollen etwas **ausrechnen** und das Ergebnis zurückgeben. Statt `void` steht dann der Typ des Ergebnisses vorne – hier `int`. Mit `return` gibst du den Wert zurück.' },
        { run: true, hl: [7, 9], say: 'Der Aufruf `quadrat(7)` wird durch das Ergebnis 49 ersetzt. Deshalb kannst du ihn speichern oder direkt weiterrechnen: 9 plus 16 ergibt 25.' },
        { layout: 'split', visual: { kind: 'compare', left: { title: 'void – macht etwas', code: 'static void gruss(String n) {\n    System.out.println("Hi " + n);\n}', note: 'Aufruf als eigene Zeile' }, right: { title: 'mit Rückgabe – liefert etwas', code: 'static int doppelt(int x) {\n    return x * 2;\n}', note: 'Aufruf als Wert: `int y = doppelt(4);`', cls: 'good' } }, say: 'Merk dir den Unterschied: Eine `void`-Methode **macht** etwas, zum Beispiel ausgeben. Eine Methode mit Rückgabetyp **liefert** einen Wert, den du weiterverwenden kannst.' },
        { layout: 'code', console: 'clear', code: cls(R`
    static boolean istGerade(int zahl) {
        return zahl % 2 == 0;
    }

    static String bewertung(int punkte) {
        if (punkte >= 90) {
            return "Sehr gut";
        } else if (punkte >= 50) {
            return "Bestanden";
        }
        return "Nicht bestanden";
    }`, R`
        System.out.println(istGerade(10));
        System.out.println(bewertung(95));
        System.out.println(bewertung(42));`), hl: [6, 13], say: 'Rückgabewerte können jeden Typ haben: `boolean`, `String`, `double`… Und `return` beendet die Methode sofort – deshalb braucht die letzte Zeile kein else.' },
        { run: true, say: 'true, „Sehr gut“ und „Nicht bestanden“. Wichtig: Jeder mögliche Weg durch die Methode muss mit einem `return` enden, sonst meckert der Compiler.' },
        { quiz: { id: 'l6-q2', q: 'Was gibt `System.out.println(doppelt(doppelt(3)));` aus, wenn `doppelt` den Wert mal 2 zurückgibt?', options: ['6', '12', '9', 'Fehler'], correct: 1, explain: 'Von innen nach außen: `doppelt(3)` ist 6, und `doppelt(6)` ist 12.' } },
      ],
    },
    {
      title: 'Aufgabe: Mini-Rechner',
      steps: [
        { t: 'Aufgabe 1', h: 'Mini-Rechner', sub: 'Jetzt bist du dran!', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Aufgabe 1: Mini-Rechner mit Methoden', items: ['Schreib Methoden `plus`, `minus`, `mal` und `geteilt`', 'Jede bekommt zwei `double`-Zahlen und gibt das Ergebnis zurück', '`geteilt` gibt bei 0 eine Fehlermeldung aus', 'Die main-Methode testet alle vier'], gap: 0.9 }, say: 'Jetzt bist du dran: Bau einen Mini-Rechner, bei dem jede Rechenart eine eigene Methode ist.' },
        {
          task: {
            id: 'l6-rechner', nr: 1, title: 'Mini-Rechner mit Methoden',
            text: ['Schreib vier Methoden `plus`, `minus`, `mal` und `geteilt`. Jede bekommt zwei `double`-Zahlen und gibt das Ergebnis als `double` zurück.', 'Bei `geteilt` durch 0 soll die Methode „Teilen durch 0 geht nicht!“ ausgeben und 0 zurückgeben. In main rufst du alle vier mit den Zahlen 12 und 4 auf und gibst die Ergebnisse aus – und einmal `geteilt(5, 0)`.'],
            req: ['Vier Methoden mit Rückgabetyp `double` und zwei `double`-Parametern', '`return` in jeder Methode', 'Sonderfall „durch 0“ in `geteilt`', 'Ausgabe der Ergebnisse für 12 und 4 (16, 8, 48, 3)'],
            example: '12 + 4 = 16.0\n12 - 4 = 8.0\n12 * 4 = 48.0\n12 / 4 = 3.0\nTeilen durch 0 geht nicht!\n5 / 0 = 0.0',
            starter: cls(R`
    // Schreib hier deine vier Methoden
`, R`
        // Teste sie hier
`),
            solution: cls(R`
    static double plus(double a, double b) {
        return a + b;
    }

    static double minus(double a, double b) {
        return a - b;
    }

    static double mal(double a, double b) {
        return a * b;
    }

    static double geteilt(double a, double b) {
        if (b == 0) {
            System.out.println("Teilen durch 0 geht nicht!");
            return 0;
        }
        return a / b;
    }`, R`
        System.out.println("12 + 4 = " + plus(12, 4));
        System.out.println("12 - 4 = " + minus(12, 4));
        System.out.println("12 * 4 = " + mal(12, 4));
        System.out.println("12 / 4 = " + geteilt(12, 4));
        System.out.println("5 / 0 = " + geteilt(5, 0));`),
            tests: [{ name: 'Rechner', input: [], expect: [{ re: '\\b16(\\.0)?\\b', label: '12 + 4 = 16' }, { re: '\\b8(\\.0)?\\b', label: '12 − 4 = 8' }, { re: '\\b48(\\.0)?\\b', label: '12 · 4 = 48' }, { re: '\\b3(\\.0)?\\b', label: '12 / 4 = 3' }, { re: 'durch 0|null', label: 'Meldung bei Division durch 0' }] }],
            codeChecks: [
              { label: 'Methode plus', re: 'static\\s+double\\s+plus\\s*\\(\\s*double' }, { label: 'Methode minus', re: 'static\\s+double\\s+minus\\s*\\(' },
              { label: 'Methode mal', re: 'static\\s+double\\s+mal\\s*\\(' }, { label: 'Methode geteilt', re: 'static\\s+double\\s+geteilt\\s*\\(' }, { label: 'return verwendet', re: '\\breturn\\b' },
            ],
            rubric: [['Programm kompiliert und läuft', 15], ['Vier Methoden mit passenden Parametern und Rückgabetyp', 35], ['Richtige Ergebnisse', 25], ['Division durch 0 abgefangen', 15], ['Aufrufe und Ausgabe in main', 10]],
            tip: 'Schreib zuerst nur `plus` und teste es. Die anderen drei sind dann fast Kopien davon.',
          },
        },
        { layout: 'code', console: 'clear', code: cls(R`
    static double plus(double a, double b) {
        return a + b;
    }

    static double geteilt(double a, double b) {
        if (b == 0) {
            System.out.println("Teilen durch 0 geht nicht!");
            return 0;
        }
        return a / b;
    }`, R`
        System.out.println("12 + 4 = " + plus(12, 4));
        System.out.println("12 / 4 = " + geteilt(12, 4));
        System.out.println("5 / 0 = " + geteilt(5, 0));`), run: true, hl: [6, 12], say: 'Abgegeben! Hier ein Ausschnitt aus einer Lösung. Bei `geteilt` sieht man schön: Ein früher `return` beendet die Methode sofort, wenn etwas nicht passt.' },
      ],
    },
    {
      title: 'Sichtbarkeit & Arrays als Parameter',
      steps: [
        { t: 'Kapitel 6', h: 'Wo gilt eine Variable?', sub: 'Sichtbarkeit und Arrays übergeben', after: 'code' },
        { layout: 'code', console: 'clear', code: cls(R`
    static void zeige() {
        int x = 5;
        System.out.println("In der Methode: " + x);
    }`, R`
        int x = 99;
        zeige();
        System.out.println("In main: " + x);`), hl: [3, 3], say: 'Wichtig: Jede Methode hat ihre eigenen Variablen. Das `x` in `zeige` und das `x` in `main` sind zwei völlig verschiedene Boxen, die zufällig gleich heißen.' },
        { run: true, say: 'Die Methode sieht nur ihr eigenes `x`. Das `x` in main bleibt 99. Willst du einer Methode einen Wert geben, nimm Parameter – willst du etwas zurückbekommen, nimm `return`.' },
        { console: 'clear', code: cls(R`
    static double schnitt(int[] werte) {
        int summe = 0;
        for (int w : werte) {
            summe += w;
        }
        return (double) summe / werte.length;
    }`, R`
        int[] noten = {2, 1, 3, 1};
        int[] punkte = {80, 95, 70};
        System.out.println(schnitt(noten));
        System.out.println(schnitt(punkte));`), hl: [2, 2], say: 'Auch Arrays kannst du an Methoden übergeben. Diese Methode berechnet den Durchschnitt von **jedem** int-Array – egal wie lang.' },
        { run: true, say: 'Einmal geschrieben, für beliebig viele Arrays benutzt. So baust du dir deine eigene kleine Werkzeugkiste.' },
        { quiz: { id: 'l6-q3', q: 'Eine Methode ändert ihren Parameter `zahl = 0;`. Was passiert mit der Variable, die beim Aufruf übergeben wurde (ein int)?', options: ['Sie wird auch 0', 'Nichts – sie behält ihren Wert', 'Es gibt einen Fehler', 'Sie wird gelöscht'], correct: 1, explain: 'Bei int, double, boolean usw. bekommt die Methode eine Kopie des Werts. Änderungen an der Kopie wirken sich draußen nicht aus.' } },
      ],
    },
    {
      title: 'Aufgabe: Noten-Werkzeuge',
      steps: [
        { t: 'Aufgabe 2', h: 'Noten-Werkzeuge', sub: 'Methoden mit Arrays', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Aufgabe 2: Noten-Werkzeuge', items: ['`double durchschnitt(int[] noten)`', '`int beste(int[] noten)` – die kleinste Zahl', '`String wort(int note)` – 1 → „Sehr gut“ … 5 → „Nicht genügend“', 'main testet alles mit einem Beispiel-Array'], gap: 0.9 }, say: 'Zweite Aufgabe: Bau drei Methoden, die mit Schulnoten arbeiten. Jede erledigt genau eine Sache.' },
        {
          task: {
            id: 'l6-noten', nr: 2, title: 'Noten-Werkzeuge',
            text: ['Schreib drei Methoden für österreichische Schulnoten (1 bis 5): `durchschnitt` gibt den Schnitt eines int-Arrays als double zurück, `beste` gibt die beste (kleinste) Note zurück, und `wort` gibt zu einer Note das Wort zurück (1 → „Sehr gut“, 2 → „Gut“, 3 → „Befriedigend“, 4 → „Genügend“, 5 → „Nicht genügend“).', 'Teste sie in main mit dem Array `{2, 1, 3, 2, 4}`.'],
            req: ['Methode `durchschnitt(int[])` mit Rückgabe `double` (für das Beispiel 2.4)', 'Methode `beste(int[])` mit Rückgabe `int` (für das Beispiel 1)', 'Methode `wort(int)` mit Rückgabe `String`', 'Ausgabe in main, z. B. „Beste Note: 1 (Sehr gut)“'],
            example: 'Durchschnitt: 2.4\nBeste Note: 1 (Sehr gut)',
            starter: cls(R`
    // Deine drei Methoden
`, R`
        int[] noten = {2, 1, 3, 2, 4};
        // Methoden aufrufen und ausgeben
`),
            solution: cls(R`
    static double durchschnitt(int[] noten) {
        int summe = 0;
        for (int n : noten) {
            summe += n;
        }
        return (double) summe / noten.length;
    }

    static int beste(int[] noten) {
        int best = noten[0];
        for (int n : noten) {
            if (n < best) {
                best = n;
            }
        }
        return best;
    }

    static String wort(int note) {
        if (note == 1) return "Sehr gut";
        if (note == 2) return "Gut";
        if (note == 3) return "Befriedigend";
        if (note == 4) return "Genügend";
        return "Nicht genügend";
    }`, R`
        int[] noten = {2, 1, 3, 2, 4};
        System.out.println("Durchschnitt: " + durchschnitt(noten));
        System.out.println("Beste Note: " + beste(noten) + " (" + wort(beste(noten)) + ")");`),
            tests: [{ name: 'Beispiel-Array', input: [], expect: [{ re: '2[.,]4', label: 'Durchschnitt 2.4' }, { re: '\\b1\\b', label: 'beste Note 1' }, { re: 'sehr gut', label: 'Wort „Sehr gut“' }] }],
            codeChecks: [
              { label: 'Methode durchschnitt(int[])', re: 'double\\s+durchschnitt\\s*\\(\\s*int\\s*\\[\\s*\\]' }, { label: 'Methode beste(int[])', re: 'int\\s+beste\\s*\\(\\s*int\\s*\\[\\s*\\]' },
              { label: 'Methode wort(int)', re: 'String\\s+wort\\s*\\(\\s*int' }, { label: 'Genügend und Nicht genügend vorhanden', re: 'Genügend[\\s\\S]*Nicht genügend|Nicht genügend[\\s\\S]*Genügend' },
            ],
            rubric: [['Programm kompiliert und läuft', 15], ['durchschnitt richtig (double, keine Ganzzahl-Falle)', 25], ['beste richtig (kleinste Zahl)', 25], ['wort für alle fünf Noten richtig', 20], ['Sinnvolle Tests in main', 15]],
            tip: 'Die Methoden kennen das Array aus main nicht – sie bekommen es als Parameter. Benutze darin also den Parameternamen.',
          },
        },
        { layout: 'code', console: 'clear', code: cls(R`
    static int beste(int[] noten) {
        int best = noten[0];
        for (int n : noten) {
            if (n < best) {
                best = n;
            }
        }
        return best;
    }`, R`
        int[] noten = {2, 1, 3, 2, 4};
        System.out.println("Beste Note: " + beste(noten));`), run: true, say: 'Abgegeben! So kann `beste` aussehen: dasselbe Minimum-Muster wie in Lektion 5 – nur jetzt sauber verpackt in einer wiederverwendbaren Methode.' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Das kannst du jetzt', items: ['Eigene Methoden mit `static void` schreiben', 'Werte mit **Parametern** übergeben', 'Ergebnisse mit `return` zurückgeben', 'Arrays an Methoden übergeben', 'Wissen, dass jede Methode ihre eigenen Variablen hat'], gap: 0.7 }, say: 'Das war Lektion 6! Ab jetzt kannst du große Programme in kleine Teile zerlegen. In Lektion 7 schauen wir uns Texte genauer an.' },
      ],
    },
  ],
};
