import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../data/fische.dart';
import '../main.dart';
import '../services/fang_dienst.dart';
import '../services/wettfischen.dart';
import 'konto_screen.dart';
import 'profil_screen.dart';
import 'widgets.dart';

/// Eigene Wettfischen: anlegen, mit Code beitreten, Rangliste.
class WettfischenScreen extends StatelessWidget {
  const WettfischenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Eigene Wettfischen')),
      body: konto?.angemeldet != true || konto?.uid == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    const Text(
                        'Mach dein eigenes Wettfischen mit Freunden, Familie '
                        'oder dem Verein. Dafür brauchst du ein Konto.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const KontoScreen())),
                      child: const Text('Anmelden'),
                    ),
                  ],
                ),
              ),
            )
          : _Liste(konto!.uid!),
      floatingActionButton: konto?.angemeldet == true
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const _AnlegenScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Neues Wettfischen'),
            )
          : null,
    );
  }
}

class _Liste extends StatefulWidget {
  const _Liste(this.uid);

  final String uid;

  @override
  State<_Liste> createState() => _ListeState();
}

class _ListeState extends State<_Liste> {
  late final _stream = wettfischenDienst.meine(widget.uid);
  final _code = TextEditingController();
  bool _tritt = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _beitreten() async {
    final konto = KontoScope.of(context)!;
    if (_code.text.trim().length != 6) {
      meldung(context, 'Der Code hat 6 Zeichen.');
      return;
    }
    setState(() => _tritt = true);
    try {
      final w = await wettfischenDienst.beitreten(
          konto.uid!, konto.name ?? '', _code.text);
      _code.clear();
      if (!mounted) return;
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => WettfischenDetail(w.id)));
    } catch (e) {
      if (mounted) {
        meldung(context, e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _tritt = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Titel('🔑 Mit Code beitreten'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _code,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp('[A-Za-z0-9]')),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'z. B. K7PX2M',
                          counterText: '',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _beitreten(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _tritt ? null : _beitreten,
                      child: const Text('Beitreten'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<String>>(
          stream: _stream,
          builder: (context, snap) {
            if (snap.hasError) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Laden fehlgeschlagen.'),
              );
            }
            final ids = snap.data;
            if (ids == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (ids.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                    'Noch kein Wettfischen. Leg eins an und schick den Code '
                    'an deine Freunde – gewertet wird automatisch aus dem '
                    'Fangbuch.',
                    textAlign: TextAlign.center),
              );
            }
            return Column(
              children: [for (final id in ids) _Kachel(id)],
            );
          },
        ),
      ],
    );
  }
}

class _Kachel extends StatelessWidget {
  const _Kachel(this.id);

  final String id;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Wettfischen?>(
      stream: wettfischenDienst.wettfischen(id),
      builder: (context, snap) {
        final w = snap.data;
        if (w == null) return const SizedBox.shrink();
        final jetzt = DateTime.now();
        final status = w.vorbei(jetzt)
            ? '🏁 vorbei'
            : w.laeuft(jetzt)
                ? '🟢 läuft'
                : '⏳ ab ${datumText(w.von)}';
        return Card(
          child: ListTile(
            leading: const Text('🏆', style: TextStyle(fontSize: 26)),
            title: Text(w.titel),
            subtitle: Text('$status · ${w.wertung.text} · ${w.fischText}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => WettfischenDetail(w.id))),
          ),
        );
      },
    );
  }
}

class _AnlegenScreen extends StatefulWidget {
  const _AnlegenScreen();

  @override
  State<_AnlegenScreen> createState() => _AnlegenScreenState();
}

class _AnlegenScreenState extends State<_AnlegenScreen> {
  final _titel = TextEditingController();
  String _gewaesser = '';
  String _fischId = '';
  Wertung _wertung = Wertung.laenge;
  late DateTime _von = _heute();
  late DateTime _bis = _von.add(const Duration(days: 1));
  bool _speichert = false;

  static DateTime _heute() {
    final j = DateTime.now();
    return DateTime(j.year, j.month, j.day);
  }

  @override
  void dispose() {
    _titel.dispose();
    super.dispose();
  }

  Future<void> _datum(bool start) async {
    final d = await showDatePicker(
      context: context,
      initialDate: start ? _von : _bis.subtract(const Duration(days: 1)),
      firstDate: _heute(),
      lastDate: _heute().add(const Duration(days: 365)),
    );
    if (d == null) return;
    setState(() {
      if (start) {
        final dauer = _bis.difference(_von);
        _von = d;
        _bis = d.add(dauer);
      } else {
        // Bis Ende des gewählten Tages.
        _bis = d.add(const Duration(days: 1));
        if (!_bis.isAfter(_von)) _bis = _von.add(const Duration(days: 1));
      }
    });
  }

  Future<void> _anlegen() async {
    final konto = KontoScope.of(context)!;
    final titel = _titel.text.trim();
    if (titel.isEmpty) {
      meldung(context, 'Bitte einen Namen eingeben.');
      return;
    }
    if (_bis.difference(_von).inDays > 31) {
      meldung(context, 'Ein Wettfischen dauert höchstens 31 Tage.');
      return;
    }
    setState(() => _speichert = true);
    try {
      final id = await wettfischenDienst.anlegen(
        uid: konto.uid!,
        name: konto.name ?? '',
        titel: titel,
        gewaesser: _gewaesser.trim(),
        fischId: _fischId,
        wertung: _wertung,
        von: _von,
        bis: _bis,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => WettfischenDetail(id)));
    } catch (e) {
      if (mounted) meldung(context, 'Anlegen fehlgeschlagen: $e');
    } finally {
      if (mounted) setState(() => _speichert = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final letzterTag = _bis.subtract(const Duration(days: 1));
    return Scaffold(
      appBar: AppBar(title: const Text('Neues Wettfischen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titel,
            maxLength: 60,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'z. B. Hechtcup am Inn',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          GewaesserFeld(
            anfang: '',
            label: 'Gewässer (optional, nur zur Info)',
            geaendert: (name, _) => _gewaesser = name,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _fischId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Welche Fische zählen?',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: '', child: Text('Alle Fischarten')),
              for (final f in fische.where((f) => !f.ausgestorben))
                DropdownMenuItem(value: f.id, child: Text(f.name)),
            ],
            onChanged: (v) => setState(() => _fischId = v ?? ''),
          ),
          const SizedBox(height: 12),
          Text('Wertung', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          SegmentedButton<Wertung>(
            showSelectedIcon: false,
            segments: [
              for (final w in Wertung.values)
                ButtonSegment(value: w, label: Text(w.text)),
            ],
            selected: {_wertung},
            onSelectionChanged: (s) => setState(() => _wertung = s.first),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _datum(true),
                  icon: const Icon(Icons.event),
                  label: Text('Von ${datumText(_von)}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _datum(false),
                  icon: const Icon(Icons.event_available),
                  label: Text('Bis ${datumText(letzterTag)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
              'Gewertet wird automatisch: Alle Fänge im Zeitraum, die die '
              'Teilnehmer ins Fangbuch eintragen. Fair bleiben – Petri Heil! 🎣'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _speichert ? null : _anlegen,
            icon: const Icon(Icons.emoji_events),
            label: const Text('Anlegen und Code bekommen'),
          ),
        ],
      ),
    );
  }
}

class WettfischenDetail extends StatefulWidget {
  const WettfischenDetail(this.id, {super.key});

  final String id;

  @override
  State<WettfischenDetail> createState() => _WettfischenDetailState();
}

class _WettfischenDetailState extends State<WettfischenDetail> {
  late final _wf = wettfischenDienst.wettfischen(widget.id);
  late final _tn = wettfischenDienst.teilnehmer(widget.id);
  bool _gemeldet = false;

  /// Meinen Stand aus dem Fangbuch melden – einmal beim Öffnen.
  Future<void> _melden(Wettfischen w) async {
    if (_gemeldet) return;
    _gemeldet = true;
    final konto = KontoScope.of(context)!;
    try {
      final faenge = await fangDienst.meineFaenge(konto.uid!).first;
      await wettfischenDienst.standMelden(
          w, konto.uid!, konto.name ?? '', faenge);
    } catch (e) {
      debugPrint('Wettfischen: $e');
    }
  }

  Future<void> _teilen(Wettfischen w) => SharePlus.instance.share(ShareParams(
        text: '🏆 Mach mit beim Wettfischen „${w.titel}“!\n'
            '${datumText(w.von)} – '
            '${datumText(w.bis.subtract(const Duration(days: 1)))}, '
            '${w.wertung.text} (${w.fischText}).\n'
            'In Austro Angler unter Mehr → Eigene Wettfischen den Code '
            '${w.code} eingeben.',
      ));

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context)!;
    final text = Theme.of(context).textTheme;
    return StreamBuilder<Wettfischen?>(
      stream: _wf,
      builder: (context, snap) {
        final w = snap.data;
        if (w == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
                child: snap.connectionState == ConnectionState.waiting
                    ? const CircularProgressIndicator()
                    : const Text('Dieses Wettfischen gibt es nicht mehr.')),
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) => _melden(w));
        final jetzt = DateTime.now();
        final ichErsteller = w.ersteller == konto.uid;
        return Scaffold(
          appBar: AppBar(
            title: Text(w.titel),
            actions: [
              PopupMenuButton<String>(
                onSelected: (a) async {
                  if (a == 'verlassen') {
                    await wettfischenDienst.verlassen(w.id, konto.uid!);
                    if (context.mounted) Navigator.of(context).pop();
                  } else if (a == 'loeschen') {
                    if (await loeschenBestaetigen(context, 'Wettfischen') &&
                        context.mounted) {
                      await wettfischenDienst.loeschen(w.id, konto.uid!);
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  }
                },
                itemBuilder: (_) => [
                  if (!ichErsteller)
                    const PopupMenuItem(
                        value: 'verlassen', child: Text('Verlassen')),
                  if (ichErsteller || konto.istAdmin)
                    const PopupMenuItem(
                        value: 'loeschen', child: Text('Löschen')),
                ],
              ),
            ],
          ),
          body: StreamBuilder<List<Teilnehmer>>(
            stream: _tn,
            builder: (context, tsnap) {
              final liste = sortiert(
                  (tsnap.data ?? const <Teilnehmer>[])
                      .where((t) => !konto.istBlockiert(t.uid))
                      .toList(),
                  w.wertung);
              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              w.vorbei(jetzt)
                                  ? '🏁 Vorbei'
                                  : w.laeuft(jetzt)
                                      ? '🟢 Läuft – noch ${_rest(w.bis, jetzt)}'
                                      : '⏳ Startet in ${_rest(w.von, jetzt)}',
                              style: text.titleMedium),
                          const SizedBox(height: 4),
                          Text('${datumText(w.von)} – '
                              '${datumText(w.bis.subtract(const Duration(days: 1)))}'),
                          Text('Wertung: ${w.wertung.text} · ${w.fischText}'),
                          if (w.gewaesser.isNotEmpty)
                            Text('Gewässer: ${w.gewaesser}'),
                          Text('Angelegt von ${at(w.erstellerName)}'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text('Code: ', style: text.titleMedium),
                              SelectableText(w.code,
                                  style: text.headlineSmall?.copyWith(
                                      letterSpacing: 4,
                                      fontWeight: FontWeight.bold)),
                              const Spacer(),
                              IconButton(
                                tooltip: 'Code kopieren',
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: w.code));
                                  meldung(context, 'Code kopiert');
                                },
                              ),
                              IconButton(
                                tooltip: 'Einladen',
                                icon: const Icon(Icons.share),
                                onPressed: () => _teilen(w),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Rangliste (${liste.length})', style: text.titleMedium),
                  const SizedBox(height: 4),
                  for (var i = 0; i < liste.length; i++)
                    Card(
                      color: liste[i].uid == konto.uid
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: ListTile(
                        leading: SizedBox(
                          width: 36,
                          child: Center(
                            child: Text(
                              switch (i) {
                                0 => '🥇',
                                1 => '🥈',
                                2 => '🥉',
                                _ => '${i + 1}.',
                              },
                              style: TextStyle(fontSize: i < 3 ? 26 : 16),
                            ),
                          ),
                        ),
                        title: Text(at(liste[i].name)),
                        subtitle: Text([
                          '${liste[i].faenge} Fische',
                          '${liste[i].arten} Arten',
                          if (liste[i].besterFisch.isNotEmpty)
                            'größter: ${(fischById(liste[i].besterFisch)?.name ?? '').split(' (').first}',
                        ].join(' · ')),
                        trailing: Text(liste[i].wertText(w.wertung),
                            style: text.titleMedium),
                        onTap: () => profilOeffnen(
                            context, liste[i].uid, liste[i].name),
                      ),
                    ),
                  if (w.vorbei(jetzt) && liste.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => urkundePdf(w, liste),
                      icon: const Icon(Icons.workspace_premium),
                      label: const Text('Urkunde erstellen'),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Dein Stand wird beim Öffnen automatisch aus deinem '
                    'Fangbuch aktualisiert (bis 3 Tage nach dem Ende).',
                    style: text.bodySmall,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  static String _rest(DateTime ziel, DateTime jetzt) {
    final d = ziel.difference(jetzt);
    if (d.inDays >= 1) return '${d.inDays} ${d.inDays == 1 ? 'Tag' : 'Tage'}';
    if (d.inHours >= 1) return '${d.inHours} Std.';
    return '${d.inMinutes.clamp(1, 59)} Min.';
  }
}

/// Urkunde mit Siegerpodest und allen Plätzen.
Future<void> urkundePdf(Wettfischen w, List<Teilnehmer> liste) async {
  final doc = pw.Document(title: 'Urkunde ${w.titel}');
  String platz(int i) => '${i + 1}. Platz';
  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    build: (_) => pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#1E6F5C'), width: 4),
      ),
      padding: const pw.EdgeInsets.all(32),
      child: pw.Column(
        children: [
          pw.Text('URKUNDE',
              style: pw.TextStyle(
                  fontSize: 40,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#1E6F5C'),
                  letterSpacing: 6)),
          pw.SizedBox(height: 8),
          pw.Text(w.titel, style: const pw.TextStyle(fontSize: 22)),
          pw.Text('${datumText(w.von)} - '
              '${datumText(w.bis.subtract(const Duration(days: 1)))}'
              '${w.gewaesser.isEmpty ? '' : ' · ${w.gewaesser}'}'),
          pw.Text('Wertung: ${w.wertung.text} (${w.fischText})'),
          pw.SizedBox(height: 32),
          pw.Text('Sieger', style: const pw.TextStyle(fontSize: 18)),
          pw.Text('@${liste.first.name}',
              style:
                  pw.TextStyle(fontSize: 34, fontWeight: pw.FontWeight.bold)),
          pw.Text(liste.first.wertText(w.wertung),
              style: const pw.TextStyle(fontSize: 20)),
          pw.SizedBox(height: 32),
          for (var i = 1; i < liste.length && i < 10; i++)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              child: pw.Text('${platz(i)}: @${liste[i].name} - '
                  '${liste[i].wertText(w.wertung)}'),
            ),
          pw.Spacer(),
          pw.Text('Petri Heil!', style: const pw.TextStyle(fontSize: 18)),
          pw.SizedBox(height: 4),
          pw.Text('Erstellt mit Austro Angler',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        ],
      ),
    ),
  ));
  await Printing.sharePdf(
      bytes: await doc.save(),
      filename:
          'Urkunde_${w.titel.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')}.pdf');
}
