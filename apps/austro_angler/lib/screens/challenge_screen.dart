import 'package:flutter/material.dart';

import '../data/fische.dart';
import '../main.dart';
import '../models/bundesland.dart';
import '../models/fang.dart';
import '../services/fang_dienst.dart';
import 'widgets.dart';

/// Fische, die sich für eine Challenge eignen. Pro Monat wird einer gewählt,
/// der in OÖ an diesem Monat nicht geschont ist.
const _kandidaten = ['flussbarsch', 'aitel', 'karpfen', 'zander', 'hecht',
  'wels', 'barbe', 'schleie', 'regenbogenforelle', 'brachse', 'aalrutte',
  'rotauge'];

String challengeFisch(DateTime monat) {
  final mitte = DateTime(monat.year, monat.month, 15);
  final offen = _kandidaten
      .where((id) =>
          fischById(id)?.regel(Bundesland.ooe).istGeschont(mitte) == false)
      .toList();
  final liste = offen.isEmpty ? _kandidaten : offen;
  return liste[(monat.year * 12 + monat.month) % liste.length];
}

const _monate = ['Jänner', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli',
  'August', 'September', 'Oktober', 'November', 'Dezember'];

/// Bester Fang pro Nutzer im Monat für den Challenge-Fisch.
List<Fang> challengeWertung(List<Fang> faenge, DateTime monat) {
  final fisch = challengeFisch(monat);
  final beste = <String, Fang>{};
  for (final f in faenge) {
    if (f.fischId != fisch || f.laengeCm == null) continue;
    if (f.datum.year != monat.year || f.datum.month != monat.month) continue;
    final alt = beste[f.uid];
    if (alt == null || f.laengeCm! > alt.laengeCm!) beste[f.uid] = f;
  }
  return beste.values.toList()
    ..sort((a, b) => b.laengeCm!.compareTo(a.laengeCm!));
}

class ChallengeListe extends StatefulWidget {
  const ChallengeListe({super.key});

  @override
  State<ChallengeListe> createState() => _ChallengeListeState();
}

class _ChallengeListeState extends State<ChallengeListe> {
  late Future<List<Fang>> _faenge = fangDienst.neuesteFaenge();

  Widget _wertung(BuildContext context, List<Fang> faenge, DateTime monat,
      {required bool aktuell}) {
    final konto = KontoScope.of(context)!;
    final fisch = fischById(challengeFisch(monat))!;
    final liste = challengeWertung(faenge, monat);
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(aktuell
                ? '🏁 Challenge ${_monate[monat.month - 1]}'
                : '🏆 Ergebnis ${_monate[monat.month - 1]}',
                style: text.titleLarge),
            Text('Größte(r) ${fisch.name}', style: text.titleMedium),
            if (aktuell)
              const Text('Gewinn: 1 Monat ⭐ Premium gratis! Zählt nur, wenn der '
                  'Fang öffentlich geteilt ist und die Länge eingetragen ist.'),
            const SizedBox(height: 8),
            if (liste.isEmpty)
              const Text('Noch keine Teilnehmer – sei die oder der Erste!'),
            for (var i = 0; i < liste.length && i < 10; i++)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Text(
                  i == 0 ? '🥇' : i == 1 ? '🥈' : i == 2 ? '🥉' : '${i + 1}.',
                  style: const TextStyle(fontSize: 22),
                ),
                title: Text(at(liste[i].nutzerName)),
                subtitle: Text('${datumText(liste[i].datum)}'
                    '${liste[i].gewaesser.isEmpty ? '' : ' · ${liste[i].gewaesser}'}'),
                trailing: Text('${liste[i].laengeCm!.toStringAsFixed(0)} cm',
                    style: text.titleMedium),
              ),
            if (!aktuell && konto.istAdmin && liste.isNotEmpty)
              FilledButton.icon(
                onPressed: () async {
                  final sieger = liste.first;
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Gewinn vergeben?'),
                      content: Text('${at(sieger.nutzerName)} bekommt 1 Monat '
                          'Premium.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Abbrechen')),
                        FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Vergeben')),
                      ],
                    ),
                  );
                  if (ok != true) return;
                  try {
                    await fangDienst.premiumVergeben(sieger.uid,
                        'Monats-Challenge ${_monate[monat.month - 1]} ${monat.year}');
                    if (context.mounted) {
                      meldung(context, 'Premium vergeben ⭐');
                    }
                  } catch (e) {
                    if (context.mounted) meldung(context, 'Fehler: $e');
                  }
                },
                icon: const Icon(Icons.card_giftcard),
                label: const Text('Admin: Gewinn (1 Monat Premium) vergeben'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jetzt = DateTime.now();
    final vormonat = DateTime(jetzt.year, jetzt.month - 1);
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _faenge = fangDienst.neuesteFaenge());
        await _faenge;
      },
      child: FutureBuilder<List<Fang>>(
        future: _faenge,
        builder: (context, snap) {
          if (snap.hasError) {
            return ListView(children: const [
              Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Challenge konnte nicht laden.')),
            ]);
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _wertung(context, snap.data!, jetzt, aktuell: true),
              _wertung(context, snap.data!, vormonat, aktuell: false),
            ],
          );
        },
      ),
    );
  }
}
