// „Darf ich …?“ – versteht eine frei getippte Frage (offline, ohne Server)
// und beantwortet sie mit den Schonzeiten und Brittelmaßen der Länder.
//
// Kein großes Sprachmodell, sondern ein Stichwort-Erkenner: Fischnamen
// (mit Mundart und Tippfehlern), Gewässer, Datum, Länge und Bundesland
// werden aus dem Text gezogen. Was er nicht sicher erkennt, sagt er dazu.

import '../data/fische.dart';
import '../data/gewaesser.dart' show zuordnung;
import '../models/bundesland.dart';
import '../models/fisch.dart';
import '../models/gewaesser.dart';

enum Ampel { ja, achtung, nein, info }

class DarfIchAntwort {
  DarfIchAntwort({
    required this.ampel,
    required this.titel,
    this.punkte = const [],
    this.verstanden = const [],
    this.fisch,
    this.gewaesser,
    required this.land,
    this.quelle,
    this.offen = const [],
    this.geschont = const [],
  });

  final Ampel ampel;
  final String titel;

  /// Gründe und Hinweise, wichtigste zuerst.
  final List<String> punkte;

  /// Was aus der Frage herausgelesen wurde (für die Chips „Verstanden“).
  final List<String> verstanden;

  final Fisch? fisch;
  final Gewaesser? gewaesser;
  final Bundesland land;

  /// (Titel, URL) der Rechtsquelle.
  final (String, String)? quelle;

  /// Bei „Was darf ich …?“: offene und geschonte Arten.
  final List<Fisch> offen;
  final List<Fisch> geschont;
}

/// Ergebnis der Texterkennung (auch einzeln testbar).
class DarfIchFrage {
  DarfIchFrage({
    this.fische = const [],
    this.gewaesser,
    this.land,
    required this.von,
    required this.bis,
    this.datumText = 'heute',
    this.datumErkannt = false,
    this.laengeCm,
    this.mitnehmen = false,
    this.wasDarfIch = false,
    this.unsicher = const [],
  });

  final List<Fisch> fische;
  final Gewaesser? gewaesser;
  final Bundesland? land;
  final DateTime von;
  final DateTime bis;
  final String datumText;
  final bool datumErkannt;
  final double? laengeCm;

  /// „mitnehmen“, „behalten“, „entnehmen“ … – dann zählt das Brittelmaß.
  final bool mitnehmen;

  /// „Was darf ich …“ ohne bestimmten Fisch.
  final bool wasDarfIch;

  /// Wörter, die vermutlich verschrieben waren („zandr“ → Zander).
  final List<String> unsicher;
}

class DarfIch {
  DarfIch(this._gewaesser);

  final List<Gewaesser> _gewaesser;

  // ── Text vorbereiten ──

  static String _norm(String s) => s
      .toLowerCase()
      .replaceAll('ß', 'ss')
      .replaceAll(RegExp(r'[^a-z0-9äöüé\s.]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// Umlaute auflösen, damit „aesche“ und „äsche“ gleich sind.
  static String _flach(String s) => s
      .replaceAll('ä', 'ae')
      .replaceAll('ö', 'oe')
      .replaceAll('ü', 'ue')
      .replaceAll('é', 'e');

  // ── Fische ──

  /// Zusätzliche Namen aus Mundart und Umgangssprache.
  static const _mundart = <String, String>{
    'forelle': 'bachforelle',
    'forellen': 'bachforelle',
    'bachforelle': 'bachforelle',
    'regenbogner': 'regenbogenforelle',
    'saibling': 'bachsaibling',
    'saiblinge': 'bachsaibling',
    'seesaibling': 'seesaibling',
    'barsch': 'flussbarsch',
    'barsche': 'flussbarsch',
    'egli': 'flussbarsch',
    'kretzer': 'flussbarsch',
    'renke': 'reinanke',
    'renken': 'reinanke',
    'felchen': 'reinanke',
    'maraene': 'reinanke',
    'coregone': 'reinanke',
    'waller': 'wels',
    'quappe': 'aalrutte',
    'rutte': 'aalrutte',
    'ruetten': 'aalrutte',
    'trueschen': 'aalrutte',
    'trueschel': 'aalrutte',
    'doebel': 'aitel',
    'brasse': 'brachse',
    'brassen': 'brachse',
    'brachsen': 'brachse',
    'donaulachs': 'huchen',
    'schied': 'rapfen',
    'ploetze': 'rotauge',
    'ukelei': 'laube',
    'groppe': 'koppe',
    'mairenke': 'seelaube',
    'zaehrte': 'russnase',
    'aland': 'nerfling',
    'sonnenbarsch': 'sonnenbarsch',
    'graser': 'graskarpfen',
    'amur': 'graskarpfen',
    'karpf': 'karpfen',
    'spiegelkarpfen': 'karpfen',
    'schuppenkarpfen': 'karpfen',
  };

  static Map<String, Fisch>? _fischIndex;

  static Map<String, Fisch> get _fischNamen {
    if (_fischIndex != null) return _fischIndex!;
    final byId = {for (final f in fische) f.id: f};
    final m = <String, Fisch>{};
    void dazu(String name, Fisch f) {
      final n = _flach(_norm(name));
      if (n.length < 3) return;
      m.putIfAbsent(n, () => f);
      // Mehrzahl: Hechte, Zander, Forellen, Barben, Aitel …
      for (final endung in ['e', 'n', 'en', 's', 'er']) {
        m.putIfAbsent('$n$endung', () => f);
      }
    }

    for (final f in fische) {
      dazu(f.id.replaceAll('_', ' '), f);
      // "Wels (Waller)", "Aalrutte (Quappe, Trüsche)"
      final teile = f.name.split(RegExp(r'[(),]'));
      for (final t in teile) {
        if (t.trim().isNotEmpty) dazu(t.trim(), f);
      }
    }
    for (final e in _mundart.entries) {
      final f = byId[e.value];
      if (f != null) m[e.key] = f;
    }
    return _fischIndex = m;
  }

  // ── Gewässer ──

  static const _keinGewaesser = {
    'see', 'bach', 'teich', 'fluss', 'heute', 'morgen', 'hecht', 'zander',
    'karpfen', 'forelle', 'wels', 'mai', 'juni', 'juli', 'oberoesterreich',
    'salzburg', 'tirol', 'wien', 'kaernten', 'steiermark', 'burgenland',
    'vorarlberg', 'niederoesterreich', 'graben', 'kanal', 'alte', 'weiher',
    'darf', 'ich', 'fangen', 'fischen', 'angeln', 'mitnehmen', 'einen',
  };

  Map<String, List<Gewaesser>>? _gewIndex;

  /// "Inn bei Braunau" → "inn bei braunau" und "inn"; "Mühlbach (Lochen)"
  /// → "mühlbach lochen" und "mühlbach".
  Map<String, List<Gewaesser>> get _gewaesserNamen {
    if (_gewIndex != null) return _gewIndex!;
    final m = <String, List<Gewaesser>>{};
    void dazu(String name, Gewaesser g) {
      final n = _flach(_norm(name));
      if (n.length < 3 || _keinGewaesser.contains(n)) return;
      (m[n] ??= []).add(g);
    }

    for (final g in _gewaesser) {
      dazu(g.name, g);
      dazu(g.anzeigeName, g);
      // Teile wie "Ibmer See / Heratinger See"
      for (final t in g.name.split(RegExp(r' / |\(|\)'))) {
        if (t.trim().isNotEmpty) dazu(t.trim(), g);
      }
      // Namen aus der Karte, die das geprüfte Gewässer ersetzt
      for (final alt in zuordnung[g.id]?.osmNamen ?? const <String>[]) {
        dazu(alt, g);
      }
      // Kurzform ohne "bei …": "Inn bei Braunau" → "Inn"
      final bei = RegExp(r'^(.+?) (bei|in|im|an der|am) ').firstMatch(g.name);
      if (bei != null) dazu(bei.group(1)!, g);
    }
    return _gewIndex = m;
  }

  // ── Bundesländer ──

  static const _laender = <String, Bundesland>{
    'wien': Bundesland.wien,
    'niederoesterreich': Bundesland.noe,
    'noe': Bundesland.noe,
    'burgenland': Bundesland.bgld,
    'oberoesterreich': Bundesland.ooe,
    'ooe': Bundesland.ooe,
    'salzburg': Bundesland.sbg,
    'steiermark': Bundesland.stmk,
    'stmk': Bundesland.stmk,
    'kaernten': Bundesland.ktn,
    'tirol': Bundesland.tirol,
    'osttirol': Bundesland.tirol,
    'vorarlberg': Bundesland.vbg,
  };

  // ── Datum ──

  static const _monate = {
    'jaenner': 1, 'januar': 1, 'jan': 1, 'feber': 2, 'februar': 2, 'feb': 2,
    'maerz': 3, 'april': 4, 'apr': 4, 'mai': 5, 'juni': 6, 'jun': 6,
    'juli': 7, 'jul': 7, 'august': 8, 'aug': 8, 'september': 9, 'sept': 9,
    'oktober': 10, 'okt': 10, 'november': 11, 'nov': 11, 'dezember': 12,
    'dez': 12,
  };
  static const _wochentage = {
    'montag': 1, 'dienstag': 2, 'mittwoch': 3, 'donnerstag': 4,
    'freitag': 5, 'samstag': 6, 'sonntag': 7, 'wochenende': 6,
  };

  /// Kleine Tippfehler verzeihen: Abstand ≤ 1 (≤ 2 bei langen Wörtern).
  static bool _aehnlich(String a, String b) {
    if (a == b) return true;
    if ((a.length - b.length).abs() > 2) return false;
    final grenze = b.length >= 8 ? 2 : 1;
    final d = List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));
    for (var i = 0; i <= a.length; i++) {
      d[i][0] = i;
    }
    for (var j = 0; j <= b.length; j++) {
      d[0][j] = j;
    }
    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final k = a[i - 1] == b[j - 1] ? 0 : 1;
        d[i][j] = [d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + k]
            .reduce((x, y) => x < y ? x : y);
      }
    }
    return d[a.length][b.length] <= grenze;
  }

  /// Zerlegt die Frage in ihre Bestandteile.
  DarfIchFrage verstehen(String text, DateTime jetzt) {
    final roh = _norm(text);
    final flach = _flach(roh);
    final woerter = flach.split(' ').where((w) => w.isNotEmpty).toList();
    final heute = DateTime(jetzt.year, jetzt.month, jetzt.day);
    final unsicher = <String>[];

    // Länge: "45 cm", "45cm", "45er", "45 zentimeter"
    double? laenge;
    final l = RegExp(r'(\d{1,3}(?:[.,]\d)?)\s*(cm|zentimeter|zenti|er\b)')
        .firstMatch(roh.replaceAll(',', '.'));
    if (l != null) laenge = double.tryParse(l.group(1)!.replaceAll(',', '.'));

    final mitnehmen = RegExp(
            r'mitnehm|mitnahm|behalt|entnehm|entnahm|essen|abschlag|toeten|mit heim|mit nach hause')
        .hasMatch(flach);

    // Gewässer: längste passende Wortfolge (bis 5 Wörter)
    Gewaesser? gew;
    var belegt = <int>{};
    var besteLaenge = 0;
    for (var n = 5; n >= 1 && gew == null; n--) {
      for (var i = 0; i + n <= woerter.length; i++) {
        final stueck = woerter.sublist(i, i + n).join(' ');
        final treffer = _gewaesserNamen[stueck];
        if (treffer == null || treffer.isEmpty) continue;
        // Kurze Einzelwörter nur nach "am/im/an/in der/bei"
        if (n == 1 && stueck.length < 5) {
          final davor = i > 0 ? woerter[i - 1] : '';
          if (!{'am', 'im', 'an', 'der', 'die', 'den', 'bei', 'zum', 'zur'}
              .contains(davor)) {
            continue;
          }
        }
        if (_fischNamen.containsKey(stueck)) continue;
        gew = _wahl(treffer);
        besteLaenge = n;
        belegt = {for (var k = i; k < i + n; k++) k};
        break;
      }
    }

    // Fische: genaue Treffer, dann mit kleinem Tippfehler
    final gefunden = <Fisch>[];
    for (var i = 0; i < woerter.length; i++) {
      if (belegt.contains(i)) continue;
      // Zwei-Wort-Namen zuerst ("kleine maraene")
      if (i + 1 < woerter.length) {
        final zwei = '${woerter[i]} ${woerter[i + 1]}';
        final f2 = _fischNamen[zwei];
        if (f2 != null) {
          if (!gefunden.contains(f2)) gefunden.add(f2);
          i++;
          continue;
        }
      }
      final w = woerter[i];
      final f = _fischNamen[w];
      if (f != null) {
        if (!gefunden.contains(f)) gefunden.add(f);
        continue;
      }
      if (w.length >= 5 && !_monate.containsKey(w) &&
          !_wochentage.containsKey(w) && !_laender.containsKey(w)) {
        for (final e in _fischNamen.entries) {
          if (e.key.length >= 5 && _aehnlich(w, e.key)) {
            if (!gefunden.contains(e.value)) gefunden.add(e.value);
            unsicher.add('„$w“ → ${e.value.name.split(' (').first}');
            break;
          }
        }
      }
    }

    // Bundesland
    Bundesland? land;
    for (final w in woerter) {
      land ??= _laender[w];
    }
    land ??= gew?.land;

    // Datum
    var von = heute, bis = heute;
    var datumText = 'heute';
    var erkannt = false;
    final datum = RegExp(r'\b(\d{1,2})\.\s?(\d{1,2})\.?(\d{2,4})?\b').firstMatch(roh);
    final datumWort =
        RegExp(r'\b(\d{1,2})\.?\s+([a-zäöü]+)').allMatches(flach).where((m) =>
            _monate.containsKey(m.group(2)));
    if (datum != null) {
      final t = int.parse(datum.group(1)!), m = int.parse(datum.group(2)!);
      var j = datum.group(3) == null ? heute.year : int.parse(datum.group(3)!);
      if (j < 100) j += 2000;
      if (m >= 1 && m <= 12 && t >= 1 && t <= 31) {
        var d = DateTime(j, m, t);
        if (datum.group(3) == null && d.isBefore(heute)) d = DateTime(j + 1, m, t);
        von = bis = d;
        datumText = 'am $t.$m.';
        erkannt = true;
      }
    } else if (datumWort.isNotEmpty) {
      final m = datumWort.first;
      final t = int.parse(m.group(1)!), mo = _monate[m.group(2)]!;
      var d = DateTime(heute.year, mo, t);
      if (d.isBefore(heute)) d = DateTime(heute.year + 1, mo, t);
      von = bis = d;
      datumText = 'am $t.$mo.';
      erkannt = true;
    } else if (woerter.contains('uebermorgen')) {
      von = bis = heute.add(const Duration(days: 2));
      datumText = 'übermorgen';
      erkannt = true;
    } else if (woerter.contains('morgen')) {
      von = bis = heute.add(const Duration(days: 1));
      datumText = 'morgen';
      erkannt = true;
    } else if (woerter.contains('heute') || woerter.contains('jetzt') ||
        woerter.contains('gerade')) {
      erkannt = true;
    } else {
      for (final w in woerter) {
        final wt = _wochentage[w];
        if (wt != null) {
          var d = heute;
          while (d.weekday != wt) {
            d = d.add(const Duration(days: 1));
          }
          von = bis = d;
          if (w == 'wochenende') bis = d.add(const Duration(days: 1));
          datumText = w == 'wochenende'
              ? 'am Wochenende'
              : 'am ${w[0].toUpperCase()}${w.substring(1)}';
          erkannt = true;
          break;
        }
        final mo = _monate[w];
        if (mo != null && (w.length > 3 || w == 'mai')) {
          var j = heute.year;
          if (mo < heute.month) j++;
          von = mo == heute.month && j == heute.year ? heute : DateTime(j, mo);
          bis = DateTime(j, mo + 1, 0);
          datumText = 'im ${w[0].toUpperCase()}${w.substring(1)}'
              .replaceAll('Jaenner', 'Jänner')
              .replaceAll('Maerz', 'März');
          erkannt = true;
          break;
        }
      }
    }

    final wasDarfIch = gefunden.isEmpty &&
        RegExp(r'\bwas\b|welche|offen|erlaubt|geht').hasMatch(flach);

    return DarfIchFrage(
      fische: gefunden,
      gewaesser: gew,
      land: land,
      von: von,
      bis: bis,
      datumText: datumText,
      datumErkannt: erkannt,
      laengeCm: laenge,
      mitnehmen: mitnehmen,
      wasDarfIch: wasDarfIch || (gefunden.isEmpty && besteLaenge > 0),
      unsicher: unsicher,
    );
  }

  /// Bei gleichnamigen Gewässern: geprüfte zuerst, dann das größte.
  Gewaesser _wahl(List<Gewaesser> treffer) {
    final l = [...treffer]..sort((a, b) {
        if (a.ausOsm != b.ausOsm) return a.ausOsm ? 1 : -1;
        return (b.groesse ?? 0).compareTo(a.groesse ?? 0);
      });
    return l.first;
  }

  // ── Antwort ──

  DarfIchAntwort fragen(String text, DateTime jetzt, Bundesland standard) {
    final f = verstehen(text, jetzt);
    final land = f.land ?? standard;
    final quelle = schonzeitQuellen[land];
    final verstanden = <String>[
      for (final x in f.fische) '🐟 ${x.name.split(' (').first}',
      if (f.gewaesser != null) '🌊 ${f.gewaesser!.anzeigeName}',
      '📍 ${land.name}${f.land == null ? ' (Standard)' : ''}',
      '📅 ${f.datumText}',
      if (f.laengeCm != null) '📏 ${_zahl(f.laengeCm!)} cm',
    ];

    // Nichts Brauchbares erkannt
    if (f.fische.isEmpty && !f.wasDarfIch) {
      return DarfIchAntwort(
        ampel: Ampel.info,
        titel: 'Das habe ich nicht ganz verstanden',
        punkte: const [
          'Nenne einen Fisch, z. B. „Darf ich heute Zander fangen?“',
          'Mit Gewässer: „Darf ich morgen am Inn einen Hecht mitnehmen?“',
          'Mit Länge: „Darf ich eine 32 cm Forelle behalten?“',
          'Oder: „Was darf ich im Mai an der Mattig fangen?“',
        ],
        verstanden: verstanden,
        land: land,
        quelle: quelle,
      );
    }

    // "Was darf ich …?" → Liste
    if (f.fische.isEmpty) {
      final kandidaten = f.gewaesser != null && f.gewaesser!.fischarten.isNotEmpty
          ? f.gewaesser!.fischarten
              .map((id) => fische.where((x) => x.id == id).firstOrNull)
              .whereType<Fisch>()
              .toList()
          : fische.where((x) => !x.ausgestorben && !x.eingeschleppt).toList();
      final offen = <Fisch>[], zu = <Fisch>[];
      for (final x in kandidaten) {
        final r = x.regel(land);
        final geschont = r.ganzjaehrigGeschont || _geschontImZeitraum(r, f.von, f.bis);
        (geschont ? zu : offen).add(x);
      }
      return DarfIchAntwort(
        ampel: Ampel.info,
        titel: f.gewaesser != null
            ? '${f.datumText[0].toUpperCase()}${f.datumText.substring(1)} am ${f.gewaesser!.anzeigeName}'
            : '${f.datumText[0].toUpperCase()}${f.datumText.substring(1)} ${_in(land)}',
        punkte: [
          if (f.gewaesser != null && !f.gewaesser!.fischQuelle.sicher)
            'Die Fischarten sind für dieses Gewässer nur typisch, nicht geprüft.',
          'Du brauchst eine gültige Fischerkarte und eine Lizenz fürs Revier. '
              'Im Revier können strengere Regeln gelten.',
        ],
        verstanden: verstanden,
        gewaesser: f.gewaesser,
        land: land,
        quelle: quelle,
        offen: offen,
        geschont: zu,
      );
    }

    final fisch = f.fische.first;
    final r = fisch.regel(land);
    final punkte = <String>[];
    var ampel = Ampel.ja;
    void nein(String s) {
      ampel = Ampel.nein;
      punkte.insert(0, s);
    }

    void achtung(String s) {
      if (ampel == Ampel.ja) ampel = Ampel.achtung;
      punkte.add(s);
    }

    final name = fisch.name.split(' (').first;

    if (fisch.ausgestorben) {
      nein('$name gilt in Österreich als ausgestorben oder verschollen. '
          'Falls du einen fängst: sofort schonend zurücksetzen und dem '
          'Landesfischereiverband melden.');
    } else if (r.ganzjaehrigGeschont) {
      nein('$name ist ${_in(land)} ganzjährig geschont – '
          'gefangen? Sofort schonend zurücksetzen.');
    } else if (r.unbekannt) {
      achtung('Für $name ${_in(land)} haben wir keine gesicherten Daten. '
          'Bitte beim Revier nachfragen.');
    } else {
      final ganzOffen = !_geschontImZeitraum(r, f.von, f.bis);
      final ganzZu = _ganzGeschont(r, f.von, f.bis);
      if (ganzZu) {
        final bis = r.bis!;
        final tage = r.tageBisOffen(f.von);
        nein('Schonzeit: ${r.schonzeitText} – $name ist ${f.datumText} geschont'
            '${tage != null && f.datumText == 'heute' ? ' (noch $tage Tage, ab ${_naechster(bis)} wieder offen)' : ''}.');
      } else if (!ganzOffen) {
        achtung('Teilweise Schonzeit: ${r.schonzeitText}. '
            '${f.datumText[0].toUpperCase()}${f.datumText.substring(1)} ist nur ein Teil erlaubt.');
      } else if (r.von != null) {
        punkte.add('Keine Schonzeit ${f.datumText} (Schonzeit ist ${r.schonzeitText}).');
        final bald = r.tageBisSchonzeit(f.von);
        if (bald != null && bald <= 14) {
          achtung('Achtung: In $bald Tagen beginnt die Schonzeit.');
        }
      } else {
        punkte.add('$name hat ${_in(land)} keine Schonzeit.');
      }

      // Brittelmaß
      final mm = r.mindestmassCm;
      if (mm != null) {
        if (f.laengeCm != null) {
          if (f.laengeCm! < mm) {
            nein('Zu klein: Brittelmaß ist $mm cm, dein Fisch hat ${_zahl(f.laengeCm!)} cm '
                '– schonend zurücksetzen.');
          } else {
            punkte.add('Länge passt: ${_zahl(f.laengeCm!)} cm ≥ Brittelmaß $mm cm.');
          }
        } else {
          punkte.add('Mitnehmen erst ab $mm cm (Brittelmaß).');
        }
      } else if (f.mitnehmen || f.laengeCm != null) {
        punkte.add('Kein gesetzliches Brittelmaß.');
      }
    }

    if (r.hinweis != null && !r.unbekannt) achtung(r.hinweis!);
    if (fisch.geschuetzt && !r.ganzjaehrigGeschont) {
      achtung('Nach EU-Recht geschützte Art – möglichst schonend zurücksetzen.');
    }
    if (fisch.eingeschleppt) {
      punkte.add('Nicht heimische Art – in manchen Revieren gilt Entnahmepflicht.');
    }
    final g = f.gewaesser;
    if (g != null && g.fischQuelle.sicher && g.fischarten.isNotEmpty &&
        !g.fischarten.contains(fisch.id)) {
      achtung('$name ist für ${g.anzeigeName} nicht als Fischart eingetragen.');
    }
    if (f.fische.length > 1) {
      punkte.add('Du hast mehrere Fische genannt – die Antwort gilt für $name. '
          'Tippe auf einen anderen Fisch, um ihn zu prüfen.');
    }
    if (f.unsicher.isNotEmpty) {
      punkte.add('Verstanden als: ${f.unsicher.join(', ')}.');
    }
    punkte.add('Du brauchst eine gültige Fischerkarte und eine Lizenz fürs Revier. '
        'Im Revier können strengere Regeln gelten.');

    final titel = switch (ampel) {
      Ampel.nein => f.laengeCm != null && !r.ganzjaehrigGeschont &&
              !_ganzGeschont(r, f.von, f.bis) && !fisch.ausgestorben
          ? 'Nein – zurücksetzen'
          : 'Nein, $name ist ${f.datumText} geschont',
      Ampel.achtung => 'Ja, aber mit Einschränkungen',
      Ampel.ja => f.mitnehmen || f.laengeCm != null
          ? 'Ja, du darfst ihn mitnehmen'
          : 'Ja, $name ist ${f.datumText} offen',
      Ampel.info => '',
    };

    return DarfIchAntwort(
      ampel: ampel,
      titel: titel,
      punkte: punkte,
      verstanden: verstanden,
      fisch: fisch,
      gewaesser: g,
      land: land,
      quelle: quelle,
    );
  }

  static bool _geschontImZeitraum(Regel r, DateTime von, DateTime bis) {
    for (var d = von; !d.isAfter(bis); d = d.add(const Duration(days: 1))) {
      if (r.istGeschont(d) == true) return true;
    }
    return false;
  }

  static bool _ganzGeschont(Regel r, DateTime von, DateTime bis) {
    for (var d = von; !d.isAfter(bis); d = d.add(const Duration(days: 1))) {
      if (r.istGeschont(d) != true) return false;
    }
    return true;
  }

  static String _naechster(Tag bis) {
    final t = DateTime(2001, bis.monat, bis.tag).add(const Duration(days: 1));
    return '${t.day}.${t.month}.';
  }

  /// „in Tirol“, aber „im Burgenland“.
  static String _in(Bundesland l) =>
      l == Bundesland.bgld ? 'im Burgenland' : 'in ${l.name}';

  static String _zahl(double z) =>
      z == z.roundToDouble() ? z.toStringAsFixed(0) : z.toString().replaceAll('.', ',');
}
