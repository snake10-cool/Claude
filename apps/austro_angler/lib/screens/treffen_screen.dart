import 'package:flutter/material.dart';

import '../main.dart';
import '../services/alle_gewaesser.dart';
import '../services/wetter.dart';
import '../services/fang_dienst.dart';
import 'profil_screen.dart';
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
    var gewaesser = '';
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
                GewaesserFeld(
                  anfang: gewaesser,
                  geaendert: (name, _) => gewaesser = name,
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
    if (gewaesser.isEmpty) {
      if (mounted) meldung(context, 'Bitte ein Gewässer angeben.');
      return;
    }
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
                          _UnwetterHinweis(t),
                          if (t.text.isNotEmpty) Text(t.text),
                          NutzerLink(t.uid, t.nutzerName,
                              vorsatz: 'Geplant von '),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: [
                              Text('Dabei (${t.zusagen.length}):'),
                              for (final z in t.zusagen.entries)
                                NutzerLink(z.key, z.value,
                                    stil: Theme.of(context)
                                        .textTheme
                                        .bodyMedium),
                            ],
                          ),
                          _Fahrten(t),
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


/// Fahrgemeinschaften zu einem Angeltag.
class _Fahrten extends StatelessWidget {
  const _Fahrten(this.t);

  final Treffen t;

  Future<void> _eintragen(BuildContext context) async {
    final konto = KontoScope.of(context)!;
    final speicher = SpeicherScope.of(context);
    final alt = t.fahrten[konto.uid];
    var biete = alt?.biete ?? true;
    var plaetze = alt?.plaetze ?? 2;
    final von = TextEditingController(
        text: alt?.von ?? (speicher.heimatName.isEmpty ? '' : speicher.heimatName));
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Fahrgemeinschaft'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Ich fahre')),
                  ButtonSegment(value: false, label: Text('Suche Mitfahrt')),
                ],
                selected: {biete},
                onSelectionChanged: (s) => setState(() => biete = s.first),
              ),
              TextField(
                controller: von,
                maxLength: 60,
                decoration: const InputDecoration(labelText: 'Ab wo?'),
              ),
              if (biete)
                Row(
                  children: [
                    const Text('Freie Plätze'),
                    const Spacer(),
                    IconButton(
                      onPressed: plaetze > 1
                          ? () => setState(() => plaetze--)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text('$plaetze'),
                    IconButton(
                      onPressed: plaetze < 8
                          ? () => setState(() => plaetze++)
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Abbrechen')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eintragen')),
          ],
        ),
      ),
    );
    if (ok != true || von.text.trim().isEmpty) return;
    try {
      await fangDienst.fahrtSetzen(t.id, konto.uid!,
          name: konto.name ?? '',
          biete: biete,
          plaetze: biete ? plaetze : 0,
          von: von.text.trim());
    } catch (_) {
      if (context.mounted) meldung(context, 'Speichern fehlgeschlagen.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context)!;
    final text = Theme.of(context).textTheme;
    final eigene = t.fahrten[konto.uid];
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in t.fahrten.entries)
            if (!konto.istBlockiert(e.key))
              Text(
                e.value.biete
                    ? '🚗 ${at(e.value.name)} fährt ab ${e.value.von} – '
                        '${e.value.plaetze} ${e.value.plaetze == 1 ? 'Platz' : 'Plätze'} frei'
                    : '🙋 ${at(e.value.name)} sucht Mitfahrt ab ${e.value.von}',
                style: text.bodyMedium,
              ),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _eintragen(context),
                icon: const Icon(Icons.directions_car_outlined, size: 18),
                label: Text(eigene == null
                    ? 'Fahrgemeinschaft'
                    : 'Meinen Eintrag ändern'),
              ),
              if (eigene != null)
                TextButton(
                  onPressed: () => fangDienst.fahrtLoeschen(t.id, konto.uid!),
                  child: const Text('Entfernen'),
                ),
            ],
          ),
          if (t.fahrten.isNotEmpty)
            Text('Treffpunkt und Uhrzeit am besten persönlich ausmachen.',
                style: text.bodySmall),
        ],
      ),
    );
  }
}


/// Zeigt eine Unwetter-Warnung für Angeltage in den nächsten 7 Tagen.
class _UnwetterHinweis extends StatefulWidget {
  const _UnwetterHinweis(this.t);

  final Treffen t;

  @override
  State<_UnwetterHinweis> createState() => _UnwetterHinweisState();
}

class _UnwetterHinweisState extends State<_UnwetterHinweis> {
  Future<String?>? _warnung;

  @override
  void initState() {
    super.initState();
    final t = widget.t;
    final ort = alleGewaesser.zuName(t.gewaesser)?.position;
    if (ort != null && t.zeit.difference(DateTime.now()).inDays <= 6) {
      _warnung = unwetterWarnung(
              ort, t.zeit, t.zeit.add(const Duration(hours: 6)))
          .catchError((_) => null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_warnung == null) return const SizedBox.shrink();
    return FutureBuilder<String?>(
      future: _warnung,
      builder: (context, snap) {
        final w = snap.data;
        if (w == null) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('⚠️ Wetter-Warnung: $w angesagt. Sicherheit geht vor!'),
        );
      },
    );
  }
}
