import 'package:flutter/material.dart';

import '../data/fische.dart';
import '../design.dart';
import '../main.dart';
import '../models/bundesland.dart';
import '../models/fisch.dart';
import 'lexikon_screen.dart';

/// Status einer Fischart an einem Tag – für die Ampel-Pille.
enum RegelStatus {
  offen('offen'),
  geschont('geschont'),
  ganzjaehrig('ganzjährig'),
  geschuetzt('geschützt'),
  unbekannt('prüfen');

  const RegelStatus(this.text);
  final String text;

  static RegelStatus von(Fisch f, Bundesland land, DateTime tag) {
    if (f.geschuetzt) return RegelStatus.geschuetzt;
    final r = f.regel(land);
    if (r.ganzjaehrigGeschont) return RegelStatus.ganzjaehrig;
    return switch (r.istGeschont(tag)) {
      true => RegelStatus.geschont,
      false => RegelStatus.offen,
      null => RegelStatus.unbekannt,
    };
  }

  Color farbe(ColorScheme s) => switch (this) {
        RegelStatus.offen => Colors.green.shade500,
        RegelStatus.unbekannt => s.onSurfaceVariant,
        _ => s.error,
      };
}

/// Umrandete Pille „offen“ / „geschont“.
class StatusPille extends StatelessWidget {
  const StatusPille(this.status, {super.key});

  final RegelStatus status;

  @override
  Widget build(BuildContext context) {
    final farbe = status.farbe(Theme.of(context).colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: farbe, width: 1.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status.text,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: farbe, fontWeight: FontWeight.w700)),
    );
  }
}

/// „Regeln heute“: alle Fischarten eines Bundeslands mit Status und
/// Brittelmaß auf einen Blick.
class RegelnScreen extends StatefulWidget {
  const RegelnScreen({super.key});

  @override
  State<RegelnScreen> createState() => _RegelnScreenState();
}

class _RegelnScreenState extends State<RegelnScreen> {
  Bundesland? _land;
  RegelStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final land = _land ?? speicher.bundesland;
    final heute = DateTime.now();
    final text = Theme.of(context).textTheme;
    final neu = DesignInfo.von(context).neu;

    final lieblinge = speicher.lieblingsfische;
    final liste = fische.where((f) => !f.ausgestorben).toList()
      ..sort((a, b) {
        final la = lieblinge.contains(a.id), lb = lieblinge.contains(b.id);
        if (la != lb) return la ? -1 : 1;
        return a.name.compareTo(b.name);
      });
    final zeilen = [
      for (final f in liste)
        (f, RegelStatus.von(f, land, heute)),
    ].where((z) => _filter == null || z.$2 == _filter).toList();
    final offen =
        liste.where((f) => RegelStatus.von(f, land, heute) == RegelStatus.offen);

    return Scaffold(
      appBar: AppBar(title: const Text('Regeln heute')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
        children: [
          if (neu) ...[
            const RotWeissRot(),
            const SizedBox(height: 10),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final b in Bundesland.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(b.name),
                      selected: b == land,
                      onSelected: (_) => setState(() => _land = b),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
              '${offen.length} von ${liste.length} Arten sind heute in '
              '${land.name} offen.',
              style: text.bodyMedium),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: [
              for (final s in [null, RegelStatus.offen, RegelStatus.geschont])
                FilterChip(
                  label: Text(s == null ? 'Alle' : 'Nur ${s.text}'),
                  selected: _filter == s,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _filter = s),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: Row(
                    children: [
                      Expanded(child: Text('ART', style: text.labelMedium)),
                      SizedBox(
                          width: 104,
                          child: Text('STATUS', style: text.labelMedium)),
                      SizedBox(
                          width: 60,
                          child: Text('MASS',
                              textAlign: TextAlign.right,
                              style: text.labelMedium)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                for (final (f, status) in zeilen)
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => FischDetail(f))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${lieblinge.contains(f.id) ? '⭐ ' : ''}'
                              '${f.name.split(' (').first}',
                              style: text.titleSmall,
                            ),
                          ),
                          SizedBox(
                            width: 104,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: StatusPille(status),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              f.regel(land).mindestmassCm == null
                                  ? '–'
                                  : '${f.regel(land).mindestmassCm} cm',
                              textAlign: TextAlign.right,
                              style: text.titleSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Immer aktuelle Landes- und Revierregeln prüfen. Revierordnungen '
            'können strenger sein als das Landesgesetz.',
            style: text.bodySmall,
          ),
        ],
      ),
    );
  }
}
