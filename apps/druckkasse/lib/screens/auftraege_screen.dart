import 'package:app_basis/app_basis.dart';
import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../l10n/l.dart';
import '../logik/typen.dart';
import '../widgets/format.dart';
import 'auftrag_bearbeiten_screen.dart';

enum _Filter { offen, erledigt, alle }

/// Bestellungen: wer hat was bestellt, Status und bezahlt.
class AuftraegeScreen extends StatefulWidget {
  const AuftraegeScreen({super.key});

  @override
  State<AuftraegeScreen> createState() => _AuftraegeScreenState();
}

class _AuftraegeScreenState extends State<AuftraegeScreen> {
  _Filter _filter = _Filter.offen;

  void _oeffnen([AuftragDetails? a]) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => AuftragBearbeitenScreen(auftrag: a),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.tabAuftraege)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: _oeffnen,
        icon: const Icon(Icons.add),
        label: Text(l.neuerAuftrag),
      ),
      body: StreamBuilder<List<AuftragDetails>>(
        stream: db.auftraegeBeobachten(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final alle = snap.data!;
          final liste = switch (_filter) {
            _Filter.offen => alle.where((a) => !a.erledigt).toList(),
            _Filter.erledigt => alle.where((a) => a.erledigt).toList(),
            _Filter.alle => alle,
          };
          final offen = alle.where((a) => !a.erledigt).toList();
          final offenSumme = offen
              .where((a) => !a.bezahlt)
              .fold(0, (s, a) => s + a.summeCent);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            children: [
              SegmentedButton<_Filter>(
                segments: [
                  ButtonSegment(
                    value: _Filter.offen,
                    label: Text('${l.filterOffen} (${offen.length})'),
                  ),
                  ButtonSegment(
                    value: _Filter.erledigt,
                    label: Text(l.filterErledigt),
                  ),
                  ButtonSegment(value: _Filter.alle, label: Text(l.filterAlle)),
                ],
                selected: {_filter},
                onSelectionChanged: (s) => setState(() => _filter = s.first),
              ),
              if (_filter == _Filter.offen && offenSumme > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    l.nochOffen(euro(offenSumme)),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              const SizedBox(height: 12),
              if (liste.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: LeerHinweis(
                    symbol: Icons.assignment_turned_in,
                    titel: _filter == _Filter.offen
                        ? l.keineOffenenAuftraege
                        : l.keineAuftraege,
                    text: _filter == _Filter.offen
                        ? l.keineAuftraegeText
                        : null,
                  ),
                ),
              for (final a in liste)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AuftragKarte(a, onTap: () => _oeffnen(a)),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AuftragKarte extends StatelessWidget {
  const _AuftragKarte(this.a, {required this.onTap});
  final AuftragDetails a;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    final faellig = a.auftrag.faelligAm;
    final heute = DateTime.now();
    final ueberfaellig =
        faellig != null &&
        !a.erledigt &&
        faellig.isBefore(DateTime(heute.year, heute.month, heute.day));
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      a.auftrag.kunde,
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    euro(a.summeCent),
                    style: t.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                a.positionen
                    .map((p) => '${p.$1.menge}× ${p.$2?.name ?? '?'}')
                    .join(', '),
                style: t.textTheme.bodyMedium,
              ),
              if (faellig != null) ...[
                const SizedBox(height: 4),
                Text(
                  l.faelligAm(datum(faellig)),
                  style: t.textTheme.bodySmall?.copyWith(
                    color: ueberfaellig ? t.colorScheme.error : null,
                    fontWeight: ueberfaellig ? FontWeight.bold : null,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in AuftragStatus.values)
                    ChoiceChip(
                      label: Text(statusName(l, s)),
                      selected: a.status == s,
                      onSelected: (_) =>
                          db.auftragStatusSetzen(a.auftrag.id, s),
                    ),
                  FilterChip(
                    avatar: Icon(
                      a.bezahlt ? Icons.euro : Icons.money_off,
                      size: 18,
                    ),
                    label: Text(a.bezahlt ? l.bezahlt : l.nichtBezahlt),
                    selected: a.bezahlt,
                    onSelected: (v) => db.auftragBezahltSetzen(a.auftrag.id, v),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String statusName(AppLocalizations l, AuftragStatus s) => switch (s) {
  AuftragStatus.offen => l.statusOffen,
  AuftragStatus.gedruckt => l.statusGedruckt,
  AuftragStatus.abgeholt => l.statusAbgeholt,
};
