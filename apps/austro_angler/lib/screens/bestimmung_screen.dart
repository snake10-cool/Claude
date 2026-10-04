import 'package:flutter/material.dart';

import '../data/bestimmung.dart';
import '../data/bilder.dart';
import '../data/fische.dart';
import '../models/fisch.dart';
import 'lexikon_screen.dart';
import 'widgets.dart';

/// Fisch bestimmen: ein paar Fragen beantworten, die App zeigt passende Arten.
class BestimmungScreen extends StatefulWidget {
  const BestimmungScreen({super.key});

  @override
  State<BestimmungScreen> createState() => _BestimmungScreenState();
}

class _BestimmungScreenState extends State<BestimmungScreen> {
  KoerperForm? _form;
  bool? _fettflosse;
  int? _barteln;
  bool? _stachel;
  bool? _saugscheibe;
  Groesse? _groesse;
  bool? _rot;
  bool? _muster;

  int get _beantwortet => [
        _form,
        _fettflosse,
        _barteln,
        _stachel,
        _saugscheibe,
        _groesse,
        _rot,
        _muster,
      ].where((a) => a != null).length;

  /// Anzahl der Widersprüche zu den Antworten.
  int _fehler(Bestimmung b) {
    var f = 0;
    if (_form != null && b.form != _form) f++;
    if (_fettflosse != null && b.fettflosse != _fettflosse) f++;
    if (_barteln != null && b.barteln != _barteln) f++;
    if (_stachel != null && b.stachel != _stachel) f++;
    if (_saugscheibe != null && b.saugscheibe != _saugscheibe) f++;
    if (_groesse != null && b.groesse != _groesse) f++;
    if (_rot != null && b.rot != _rot) f++;
    if (_muster != null && b.muster != _muster) f++;
    return f;
  }

  void _zuruecksetzen() => setState(() {
        _form = null;
        _fettflosse = null;
        _barteln = null;
        _stachel = null;
        _saugscheibe = null;
        _groesse = null;
        _rot = null;
        _muster = null;
      });

  Widget _frage<T>(String titel, String? hilfe, T? wert,
      List<(T, String)> optionen, void Function(T?) setzen) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titel, style: text.titleSmall),
          if (hilfe != null) Text(hilfe, style: text.bodySmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final (w, t) in optionen)
                ChoiceChip(
                  label: Text(t),
                  selected: wert == w,
                  onSelected: (an) => setState(() => setzen(an ? w : null)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final kandidaten = <(Fisch, int)>[
      for (final f in fische)
        if (!f.ausgestorben && bestimmung[f.id] != null)
          (f, _fehler(bestimmung[f.id]!)),
    ]..sort((a, b) => a.$2.compareTo(b.$2));
    final passend = kandidaten.where((k) => k.$2 == 0).toList();
    final fastPassend = kandidaten.where((k) => k.$2 == 1).toList();
    const janein = [(true, 'Ja'), (false, 'Nein')];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcher Fisch ist das?'),
        actions: [
          if (_beantwortet > 0)
            IconButton(
              tooltip: 'Von vorne',
              icon: const Icon(Icons.refresh),
              onPressed: _zuruecksetzen,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const HinweisKarte(
            'Beantworte, was du siehst – den Rest einfach auslassen. Die Liste '
            'unten wird sofort kleiner.',
            icon: Icons.search,
          ),
          const SizedBox(height: 12),
          _frage('Körperform', null, _form,
              [for (final f in KoerperForm.values) (f, f.text)], (v) => _form = v),
          _frage(
              'Barteln am Maul?',
              'Die "Bartfäden" am Maul, z. B. beim Karpfen oder Wels.',
              _barteln,
              const [(0, 'Keine'), (2, '2'), (4, '4'), (6, '6 oder mehr')],
              (v) => _barteln = v),
          _frage(
              'Fettflosse?',
              'Kleine, weiche Flosse ohne Strahlen zwischen Rücken- und '
                  'Schwanzflosse – typisch für Forellen und Saiblinge.',
              _fettflosse,
              janein,
              (v) => _fettflosse = v),
          _frage(
              'Stachelige Rückenflosse?',
              'Harte, spitze Strahlen vorne an der Rückenflosse (Vorsicht!).',
              _stachel,
              janein,
              (v) => _stachel = v),
          _frage(
              'Saugscheibe am Bauch?',
              'Die Bauchflossen sind zu einem runden Saugnapf verwachsen.',
              _saugscheibe,
              janein,
              (v) => _saugscheibe = v),
          _frage('Wie groß wird er?', null, _groesse,
              [for (final g in Groesse.values) (g, g.text)], (v) => _groesse = v),
          _frage('Rote oder orange Flossen, Augen oder Punkte?', null, _rot,
              janein, (v) => _rot = v),
          _frage('Punkte, Flecken oder Streifen?', null, _muster, janein,
              (v) => _muster = v),
          const Divider(),
          Text(
            _beantwortet == 0
                ? 'Alle ${passend.length} Arten'
                : '${passend.length} passende Arten',
            style: text.titleMedium,
          ),
          const SizedBox(height: 4),
          for (final (f, _) in passend) _Kandidat(f),
          if (passend.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Keine Art passt genau. Vielleicht passt eine '
                  'Antwort nicht ganz – schau bei "Fast passend".'),
            ),
          if (_beantwortet > 0 && fastPassend.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Fast passend (1 Merkmal anders)', style: text.titleSmall),
            for (final (f, _) in fastPassend.take(10)) _Kandidat(f),
          ],
          const SizedBox(height: 8),
          Text(
            'Nur eine Hilfe – Jungfische und Mischlinge sehen oft anders aus. '
            'Im Zweifel: zurücksetzen.',
            style: text.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Kandidat extends StatelessWidget {
  const _Kandidat(this.fisch);

  final Fisch fisch;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: fischBilder[fisch.id] == null
            ? const CircleAvatar(child: Icon(Icons.set_meal))
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(fischBilder[fisch.id]!.pfad,
                    width: 56, height: 40, fit: BoxFit.cover),
              ),
        title: Text(fisch.name),
        subtitle: Text(fisch.familie),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => FischDetail(fisch))),
      ),
    );
  }
}
