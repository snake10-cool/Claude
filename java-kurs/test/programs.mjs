// Testprogramme für den Vergleich mit echtem Java. Jedes Programm heißt Main.
const M = (body, extra = '', imports = '') => `${imports}public class Main {\n${extra}\n  public static void main(String[] args) {\n${body}\n  }\n}\n`;

export const PROGRAMS = [
  { name: 'hallo', src: M('System.out.println("Hallo Welt!");\nSystem.out.print("A");\nSystem.out.print("B\\n");\nSystem.out.println();') },
  { name: 'rechnen', src: M('int a = 17, b = 5;\nSystem.out.println(a + b);\nSystem.out.println(a - b);\nSystem.out.println(a * b);\nSystem.out.println(a / b);\nSystem.out.println(a % b);\nSystem.out.println(-a / b);\nSystem.out.println(-a % b);\ndouble c = a / 2.0;\nSystem.out.println(c);\nSystem.out.println(a / 2 * 2.0);\nSystem.out.println(1 + 2 + "x" + 1 + 2);\nSystem.out.println("x" + (1 + 2));') },
  { name: 'doubles', src: M('System.out.println(0.1 + 0.2);\nSystem.out.println(10.0 / 3);\nSystem.out.println(1e10);\nSystem.out.println(123456789.0);\nSystem.out.println(0.0001);\nSystem.out.println(5.0);\nSystem.out.println(1.0 / 0);\nSystem.out.println(-1.0 / 0);\nSystem.out.println(0.0 / 0);\nSystem.out.println(2.5e-5);\nSystem.out.println(1234567.0);\nSystem.out.println(12345678.9);\nSystem.out.println(100.0 * 1.1);\nfloat f = 0.1f + 0.2f;\nSystem.out.println(f);\nSystem.out.println(3.0f / 7);\nSystem.out.println((double) 3.14f);') },
  { name: 'intoverflow', src: M('int x = Integer.MAX_VALUE;\nx++;\nSystem.out.println(x);\nint y = 50000 * 50000;\nSystem.out.println(y);\nlong z = 50000L * 50000;\nSystem.out.println(z);\nSystem.out.println(Integer.MIN_VALUE - 1);\nSystem.out.println((int) 3.99);\nSystem.out.println((int) -3.99);\nSystem.out.println((int) 1e20);\nSystem.out.println((byte) 200);\nSystem.out.println((short) 70000);') },
  { name: 'chars', src: M('char c = \'A\';\nc++;\nSystem.out.println(c);\nSystem.out.println(c + 1);\nSystem.out.println((char) (c + 1));\nSystem.out.println("" + c + 1);\nchar d = 97;\nSystem.out.println(d);\nint code = \'z\';\nSystem.out.println(code);\nSystem.out.println(Character.isDigit(\'7\') + " " + Character.isLetter(\'7\') + " " + Character.toUpperCase(\'q\'));\nSystem.out.println(\'a\' + \'b\');\nSystem.out.println("" + \'a\' + \'b\');') },
  { name: 'strings', src: M('String s = "Hallo Java";\nSystem.out.println(s.length());\nSystem.out.println(s.charAt(1));\nSystem.out.println(s.toUpperCase());\nSystem.out.println(s.toLowerCase());\nSystem.out.println(s.substring(6));\nSystem.out.println(s.substring(0, 5));\nSystem.out.println(s.indexOf("Java"));\nSystem.out.println(s.indexOf(\'x\'));\nSystem.out.println(s.contains("lo"));\nSystem.out.println(s.replace("a", "4"));\nSystem.out.println(s.startsWith("Ha") + " " + s.endsWith("x"));\nSystem.out.println("  hi  ".trim() + "|");\nSystem.out.println("abc".compareTo("abd"));\nSystem.out.println("b".compareTo("a"));\nSystem.out.println("Apfel".compareTo("Apfelbaum"));\nSystem.out.println("ab".repeat(3));\nSystem.out.println(String.join("-", "a", "b", "c"));\nSystem.out.println("Hallo".equals("Hallo") + " " + "Hallo".equalsIgnoreCase("hallo"));\nSystem.out.println("".isEmpty());\nSystem.out.println("Java".hashCode());') },
  { name: 'stringident', src: M('String a = "hi";\nString b = "hi";\nString c = new String("hi");\nString d = "h";\nd = d + "i";\nSystem.out.println(a == b);\nSystem.out.println(a == c);\nSystem.out.println(a == d);\nSystem.out.println(a.equals(c));\nSystem.out.println(a.equals(d));') },
  { name: 'split', src: M('String[] t = "a,b,,c,,".split(",");\nSystem.out.println(t.length);\nfor (String x : t) System.out.println("[" + x + "]");\nString[] w = "Hallo schöne  Welt".split(" ");\nSystem.out.println(w.length);\nSystem.out.println(java.util.Arrays.toString("1 2 3".split(" ")));') },
  { name: 'ifelse', src: M('int note = 3;\nif (note == 1) {\n  System.out.println("Sehr gut");\n} else if (note <= 3) {\n  System.out.println("Passt");\n} else {\n  System.out.println("Hmm");\n}\nboolean b = note > 2 && note < 5;\nSystem.out.println(b);\nSystem.out.println(!b || note == 3);\nint max = note > 5 ? note : 5;\nSystem.out.println(max);\nif (note % 2 == 1) System.out.println("ungerade");') },
  { name: 'switch', src: M('for (int i = 0; i < 5; i++) {\n  switch (i) {\n    case 0: System.out.println("null"); break;\n    case 1:\n    case 2: System.out.println("eins/zwei");\n    case 3: System.out.println("drei (auch durchgefallen)"); break;\n    default: System.out.println("sonst");\n  }\n}\nString tag = "Sa";\nswitch (tag) {\n  case "Sa", "So" -> System.out.println("Wochenende");\n  default -> System.out.println("Arbeit");\n}') },
  { name: 'loops', src: M('int summe = 0;\nfor (int i = 1; i <= 10; i++) summe += i;\nSystem.out.println(summe);\nint n = 5;\nwhile (n > 0) { System.out.print(n + " "); n--; }\nSystem.out.println();\nint k = 0;\ndo { k += 3; } while (k < 10);\nSystem.out.println(k);\nfor (int i = 0; i < 10; i++) {\n  if (i == 3) continue;\n  if (i == 6) break;\n  System.out.print(i);\n}\nSystem.out.println();\nouter:\nfor (int i = 0; i < 3; i++) {\n  for (int j = 0; j < 3; j++) {\n    if (j == 2) continue outer;\n    if (i == 2) break outer;\n    System.out.print(i + "" + j + " ");\n  }\n}\nSystem.out.println();\nfor (int i = 1, j = 10; i < j; i += 3, j -= 2) System.out.print(i + ":" + j + " ");\nSystem.out.println();') },
  { name: 'einmaleins', src: M('for (int i = 1; i <= 5; i++) {\n  for (int j = 1; j <= 5; j++) {\n    System.out.printf("%4d", i * j);\n  }\n  System.out.println();\n}') },
  { name: 'arrays', src: M('int[] z = {5, 3, 9, 1};\nSystem.out.println(z.length);\nSystem.out.println(z[2]);\nz[0] = 42;\nint s = 0;\nfor (int x : z) s += x;\nSystem.out.println(s);\nSystem.out.println(java.util.Arrays.toString(z));\njava.util.Arrays.sort(z);\nSystem.out.println(java.util.Arrays.toString(z));\ndouble[] d = new double[3];\nSystem.out.println(java.util.Arrays.toString(d));\nString[] n = new String[2];\nSystem.out.println(n[0]);\nint[][] g = new int[3][4];\ng[1][2] = 7;\nSystem.out.println(g[1][2] + " " + g.length + " " + g[0].length);\nint[][] h = {{1, 2}, {3, 4, 5}};\nSystem.out.println(h[1][2] + " " + h[1].length);\nchar[] cs = {\'J\', \'a\', \'v\', \'a\'};\nSystem.out.println(cs);\nint[] copy = java.util.Arrays.copyOf(z, 6);\nSystem.out.println(java.util.Arrays.toString(copy));') },
  { name: 'arraybounds', src: M('int[] a = new int[3];\nSystem.out.println("vorher");\na[3] = 1;\nSystem.out.println("nachher");') },
  { name: 'divzero', src: M('int a = 5;\nint b = 0;\nSystem.out.println("start");\nSystem.out.println(a / b);') },
  { name: 'nullpointer', src: M('String s = null;\nSystem.out.println(s + "!");\nSystem.out.println(s.length());') },
  { name: 'parseint', src: M('System.out.println(Integer.parseInt("42") + 1);\nSystem.out.println(Double.parseDouble("3.5") * 2);\nSystem.out.println(Integer.parseInt("abc"));') },
  { name: 'methods', src: M('System.out.println(quadrat(7));\nSystem.out.println(max(3, 9));\nSystem.out.println(max(2.5, 1.5));\ngruss("Lena");\nSystem.out.println(fakultaet(10));\nSystem.out.println(fib(15));\nSystem.out.println(istGerade(4) + " " + istGerade(7));', `  static int quadrat(int x) { return x * x; }
  static int max(int a, int b) { if (a > b) return a; return b; }
  static double max(double a, double b) { return a > b ? a : b; }
  static void gruss(String name) { System.out.println("Servus " + name + "!"); }
  static long fakultaet(int n) { return n <= 1 ? 1 : n * fakultaet(n - 1); }
  static int fib(int n) { if (n < 2) return n; return fib(n - 1) + fib(n - 2); }
  static boolean istGerade(int n) { return n % 2 == 0; }`) },
  { name: 'printf', src: M('double pi = 3.14159265;\nSystem.out.printf("%.2f%n", pi);\nSystem.out.printf("%8.3f|%n", pi);\nSystem.out.printf("%-8d|%n", 42);\nSystem.out.printf("%05d%n", 42);\nSystem.out.printf("%s ist %d Jahre alt.%n", "Mia", 14);\nSystem.out.printf("%,d%n", 1234567);\nSystem.out.printf("%.0f %.1f %.2f%n", 2.5, 0.05, 1.005);\nSystem.out.printf("%x %X%n", 255, 255);\nSystem.out.printf("%c%c%n", \'J\', 65);\nSystem.out.printf("%b %10s|%-6s|%n", true, "rechts", "li");\nSystem.out.println(String.format("%.3f", 2.0 / 3));\nSystem.out.printf("%e%n", 12345.678);\nSystem.out.printf("100%%%n");\nSystem.out.printf("%+d %+.1f%n", 5, -2.25);') },
  { name: 'printfbad', src: M('System.out.printf("%d%n", 3.5);') },
  { name: 'math', src: M('System.out.println(Math.max(3, 8));\nSystem.out.println(Math.min(-1.5, 2));\nSystem.out.println(Math.abs(-7));\nSystem.out.println(Math.pow(2, 10));\nSystem.out.println(Math.sqrt(144));\nSystem.out.println(Math.round(2.5));\nSystem.out.println(Math.round(-2.5));\nSystem.out.println(Math.round(2.4));\nSystem.out.println(Math.floor(-1.1));\nSystem.out.println(Math.ceil(1.1));\nSystem.out.println(Math.PI);\nSystem.out.println((int) Math.pow(3, 4));\nSystem.out.println(Math.hypot(3, 4));') },
  { name: 'scanner', input: ['Mia', '14', '1.75'], src: M('Scanner sc = new Scanner(System.in);\nSystem.out.print("Name: ");\nString name = sc.nextLine();\nSystem.out.print("Alter: ");\nint alter = sc.nextInt();\nSystem.out.print("Größe: ");\ndouble g = sc.nextDouble();\nSystem.out.println(name + " ist " + alter + " und " + g + " m groß.");', '', 'import java.util.Scanner;\n') },
  { name: 'scannerline', input: ['7', 'Hallo du'], src: M('Scanner sc = new Scanner(System.in);\nint x = sc.nextInt();\nString rest = sc.nextLine();\nString zeile = sc.nextLine();\nSystem.out.println(x + "|" + rest + "|" + zeile);', '', 'import java.util.Scanner;\n') },
  { name: 'scannertokens', input: ['3 4 5', 'x'], src: M('Scanner sc = new Scanner(System.in);\nint s = 0;\nwhile (sc.hasNextInt()) s += sc.nextInt();\nSystem.out.println(s);\nSystem.out.println(sc.next());', '', 'import java.util.Scanner;\n') },
  { name: 'scannermismatch', input: ['abc'], src: M('Scanner sc = new Scanner(System.in);\nint x = sc.nextInt();\nSystem.out.println(x);', '', 'import java.util.Scanner;\n') },
  { name: 'trycatch', input: ['zwölf', '12'], src: M('Scanner sc = new Scanner(System.in);\nint zahl = -1;\nwhile (zahl < 0) {\n  try {\n    zahl = sc.nextInt();\n  } catch (InputMismatchException e) {\n    System.out.println("Keine Zahl: " + sc.next());\n  }\n}\nSystem.out.println(zahl);\ntry {\n  int[] a = new int[2];\n  a[5] = 1;\n} catch (ArrayIndexOutOfBoundsException e) {\n  System.out.println("Fehler: " + e.getMessage());\n} finally {\n  System.out.println("finally");\n}\ntry {\n  throw new IllegalArgumentException("zu klein");\n} catch (RuntimeException e) {\n  System.out.println(e);\n}', '', 'import java.util.*;\n') },
  { name: 'random', src: M('Random r = new Random(42);\nfor (int i = 0; i < 5; i++) System.out.print(r.nextInt(100) + " ");\nSystem.out.println();\nSystem.out.println(r.nextInt(16));\nSystem.out.println(r.nextDouble());\nSystem.out.println(r.nextBoolean());\nRandom w = new Random(7);\nSystem.out.println(w.nextInt(6) + 1);\nSystem.out.println(w.nextInt());', '', 'import java.util.Random;\n') },
  { name: 'arraylist', src: M('ArrayList<String> l = new ArrayList<>();\nl.add("Hecht");\nl.add("Forelle");\nl.add("Karpfen");\nSystem.out.println(l);\nSystem.out.println(l.size() + " " + l.get(1));\nl.remove("Forelle");\nl.add(0, "Zander");\nSystem.out.println(l + " " + l.contains("Hecht") + " " + l.indexOf("Karpfen"));\nfor (String f : l) System.out.print(f.length() + " ");\nSystem.out.println();\nArrayList<Integer> z = new ArrayList<>();\nfor (int i = 0; i < 5; i++) z.add(i * i);\nz.remove(1);\nint s = 0;\nfor (int x : z) s += x;\nSystem.out.println(z + " " + s);\nCollections.sort(l);\nSystem.out.println(l);\nArrayList<Double> d = new ArrayList<>();\nd.add(2.5);\nd.add(1.0);\nSystem.out.println(d);', '', 'import java.util.ArrayList;\nimport java.util.Collections;\n') },
  { name: 'listbounds', src: M('ArrayList<String> l = new ArrayList<>();\nl.add("a");\nSystem.out.println(l.get(1));', '', 'import java.util.ArrayList;\n') },
  { name: 'hashmap', src: M('HashMap<String, Integer> m = new HashMap<>();\nm.put("Hecht", 3);\nm.put("Forelle", 5);\nm.put("Hecht", m.get("Hecht") + 1);\nSystem.out.println(m.get("Hecht") + " " + m.get("Zander") + " " + m.containsKey("Forelle") + " " + m.size());\nSystem.out.println(m.getOrDefault("Aal", 0));', '', 'import java.util.HashMap;\n') },
  { name: 'classes', src: `class Hund {
  private String name;
  private int alter;
  static int anzahl = 0;
  Hund(String name, int alter) { this.name = name; this.alter = alter; anzahl++; }
  Hund(String name) { this(name, 1); }
  String getName() { return name; }
  void geburtstag() { alter++; }
  void bellen() { System.out.println(name + " sagt: Wuff!"); }
  public String toString() { return name + " (" + alter + ")"; }
}
public class Main {
  public static void main(String[] args) {
    Hund h = new Hund("Bello", 3);
    Hund k = new Hund("Luna");
    h.bellen();
    h.geburtstag();
    System.out.println(h);
    System.out.println(k.getName() + " " + Hund.anzahl);
    Hund[] alle = { h, k };
    for (Hund x : alle) System.out.println("- " + x);
    Hund n = null;
    System.out.println(n);
  }
}
` },
  { name: 'inheritance', src: `class Tier {
  protected String name;
  Tier(String name) { this.name = name; }
  String laut() { return "..."; }
  void sprich() { System.out.println(name + ": " + laut()); }
}
class Katze extends Tier {
  Katze(String n) { super(n); }
  @Override
  String laut() { return "Miau"; }
}
class Kuh extends Tier {
  Kuh(String n) { super(n); }
  String laut() { return "Muh" + super.laut(); }
}
public class Main {
  public static void main(String[] args) {
    Tier[] tiere = { new Katze("Mimi"), new Kuh("Berta"), new Tier("???") };
    for (Tier t : tiere) t.sprich();
    System.out.println(tiere[0] instanceof Katze);
    System.out.println(tiere[1] instanceof Katze);
    System.out.println(tiere[1] instanceof Tier);
  }
}
` },
  { name: 'equalsobj', src: `class Punkt {
  int x, y;
  Punkt(int x, int y) { this.x = x; this.y = y; }
  public boolean equals(Object o) { if (!(o instanceof Punkt)) return false; Punkt p = (Punkt) o; return x == p.x && y == p.y; }
  public String toString() { return "(" + x + "|" + y + ")"; }
}
public class Main {
  public static void main(String[] args) {
    Punkt a = new Punkt(1, 2), b = new Punkt(1, 2);
    System.out.println(a == b);
    System.out.println(a.equals(b));
    java.util.ArrayList<Punkt> l = new java.util.ArrayList<>();
    l.add(a);
    System.out.println(l.contains(b) + " " + l);
  }
}
` },
  { name: 'stringbuilder', src: M('StringBuilder sb = new StringBuilder();\nfor (int i = 0; i < 5; i++) sb.append(i).append(\',\');\nsb.deleteCharAt(sb.length() - 1);\nSystem.out.println(sb);\nSystem.out.println(new StringBuilder("Otto").reverse().toString().equals("ottO"));\nString s = "";\nfor (char c = \'a\'; c <= \'e\'; c++) s += c;\nSystem.out.println(s);') },
  { name: 'compound', src: M('int x = 10;\nx += 5;\nx -= 3;\nx *= 2;\nx /= 5;\nx %= 3;\nSystem.out.println(x);\nint y = 7;\ny += 2.9;\nSystem.out.println(y);\nint i = 5;\nint a = i++ + ++i;\nSystem.out.println(a + " " + i);\ndouble d = 1;\nd /= 4;\nSystem.out.println(d);\nString s = "a";\ns += 1 + 2;\nSystem.out.println(s);\nchar c = \'a\';\nc += 2;\nSystem.out.println(c);') },
  { name: 'ternaryprec', src: M('int a = 3, b = 4;\nSystem.out.println(a + b * 2 - 1);\nSystem.out.println((a + b) * 2);\nSystem.out.println(a > b ? "a" : a == b ? "gleich" : "b");\nSystem.out.println(10 - 4 - 3);\nSystem.out.println(100 / 10 / 5);\nSystem.out.println(a < b == true);\nSystem.out.println(1 << 4 | 3);\nSystem.out.println(-17 >> 2);\nSystem.out.println(-17 >>> 28);\nSystem.out.println(5 & 3 ^ 6);') },
  { name: 'staticerr', src: M('System.out.println(hallo());', '  int hallo() { return 1; }') },
  { name: 'notinit', src: M('int x;\nSystem.out.println(x);') },
  { name: 'typeerr', src: M('int x = 3.5;\nSystem.out.println(x);') },
  { name: 'missingsemi', src: M('int x = 3\nSystem.out.println(x);') },
  { name: 'stackoverflow', src: M('System.out.println(f(1));', '  static int f(int n) { return f(n + 1) + 1; }') },
  { name: 'charat', src: M('String s = "abc";\nSystem.out.println(s.charAt(3));') },
  { name: 'substringerr', src: M('String s = "abc";\nSystem.out.println(s.substring(2, 5));') },
  { name: 'userexception', src: `class ZuKaltException extends Exception {
  ZuKaltException(String m) { super(m); }
}
public class Main {
  static void pruefe(int grad) throws ZuKaltException { if (grad < 5) throw new ZuKaltException("Wasser zu kalt: " + grad); System.out.println("passt: " + grad); }
  public static void main(String[] args) {
    try { pruefe(12); pruefe(2); } catch (ZuKaltException e) { System.out.println("Gefangen: " + e.getMessage()); }
  }
}
` },
  { name: 'varargs', src: M('System.out.println(summe());\nSystem.out.println(summe(1, 2, 3));\nint[] z = {4, 5};\nSystem.out.println(summe(z));', '  static int summe(int... zahlen) { int s = 0; for (int z : zahlen) s += z; return s; }') },
  { name: 'var', src: M('var x = 5;\nvar s = "Text";\nvar d = 2.0;\nSystem.out.println(x + s + d);\nfor (var i = 0; i < 3; i++) System.out.print(i);\nSystem.out.println();') },
  { name: 'wrapper', src: M('Integer a = 5;\nint b = a + 2;\nSystem.out.println(b);\nDouble d = 2.0;\nSystem.out.println(d / 4);\nSystem.out.println(Integer.valueOf(7).equals(7));\nSystem.out.println(Integer.toBinaryString(10));\nSystem.out.println(Integer.MAX_VALUE);') },
  { name: 'longs', src: M('long big = 3_000_000_000L;\nSystem.out.println(big * 2);\nSystem.out.println(big / 7);\nlong ms = 1000L * 60 * 60 * 24 * 365;\nSystem.out.println(ms);\nint i = (int) big;\nSystem.out.println(i);') },
  { name: 'nestedsum', src: M('int[][] m = {{1,2,3},{4,5,6},{7,8,9}};\nint diag = 0;\nfor (int i = 0; i < m.length; i++) diag += m[i][i];\nSystem.out.println(diag);\nfor (int[] row : m) { for (int v : row) System.out.print(v + " "); System.out.println(); }\nSystem.out.println(java.util.Arrays.toString(m[1]));') },
  { name: 'gradecalc', input: ['3', '1', '2', '5'], src: M('Scanner sc = new Scanner(System.in);\nint n = sc.nextInt();\nint[] noten = new int[n];\ndouble summe = 0;\nfor (int i = 0; i < n; i++) { noten[i] = sc.nextInt(); summe += noten[i]; }\ndouble schnitt = summe / n;\nSystem.out.printf("Schnitt: %.2f%n", schnitt);\nString text = schnitt < 1.5 ? "Sehr gut" : schnitt < 2.5 ? "Gut" : "Befriedigend";\nSystem.out.println(text);', '', 'import java.util.Scanner;\n') },
];
