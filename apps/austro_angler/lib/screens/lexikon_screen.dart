import 'package:flutter/material.dart';

import '../data/bilder.dart';
import '../data/fische.dart';
import '../data/gewaesser.dart';
import '../data/koeder.dart';
import '../models/bundesland.dart';
import '../services/alle_gewaesser.dart';
import '../services/fang_dienst.dart';
import '../services/wecker.dart';
import '../main.dart';
import '../models/fisch.dart';
import '../models/gewaesser.dart';
import 'bestimmung_screen.dart';
import 'gewaesser_screen.dart';
import 'glossar_screen.dart';
import 'widgets.dart';

/// Teilt den Merkmal-Text in einzelne Punkte (an Kommas und Satzenden).
List<String> merkmalPunkte(String text) {
  final punkte = <String>[];
  for (final satz in text.split(RegExp(r'(?<=[.!])\s+'))) {
    final teile = satz.replaceAll(RegExp(r'[.!]$'), '').split(RegExp(r',\s+'));
    // Kurze Sätze ohne Aufzählung bleiben zusammen.
    punkte.addAll(teile.where((t) => t.trim().isNotEmpty).map((t) {
      final s = t.trim();
      return s[0].toUpperCase() + s.substring(1);
    }));
  }
  return punkte;
}

/// Geprüfte Gewässer, in denen es diesen Fisch gibt – nächstes zu Braunau zuerst.
List<Gewaesser> gewaesserMit(Fisch fisch) =>
    gewaesserListe.where((g) => g.fischarten.contains(fisch.id)).toList()
      ..sort((a, b) => kmVonBraunau(a).compareTo(kmVonBraunau(b)));

enum _FischFilter {
  alle('Alle'),
  raub('Raubfische'),
  fried('Friedfische'),
  offen('Heute offen'),
  geschuetzt('Geschützt'),
  fremd('Nicht heimisch'),
  ausgestorben('Ausgestorben');

  const _FischFilter(this.text);

  final String text;
}

class LexikonScreen extends StatefulWidget {
  const LexikonScreen({super.key});

  @override
  State<LexikonScreen> createState() => _LexikonScreenState();
}

class _LexikonScreenState extends State<LexikonScreen> {
  String _suche = '';
  var _filter = _FischFilter.alle;

  @override
  Widget build(BuildContext context) {
    final land = SpeicherScope.of(context).bundesland;
    final heute = DateTime.now();
    final suche = _suche.toLowerCase();
    final liste = fische.where((f) {
      if (suche.isNotEmpty &&
          !f.name.toLowerCase().contains(suche) &&
          !f.familie.toLowerCase().contains(suche)) {
        return false;
      }
      return switch (_filter) {
        _FischFilter.alle => !f.ausgestorben,
        _FischFilter.raub => f.raubfisch && !f.ausgestorben,
        _FischFilter.fried => !f.raubfisch && !f.ausgestorben,
        _FischFilter.offen => f.regel(land).istGeschont(heute) == false,
        _FischFilter.geschuetzt => f.geschuetzt,
        _FischFilter.fremd => f.eingeschleppt,
        _FischFilter.ausgestorben => f.ausgestorben,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Fischlexikon (${fische.length} Arten)'),
        actions: [
          IconButton(
            tooltip: 'Welcher Fisch ist das?',
            icon: const Icon(Icons.manage_search),
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BestimmungScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const BundeslandWahl(),
          const JunganglerTipp(
              'Schonzeit = in dieser Zeit darf der Fisch nicht gefangen werden. '
              'Brittelmaß = so lang muss er mindestens sein.'),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Fisch oder Familie suchen',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _suche = v.trim()),
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final f in _FischFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(f.text),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
          Text('${liste.length} Arten',
              style: Theme.of(context).textTheme.labelLarge),
          if (liste.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Nichts gefunden.', textAlign: TextAlign.center),
            ),
          for (final f in liste)
            Card(
              child: ListTile(
                leading: fischBilder[f.id] == null
                    ? const CircleAvatar(child: Icon(Icons.set_meal))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          fischBilder[f.id]!.pfad,
                          width: 56,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                title: Text([
                  f.name,
                  if (f.geschuetzt) '🛡️',
                  if (f.eingeschleppt) '🌍',
                  if (f.ausgestorben) '✝',
                ].join(' ')),
                subtitle: Text(
                  'Schonzeit: ${f.regel(land).schonzeitText}\n'
                  'Brittelmaß: ${f.regel(land).mindestmassText}',
                ),
                isThreeLine: true,
                trailing: _StatusPunkt(f.regel(land).istGeschont(heute)),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => FischDetail(f)),
                ),
              ),
            ),
          const SizedBox(height: 8),
          const HinweisKarte(
            '🛡️ = geschützte Art · 🌍 = nicht heimisch · ✝ = in Österreich '
            'ausgestorben.\n'
            '$schonzeitenStand. Bei vielen kleineren Arten sind die '
            'Schonzeiten noch nicht recherchiert ("unbekannt"). Einzelne '
            'Reviere haben oft strengere Regeln – die Lizenz gilt immer vor.',
          ),
        ],
      ),
    );
  }
}

class _StatusPunkt extends StatelessWidget {
  const _StatusPunkt(this.geschont);

  final bool? geschont;

  @override
  Widget build(BuildContext context) {
    final (farbe, text) = switch (geschont) {
      true => (Colors.red.shade600, 'Schonzeit'),
      false => (Colors.green.shade600, 'Offen'),
      null => (Colors.grey, '?'),
    };
    return Chip(
      label: Text(text, style: const TextStyle(color: Colors.white)),
      backgroundColor: farbe,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

class FischDetail extends StatelessWidget {
  const FischDetail(this.fisch, {super.key});

  final Fisch fisch;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(fisch.name),
        actions: [
          if (!fisch.ausgestorben)
            IconButton(
              tooltip: 'Im Schonzeit-Countdown zeigen',
              icon: Icon(SpeicherScope.of(context)
                      .lieblingsfische
                      .contains(fisch.id)
                  ? Icons.star
                  : Icons.star_border),
              onPressed: () => SpeicherScope.of(context)
                  .lieblingsfischUmschalten(fisch.id),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${fisch.familie} · ${fisch.raubfisch ? 'Raubfisch' : 'Friedfisch'}',
            style: text.labelLarge,
          ),
          const SizedBox(height: 16),
          if (fischBilder[fisch.id] case final bild?) ...[
            QuellenBild(bild, hoehe: 220),
            const SizedBox(height: 16),
          ],
          Text('Erkennungsmerkmale', style: text.titleMedium),
          const SizedBox(height: 4),
          for (final m in merkmalPunkte(fisch.merkmale))
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✔  '),
                  Expanded(child: Text(m)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          _Abschnitt('Lebensraum', fisch.lebensraum),
          _Abschnitt('Köder', fisch.koeder),
          if (koederTipps[fisch.id] case final tipps?) ...[
            Text('Köder-Ratgeber nach Jahreszeit', style: text.titleMedium),
            const SizedBox(height: 4),
            for (var i = 0; i < 4; i++)
              Card(
                color: i == jahreszeit(DateTime.now())
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: ListTile(
                  dense: true,
                  title: Text(jahreszeitNamen[i] +
                      (i == jahreszeit(DateTime.now()) ? '  (jetzt)' : '')),
                  subtitle: Text(tipps[i]),
                ),
              ),
            const SizedBox(height: 12),
          ],
          if (Wecker.unterstuetzt) _WeckerKnopf(fisch),
          Text('Schonzeit & Brittelmaß', style: text.titleMedium),
          const SizedBox(height: 8),
          Table(
            border: TableBorder.all(color: Theme.of(context).dividerColor),
            columnWidths: const {0: IntrinsicColumnWidth()},
            children: [
              const TableRow(children: [
                _Zelle('', fett: true),
                _Zelle('Schonzeit', fett: true),
                _Zelle('Brittelmaß', fett: true),
              ]),
              for (final b in Bundesland.values)
                TableRow(children: [
                  _Zelle(b.kurz, fett: true),
                  _Zelle(fisch.regel(b).schonzeitText),
                  _Zelle(fisch.regel(b).mindestmassText),
                ]),
            ],
          ),
          for (final e in fisch.regeln.entries)
            if (e.value.hinweis != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('${e.key.kurz}: ${e.value.hinweis}'),
              ),
          const SizedBox(height: 8),
          Text(schonzeitenStand, style: text.bodySmall),
          const SizedBox(height: 24),
          if (!fisch.ausgestorben) WoGibtEsIhn(fisch),
        ],
      ),
    );
  }
}

class _Abschnitt extends StatelessWidget {
  const _Abschnitt(this.titel, this.inhalt);

  final String titel;
  final String inhalt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titel, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(inhalt),
        ],
      ),
    );
  }
}

class _Zelle extends StatelessWidget {
  const _Zelle(this.text, {this.fett = false});

  final String text;
  final bool fett;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: fett ? const TextStyle(fontWeight: FontWeight.bold) : null,
      ),
    );
  }
}

class _WeckerKnopf extends StatefulWidget {
  const _WeckerKnopf(this.fisch);

  final Fisch fisch;

  @override
  State<_WeckerKnopf> createState() => _WeckerKnopfState();
}

class _WeckerKnopfState extends State<_WeckerKnopf> {
  bool? _an;

  @override
  void initState() {
    super.initState();
    Wecker.instanz.fische().then((f) {
      if (mounted) setState(() => _an = f.contains(widget.fisch.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final land = SpeicherScope.of(context).bundesland;
    final regel = widget.fisch.regel(land);
    if (regel.von == null || regel.bis == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: const Icon(Icons.alarm),
        title: const Row(children: [
          Flexible(child: Text('Schonzeit-Wecker')),
          SizedBox(width: 8),
          PremiumMarke(),
        ]),
        subtitle: Text('Erinnerung um 8 Uhr am Tag nach dem ${regel.bis}, wenn die '
            'Schonzeit in ${land.name} endet'),
        value: _an ?? false,
        onChanged: _an == null
            ? null
            : (_) async {
                final an =
                    await Wecker.instanz.umschalten(widget.fisch.id, land);
                if (mounted) setState(() => _an = an);
              },
      ),
    );
  }
}


enum _Sicherheit {
  alle('Alle'),
  sicher('✅ Sicher'),
  unsicher('❔ Nicht sicher');

  const _Sicherheit(this.text);

  final String text;
}

/// Alle Gewässer mit diesem Fisch, filterbar nach Ort und Sicherheit.
class WoGibtEsIhn extends StatefulWidget {
  const WoGibtEsIhn(this.fisch, {super.key});

  final Fisch fisch;

  @override
  State<WoGibtEsIhn> createState() => _WoGibtEsIhnState();
}

class _WoGibtEsIhnState extends State<WoGibtEsIhn> {
  var _sicherheit = _Sicherheit.sicher;
  bool _nurBezirk = true;
  String _suche = '';
  int _anzahl = 30;
  Map<String, int> _gefangen = const {};
  Set<String> _vonAnglern = const {};

  @override
  void initState() {
    super.initState();
    alleGewaesser.addListener(_neu);
    WidgetsBinding.instance.addPostFrameCallback((_) => _communityLaden());
  }

  @override
  void dispose() {
    alleGewaesser.removeListener(_neu);
    super.dispose();
  }

  void _neu() => setState(() {});

  Future<void> _communityLaden() async {
    if (!mounted || KontoScope.of(context) == null) return;
    try {
      final gefangen = await fangDienst.gewaesserMitFang(widget.fisch.id);
      final infos =
          await fangDienst.gewaesserMitFischLautInfos(widget.fisch.id);
      if (mounted) {
        setState(() {
          _gefangen = {
            for (final e in gefangen.entries) e.key.toLowerCase(): e.value,
          };
          _vonAnglern = infos;
        });
      }
    } catch (_) {}
  }

  /// Warum der Fisch hier vorkommen soll – oder null.
  (bool sicher, String grund)? _grund(Gewaesser g) {
    final fang = _gefangen[g.anzeigeName.toLowerCase()];
    if (fang != null) return (true, '🎣 hier gefangen ($fang×)');
    if (_vonAnglern.contains(g.id)) return (true, '🙋 von Anglern (geprüft)');
    if (!g.fischarten.contains(widget.fisch.id)) return null;
    return (g.fischQuelle.sicher, '${g.fischQuelle.zeichen} ${g.fischQuelle.text}');
  }

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final text = Theme.of(context).textTheme;
    final suche = _suche.toLowerCase();
    final bezirk = _nurBezirk ? speicher.bezirk : '';
    final treffer = <(Gewaesser, String, bool)>[];
    var sicher = 0, unsicher = 0;
    for (final g in alleGewaesser.liste) {
      if (g.land != speicher.bundesland) continue;
      if (bezirk.isNotEmpty && g.bezirk != bezirk) continue;
      if (suche.isNotEmpty &&
          !g.name.toLowerCase().contains(suche) &&
          !g.ort.toLowerCase().contains(suche)) {
        continue;
      }
      final grund = _grund(g);
      if (grund == null) continue;
      grund.$1 ? sicher++ : unsicher++;
      if (_sicherheit == _Sicherheit.sicher && !grund.$1) continue;
      if (_sicherheit == _Sicherheit.unsicher && grund.$1) continue;
      treffer.add((g, grund.$2, grund.$1));
    }
    // Sichere und große Gewässer zuerst.
    treffer.sort((a, b) {
      final s = (b.$3 ? 1 : 0) - (a.$3 ? 1 : 0);
      if (s != 0) return s;
      return (b.$1.groesse ?? 999).compareTo(a.$1.groesse ?? 999);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Wo gibt es ${widget.fisch.name}?', style: text.titleMedium),
        Text(
          '${speicher.bundesland.name}'
          '${bezirk.isEmpty ? '' : ', Bezirk $bezirk'}: '
          '$sicher sicher, $unsicher nicht sicher',
          style: text.bodySmall,
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Gewässer oder Ort suchen',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => setState(() {
            _suche = v.trim();
            _anzahl = 30;
          }),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final s in _Sicherheit.values)
              ChoiceChip(
                label: Text(s.text),
                selected: _sicherheit == s,
                onSelected: (_) => setState(() {
                  _sicherheit = s;
                  _anzahl = 30;
                }),
              ),
            if (speicher.bezirk.isNotEmpty)
              FilterChip(
                label: Text('Nur Bezirk ${speicher.bezirk}'),
                selected: _nurBezirk,
                onSelected: (v) => setState(() => _nurBezirk = v),
              ),
          ],
        ),
        const SizedBox(height: 4),
        if (!alleGewaesser.geladen)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (treffer.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Keine Gewässer gefunden. Probier einen anderen '
                'Filter oder wähle oben ein anderes Bundesland.'),
          ),
        for (final (g, grund, _) in treffer.take(_anzahl))
          Card(
            child: ListTile(
              dense: true,
              leading: Icon(g.typ.fliesst ? Icons.waves : Icons.water),
              title: Text(g.name),
              subtitle: Text('${g.typ.name} · ${g.ort}\n$grund',
                  maxLines: 3, overflow: TextOverflow.ellipsis),
              isThreeLine: true,
              trailing: g.preise.isEmpty
                  ? null
                  : Text(g.preise.first.euroText, style: text.titleSmall),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => GewaesserDetail(g)),
              ),
            ),
          ),
        if (treffer.length > _anzahl)
          TextButton(
            onPressed: () => setState(() => _anzahl += 50),
            child: Text('Mehr anzeigen (${treffer.length - _anzahl} weitere)'),
          ),
        const SizedBox(height: 4),
        Text(
          '✅ Geprüft · 📚 Fachquellen · 🎣 Fänge der Community · 🙋 von Anglern '
          'ergänzt – alles "sicher". ❔ = nur typisch für diesen Gewässertyp, '
          'also nicht sicher.',
          style: text.bodySmall,
        ),
      ],
    );
  }
}
