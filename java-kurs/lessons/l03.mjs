// Lektion 3 – Eingaben & Entscheidungen
const R = String.raw;
const prog = (body, imports = 'import java.util.Scanner;\n\n') => `${imports}public class Main {\n    public static void main(String[] args) {\n${body.replace(/^\n/, '').replace(/\n$/, '')}\n    }\n}\n`;

export default {
  id: 'java-03', nr: 3,
  title: 'Eingaben & Entscheidungen',
  sub: 'Dein Programm fragt nach, vergleicht Werte und entscheidet mit if, else und den logischen Operatoren.',
  outro: 'Dein Programm kann jetzt zuhören und entscheiden – das ist der Schritt von „Text ausgeben“ zu echter Logik. In Lektion 4 kommen Schleifen: Dinge wiederholen, ohne alles hundertmal hinzuschreiben.',
  playground: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Wie alt bist du? ");
        int alter = sc.nextInt();
        if (alter >= 18) {
            System.out.println("Volljährig!");
        } else {
            System.out.println("Noch " + (18 - alter) + " Jahre bis 18.");
        }`),
  chapters: [
    {
      title: 'Programme, die reagieren',
      steps: [
        { t: 'Lektion 3', h: 'Eingaben & Entscheidungen', sub: 'Programme, die zuhören und reagieren', say: 'Servus! Bisher haben deine Programme immer genau dasselbe gemacht. Heute ändern wir das: Dein Programm fragt den Benutzer etwas – und reagiert unterschiedlich auf die Antwort.' },
        { layout: 'visual', visual: { kind: 'flow', title: 'Fast jedes Programm funktioniert so', dir: 'row', items: [{ h: '⌨️ Eingabe', p: 'Benutzer tippt etwas' }, { h: '⚙️ Verarbeitung', p: 'rechnen & entscheiden', cls: 'hot' }, { h: '💬 Ausgabe', p: 'Antwort anzeigen', cls: 'ok' }], gap: 1.1 }, say: 'Fast jedes Programm folgt diesem Muster: Eingabe, Verarbeitung, Ausgabe. Ein Spiel liest deine Tasten, ein Online-Shop deine Bestellung. Heute baust du alle drei Teile selbst.' },
      ],
    },
    {
      title: 'Eingaben mit Scanner',
      steps: [
        { t: 'Kapitel 2', h: 'Der Scanner', sub: 'Text von der Tastatur einlesen', after: 'editor' },
        { layout: 'editor', code: prog(R`
        Scanner sc = new Scanner(System.in);`), hl: [1, 1], say: 'Zum Einlesen gibt es in Java den **Scanner**. Er wohnt in einer Bibliothek, deshalb müssen wir ihn ganz oben mit `import` holen.' },
        { hl: [5, 5], say: 'In der main-Methode erzeugen wir dann einen Scanner und nennen ihn `sc`. `System.in` bedeutet: Lies von der Tastatur.' },
        { code: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Wie heißt du? ");
        String name = sc.nextLine();
        System.out.println("Servus " + name + "!");`), hl: [6, 7], say: '`sc.nextLine()` wartet, bis der Benutzer etwas eintippt und Enter drückt. Die ganze Zeile landet dann in der Variable `name`.' },
        { layout: 'code', console: 'clear', run: true, input: ['Lena'], say: 'Probieren wir es aus. Der Benutzer tippt „Lena“ – das siehst du in Grün. Und das Programm antwortet mit seinem Namen.' },
        { hl: [6, 6], say: 'Kleiner Trick: Für die Frage nehmen wir `print` statt `println`. Dann tippt der Benutzer direkt hinter der Frage, in derselben Zeile.' },
        { layout: 'split', visual: { kind: 'table', title: 'Die wichtigsten Scanner-Befehle', head: ['Befehl', 'liest …', 'Typ'], rows: [['`sc.nextLine()`', 'eine ganze Zeile', '`String`'], ['`sc.next()`', 'ein einzelnes Wort', '`String`'], ['`sc.nextInt()`', 'eine ganze Zahl', '`int`'], ['`sc.nextDouble()`', 'eine Kommazahl', '`double`']], gap: 0.8 }, console: 'clear', code: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Wie alt bist du? ");
        int alter = sc.nextInt();
        System.out.println("In 4 Jahren bist du " + (alter + 4) + ".");`), hl: [7, 7], say: 'Für Zahlen gibt es eigene Befehle: `nextInt()` für ganze Zahlen und `nextDouble()` für Kommazahlen. Damit kannst du gleich weiterrechnen.' },
        { layout: 'code', run: true, input: ['14'], say: 'Der Benutzer gibt 14 ein, das Programm rechnet 14 plus 4. Ganz ohne den Code zu ändern, funktioniert es jetzt für jedes Alter.' },
        { console: 'clear', run: true, input: ['vierzehn'], expectError: true, say: 'Und was passiert, wenn jemand Buchstaben statt einer Zahl eintippt? Dann stürzt das Programm mit einer **InputMismatchException** ab: Die Eingabe passt nicht zum Typ.' },
        { quiz: { id: 'l3-q1', q: 'Mit welchem Befehl liest du eine ganze Zahl ein?', options: ['`sc.nextLine()`', '`sc.nextInt()`', '`sc.readInt()`', '`sc.next()`'], correct: 1, explain: '`nextInt()` liest eine ganze Zahl und liefert einen `int`. `nextLine()` liefert immer Text.' } },
      ],
    },
    {
      title: 'Vergleiche',
      steps: [
        { t: 'Kapitel 3', h: 'Vergleiche', sub: 'Ist das wahr oder falsch?', after: 'split' },
        { layout: 'split', console: 'clear', visual: { kind: 'table', title: 'Vergleichsoperatoren', head: ['Zeichen', 'Bedeutung', 'Beispiel → Ergebnis'], rows: [['`==`', 'gleich', '`5 == 5` → true'], ['`!=`', 'ungleich', '`5 != 3` → true'], ['`<`', 'kleiner', '`3 < 2` → false'], ['`>`', 'größer', '`7 > 2` → true'], ['`<=`', 'kleiner oder gleich', '`4 <= 4` → true'], ['`>=`', 'größer oder gleich', '`9 >= 10` → false']], gap: 0.6 }, code: prog(R`
        int alter = 15;
        System.out.println(alter >= 18);
        System.out.println(alter == 15);
        System.out.println(alter != 15);`, ''), hl: [4, 6], say: 'Um zu entscheiden, muss ein Programm Werte vergleichen. Das Ergebnis eines Vergleichs ist immer ein `boolean`: entweder `true` oder `false`.' },
        { layout: 'all', run: true, say: '15 ist nicht größer oder gleich 18, also false. 15 ist gleich 15, also true. Und „ungleich 15“ stimmt natürlich nicht.' },
        { hl: [5, 5], say: 'Wichtig: Ein einzelnes `=` **speichert** einen Wert. Zum **Vergleichen** brauchst du zwei: `==`. Das verwechselt am Anfang jeder.' },
      ],
    },
    {
      title: 'if und else',
      steps: [
        { t: 'Kapitel 4', h: 'if und else', sub: 'Wenn … dann … sonst', after: 'split' },
        { layout: 'split', console: 'clear', visual: { kind: 'flow', items: [{ h: 'alter >= 18 ?', p: 'Bedingung', cls: 'hot' }, { h: '✅ true → if-Block', p: '„Du darfst wählen!“', cls: 'ok' }, { h: '❌ false → else-Block', p: '„Noch nicht …“' }], gap: 1.0 }, code: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Alter: ");
        int alter = sc.nextInt();
        if (alter >= 16) {
            System.out.println("Du darfst in Österreich wählen!");
        } else {
            System.out.println("Noch " + (16 - alter) + " Jahre bis zur Wahl.");
        }`), hl: [8, 12], say: 'Mit `if` trifft dein Programm Entscheidungen. In den runden Klammern steht die **Bedingung**. Ist sie true, wird der Block in den geschweiften Klammern ausgeführt.' },
        { hl: [10, 12], say: 'Ist die Bedingung false, springt Java in den `else`-Block. Es läuft also immer **genau einer** der beiden Blöcke. In Österreich darf man übrigens schon ab 16 wählen.' },
        { layout: 'all', run: true, input: ['17'], say: 'Mit 17 ist die Bedingung erfüllt: Der if-Block läuft.' },
        { console: 'clear', run: true, input: ['13'], say: 'Mit 13 ist sie nicht erfüllt: Diesmal läuft der else-Block – und rechnet sogar aus, wie lange es noch dauert.' },
        { layout: 'code', console: 'clear', code: prog(R`
        int temperatur = 31;
        if (temperatur > 30) {
            System.out.println("Ab ins Freibad!");
        }
        System.out.println("Schönen Tag noch.");`, ''), hl: [4, 6], say: 'Der else-Teil ist übrigens freiwillig. Fehlt er, passiert bei false einfach gar nichts – und das Programm macht danach normal weiter.' },
        { run: true, say: 'Bei 31 Grad geht es ins Freibad. Die letzte Zeile steht außerhalb vom if und läuft deshalb immer.' },
      ],
    },
    {
      title: 'else if – mehrere Fälle',
      steps: [
        { t: 'Kapitel 5', h: 'else if', sub: 'Wenn es mehr als zwei Möglichkeiten gibt', after: 'code' },
        { layout: 'code', console: 'clear', code: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Punkte (0-100): ");
        int punkte = sc.nextInt();
        if (punkte >= 90) {
            System.out.println("Note 1 – Sehr gut");
        } else if (punkte >= 78) {
            System.out.println("Note 2 – Gut");
        } else if (punkte >= 64) {
            System.out.println("Note 3 – Befriedigend");
        } else if (punkte >= 50) {
            System.out.println("Note 4 – Genügend");
        } else {
            System.out.println("Note 5 – Nicht genügend");
        }`), hl: [8, 18], say: 'Gibt es mehr als zwei Fälle, hängst du mit `else if` weitere Bedingungen an. Hier ein Notenrechner – mit genau den Grenzen, nach denen auch deine Aufgaben hier benotet werden.' },
        { run: true, input: ['82'], say: 'Java prüft von oben nach unten: 82 ist nicht über 90, aber über 78. Also Note 2. Sobald eine Bedingung passt, werden alle weiteren übersprungen.' },
        { quiz: { id: 'l3-q2', q: 'Was passiert, wenn man die Reihenfolge umdreht und zuerst `if (punkte >= 50)` prüft?', options: ['Nichts, das Ergebnis bleibt gleich', 'Alle ab 50 Punkten bekommen eine 4 – auch mit 100 Punkten', 'Das Programm kompiliert nicht'], correct: 1, explain: 'Die erste passende Bedingung gewinnt. 100 ist auch ≥ 50 – also würde jeder ab 50 Punkten bei der ersten Bedingung landen. Bei else-if-Ketten ist die Reihenfolge entscheidend!' } },
      ],
    },
    {
      title: 'Und, Oder, Nicht',
      steps: [
        { t: 'Kapitel 6', h: 'Und, Oder, Nicht', sub: 'Bedingungen kombinieren', after: 'split' },
        { layout: 'split', console: 'clear', visual: { kind: 'table', title: 'Logische Operatoren', head: ['Zeichen', 'heißt', 'true, wenn …'], rows: [['`&&`', 'und', '**beide** Seiten true sind'], ['`||`', 'oder', '**mindestens eine** Seite true ist'], ['`!`', 'nicht', 'der Wert false ist (dreht um)']], gap: 0.8 }, code: prog(R`
        int alter = 12;
        boolean wochenende = true;
        boolean ferien = false;

        if (alter >= 6 && alter <= 14) {
            System.out.println("Kinderpreis im Freibad");
        }
        if (wochenende || ferien) {
            System.out.println("Ausschlafen!");
        }
        if (!ferien) {
            System.out.println("Hausaufgaben nicht vergessen.");
        }`, ''), hl: [7, 9], say: 'Oft hängt eine Entscheidung von mehreren Dingen ab. Mit `&&` (und) müssen **beide** Bedingungen stimmen – hier: mindestens 6 **und** höchstens 14 Jahre alt.' },
        { hl: [10, 12], say: 'Mit `||` (oder) reicht es, wenn **eine** stimmt: Am Wochenende **oder** in den Ferien wird ausgeschlafen.' },
        { hl: [13, 15], say: 'Und `!` dreht einen Wert um: `!ferien` heißt „nicht Ferien“. Weil ferien false ist, ist `!ferien` true.' },
        { layout: 'all', run: true, say: 'Alle drei Bedingungen sind erfüllt, also erscheinen alle drei Zeilen.' },
        { quiz: { id: 'l3-q3', q: 'Wann ist `(x > 0 && x < 10)` true?', options: ['Wenn x zwischen 1 und 9 liegt', 'Wenn x kleiner als 0 oder größer als 10 ist', 'Immer', 'Wenn x genau 0 oder 10 ist'], correct: 0, explain: 'Beide Bedingungen müssen stimmen: größer als 0 UND kleiner als 10. Bei ganzen Zahlen also 1 bis 9.' } },
      ],
    },
    {
      title: 'Die String-Falle',
      steps: [
        { t: 'Kapitel 7', h: 'Die String-Falle', sub: 'Warum == bei Text nicht klappt', after: 'code' },
        { layout: 'code', console: 'clear', code: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Passwort: ");
        String eingabe = sc.nextLine();
        System.out.println(eingabe == "geheim");
        System.out.println(eingabe.equals("geheim"));`), hl: [8, 8], say: 'Jetzt kommt eine der gemeinsten Fallen in Java. Wir lesen ein Passwort ein und vergleichen es mit `==`. Was glaubst du, kommt heraus?' },
        { run: true, input: ['geheim'], say: 'Obwohl wir genau „geheim“ eingetippt haben, liefert `==` **false**! Strings sind in Java Objekte. `==` prüft, ob es **dasselbe Objekt** ist – nicht, ob der Text gleich ist.' },
        { hl: [9, 9], say: 'Für Text nimmst du deshalb immer `.equals(...)`. Das vergleicht wirklich Buchstabe für Buchstabe. Merk dir: **Zahlen mit ==, Text mit equals.**' },
        { layout: 'split', visual: { kind: 'compare', left: { title: '❌ So nicht', code: 'if (name == "Lena")', note: 'vergleicht Objekte – oft false', cls: 'bad' }, right: { title: '✅ So schon', code: 'if (name.equals("Lena"))', note: 'vergleicht den Text', cls: 'good' } }, say: 'Und wenn Groß- und Kleinschreibung egal sein soll, gibt es `equalsIgnoreCase`. Dann ist „LENA“ gleich „lena“.' },
        { quiz: { id: 'l3-q4', q: 'Wie prüfst du richtig, ob die Variable `antwort` den Text „ja“ enthält?', options: ['`antwort == "ja"`', '`antwort = "ja"`', '`antwort.equals("ja")`', '`antwort.equals(ja)`'], correct: 2, explain: 'Text vergleicht man mit `.equals()`, und der Vergleichstext steht in Anführungszeichen.' } },
      ],
    },
    {
      title: 'Aufgabe: Ticket-Automat',
      steps: [
        { t: 'Aufgabe 1', h: 'Ticket-Automat', sub: 'Jetzt bist du dran!', after: 'visual' },
        { layout: 'visual', visual: { kind: 'table', title: 'Preise im Kino', head: ['Alter', 'Preis'], rows: [['unter 6', 'gratis'], ['6 bis 17', '6.50 €'], ['ab 18', '11.00 €']], gap: 0.8 }, say: 'Jetzt bist du dran! Bau einen **Ticket-Automaten** fürs Kino: Er fragt nach Name und Alter und sagt dann, was das Ticket kostet.' },
        {
          task: {
            id: 'l3-ticket', nr: 1, title: 'Ticket-Automat',
            text: ['Schreib einen Ticket-Automaten fürs Kino. Das Programm fragt zuerst nach dem **Namen**, dann nach dem **Alter**.', 'Dann gibt es den passenden Preis aus: unter 6 Jahren gratis, von 6 bis 17 Jahren 6.50 Euro, ab 18 Jahren 11.00 Euro. Begrüße die Person dabei mit Namen.'],
            req: ['`import java.util.Scanner;` und ein Scanner', 'Name mit `nextLine()`, Alter mit `nextInt()` einlesen', '`if` / `else if` / `else` für die drei Preise', 'Unter 6: „gratis“, 6–17: 6.5, ab 18: 11.0', 'Ausgabe mit dem Namen'],
            example: 'Wie heißt du? Mia\nWie alt bist du? 12\nHallo Mia! Dein Ticket kostet 6.5 Euro.',
            starter: prog(R`
        Scanner sc = new Scanner(System.in);
        // Frag nach Name und Alter und gib den Preis aus

`),
            solution: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Wie heißt du? ");
        String name = sc.nextLine();
        System.out.print("Wie alt bist du? ");
        int alter = sc.nextInt();
        if (alter < 6) {
            System.out.println("Hallo " + name + "! Für dich ist das Ticket gratis.");
        } else if (alter < 18) {
            System.out.println("Hallo " + name + "! Dein Ticket kostet 6.5 Euro.");
        } else {
            System.out.println("Hallo " + name + "! Dein Ticket kostet 11.0 Euro.");
        }`),
            tests: [
              { name: 'Kind (5 Jahre)', input: ['Mia', '5'], expect: [{ re: 'gratis|kostenlos|0[.,]0', label: 'gratis' }, { has: 'Mia', label: 'Name in der Ausgabe' }] },
              { name: 'Jugendlich (12 Jahre)', input: ['Tom', '12'], expect: [{ re: '6[.,]5', label: '6.5 Euro' }] },
              { name: 'Grenzfall 17 Jahre', input: ['Ida', '17'], expect: [{ re: '6[.,]5', label: '6.5 Euro bei 17' }] },
              { name: 'Erwachsen (18 Jahre)', input: ['Ben', '18'], expect: [{ re: '\\b11\\b|11[.,]0', label: '11 Euro bei 18' }] },
            ],
            codeChecks: [{ label: 'Scanner verwendet', re: 'new\\s+Scanner\\s*\\(\\s*System\\.in\\s*\\)' }, { label: 'nextInt für das Alter', re: 'nextInt\\s*\\(' }, { label: 'else if verwendet', re: 'else\\s+if' }],
            rubric: [['Programm kompiliert und läuft', 20], ['Eingabe von Name und Alter mit Scanner', 20], ['Richtige Preise für alle Altersgruppen (auch Grenzfälle 6 und 18)', 40], ['Freundliche Ausgabe mit Namen', 20]],
            tip: 'Teste die Grenzen extra: 5, 6, 17 und 18. Genau dort passieren die meisten Fehler.',
          },
        },
        { layout: 'code', console: 'clear', code: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Wie heißt du? ");
        String name = sc.nextLine();
        System.out.print("Wie alt bist du? ");
        int alter = sc.nextInt();
        if (alter < 6) {
            System.out.println("Hallo " + name + "! Für dich ist das Ticket gratis.");
        } else if (alter < 18) {
            System.out.println("Hallo " + name + "! Dein Ticket kostet 6.5 Euro.");
        } else {
            System.out.println("Hallo " + name + "! Dein Ticket kostet 11.0 Euro.");
        }`), run: true, input: ['Mia', '12'], hl: [10, 15], say: 'Abgegeben! So könnte es aussehen. Weil die else-if-Kette von oben prüft, reicht bei der zweiten Bedingung `alter < 18` – unter 6 wurde ja schon vorher abgefangen.' },
      ],
    },
    {
      title: 'Schön formatieren mit printf',
      steps: [
        { t: 'Kapitel 9', h: 'printf', sub: 'Zahlen schön formatieren', after: 'code' },
        { layout: 'code', console: 'clear', code: prog(R`
        double preis = 45.0 - 29.99;
        System.out.println("Rest: " + preis + " Euro");
        System.out.printf("Rest: %.2f Euro%n", preis);`, ''), hl: [3, 4], say: 'Erinnerst du dich an die komische Zahl aus Lektion 2? Mit `printf` kannst du Zahlen schön formatieren. `%.2f` heißt: Kommazahl mit genau **2 Nachkommastellen**.' },
        { run: true, say: 'Viel besser! printf rundet auf zwei Stellen. Das `%n` am Ende macht eine neue Zeile – printf springt nämlich nicht von selbst weiter.' },
        { layout: 'split', console: 'clear', visual: { kind: 'table', title: 'Platzhalter für printf', head: ['Platzhalter', 'für', 'Beispiel'], rows: [['`%d`', 'ganze Zahlen', '`printf("%d Punkte", 42)`'], ['`%.2f`', 'Kommazahl, 2 Stellen', '`printf("%.2f", 3.14159)`'], ['`%s`', 'Text', '`printf("Hallo %s", name)`'], ['`%n`', 'neue Zeile', '`printf("Ende%n")`']], gap: 0.7 }, code: prog(R`
        String name = "Lena";
        int fische = 3;
        double gewicht = 4.7712;
        System.out.printf("%s hat %d Fische gefangen.%n", name, fische);
        System.out.printf("Gesamtgewicht: %.1f kg%n", gewicht);`, ''), hl: [6, 7], say: 'Du kannst mehrere Platzhalter in einen Text packen. Die Werte kommen danach, durch Beistriche getrennt, in der richtigen Reihenfolge.' },
        { layout: 'all', run: true, say: '`%s` wird durch den Namen ersetzt, `%d` durch die Anzahl und `%.1f` durch das Gewicht mit einer Nachkommastelle.' },
        { quiz: { id: 'l3-q5', q: 'Was gibt `System.out.printf("%.1f", 2.46);` aus?', options: ['2.46', '2.4', '2.5', '2'], correct: 2, explain: '`%.1f` rundet auf eine Nachkommastelle: 2.46 wird zu 2.5.' } },
      ],
    },
    {
      title: 'Aufgabe: Notenrechner',
      steps: [
        { t: 'Aufgabe 2', h: 'Notenrechner', sub: 'Mit Fehlerprüfung', after: 'visual' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Aufgabe 2: Notenrechner', items: ['Lies die Punkte (0–100) mit dem Scanner ein', 'Gib die österreichische Note **und** das Wort dazu aus', 'Bei Punkten unter 0 oder über 100: „Ungültige Eingabe“', 'Grenzen: ab 90 → 1, ab 78 → 2, ab 64 → 3, ab 50 → 4, sonst 5'], gap: 0.9 }, say: 'Letzte Aufgabe! Bau deinen eigenen Notenrechner – mit einer Extra-Prüfung: Ungültige Punkte sollen abgefangen werden. Dafür brauchst du `||`.' },
        {
          task: {
            id: 'l3-noten', nr: 2, title: 'Notenrechner',
            text: ['Schreib ein Programm, das eine Punktezahl von 0 bis 100 einliest und die passende österreichische Schulnote mit Wort ausgibt.', 'Ist die Eingabe kleiner als 0 oder größer als 100, soll stattdessen „Ungültige Eingabe“ erscheinen.'],
            req: ['Punkte mit dem Scanner (`nextInt()`) einlesen', 'Ungültige Werte (< 0 oder > 100) mit `||` abfangen', 'Notengrenzen: ab 90 → 1 Sehr gut, ab 78 → 2 Gut, ab 64 → 3 Befriedigend, ab 50 → 4 Genügend, sonst 5 Nicht genügend', 'Ausgabe von Note und Wort, z. B. „Note 2 – Gut“'],
            example: 'Punkte: 82\nNote 2 – Gut',
            starter: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Punkte: ");
        int punkte = sc.nextInt();
        // Prüfe hier die Punkte und gib die Note aus

`),
            solution: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Punkte: ");
        int punkte = sc.nextInt();
        if (punkte < 0 || punkte > 100) {
            System.out.println("Ungültige Eingabe");
        } else if (punkte >= 90) {
            System.out.println("Note 1 – Sehr gut");
        } else if (punkte >= 78) {
            System.out.println("Note 2 – Gut");
        } else if (punkte >= 64) {
            System.out.println("Note 3 – Befriedigend");
        } else if (punkte >= 50) {
            System.out.println("Note 4 – Genügend");
        } else {
            System.out.println("Note 5 – Nicht genügend");
        }`),
            tests: [
              { name: '95 Punkte', input: ['95'], expect: [{ re: '\\b1\\b|sehr gut', label: 'Note 1' }] },
              { name: '82 Punkte', input: ['82'], expect: [{ re: '\\b2\\b|(^|[^e])\\bgut', label: 'Note 2' }] },
              { name: 'Grenze 78', input: ['78'], expect: [{ re: '\\b2\\b', label: 'Note 2 bei 78' }] },
              { name: '70 Punkte', input: ['70'], expect: [{ re: '\\b3\\b|befriedigend', label: 'Note 3' }] },
              { name: 'Grenze 50', input: ['50'], expect: [{ re: '\\b4\\b|genügend', label: 'Note 4 bei 50' }] },
              { name: '20 Punkte', input: ['20'], expect: [{ re: '\\b5\\b|nicht genügend', label: 'Note 5' }] },
              { name: 'Ungültig (120)', input: ['120'], expect: [{ re: 'ungültig|ungueltig|falsch|fehler', label: '„Ungültige Eingabe“ bei 120' }] },
              { name: 'Ungültig (-5)', input: ['-5'], expect: [{ re: 'ungültig|ungueltig|falsch|fehler', label: '„Ungültige Eingabe“ bei -5' }] },
            ],
            codeChecks: [{ label: 'Oder-Verknüpfung || verwendet', re: '\\|\\|' }, { label: 'else if verwendet', re: 'else\\s+if' }],
            rubric: [['Programm kompiliert und läuft', 15], ['Punkte werden mit dem Scanner eingelesen', 15], ['Alle fünf Noten mit richtigen Grenzen', 45], ['Ungültige Eingaben werden mit || abgefangen', 15], ['Verständliche Ausgabe mit Note und Wort', 10]],
            tip: 'Prüf die ungültigen Werte ganz am Anfang der if-Kette – dann musst du dich danach nicht mehr darum kümmern.',
          },
        },
        { layout: 'code', console: 'clear', code: prog(R`
        Scanner sc = new Scanner(System.in);
        System.out.print("Punkte: ");
        int punkte = sc.nextInt();
        if (punkte < 0 || punkte > 100) {
            System.out.println("Ungültige Eingabe");
        } else if (punkte >= 90) {
            System.out.println("Note 1 – Sehr gut");
        } else if (punkte >= 78) {
            System.out.println("Note 2 – Gut");
        } else if (punkte >= 64) {
            System.out.println("Note 3 – Befriedigend");
        } else if (punkte >= 50) {
            System.out.println("Note 4 – Genügend");
        } else {
            System.out.println("Note 5 – Nicht genügend");
        }`), run: true, input: ['105'], hl: [8, 9], say: 'So könnte die Lösung aussehen. Die Prüfung auf ungültige Werte steht ganz oben – 105 Punkte werden sofort abgefangen.' },
        { layout: 'visual', visual: { kind: 'bullets', title: 'Das kannst du jetzt', items: ['Eingaben mit dem `Scanner` lesen', 'Werte vergleichen mit `== != < > <= >=`', 'Entscheiden mit `if`, `else if` und `else`', 'Bedingungen verknüpfen mit `&&`, `||` und `!`', 'Texte richtig vergleichen mit `equals`', 'Zahlen formatieren mit `printf`'], gap: 0.7 }, say: 'Das war Lektion 3! Dein Programm kann jetzt zuhören und entscheiden. In Lektion 4 lernst du **Schleifen** – damit wiederholst du Dinge, ohne sie hundertmal hinzuschreiben.' },
      ],
    },
  ],
};
