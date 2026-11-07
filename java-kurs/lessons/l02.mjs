// Lektion 2 – Variablen & Datentypen
const R = String.raw;
const main = (body) => `public class Main {\n    public static void main(String[] args) {\n${body.replace(/^\n/, '').replace(/\n$/, '')}\n    }\n}\n`;

export default {
  id: 'java-02', nr: 2,
  title: 'Variablen & Datentypen',
  sub: 'Wie sich dein Programm Dinge merkt, rechnet und Text mit Zahlen verbindet.',
  outro: 'Du kennst jetzt Variablen, die wichtigsten Datentypen und die Rechenzeichen – inklusive der Falle bei der Ganzzahl-Division. In Lektion 3 lernst du Eingaben und Entscheidungen mit if und else.',
  playground: main(R`
        int punkte = 10;
        double preis = 4.99;
        String name = "Lena";
        System.out.println(name + " hat " + punkte + " Punkte.");`),
  chapters: [
    {
      title: 'Warum Variablen?',
      steps: [
        { t: 'Lektion 2', h: 'Variablen & Datentypen', sub: 'Wie sich dein Programm Dinge merkt', say: 'Servus und willkommen zurück! In Lektion 1 hat dein Programm nur fixen Text ausgegeben. Heute lernst du, wie es sich Dinge merken und damit rechnen kann.' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Ein Programm muss sich vieles merken', items: ['deinen **Namen** im Spiel', 'deine **Punkte** und **Leben**', 'den **Preis** von etwas im Shop', 'ob du schon **eingeloggt** bist'], gap: 0.9 }, say: 'Fast jedes Programm muss sich etwas merken: deinen Namen, deine Punkte, einen Preis oder ob du eingeloggt bist. Dafür gibt es **Variablen**.' },
        { visual: { kind: 'boxes', title: 'Eine Variable ist wie eine beschriftete Box', vars: [{ type: 'int', name: 'punkte', value: '120' }, { type: 'String', name: 'spieler', value: '"Lena"', cls: 'str' }, { type: 'boolean', name: 'eingeloggt', value: 'true', cls: 'bool' }], gap: 0.9, note: 'Jede Box hat einen **Namen**, einen **Typ** und einen **Wert**.', noteAt: 3.2 }, say: 'Stell dir eine Variable wie eine beschriftete Box vor. Außen steht der **Name**, drinnen liegt der **Wert**. Und der **Typ** sagt, was überhaupt hineinpassen darf.' },
      ],
    },
    {
      title: 'Variablen anlegen',
      steps: [
        { t: 'Kapitel 2', h: 'Variablen anlegen', sub: 'Deklarieren und zuweisen', after: 'split' },
        { layout: 'split', visual: { kind: 'boxes', vars: [{ type: 'int', name: 'punkte', value: '?' }], start: 0.4 }, code: main(R`
        int punkte;`), hl: [3, 3], say: 'So legst du eine Variable an: zuerst der **Typ**, dann der **Name**, dann ein Strichpunkt. Das nennt man **Deklarieren**. `int` steht für ganze Zahlen.' },
        { visual: { kind: 'boxes', vars: [{ type: 'int', name: 'punkte', value: '10' }], start: 0.4 }, code: main(R`
        int punkte;
        punkte = 10;`), hl: [4, 4], say: 'Mit dem Gleichheitszeichen legst du einen Wert in die Box. Das heißt **Zuweisen**. Jetzt steckt die Zahl 10 in der Variable `punkte`.' },
        { visual: { kind: 'boxes', vars: [{ type: 'int', name: 'punkte', value: '10', s: 0 }, { type: 'int', name: 'leben', value: '3' }], start: 0.6 }, code: main(R`
        int punkte;
        punkte = 10;
        int leben = 3;`), hl: [5, 5], say: 'Meistens macht man beides in einer Zeile: deklarieren und gleich einen Startwert zuweisen. `int leben = 3;` – fertig.' },
        { layout: 'code', console: 'clear', code: main(R`
        int punkte;
        punkte = 10;
        int leben = 3;
        System.out.println(punkte);
        System.out.println("punkte");
        System.out.println("Leben: " + leben);`), hl: [6, 8], say: 'Jetzt geben wir die Werte aus. Achtung, Unterschied: Ohne Anführungszeichen meint Java die **Variable**. Mit Anführungszeichen ist es nur ein Text.' },
        { run: true, say: 'Siehst du? `punkte` ohne Anführungszeichen ergibt 10. Mit Anführungszeichen kommt einfach das Wort „punkte“ heraus. Und mit `+` hängst du den Wert an einen Text.' },
        { quiz: { id: 'l2-q1', q: 'Was gibt dieser Code aus?\n`int x = 5;`\n`System.out.println("x");`', options: ['5', 'x', 'einen Fehler'], correct: 1, explain: 'Mit Anführungszeichen ist es ein Text – also wird einfach der Buchstabe x ausgegeben. Für den Wert müsste es `println(x)` heißen.' } },
      ],
    },
    {
      title: 'Datentypen',
      steps: [
        { t: 'Kapitel 3', h: 'Die wichtigsten Datentypen', sub: 'Welche Box für welchen Wert?', after: 'visual' },
        { layout: 'visual', visual: { kind: 'table', title: 'Die fünf wichtigsten Typen', head: ['Typ', 'Was passt hinein?', 'Beispiel'], rows: [['`int`', 'ganze Zahlen', '`42`, `-7`, `0`'], ['`double`', 'Kommazahlen (mit Punkt!)', '`3.14`, `-0.5`'], ['`boolean`', 'wahr oder falsch', '`true`, `false`'], ['`char`', 'ein einzelnes Zeichen', "`'A'`, `'?'`"], ['`String`', 'Text (beliebig lang)', '`"Hallo"`']], gap: 0.8 }, say: 'Für jede Art von Wert gibt es einen passenden Typ. Diese fünf brauchst du am Anfang fast immer.' },
        { layout: 'code', console: 'clear', code: main(R`
        int alter = 14;
        double groesse = 1.68;
        boolean hatHaustier = true;
        char note = 'A';
        String name = "Lena";
        System.out.println(name + " ist " + alter + " Jahre alt.");
        System.out.println("Größe: " + groesse + " m");
        System.out.println("Haustier? " + hatHaustier + ", Lieblingsbuchstabe: " + note);`), hl: [3, 7], say: 'Hier sind alle fünf in Aktion. Schau dir genau an, wie die Werte geschrieben werden.' },
        { hl: [7, 7], say: 'Zwei Dinge sind wichtig: `String` wird **großgeschrieben**, weil es eine Klasse ist. Und ein `char` steht in **einfachen** Anführungszeichen, ein String in doppelten.' },
        { run: true, say: 'Alle Werte landen sauber in der Ausgabe – egal ob Zahl, Text oder true und false.' },
        { console: 'clear', code: main(R`
        double preis = 2,50;
        System.out.println(preis);`), hl: [3, 3], say: 'Achtung, Österreich-Falle! Bei uns schreibt man Kommazahlen mit Beistrich. Java versteht aber nur den **Punkt** – 2,50 geht schief.' },
        { run: true, expectError: true, say: 'Der Compiler meckert, weil er das Komma nicht versteht. Richtig wäre `2.50` – mit Punkt.' },
        { console: 'clear', code: main(R`
        double preis = 2.50;
        System.out.println(preis);`), run: true, say: 'Mit Punkt klappt es. Übrigens zeigt Java `2.5` an – die Null am Ende lässt es einfach weg.' },
        { quiz: { id: 'l2-q2', q: 'Welcher Typ passt für den Wert 3.75?', options: ['`int`', '`double`', '`char`', '`boolean`'], correct: 1, explain: '3.75 hat Nachkommastellen, also braucht es `double`. In ein `int` passen nur ganze Zahlen.' } },
      ],
    },
    {
      title: 'Werte ändern',
      steps: [
        { t: 'Kapitel 4', h: 'Werte ändern', sub: 'Variablen heißen so, weil sie variabel sind', after: 'split' },
        { layout: 'split', console: 'clear', visual: { kind: 'boxes', vars: [{ type: 'int', name: 'punkte', value: '10' }], start: 0.3 }, code: main(R`
        int punkte = 10;
        punkte = 25;`), hl: [4, 4], say: 'Der Wert einer Variable kann sich jederzeit ändern. Weist du einen neuen Wert zu, wird der alte einfach überschrieben.' },
        { visual: { kind: 'boxes', vars: [{ type: 'int', name: 'punkte', value: '25' }], start: 0.3 }, say: 'Jetzt steckt 25 in der Box. Die 10 ist weg – eine Variable kann sich immer nur **einen** Wert merken.' },
        { visual: { kind: 'boxes', vars: [{ type: 'int', name: 'punkte', value: '30' }], start: 1.5, note: 'Rechts ausrechnen (25 + 5 = 30), dann links speichern.', noteAt: 2.5 }, code: main(R`
        int punkte = 10;
        punkte = 25;
        punkte = punkte + 5;`), hl: [5, 5], say: 'Und das hier? `punkte = punkte + 5;` Mathematisch ist das Unsinn – aber in Java heißt `=` nicht „ist gleich“, sondern „**speichere**“: Erst wird rechts gerechnet, dann links gespeichert.' },
        { layout: 'code', code: main(R`
        int punkte = 10;
        punkte = 25;
        punkte = punkte + 5;
        punkte += 5;     // Kurzform für: punkte = punkte + 5
        punkte++;        // erhöht um genau 1
        punkte--;        // verringert um genau 1
        System.out.println("Punkte: " + punkte);`), hl: [6, 8], say: 'Weil man das ständig braucht, gibt es Kurzformen: `+=` addiert etwas dazu, `++` zählt um eins hoch, `--` zählt um eins herunter.' },
        { run: true, say: 'Rechnen wir mit: 25 plus 5 ist 30, plus 5 ist 35, plus 1 ist 36, minus 1 ist wieder 35.' },
      ],
    },
    {
      title: 'Rechnen mit Java',
      steps: [
        { t: 'Kapitel 5', h: 'Rechnen mit Java', sub: '+ − * / und das geheimnisvolle %', after: 'split' },
        { layout: 'split', console: 'clear', visual: { kind: 'table', title: 'Rechenzeichen', head: ['Zeichen', 'Bedeutung', 'Beispiel'], rows: [['`+`', 'plus', '`7 + 2` → 9'], ['`-`', 'minus', '`7 - 2` → 5'], ['`*`', 'mal', '`7 * 2` → 14'], ['`/`', 'geteilt', '`7 / 2` → **3** (!)'], ['`%`', 'Rest der Division', '`7 % 2` → 1']], gap: 0.7 }, code: main(R`
        int a = 7;
        int b = 2;
        System.out.println(a + b);
        System.out.println(a - b);
        System.out.println(a * b);
        System.out.println(a / b);
        System.out.println(a % b);`), hl: [5, 9], say: 'Java rechnet mit den bekannten Zeichen. Mal ist ein Stern, geteilt ein Schrägstrich. Und dann gibt es noch das Prozentzeichen – dazu gleich mehr.' },
        { layout: 'all', run: true, hl: [8, 8], say: 'Moment – 7 geteilt durch 2 ergibt 3? Das ist die berühmteste Falle in Java: Teilst du zwei `int`-Werte, kommt wieder ein `int` heraus. Die Nachkommastellen werden einfach **abgeschnitten**.' },
        { hl: [9, 9], say: 'Und `%` heißt **Modulo**: Es gibt den Rest der Division. 7 durch 2 ist 3, Rest 1. Damit prüft man zum Beispiel, ob eine Zahl gerade ist: Dann ist der Rest 0.' },
        { layout: 'code', console: 'clear', code: main(R`
        int a = 7;
        int b = 2;
        System.out.println(a / b);         // 3 (int geteilt durch int)
        System.out.println(a / 2.0);       // 3.5 (eine Kommazahl ist dabei)
        System.out.println((double) a / b); // 3.5 (umgewandelt)
        System.out.println((int) 9.99);     // 9 (abgeschnitten, nicht gerundet!)`), hl: [6, 7], say: 'Willst du das genaue Ergebnis, muss mindestens eine Kommazahl dabei sein: zum Beispiel `2.0` statt `2`, oder du wandelst mit `(double)` um.' },
        { run: true, hl: [8, 8], say: 'Umgekehrt macht `(int)` aus einer Kommazahl eine ganze Zahl. Achtung: Es wird nicht gerundet, sondern abgeschnitten. Aus 9.99 wird 9.' },
        { quiz: { id: 'l2-q3', q: 'Was ergibt `17 / 5` in Java (beides int)?', options: ['3.4', '3', '4', '2'], correct: 1, explain: '17 geteilt durch 5 ist 3,4 – aber bei int wird der Kommateil abgeschnitten. Übrig bleibt 3. (Und `17 % 5` wäre der Rest: 2.)' } },
      ],
    },
    {
      title: 'Text und Zahlen verbinden',
      steps: [
        { t: 'Kapitel 6', h: 'Text + Zahlen', sub: 'Die Plus-Falle', after: 'code' },
        { layout: 'code', console: 'clear', code: main(R`
        String name = "Max";
        int punkte = 42;
        System.out.println(name + " hat " + punkte + " Punkte");
        System.out.println("Summe: " + 2 + 3);
        System.out.println("Summe: " + (2 + 3));
        System.out.println(2 + 3 + " ist die Summe");`), hl: [5, 5], say: 'Mit `+` verbindest du Text mit Variablen. Das kennst du schon. Aber Vorsicht – schau dir die nächsten Zeilen genau an.' },
        { run: true, hl: [6, 8], say: '„Summe: 23“? Java liest von links nach rechts: Zuerst wird „Summe: “ mit 2 verbunden – ab da ist alles Text, und die 3 wird nur angehängt. Mit **Klammern** wird zuerst gerechnet.' },
        { hl: [8, 8], say: 'In der letzten Zeile stehen die Zahlen ganz vorne. Da rechnet Java zuerst 2 plus 3, und erst dann kommt der Text dazu. Reihenfolge ist alles!' },
        { quiz: { id: 'l2-q4', q: 'Was gibt `System.out.println("Ergebnis: " + 4 * 2);` aus?', options: ['Ergebnis: 42', 'Ergebnis: 8', 'Ergebnis: 4 * 2'], correct: 1, explain: 'Punkt vor Strich gilt auch hier: `4 * 2` wird zuerst ausgerechnet, erst dann wird die 8 an den Text gehängt.' } },
      ],
    },
    {
      title: 'Aufgabe: Taschengeld-Rechner',
      steps: [
        { t: 'Aufgabe 1', h: 'Taschengeld-Rechner', sub: 'Jetzt bist du dran!', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Aufgabe 1: Taschengeld-Rechner', items: ['Speichere Name, Taschengeld pro Woche und Anzahl Wochen in **Variablen**', 'Rechne aus, wie viel Geld insgesamt zusammenkommt', 'Ziehe den Preis von etwas ab, das du kaufen willst', 'Gib alles schön mit Text aus'], gap: 0.9 }, say: 'Jetzt bist du dran: Bau einen kleinen **Taschengeld-Rechner**. Denk an die passenden Typen – Geldbeträge haben Nachkommastellen!' },
        {
          task: {
            id: 'l2-taschengeld', nr: 1, title: 'Taschengeld-Rechner',
            text: ['Schreib ein Programm, das ausrechnet, wie viel Taschengeld nach einigen Wochen zusammenkommt – und wie viel übrig bleibt, wenn du dir etwas kaufst (z. B. ein Spiel).', 'Die Werte schreibst du direkt in den Code (Eingaben lernst du in Lektion 3).'],
            req: ['Eine `String`-Variable für den Namen', 'Eine `double`-Variable für das Taschengeld pro Woche (z. B. 7.50)', 'Eine `int`-Variable für die Anzahl der Wochen', 'Eine Rechnung mit `*` für das Gesamtgeld und eine mit `-` für den Rest nach dem Kauf', 'Ausgabe mit Text und Variablen, verbunden mit `+`'],
            example: 'Lena spart 6 Wochen lang 7.5 Euro.\nInsgesamt: 45.0 Euro\nNach dem Kauf von "Minecraft" (29.99 Euro) bleiben 15.01 Euro.',
            starter: main(R`
        String name = "Lena";
        // Lege hier deine weiteren Variablen an

`),
            solution: main(R`
        String name = "Lena";
        double proWoche = 7.50;
        int wochen = 6;
        double gesamt = proWoche * wochen;
        String spiel = "Minecraft";
        double preis = 29.99;
        double rest = gesamt - preis;
        System.out.println(name + " spart " + wochen + " Wochen lang " + proWoche + " Euro.");
        System.out.println("Insgesamt: " + gesamt + " Euro");
        System.out.println("Nach dem Kauf von \"" + spiel + "\" (" + preis + " Euro) bleiben " + rest + " Euro.");`),
            tests: [{ name: 'Programm läuft und gibt Beträge aus', input: [], expect: [{ re: '\\d', label: 'Zahlen in der Ausgabe' }, { re: '(.+\\n){2,}', label: 'mindestens 2 Zeilen Ausgabe' }] }],
            codeChecks: [
              { label: 'String-Variable', re: '\\bString\\s+\\w+\\s*=' },
              { label: 'double-Variable', re: '\\bdouble\\s+\\w+\\s*=' },
              { label: 'int-Variable', re: '\\bint\\s+\\w+\\s*=' },
              { label: 'Multiplikation mit *', re: '\\w\\s*\\*\\s*\\w' },
              { label: 'Subtraktion mit -', re: '\\w\\s*-\\s*\\w' },
            ],
            rubric: [['Programm kompiliert und läuft', 25], ['Passende Datentypen (String, double, int)', 25], ['Richtige Rechnungen für Gesamtgeld und Rest', 30], ['Verständliche Ausgabe mit Text und Variablen', 20]],
            tip: 'Wenn bei Geldbeträgen komische Zahlen wie 15.010000000000002 herauskommen, ist das normal bei double – in Lektion 3 lernst du printf, damit sieht es schöner aus.',
          },
        },
        { layout: 'code', console: 'clear', code: main(R`
        String name = "Lena";
        double proWoche = 7.50;
        int wochen = 6;
        double gesamt = proWoche * wochen;
        String spiel = "Minecraft";
        double preis = 29.99;
        double rest = gesamt - preis;
        System.out.println(name + " spart " + wochen + " Wochen lang " + proWoche + " Euro.");
        System.out.println("Insgesamt: " + gesamt + " Euro");
        System.out.println("Nach dem Kauf von \"" + spiel + "\" (" + preis + " Euro) bleiben " + rest + " Euro.");`), hl: [4, 9], say: 'Abgegeben! Hier eine mögliche Lösung. Jede Zahl hat ihre eigene Variable mit einem gut lesbaren Namen.' },
        { run: true, say: 'Schau dir den Rest an: 15.010000000000002! Kommazahlen sind im Computer nicht ganz exakt gespeichert. Wie man das schön rundet, lernst du in der nächsten Lektion.' },
      ],
    },
    {
      title: 'Namen & Konstanten',
      steps: [
        { t: 'Kapitel 8', h: 'Gute Namen & Konstanten', sub: 'Regeln, die Profis einhalten', after: 'visual' },
        { layout: 'visual', visual: { kind: 'table', title: 'Erlaubt oder nicht?', head: ['Name', 'Okay?', 'Warum'], rows: [['`punkte`', '✅', 'klein, sprechend'], ['`anzahlLeben`', '✅', 'camelCase: neue Wörter groß'], ['`2spieler`', '❌', 'darf nicht mit Ziffer anfangen'], ['`mein name`', '❌', 'keine Leerzeichen'], ['`class`', '❌', 'reserviertes Java-Wort'], ['`x`', '⚠️', 'erlaubt, aber nichtssagend']], gap: 0.7 }, say: 'Variablennamen haben Regeln: keine Leerzeichen, nicht mit einer Ziffer anfangen und keine Java-Wörter wie `class`. Profis schreiben im **camelCase**: klein anfangen, jedes neue Wort groß.' },
        { layout: 'code', console: 'clear', code: main(R`
        final double MWST = 0.20;   // Mehrwertsteuer in Österreich
        double netto = 50.0;
        double brutto = netto + netto * MWST;
        System.out.println("Brutto: " + brutto + " Euro");`), hl: [3, 3], say: 'Und wenn sich ein Wert nie ändern darf? Dann schreibst du `final` davor. Das ist eine **Konstante**. Die schreibt man üblicherweise in GROSSBUCHSTABEN.' },
        { run: true, say: '50 Euro netto plus 20 Prozent Steuer ergeben 60 Euro. Würde jemand später `MWST = 0.5;` schreiben, meldet Java sofort einen Fehler.' },
        { quiz: { id: 'l2-q5', q: 'Welcher Variablenname ist erlaubt UND gut gewählt?', options: ['`Anzahl Fische`', '`3fische`', '`anzahlFische`', '`int`'], correct: 2, explain: '`anzahlFische` ist camelCase, beginnt mit einem Buchstaben, hat keine Leerzeichen und ist kein Java-Wort.' } },
      ],
    },
    {
      title: 'Aufgabe: Angel-Statistik',
      steps: [
        { t: 'Aufgabe 2', h: 'Angel-Statistik', sub: 'Rechnen mit / und %', after: 'visual' },
        { layout: 'visual', visual: { kind: 'boxes', title: 'Dein Fang heute', vars: [{ type: 'int', name: 'hecht', value: '2350' }, { type: 'int', name: 'zander', value: '1780' }, { type: 'int', name: 'forelle', value: '640' }], gap: 0.8, note: 'Gewichte in **Gramm**', noteAt: 2.6 }, say: 'Letzte Aufgabe! Du warst angeln und hast drei Fische gefangen. Die Gewichte sind in Gramm gespeichert. Jetzt soll dein Programm eine kleine Statistik ausgeben.' },
        {
          task: {
            id: 'l2-angeln', nr: 2, title: 'Angel-Statistik',
            text: ['Du hast drei Fische gefangen: einen Hecht (2350 g), einen Zander (1780 g) und eine Forelle (640 g). Speichere die Gewichte in `int`-Variablen.', 'Gib aus: das Gesamtgewicht in Gramm, das **Durchschnittsgewicht** (mit Nachkommastellen!) und das Gesamtgewicht als „… kg und … g“ – dafür brauchst du `/` und `%`.'],
            req: ['Drei `int`-Variablen für die Gewichte', 'Gesamtgewicht in Gramm ausgeben', 'Durchschnitt als Kommazahl (z. B. `1590.0`) – Achtung Ganzzahl-Division!', 'Gesamtgewicht als Kilo und Gramm mit `/ 1000` und `% 1000`', 'Ausgabe mit erklärendem Text'],
            example: 'Gesamtgewicht: 4770 g\nDurchschnitt: 1590.0 g\nDas sind 4 kg und 770 g.',
            starter: main(R`
        int hecht = 2350;
        int zander = 1780;
        int forelle = 640;
        // Rechne und gib die Statistik aus

`),
            solution: main(R`
        int hecht = 2350;
        int zander = 1780;
        int forelle = 640;
        int gesamt = hecht + zander + forelle;
        double schnitt = gesamt / 3.0;
        int kilo = gesamt / 1000;
        int gramm = gesamt % 1000;
        System.out.println("Gesamtgewicht: " + gesamt + " g");
        System.out.println("Durchschnitt: " + schnitt + " g");
        System.out.println("Das sind " + kilo + " kg und " + gramm + " g.");`),
            tests: [{ name: 'Statistik stimmt', input: [], expect: [{ has: '4770', label: 'Gesamtgewicht 4770' }, { re: '1590[.,]0|1590 ', label: 'Durchschnitt 1590.0 (als Kommazahl)' }, { re: '\\b4\\b[^\\n]*\\b770\\b', label: '4 kg und 770 g' }] }],
            codeChecks: [
              { label: 'Division mit /', re: '/\\s*(1000|3)' },
              { label: 'Modulo mit %', re: '%\\s*1000' },
              { label: 'double für den Durchschnitt', re: '\\bdouble\\b|\\(double\\)|3\\.0' },
            ],
            rubric: [['Programm kompiliert und läuft', 20], ['Gesamtgewicht richtig berechnet', 20], ['Durchschnitt als Kommazahl richtig (keine Ganzzahl-Division)', 25], ['Kilo und Gramm mit / und % richtig', 25], ['Verständliche Ausgabe', 10]],
            tip: 'Für den Durchschnitt teile durch `3.0` statt durch `3` – sonst schneidet Java die Nachkommastellen ab.',
          },
        },
        { layout: 'code', console: 'clear', code: main(R`
        int hecht = 2350;
        int zander = 1780;
        int forelle = 640;
        int gesamt = hecht + zander + forelle;
        double schnitt = gesamt / 3.0;
        int kilo = gesamt / 1000;
        int gramm = gesamt % 1000;
        System.out.println("Gesamtgewicht: " + gesamt + " g");
        System.out.println("Durchschnitt: " + schnitt + " g");
        System.out.println("Das sind " + kilo + " kg und " + gramm + " g.");`), run: true, hl: [7, 9], say: 'So könnte die Lösung aussehen: `gesamt / 3.0` liefert die genaue Kommazahl, `/ 1000` die ganzen Kilo und `% 1000` die restlichen Gramm. Petri Heil! 🎣' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Das kannst du jetzt', items: ['Variablen deklarieren und Werte zuweisen', 'Die Typen `int`, `double`, `boolean`, `char` und `String`', 'Rechnen mit `+ - * / %` und die Ganzzahl-Falle', 'Umwandeln mit `(int)` und `(double)`', 'Text und Zahlen mit `+` verbinden', 'Konstanten mit `final`'], gap: 0.7 }, say: 'Das war Lektion 2! Du kannst jetzt mit Variablen arbeiten und rechnen. In Lektion 3 wird es interaktiv: Dein Programm fragt den Benutzer etwas und trifft Entscheidungen.' },
      ],
    },
  ],
};
