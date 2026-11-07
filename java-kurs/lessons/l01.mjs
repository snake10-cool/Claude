// Lektion 1 – Hallo Java!
const R = String.raw;
const main = (body) => `public class Main {\n    public static void main(String[] args) {\n${body.replace(/^\n/, '').replace(/\n$/, '')}\n    }\n}\n`;

export default {
  id: 'java-01', nr: 1,
  title: 'Hallo Java!',
  sub: 'Was Java ist, wie ein Programm entsteht und wie du dein erstes Programm schreibst, ausführst und Fehler findest.',
  outro: 'Du kannst jetzt Programme schreiben, Text ausgeben, Sonderzeichen benutzen und Fehlermeldungen lesen. In Lektion 2 lernst du Variablen – damit merkt sich dein Programm Dinge.',
  playground: main(R`
        System.out.println("Hallo Welt!");
        System.out.println("Probier hier alles aus, was du gelernt hast.");`),
  chapters: [
    {
      title: 'Willkommen bei Java',
      steps: [
        { t: 'Lektion 1', h: 'Hallo Java! ☕', sub: 'Dein erstes Programm – Schritt für Schritt', say: 'Servus! Ich bin dein Java-Coach. In dieser Lektion schreibst du dein allererstes Java-Programm. Drück jederzeit auf Pause, wenn du in Ruhe lesen willst.' },
        { layout: 'visual', visual: { kind: 'big', text: '☕ Java', sub: 'eine der beliebtesten Programmiersprachen der Welt – seit 1995' }, say: 'Java gibt es schon seit 1995. Der Name kommt übrigens von einer Kaffeesorte – deshalb ist das Logo eine Kaffeetasse.' },
        { visual: { kind: 'bullets', title: 'Hier steckt Java drin', items: ['**Minecraft Java Edition** – das ganze Spiel ist in Java geschrieben', '**Android-Apps** – auf Milliarden Handys', '**Banken, Shops & Server** – riesige Programme laufen mit Java', '**Schule & Uni** – Java ist eine der wichtigsten Lernsprachen'], gap: 1.1 }, say: 'Java steckt in mehr Dingen, als du denkst: in Minecraft, in Android-Apps, bei Banken und Online-Shops. Wer Java kann, kann richtig viel bauen.' },
        { visual: { kind: 'big', text: 'Computer sind fleißig –\naber nicht schlau.', sub: 'Sie machen exakt das, was im Code steht. Nicht mehr und nicht weniger.' }, say: 'Programmieren heißt: Du gibst dem Computer ganz genaue Befehle. Er führt sie blitzschnell aus – aber er denkt nicht mit. Deshalb muss jeder Befehl ganz exakt sein.' },
        { quiz: { id: 'l1-q1', q: 'Welches berühmte Spiel ist in Java programmiert?', options: ['Fortnite', 'Minecraft Java Edition', 'FIFA'], correct: 1, explain: 'Genau! Auch Mods und Server-Plugins für Minecraft schreibt man in Java.' } },
      ],
    },
    {
      title: 'Vom Text zum Programm',
      steps: [
        { t: 'Kapitel 2', h: 'Vom Text zum Programm', sub: 'Was passiert, wenn du auf „Ausführen“ drückst?', after: 'visual' },
        { layout: 'visual', visual: { kind: 'flow', title: 'So wird aus Text ein Programm', items: [{ h: '📝 Quellcode', p: '`Main.java` – das schreibst du' }, { h: '🔍 Compiler (javac)', p: 'prüft und übersetzt', cls: 'hot' }, { h: '📦 Bytecode', p: '`Main.class` – für die Maschine' }, { h: '⚙️ Java Virtual Machine', p: 'führt den Bytecode aus' }, { h: '💬 Ausgabe', p: 'z. B. „Hallo Welt!“', cls: 'ok' }], gap: 1.3, dir: 'row' }, say: 'Ein Java-Programm ist zuerst nur Text. Diesen Text nennt man **Quellcode**. Er steht in einer Datei, die auf `.java` endet – zum Beispiel `Main.java`.' },
        { say: 'Dann kommt der **Compiler**. Er prüft deinen Code ganz genau. Findet er einen Fehler, etwa einen vergessenen Strichpunkt, meldet er ihn – und das Programm startet gar nicht erst.' },
        { say: 'Ist alles richtig, übersetzt der Compiler den Code in **Bytecode**. Den führt die **Java Virtual Machine** aus – auf Windows, Mac, Linux, egal wo. Darum heißt es bei Java: „Write once, run anywhere.“' },
        { visual: { kind: 'big', text: '▶ Ausführen', sub: 'Hier im Kurs passiert das alles automatisch mit einem Klick.' }, say: 'Keine Sorge, das musst du dir nicht alles merken. Hier im Kurs passiert das automatisch, sobald du auf „Ausführen“ drückst.' },
      ],
    },
    {
      title: 'Hallo Welt!',
      steps: [
        { t: 'Kapitel 3', h: 'Hallo Welt!', sub: 'Das berühmteste Programm der Welt', after: 'editor' },
        { layout: 'editor', file: 'Main.java', code: R`
public class Main {

}
`, hl: [1, 1], say: 'Jedes Java-Programm steckt in einer **Klasse**. Unsere Klasse heißt `Main`. Wichtig: Die Datei muss genauso heißen wie die Klasse – also `Main.java`.' },
        { hl: [1, 3], say: '`public` heißt „öffentlich“, `class` heißt „jetzt kommt eine Klasse“. Und alles zwischen der geschweiften Klammer `{` und der schließenden `}` gehört zur Klasse.' },
        { code: R`
public class Main {
    public static void main(String[] args) {

    }
}
`, hl: [2, 4], say: 'Jetzt kommt die wichtigste Zeile: die **main-Methode**. Hier startet jedes Java-Programm. Alles, was zwischen ihren Klammern steht, wird der Reihe nach ausgeführt.' },
        { layout: 'split', visual: { kind: 'bullets', title: 'Die Start-Zeile', items: ['`public` – von außen aufrufbar', '`static` – gehört zur Klasse (lernst du später)', '`void` – gibt nichts zurück', '`main` – der Startpunkt des Programms', '`String[] args` – Startwerte (brauchen wir kaum)'], gap: 0.9 }, hl: [2, 2], say: 'Diese Zeile sieht am Anfang wild aus. Merk sie dir einfach wie eine Zauberformel. Was die einzelnen Wörter genau bedeuten, lernst du im Lauf des Kurses.' },
        { layout: 'editor', code: main(R`        System.out.println("Hallo Welt!");`), hl: [3, 3], say: 'Und jetzt der eigentliche Befehl: `System.out.println(...)` schreibt etwas in die **Konsole** – das ist das Textfenster, in dem die Ausgabe erscheint.' },
        { hl: [3, 3], say: 'Text steht in Java immer in **Anführungszeichen** `"…"`. So ein Text heißt **String**. Und ganz wichtig: Jede Anweisung endet mit einem **Strichpunkt** `;`.' },
        { layout: 'code', run: true, say: 'Zeit für den großen Moment: Wir führen das Programm aus!' },
        { say: 'Da steht es: **Hallo Welt!** 🎉 Herzlichen Glückwunsch, das war dein erstes Java-Programm. Genau so fangen alle Programmierer an.' },
        { layout: 'split', visual: { kind: 'code', title: 'Das gleiche Programm, ohne Einrückung:', code: 'public class Main{public static void main(String[] args){System.out.println("Hallo Welt!");}}', note: 'Läuft genauso – aber niemand will das lesen. Rück deinen Code immer ordentlich ein!', noteAt: 1.5 }, say: 'Übrigens: Leerzeichen und Einrückungen sind Java egal. Für Menschen sind sie aber super wichtig – sie zeigen auf einen Blick, was wo hineingehört.' },
      ],
    },
    {
      title: 'print, println & Sonderzeichen',
      steps: [
        { t: 'Kapitel 4', h: 'Mehr Ausgaben', sub: 'println, print und Sonderzeichen', after: 'code' },
        { layout: 'code', console: 'clear', code: main(R`
        System.out.println("Servus!");
        System.out.println("Ich lerne Java.");
        System.out.println("Das macht Spaß!");`), hl: [3, 5], say: 'Du kannst so viele Zeilen ausgeben, wie du willst. Die Befehle werden von oben nach unten ausgeführt, einer nach dem anderen.' },
        { run: true, say: 'Jedes `println` schreibt seinen Text und springt danach in die nächste Zeile.' },
        { console: 'clear', code: main(R`
        System.out.print("Eins ");
        System.out.print("Zwei ");
        System.out.println("Drei");
        System.out.println("Vier");`), hl: [3, 4], say: 'Das „ln“ in `println` steht für **line**, also „Zeile“. Lässt du es weg, schreibt `print` einfach in derselben Zeile weiter.' },
        { run: true, say: '„Eins“, „Zwei“ und „Drei“ landen in einer Zeile, weil `print` keinen Zeilenumbruch macht. Erst `println` springt weiter – deshalb steht „Vier“ in der nächsten Zeile.' },
        { quiz: { id: 'l1-q2', q: 'Was gibt dieser Code aus?\n`System.out.print("A");`\n`System.out.println("B");`\n`System.out.print("C");`', options: ['A, B und C untereinander', 'AB – und darunter C', 'ABC in einer Zeile'], correct: 1, explain: '`print` bleibt in der Zeile, `println` springt danach weiter. Also steht AB in der ersten Zeile und C in der zweiten.' } },
        { layout: 'split', visual: { kind: 'table', title: 'Sonderzeichen im Text', head: ['Schreibweise', 'Bedeutung'], rows: [['`\\n`', 'neue Zeile'], ['`\\t`', 'Tabulator (großer Abstand)'], ['`\\"`', 'ein Anführungszeichen'], ['`\\\\`', 'ein Backslash \\']], gap: 0.8 }, console: 'clear', code: main(R`
        System.out.println("Sie sagte: \"Servus!\"");
        System.out.println("Name:\tLena");
        System.out.println("Zeile 1\nZeile 2");`), hl: [3, 3], say: 'Wie schreibt man ein Anführungszeichen, wenn der Text selbst in Anführungszeichen steht? Mit einem **Backslash** davor. So eine Kombination heißt **Escape-Sequenz**.' },
        { layout: 'all', run: true, hl: [4, 5], say: '`\\t` macht einen großen Abstand – praktisch für Tabellen. Und `\\n` erzeugt mitten im Text eine neue Zeile.' },
      ],
    },
    {
      title: 'Fehler sind deine Freunde',
      steps: [
        { t: 'Kapitel 5', h: 'Fehler sind deine Freunde', sub: 'Was tun, wenn’s rot wird?', after: 'code' },
        { layout: 'code', console: 'clear', code: main(R`        System.out.println("Hallo Welt!")`), hl: [3, 3], say: 'Jeder Programmierer macht Fehler – ständig! Wichtig ist nur, die Fehlermeldungen lesen zu können. Schau genau hin: Was fehlt in Zeile 3?' },
        { run: true, expectError: true, say: 'Der **Strichpunkt** fehlt! Der Compiler meldet sofort einen Fehler – mit der Zeilennummer. Das Programm startet gar nicht erst.' },
        { console: 'clear', code: main(R`        System.out.println("Hallo Welt!");`), run: true, say: 'Wir ergänzen den Strichpunkt – und schon läuft alles wieder.' },
        { console: 'clear', code: main(R`        system.out.println("Hallo Welt!");`), hl: [3, 3], say: 'Zweiter Klassiker: Java unterscheidet **Groß- und Kleinschreibung**. Für Java ist `system` etwas völlig anderes als `System`.' },
        { run: true, expectError: true, say: 'Und wieder eine Meldung. Sie sagt dir sogar, wie es richtig heißt: `System` mit großem S.' },
        { quiz: { id: 'l1-q3', q: 'Welche Zeile ist komplett richtig?', options: ['`System.out.println("Hi")`', '`system.out.println("Hi");`', '`System.out.println("Hi");`', '`System.out.printn("Hi");`'], correct: 2, explain: 'Großes S bei `System`, richtig geschriebenes `println`, Text in Anführungszeichen und am Ende ein Strichpunkt.' } },
        { layout: 'split', visual: { kind: 'bullets', title: 'Deine Fehler-Checkliste', items: ['Strichpunkt `;` am Ende jeder Anweisung?', 'Klammern `( )` und `{ }` immer paarweise?', 'Anführungszeichen `"…"` geschlossen?', 'Groß- und Kleinschreibung: `System`, `String`, `Main`'], gap: 1.0 }, code: main(R`        System.out.println("Hallo Welt!");`), say: 'Mein Tipp: Lies die Meldung genau und schau dir die genannte Zeile an. Oft ist der Fehler direkt dort – oder in der Zeile davor.' },
      ],
    },
    {
      title: 'Kommentare',
      steps: [
        { t: 'Kapitel 6', h: 'Kommentare', sub: 'Notizen, die Java ignoriert', after: 'code' },
        { layout: 'code', console: 'clear', code: R`
public class Main {
    // Das ist ein Kommentar – Java ignoriert ihn
    public static void main(String[] args) {
        System.out.println("Kommentare sieht man nicht"); // auch hier geht's
    }
}
`, hl: [2, 2], say: 'Manchmal willst du Notizen in den Code schreiben. Dafür gibt es **Kommentare**. Alles nach `//` bis zum Zeilenende ignoriert Java.' },
        { code: R`
public class Main {
    // Das ist ein Kommentar – Java ignoriert ihn
    public static void main(String[] args) {
        System.out.println("Kommentare sieht man nicht"); // auch hier geht's

        /* Ein Kommentar
           über mehrere Zeilen */
        // System.out.println("Diese Zeile ist ausgeschaltet");
    }
}
`, hl: [6, 8], say: 'Für längere Notizen gibt es `/* … */` über mehrere Zeilen. Und ein Profi-Trick: Mit `//` vor einem Befehl schaltest du ihn kurz aus, ohne ihn zu löschen.' },
        { run: true, say: 'Nur eine Zeile erscheint – alles in den Kommentaren wurde übersprungen.' },
        { layout: 'split', visual: { kind: 'big', text: 'Gute Kommentare erklären das *Warum*.', sub: 'Was der Code macht, sieht man am Code selbst.' }, say: 'Gute Kommentare erklären, **warum** etwas im Code steht. So verstehst du deinen eigenen Code auch in drei Monaten noch.' },
      ],
    },
    {
      title: 'Aufgabe: Dein Steckbrief',
      steps: [
        { t: 'Aufgabe 1', h: 'Jetzt bist du dran!', sub: 'Dein Steckbrief als Java-Programm', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Aufgabe 1: Dein Steckbrief', items: ['Gib mindestens **4 Zeilen** über dich aus', 'Benutze `println` **und** `print`', 'Benutze mindestens ein **Sonderzeichen** wie `\\t` oder `\\"`', 'Schreib mindestens einen **Kommentar**'], gap: 0.9 }, say: 'Jetzt bist du dran! Du schreibst deinen eigenen **Steckbrief**. Das Video wird gesperrt, bis du abgibst. Vorher kannst du so oft testen, wie du willst.' },
        {
          task: {
            id: 'l1-steckbrief', nr: 1, title: 'Dein Steckbrief',
            text: ['Schreib ein Java-Programm, das einen kleinen **Steckbrief** über dich (oder eine erfundene Person) in der Konsole ausgibt – zum Beispiel Name, Alter, Hobby und Lieblingsspiel.', 'Mach es ein bisschen schön: Eine Überschrift oder eine Linie aus Zeichen wie `=====` darf gern sein.'],
            req: ['Das Programm kompiliert und läuft ohne Fehler', 'Mindestens **4 Zeilen** Ausgabe', '`System.out.println` **und** `System.out.print` werden beide verwendet', 'Mindestens ein Sonderzeichen: `\\t`, `\\n` oder `\\"`', 'Mindestens ein Kommentar (`//` oder `/* … */`)'],
            example: '===== STECKBRIEF =====\nName:\tLena\nAlter:\t14\nHobby:\tAngeln & Gitarre\nLieblingsspiel: "Minecraft"',
            starter: main(R`
        // Schreib hier deinen Steckbrief
        System.out.println("===== STECKBRIEF =====");
`),
            solution: main(R`
        // Mein Steckbrief
        System.out.println("===== STECKBRIEF =====");
        System.out.println("Name:\tLena");
        System.out.print("Alter:\t");
        System.out.println("14");
        System.out.println("Hobby:\tAngeln & Gitarre");
        System.out.println("Lieblingsspiel: \"Minecraft\"");`),
            tests: [{ name: 'Programm läuft und gibt mindestens 4 Zeilen aus', input: [], expect: [{ re: '(.+\\n){4,}', label: 'mindestens 4 Zeilen Ausgabe' }] }],
            codeChecks: [
              { label: 'println verwendet', re: 'System\\.out\\.println\\s*\\(' },
              { label: 'print (ohne ln) verwendet', re: 'System\\.out\\.print\\s*\\(' },
              { label: 'Sonderzeichen \\t, \\n oder \\" verwendet', re: '\\\\[tn"]' },
              { label: 'Kommentar vorhanden', re: '//|/\\*' },
            ],
            rubric: [['Programm kompiliert und läuft', 30], ['Mindestens 4 Zeilen Steckbrief mit sinnvollem Inhalt', 25], ['print und println richtig eingesetzt', 20], ['Mindestens ein Sonderzeichen (\\t, \\n oder \\")', 15], ['Mindestens ein Kommentar', 10]],
            tip: 'Teste nach jeder neuen Zeile mit „Ausführen“ – dann findest du Fehler sofort.',
          },
        },
        { layout: 'all', console: 'clear', visual: { kind: 'big', text: 'Abgegeben! ✓', sub: 'Hier ist eine mögliche Lösung – deine darf ganz anders aussehen.' }, code: main(R`
        // Mein Steckbrief
        System.out.println("===== STECKBRIEF =====");
        System.out.println("Name:\tLena");
        System.out.print("Alter:\t");
        System.out.println("14");
        System.out.println("Hobby:\tAngeln & Gitarre");
        System.out.println("Lieblingsspiel: \"Minecraft\"");`), say: 'Stark, abgegeben! Schauen wir uns eine mögliche Lösung an. Deine darf natürlich ganz anders aussehen – Hauptsache, sie erfüllt die Punkte.' },
        { run: true, hl: [6, 7], say: 'Hier siehst du `print` und `println` zusammen: „Alter:“ und „14“ landen in derselben Zeile. Und `\\t` sorgt für saubere Abstände.' },
      ],
    },
    {
      title: 'Ausblick & Aufgabe 2',
      steps: [
        { t: 'Kapitel 8', h: 'Java kann rechnen', sub: 'Ein Vorgeschmack auf Lektion 2', after: 'code' },
        { layout: 'code', console: 'clear', code: main(R`
        System.out.println(3 + 4);
        System.out.println("3 + 4");
        System.out.println("3 + 4 = " + (3 + 4));`), hl: [3, 5], say: 'Ein kleiner Vorgeschmack: `println` kann auch rechnen! Achte auf die Anführungszeichen.' },
        { run: true, say: 'Ohne Anführungszeichen rechnet Java: 7. Mit Anführungszeichen ist es nur Text. Und mit `+` verbindest du Text und Zahlen zu einem langen Text.' },
        { quiz: { id: 'l1-q4', q: 'Was gibt `System.out.println("1" + 1);` aus?', options: ['2', '11', 'Einen Fehler'], correct: 1, explain: 'Sobald ein String im Spiel ist, verbindet `+` die Teile zu Text: "1" + 1 wird zu "11".' } },
        { t: 'Aufgabe 2', h: 'Zeichnen mit Text', sub: 'ASCII-Kunst – Bilder nur aus Zeichen', after: 'visual' },
        { layout: 'visual', visual: { kind: 'code', title: 'So kann ASCII-Kunst aussehen:', code: '      /\\_/\\\n     ( o.o )\n      > ^ <\n   Katze sagt: "Miau"', note: 'Für einen Backslash \\ im Text schreibst du \\\\ – und für " schreibst du \\"', noteAt: 1.2 }, say: 'Letzte Aufgabe für heute: Zeichne ein Bild nur aus Textzeichen – eine Katze, einen Fisch, einen Creeper oder was dir einfällt. Das nennt man **ASCII-Kunst**.' },
        {
          task: {
            id: 'l1-ascii', nr: 2, title: 'Zeichnen mit Text (ASCII-Kunst)',
            text: ['Zeichne mit `System.out.println` ein Bild nur aus Zeichen – z. B. eine Katze, einen Fisch, ein Haus oder einen Creeper.', 'Denk dran: Einen Backslash schreibst du im Text als `\\\\`, ein Anführungszeichen als `\\"`.'],
            req: ['Das Programm kompiliert und läuft ohne Fehler', 'Das Bild hat mindestens **5 Zeilen**', 'Mindestens ein `\\\\` oder `\\"` im Code', 'Ein Kommentar sagt, was das Bild zeigt'],
            example: '      /\\_/\\\n     ( o.o )\n      > ^ <\n     /     \\\n    (_______)\n   "Miau!"',
            starter: main(R`
        // Mein Bild:
        System.out.println("      /\\_/\\");
`),
            solution: main(R`
        // Mein Bild: eine Katze
        System.out.println("      /\\_/\\");
        System.out.println("     ( o.o )");
        System.out.println("      > ^ <");
        System.out.println("     /     \\");
        System.out.println("    (_______)");
        System.out.println("   \"Miau!\"");`),
            tests: [{ name: 'Bild mit mindestens 5 Zeilen', input: [], expect: [{ re: '(.*\\n){5,}', label: 'mindestens 5 Zeilen Ausgabe' }] }],
            codeChecks: [
              { label: 'Escape-Sequenz \\\\ oder \\" verwendet', re: '\\\\\\\\|\\\\"' },
              { label: 'Kommentar vorhanden', re: '//|/\\*' },
              { label: 'mindestens 5-mal println', re: '(System\\.out\\.println[\\s\\S]*){5}' },
            ],
            rubric: [['Programm kompiliert und läuft', 30], ['Bild mit mindestens 5 Zeilen, erkennbar und mit Mühe gemacht', 35], ['Escape-Sequenz \\\\ oder \\" richtig benutzt', 20], ['Kommentar beschreibt das Bild', 15]],
            tip: 'Zeichne dein Bild zuerst auf Papier oder im Kopf Zeile für Zeile – dann übertrag jede Zeile in ein println.',
          },
        },
        { layout: 'code', console: 'clear', code: main(R`
        // Mein Bild: eine Katze
        System.out.println("      /\\_/\\");
        System.out.println("     ( o.o )");
        System.out.println("      > ^ <");
        System.out.println("     /     \\");
        System.out.println("    (_______)");
        System.out.println("   \"Miau!\"");`), run: true, say: 'Fertig! So sieht die Beispiel-Katze aus. Deine Zeichnung ist bestimmt kreativer. 😺' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Das kannst du jetzt', items: ['Ein Java-Programm mit Klasse und `main` schreiben', 'Text mit `println` und `print` ausgeben', 'Sonderzeichen wie `\\n`, `\\t` und `\\"` benutzen', 'Fehlermeldungen lesen und Fehler beheben', 'Kommentare schreiben'], gap: 0.8 }, say: 'Das war Lektion 1! In Lektion 2 lernst du **Variablen** – damit kann sich dein Programm Dinge merken und rechnen. Bis gleich!' },
      ],
    },
  ],
};
