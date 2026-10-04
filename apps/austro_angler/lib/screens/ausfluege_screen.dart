import 'package:flutter/material.dart';

import '../main.dart';
import '../models/fang.dart';
import '../services/fang_dienst.dart';
import 'widgets.dart';

/// Ganze Angeltage erfassen – auch die ohne Fang ("Schneidertage").
class AusfluegeScreen extends StatefulWidget {
  const AusfluegeScreen({super.key});

  @override
  State<AusfluegeScreen> createState() => _AusfluegeScreenState();
}

class _AusfluegeScreenState extends State<AusfluegeScreen> {
  Stream<List<Ausflug>>? _ausfluege;
  Stream<List<Fang>>? _faenge;

  /// Fänge, die zeitlich in den Ausflug fallen.
  static List<Fang> faengeIm(Ausflug a, List<Fang> faenge) => faenge
      .where((f) => !f.datum.isBefore(a.start) && !f.datum.isAfter(a.ende))
      .toList();

  Future<DateTime?> _zeitWaehlen(BuildContext context, DateTime start) async {
    final d = await showDatePicker(
      context: context,
      initialDate: start,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (d == null || !context.mounted) return null;
    final t = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(start));
    return DateTime(d.year, d.month, d.day, t?.hour ?? start.hour,
        t?.minute ?? start.minute);
  }

  Future<void> _bearbeiten(String uid, [Ausflug? alt]) async {
    final jetzt = DateTime.now();
    var gewaesser = alt?.gewaesser ?? '';
    var start = alt?.start ?? DateTime(jetzt.year, jetzt.month, jetzt.day, 6);
    var ende = alt?.ende ?? DateTime(jetzt.year, jetzt.month, jetzt.day, 10);
    final notiz = TextEditingController(text: alt?.notiz ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(alt == null ? 'Angeltag eintragen' : 'Angeltag bearbeiten'),
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
                  leading: const Icon(Icons.play_arrow),
                  title: Text('Von ${datumText(start)} ${uhrText(start)}'),
                  onTap: () async {
                    final z = await _zeitWaehlen(context, start);
                    if (z != null) setState(() => start = z);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.stop),
                  title: Text('Bis ${datumText(ende)} ${uhrText(ende)}'),
                  onTap: () async {
                    final z = await _zeitWaehlen(context, ende);
                    if (z != null) setState(() => ende = z);
                  },
                ),
                TextField(
                  controller: notiz,
                  maxLines: 2,
                  maxLength: 300,
                  decoration:
                      const InputDecoration(labelText: 'Notiz (Bedingungen …)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Abbrechen')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Speichern')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    if (!ende.isAfter(start)) {
      if (mounted) meldung(context, 'Das Ende muss nach dem Start liegen.');
      return;
    }
    await fangDienst.ausflugSpeichern(
      uid,
      Ausflug(
          id: alt?.id ?? '',
          gewaesser: gewaesser,
          start: start,
          ende: ende,
          notiz: notiz.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = KontoScope.of(context)?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Angeltage')),
        body: const Center(child: Text('Bitte anmelden.')),
      );
    }
    _ausfluege ??= fangDienst.ausfluege(uid);
    _faenge ??= fangDienst.meineFaenge(uid);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Meine Angeltage')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bearbeiten(uid),
        icon: const Icon(Icons.add),
        label: const Text('Angeltag'),
      ),
      body: StreamBuilder<List<Ausflug>>(
        stream: _ausfluege,
        builder: (context, aSnap) => StreamBuilder<List<Fang>>(
          stream: _faenge,
          builder: (context, fSnap) {
            if (!aSnap.hasData || !fSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final ausfluege = aSnap.data!;
            final faenge = fSnap.data!;
            final schneider =
                ausfluege.where((a) => faengeIm(a, faenge).isEmpty).length;
            final stunden = ausfluege.fold<double>(
                0, (s, a) => s + a.dauer.inMinutes / 60);
            final gefangen =
                ausfluege.fold<int>(0, (s, a) => s + faengeIm(a, faenge).length);
            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Titel('📈 Ehrliche Bilanz', premium: true),
                        const SizedBox(height: 6),
                        Text('${ausfluege.length} Angeltage · '
                            '${stunden.toStringAsFixed(0)} Stunden am Wasser'),
                        Text('$gefangen Fänge · $schneider Schneidertage'),
                        if (stunden > 0)
                          Text('Ø ${(gefangen / stunden).toStringAsFixed(2).replaceAll('.', ',')} '
                              'Fische pro Stunde',
                              style: text.titleMedium),
                      ],
                    ),
                  ),
                ),
                if (ausfluege.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                        'Trag deine Angeltage ein – auch die ohne Fang. Fänge '
                        'im selben Zeitraum werden automatisch zugeordnet.',
                        textAlign: TextAlign.center),
                  ),
                for (final a in ausfluege)
                  Card(
                    child: ListTile(
                      leading: Text(
                          faengeIm(a, faenge).isEmpty ? '🪣' : '🎣',
                          style: const TextStyle(fontSize: 28)),
                      title: Text(a.gewaesser),
                      subtitle: Text([
                        '${datumText(a.start)}, ${uhrText(a.start)}–${uhrText(a.ende)}',
                        faengeIm(a, faenge).isEmpty
                            ? 'Schneidertag'
                            : '${faengeIm(a, faenge).length} Fänge',
                        if (a.notiz.isNotEmpty) a.notiz,
                      ].join('\n')),
                      isThreeLine: true,
                      onTap: () => _bearbeiten(uid, a),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => fangDienst.ausflugLoeschen(uid, a.id),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
