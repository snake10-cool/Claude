import 'package:flutter/material.dart';

import '../data/gewaesser.dart';
import '../main.dart';
import '../services/fang_dienst.dart';
import 'widgets.dart';

/// Gemeinsame Angeltage planen und zusagen.
class TreffenListe extends StatefulWidget {
  const TreffenListe({super.key});

  @override
  State<TreffenListe> createState() => _TreffenListeState();
}

class _TreffenListeState extends State<TreffenListe>
    with AutomaticKeepAliveClientMixin {
  final _stream = fangDienst.kommendeTreffen();

  @override
  bool get wantKeepAlive => true;

  static const _tage = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  Future<void> _neu() async {
    final konto = KontoScope.of(context)!;
    var gewaesser = gewaesserListe.first.name;
    var zeit = DateTime.now().add(const Duration(days: 1));
    zeit = DateTime(zeit.year, zeit.month, zeit.day, 6);
    final text = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Angeltag planen'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: gewaesser,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Gewässer'),
                  items: [
                    for (final g in gewaesserListe)
                      DropdownMenuItem(value: g.name, child: Text(g.name)),
                  ],
                  onChanged: (v) => setState(() => gewaesser = v!),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event),
                  title: Text('${datumText(zeit)} um ${uhrText(zeit)}'),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: zeit,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 180)),
                    );
                    if (d == null || !context.mounted) return;
                    final t = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(zeit),
                    );
                    setState(
                      () => zeit = DateTime(
                        d.year,
                        d.month,
                        d.day,
                        t?.hour ?? zeit.hour,
                        t?.minute ?? zeit.minute,
                      ),
                    );
                  },
                ),
                TextField(
                  controller: text,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    labelText: 'Infos (z. B. Treffpunkt, Zielfisch)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Veröffentlichen'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await fangDienst.treffenAnlegen(
        uid: konto.uid!,
        name: konto.name ?? '',
        gewaesser: gewaesser,
        zeit: zeit,
        text: text.text.trim(),
      );
    } catch (_) {
      if (mounted) meldung(context, 'Speichern fehlgeschlagen.');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final konto = KontoScope.of(context)!;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'treffen',
        onPressed: _neu,
        icon: const Icon(Icons.add),
        label: const Text('Angeltag planen'),
      ),
      body: StreamBuilder<List<Treffen>>(
        stream: _stream,
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(child: Text('Laden fehlgeschlagen.'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final liste = snap.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
            children: [
              if (liste.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Noch keine Angeltage geplant.\nPlan einen und lade die '
                    'anderen ein! 🎣',
                    textAlign: TextAlign.center,
                  ),
                ),
              for (final t in liste)
                if (!konto.istBlockiert(t.uid))
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_tage[t.zeit.weekday - 1]}, ${datumText(t.zeit)} '
                            'um ${uhrText(t.zeit)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text('📍 ${t.gewaesser}'),
                          if (t.text.isNotEmpty) Text(t.text),
                          Text(
                            'Geplant von ${at(t.nutzerName)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Dabei (${t.zusagen.length}): '
                            '${t.zusagen.values.map(at).join(', ')}',
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (t.zusagen.containsKey(konto.uid))
                                OutlinedButton(
                                  onPressed: () => fangDienst.zusagen(
                                    t.id,
                                    konto.uid!,
                                    konto.name ?? '',
                                    dabei: false,
                                  ),
                                  child: const Text('Doch nicht'),
                                )
                              else
                                FilledButton(
                                  onPressed: () => fangDienst.zusagen(
                                    t.id,
                                    konto.uid!,
                                    konto.name ?? '',
                                    dabei: true,
                                  ),
                                  child: const Text('Bin dabei! 🙋'),
                                ),
                              const Spacer(),
                              if (t.uid == konto.uid || konto.istAdmin)
                                IconButton(
                                  tooltip: 'Absagen/Löschen',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () =>
                                      fangDienst.treffenLoeschen(t.id),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              const HinweisKarte(
                'Angeltage sehen alle angemeldeten Austro Angler. Trefft '
                'euch an öffentlichen Plätzen und sagt jemandem Bescheid, '
                'wohin ihr geht.',
              ),
            ],
          );
        },
      ),
    );
  }
}
