import 'package:flutter/material.dart';

import '../data/fische.dart';
import '../main.dart';
import '../models/fang.dart';
import '../services/abzeichen.dart';
import '../services/fang_dienst.dart';
import 'fangbuch_screen.dart';
import 'kommentare_screen.dart';
import 'melden.dart';
import 'widgets.dart';

/// Öffnet das öffentliche Profil eines Nutzers.
void profilOeffnen(BuildContext context, String uid, String name) {
  if (uid.isEmpty) return;
  Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ProfilScreen(uid: uid, name: name)));
}

/// Antippbares "@name", das zum Profil führt.
class NutzerLink extends StatelessWidget {
  const NutzerLink(this.uid, this.name, {super.key, this.vorsatz = '', this.stil});

  final String uid;
  final String name;
  final String vorsatz;
  final TextStyle? stil;

  @override
  Widget build(BuildContext context) {
    final farbe = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: uid.isEmpty ? null : () => profilOeffnen(context, uid, name),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(text: vorsatz),
          TextSpan(
            text: at(name),
            style: TextStyle(color: farbe, fontWeight: FontWeight.w600),
          ),
        ]),
        style: stil ?? Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

/// Öffentliches Profil mit Statistik, Abzeichen und allen geteilten Fängen.
class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key, required this.uid, required this.name});

  final String uid;
  final String name;

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  late final Future<List<Fang>> _faenge = fangDienst.faengeVon(widget.uid);
  late final _info = fangDienst.nutzerInfo(widget.uid).catchError(
      (_) => (name: widget.name, verein: '', seit: null as DateTime?));
  Stream<Map<String, String>>? _freunde;
  Stream<bool>? _gesendet;
  Stream<Map<String, String>>? _anMich;

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context);
    final ich = konto?.uid;
    final fremd = ich != null && ich != widget.uid;
    if (fremd) {
      _freunde ??= fangDienst.freunde(ich);
      _gesendet ??= fangDienst.anfrageGesendet(ich, widget.uid);
      _anMich ??= fangDienst.anfragenAnMich(ich);
    }
    final blockiert = konto?.istBlockiert(widget.uid) ?? false;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(at(widget.name)),
        actions: [
          if (fremd)
            PopupMenuButton<String>(
              onSelected: (w) {
                if (w == 'melden') {
                  meldenDialog(context,
                      typ: 'nutzer',
                      bezug: '${widget.uid} (${at(widget.name)})',
                      titel: '${at(widget.name)} melden',
                      hinweis: 'Was ist das Problem? Z. B. Beleidigungen, '
                          'Spam, falsche Angaben.');
                } else if (w == 'blockieren') {
                  blockierenDialog(context, widget.uid, widget.name);
                } else if (w == 'entblocken') {
                  fangDienst.entblocken(ich, widget.uid);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'melden', child: Text('🚩 Nutzer melden')),
                if (blockiert)
                  const PopupMenuItem(
                      value: 'entblocken', child: Text('🔓 Blockierung aufheben'))
                else
                  const PopupMenuItem(
                      value: 'blockieren', child: Text('🚫 Blockieren')),
              ],
            ),
        ],
      ),
      body: FutureBuilder<List<Fang>>(
        future: _faenge,
        builder: (context, snap) {
          final faenge = snap.data ?? const <Fang>[];
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Icon(Icons.account_circle, size: 80),
              Text(at(widget.name),
                  style: text.headlineSmall, textAlign: TextAlign.center),
              FutureBuilder(
                future: _info,
                builder: (context, i) {
                  final info = i.data;
                  if (info == null) return const SizedBox.shrink();
                  return Text(
                    [
                      if (info.verein.isNotEmpty) '🎣 ${info.verein}',
                      if (info.seit != null)
                        'dabei seit ${info.seit!.month}/${info.seit!.year}',
                    ].join(' · '),
                    textAlign: TextAlign.center,
                    style: text.bodySmall,
                  );
                },
              ),
              const SizedBox(height: 12),
              if (fremd && !blockiert) _FreundKnopf(this),
              const SizedBox(height: 12),
              if (blockiert)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Du hast diese Person blockiert.',
                      textAlign: TextAlign.center),
                )
              else if (snap.connectionState != ConnectionState.done)
                const Center(child: CircularProgressIndicator())
              else ...[
                _ProfilStatistik(faenge),
                const SizedBox(height: 8),
                Text('Geteilte Fänge (${faenge.length})',
                    style: text.titleMedium),
                const SizedBox(height: 4),
                if (faenge.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Noch keine geteilten Fänge.',
                        textAlign: TextAlign.center),
                  ),
                for (final f in faenge)
                  FangKarte(
                    f,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => KommentareScreen(f))),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Freundschaft: Anfrage senden, zurückziehen, annehmen oder Freund entfernen.
class _FreundKnopf extends StatelessWidget {
  const _FreundKnopf(this.s);

  final _ProfilScreenState s;

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context)!;
    final ich = konto.uid!;
    final andere = s.widget.uid;
    final name = s.widget.name;
    return StreamBuilder<Map<String, String>>(
      stream: s._freunde,
      builder: (context, f) {
        if (f.data?.containsKey(andere) ?? false) {
          return Center(
            child: OutlinedButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('${at(name)} als Freund entfernen?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Abbrechen')),
                      FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Entfernen')),
                    ],
                  ),
                );
                if (ok == true) await fangDienst.freundEntfernen(ich, andere);
              },
              icon: const Icon(Icons.how_to_reg),
              label: const Text('Freunde ✓'),
            ),
          );
        }
        return StreamBuilder<Map<String, String>>(
          stream: s._anMich,
          builder: (context, a) {
            if (a.data?.containsKey(andere) ?? false) {
              return Center(
                child: FilledButton.icon(
                  onPressed: () => fangDienst.anfrageAnnehmen(
                      ich, konto.name ?? '', andere, name),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Anfrage annehmen'),
                ),
              );
            }
            return StreamBuilder<bool>(
              stream: s._gesendet,
              builder: (context, g) {
                if (g.data ?? false) {
                  return Center(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          fangDienst.anfrageZurueckziehen(ich, andere),
                      icon: const Icon(Icons.hourglass_top),
                      label: const Text('Anfrage gesendet – zurückziehen'),
                    ),
                  );
                }
                return Center(
                  child: FilledButton.icon(
                    onPressed: () async {
                      try {
                        await fangDienst.anfrageSenden(
                            ich, konto.name ?? '', andere);
                        if (context.mounted) {
                          meldung(context, 'Freundschaftsanfrage geschickt.');
                        }
                      } catch (_) {
                        if (context.mounted) {
                          meldung(context, 'Senden fehlgeschlagen.');
                        }
                      }
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Freundschaftsanfrage senden'),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ProfilStatistik extends StatelessWidget {
  const _ProfilStatistik(this.faenge);

  final List<Fang> faenge;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final arten = <String, int>{};
    final gewaesser = <String, int>{};
    var petri = 0;
    Fang? groesster;
    for (final f in faenge) {
      arten[f.fischId] = (arten[f.fischId] ?? 0) + 1;
      if (f.gewaesser.isNotEmpty) {
        gewaesser[f.gewaesser] = (gewaesser[f.gewaesser] ?? 0) + 1;
      }
      petri += f.petriHeil.length;
      if (f.laengeCm != null &&
          (groesster == null || f.laengeCm! > groesster.laengeCm!)) {
        groesster = f;
      }
    }
    String? top(Map<String, int> m) => m.isEmpty
        ? null
        : (m.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;
    final lieblingsfisch = top(arten);
    final lieblingsgewaesser = top(gewaesser);
    final zurueck = faenge.where((f) => f.zurueckgesetzt).length;
    final abzeichen =
        alleAbzeichen.where((a) => a.erreicht(faenge)).toList();

    Widget zahl(String wert, String label) => Expanded(
          child: Column(
            children: [
              Text(wert, style: text.titleLarge, textAlign: TextAlign.center),
              Text(label, style: text.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Titel('📊 Statistik'),
            const SizedBox(height: 8),
            Row(children: [
              zahl('${faenge.length}', 'Fänge'),
              zahl('${arten.length}', 'Arten'),
              zahl('$petri', 'Petri Heil'),
              zahl('$zurueck', 'Zurückgesetzt'),
            ]),
            const Divider(),
            if (groesster != null)
              Text('🏆 Größter Fang: ${fischById(groesster.fischId)?.name ?? ''} '
                  'mit ${groesster.laengeCm!.toStringAsFixed(0)} cm'),
            if (lieblingsfisch != null)
              Text('🐟 Lieblingsfisch: '
                  '${fischById(lieblingsfisch)?.name ?? lieblingsfisch} '
                  '(${arten[lieblingsfisch]}×)'),
            if (lieblingsgewaesser != null)
              Text('📍 Lieblingsgewässer: $lieblingsgewaesser'),
            if (abzeichen.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('🏅 Abzeichen (${abzeichen.length})',
                  style: text.labelLarge),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final a in abzeichen)
                    Tooltip(
                      message: '${a.name}: ${a.beschreibung}',
                      child: Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text('${a.icon} ${a.name}'),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Text('Nur aus öffentlich geteilten Fängen.', style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}
