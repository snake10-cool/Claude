
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../data/fische.dart';
import '../services/alle_gewaesser.dart';
import '../main.dart';
import '../models/bundesland.dart';
import '../models/fang.dart';
import '../services/fang_dienst.dart';
import '../services/wetter.dart';
import '../services/wochen_challenges.dart';
import 'gewaesser_screen.dart';
import 'messen_screen.dart';
import 'profil_screen.dart';
import 'video.dart';
import 'koeder_screen.dart';
import 'ort_waehlen.dart';
import 'statistik_screen.dart';
import 'story_screen.dart';
import 'widgets.dart';

class FangbuchScreen extends StatefulWidget {
  const FangbuchScreen({super.key});

  @override
  State<FangbuchScreen> createState() => _FangbuchScreenState();
}

class _FangbuchScreenState extends State<FangbuchScreen> {
  String? _uid;
  Stream<List<Fang>>? _stream;

  /// Den Stream nur neu anlegen, wenn sich der Nutzer ändert.
  Stream<List<Fang>> _streamFuer(String uid) {
    if (uid != _uid || _stream == null) {
      _uid = uid;
      _stream = fangDienst.meineFaenge(uid);
    }
    return _stream!;
  }

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context);
    final online = konto?.angemeldet ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mein Fangbuch'),
        actions: [
          IconButton(
            tooltip: 'Statistik & Abzeichen',
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StatistikScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FangFormular()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Fang eintragen'),
      ),
      body: online
          ? StreamBuilder<List<Fang>>(
              stream: _streamFuer(konto!.uid!),
              builder: (context, snap) {
                if (snap.hasError) {
                  return const Center(child: Text('Laden fehlgeschlagen.'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _FangListe(snap.data!);
              },
            )
          : _FangListe(
              SpeicherScope.of(context).faenge,
              oben: konto == null
                  ? null
                  : const AnmeldenKarte(
                      'Melde dich an, damit deine Fänge auf allen Geräten '
                      'gespeichert sind und du sie mit der Community teilen '
                      'kannst.',
                    ),
            ),
    );
  }
}

class _FangListe extends StatelessWidget {
  const _FangListe(this.faenge, {this.oben});

  final List<Fang> faenge;
  final Widget? oben;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
      children: [
        ?oben,
        if (faenge.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Noch keine Fänge.\nPetri Heil beim nächsten Mal! 🎣',
              textAlign: TextAlign.center,
            ),
          )
        else ...[
          _Statistik(faenge),
          WochenChallengeKarte(faenge),
          for (final f in faenge)
            FangKarte(
              f,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => FangFormular(fang: f)),
              ),
            ),
        ],
      ],
    );
  }
}

/// Zwei persönliche Aufgaben pro Woche.
class WochenChallengeKarte extends StatelessWidget {
  const WochenChallengeKarte(this.faenge, {super.key});

  final List<Fang> faenge;

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final jetzt = DateTime.now();
    final start = wochenbeginn(jetzt);
    final woche = faenge.where((f) => !f.datum.isBefore(start)).toList();
    final frueher = faenge.where((f) => f.datum.isBefore(start)).toList();
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: Titel('🎯 Wochen-Challenges')),
                Text('⭐ ${speicher.erledigteChallenges.length}',
                    style: text.titleMedium),
              ],
            ),
            for (final c in challengesDerWoche(jetzt)) ...[
              const SizedBox(height: 8),
              Builder(builder: (context) {
                final stand = c.zaehlen(woche, frueher).clamp(0, c.ziel);
                final fertig = stand >= c.ziel;
                final schluessel = challengeSchluessel(jetzt, c);
                if (fertig && !speicher.erledigteChallenges.contains(schluessel)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    speicher.challengeErledigt(schluessel);
                    if (context.mounted) {
                      meldung(context, 'Challenge geschafft: ${c.titel} ⭐');
                    }
                  });
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${fertig ? '✅' : c.symbol} ${c.titel}'),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                        value: stand / c.ziel, minHeight: 6),
                    Text('$stand / ${c.ziel}', style: text.bodySmall),
                  ],
                );
              }),
            ],
            const SizedBox(height: 4),
            Text('Neue Aufgaben jeden Montag. ⭐ = geschaffte Challenges.',
                style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Statistik extends StatelessWidget {
  const _Statistik(this.faenge);

  final List<Fang> faenge;

  @override
  Widget build(BuildContext context) {
    final mitLaenge = faenge.where((f) => f.laengeCm != null).toList()
      ..sort((a, b) => b.laengeCm!.compareTo(a.laengeCm!));
    final groesster = mitLaenge.isEmpty ? null : mitLaenge.first;

    String haeufigster(Iterable<String> werte) {
      final zaehler = <String, int>{};
      for (final w in werte.where((w) => w.isNotEmpty)) {
        zaehler[w] = (zaehler[w] ?? 0) + 1;
      }
      if (zaehler.isEmpty) return '–';
      return (zaehler.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)))
          .first
          .key;
    }

    final topFisch = haeufigster(faenge.map((f) => f.fischId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Zahl('${faenge.length}', 'Fänge'),
                _Zahl(
                  groesster == null
                      ? '–'
                      : '${groesster.laengeCm!.toStringAsFixed(0)} cm',
                  groesster == null
                      ? 'Größter'
                      : fischById(groesster.fischId)?.name ?? 'Größter',
                ),
                _Zahl(
                  '${faenge.where((f) => f.zurueckgesetzt).length}',
                  'Zurückgesetzt',
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Zahl(fischById(topFisch)?.name ?? '–', 'Häufigster Fisch'),
                _Zahl(haeufigster(faenge.map((f) => f.koeder)), 'Top-Köder'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Zahl extends StatelessWidget {
  const _Zahl(this.wert, this.label);

  final String wert;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Flexible(
      child: Column(
        children: [
          Text(wert, style: text.titleMedium, overflow: TextOverflow.ellipsis),
          Text(label, style: text.bodySmall, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// Karte für einen Fang – im Fangbuch und im Community-Feed.
class FangKarte extends StatelessWidget {
  const FangKarte(this.fang, {super.key, this.onTap, this.unten});

  final Fang fang;
  final VoidCallback? onTap;
  final Widget? unten;

  @override
  Widget build(BuildContext context) {
    final fisch = fischById(fang.fischId);
    final text = Theme.of(context).textTheme;
    final details = [
      if (fang.laengeCm != null) '${fang.laengeCm!.toStringAsFixed(0)} cm',
      if (fang.gewichtG != null) _gewicht(fang.gewichtG!),
      if (fang.koeder.isNotEmpty) 'Köder: ${fang.koeder}',
      if (fang.ausruestung.isNotEmpty) '🧰 ${fang.ausruestung}',
    ].join(' · ');
    final ort = [
      if (fang.gewaesser.isNotEmpty) fang.gewaesser,
      if (fang.bundesland.isNotEmpty) fang.bundesland,
    ].join(', ');

    final geschichte = fang.geschichte.isNotEmpty;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: geschichte
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary, width: 2),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (fang.hatFoto) FangFoto(fang.id),
            if (fang.hatVideo)
              Material(
                color: Colors.black87,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => VideoScreen(fang.id,
                          titel: fisch?.name ?? 'Video'))),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_fill, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Video ansehen',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(fisch?.name ?? fang.fischId,
                            style: text.titleMedium),
                      ),
                      if (fang.zurueckgesetzt)
                        const Tooltip(
                          message: 'Zurückgesetzt',
                          child: Icon(Icons.replay, size: 18),
                        ),
                      if (fang.uid.isNotEmpty && !fang.oeffentlich)
                        const Tooltip(
                          message: 'Privat',
                          child: Icon(Icons.lock_outline, size: 18),
                        ),
                    ],
                  ),
                  if (details.isNotEmpty) Text(details),
                  if (fang.nutzerName.isNotEmpty)
                    NutzerLink(fang.uid, fang.nutzerName, vorsatz: 'von '),
                  Text(
                    [
                      '${datumText(fang.datum)} ${uhrText(fang.datum)}',
                      if (ort.isNotEmpty) ort,
                    ].join(' · '),
                    style: text.bodySmall,
                  ),
                  if (fang.wetter case final w?)
                    Text(wetterKurz(w), style: text.bodySmall),
                  if (fang.notiz.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(fang.notiz),
                  ],
                  if (geschichte) ...[
                    const SizedBox(height: 6),
                    Text('📖 Fang-Geschichte', style: text.labelLarge),
                    Text(
                      fang.geschichte,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (fang.geschichte.length > 150)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('📖 ${fisch?.name ?? ''}'),
                              content: SingleChildScrollView(
                                  child: Text(fang.geschichte)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Schließen'),
                                ),
                              ],
                            ),
                          ),
                          child: const Text('Weiterlesen'),
                        ),
                      ),
                  ],
                  ?unten,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _gewicht(int g) => g >= 1000
      ? '${(g / 1000).toStringAsFixed(1).replaceAll('.', ',')} kg'
      : '$g g';
}

class FangFormular extends StatefulWidget {
  const FangFormular({super.key, this.fang});

  final Fang? fang;

  @override
  State<FangFormular> createState() => _FangFormularState();
}

class _FangFormularState extends State<FangFormular> {
  late String _fischId = widget.fang?.fischId ?? fische.first.id;
  late DateTime _datum = widget.fang?.datum ?? DateTime.now();
  late bool _zurueck = widget.fang?.zurueckgesetzt ?? false;
  late bool _oeffentlich = widget.fang?.oeffentlich ?? true;
  late Bundesland _land = Bundesland.ausName(widget.fang?.bundesland) ??
      SpeicherScope.of(context).bundesland;
  late final _laenge = TextEditingController(
    text: widget.fang?.laengeCm?.toStringAsFixed(0) ?? '',
  );
  late final _gewicht =
      TextEditingController(text: widget.fang?.gewichtG?.toString() ?? '');
  late final _gewaesser =
      TextEditingController(text: widget.fang?.gewaesser ?? '');
  late final _koeder = TextEditingController(text: widget.fang?.koeder ?? '');
  late final _notiz = TextEditingController(text: widget.fang?.notiz ?? '');
  late final _ausruestung =
      TextEditingController(text: widget.fang?.ausruestung ?? '');
  late final _geschichte =
      TextEditingController(text: widget.fang?.geschichte ?? '');
  List<String> _meineAusruestung = const [];
  Uint8List? _neuesFoto;
  bool _fotoEntfernen = false;
  Uint8List? _neuesVideo;
  bool _videoEntfernen = false;
  bool _videoLaedt = false;

  Future<void> _videoAufnehmen(ImageSource quelle) async {
    setState(() => _videoLaedt = true);
    try {
      final bytes = await videoWaehlen(quelle);
      if (bytes != null && mounted) {
        setState(() {
          _neuesVideo = bytes;
          _videoEntfernen = false;
        });
      }
    } catch (e) {
      if (mounted) meldung(context, '$e'.replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _videoLaedt = false);
    }
  }
  bool _speichert = false;
  LatLng? _ort;
  bool _ortGeaendert = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = KontoScope.of(context)?.uid;
      if (uid == null) return;
      fangDienst.ausruestung(uid).first.then((l) {
        if (mounted) {
          setState(() => _meineAusruestung = [for (final a in l) a.name]);
        }
      }).catchError((_) {});
    });
    final f = widget.fang;
    if (f != null && f.uid.isNotEmpty) {
      fangDienst.fangorte(f.uid).first.then((orte) {
        if (mounted && orte[f.id] != null && !_ortGeaendert) {
          setState(() => _ort = orte[f.id]);
        }
      }).catchError((_) {});
    }
  }

  /// Ort für das Wetter: eigener Fangort, sonst das Gewässer, sonst Braunau.
  LatLng get _wetterOrt {
    if (_ort != null) return _ort!;
    return alleGewaesser.zuName(_gewaesser.text)?.position ?? braunau;
  }

  bool get _online => KontoScope.of(context)?.angemeldet ?? false;

  /// Am PC gibt es nur die Bildauswahl, keine Kamera.
  bool get _hatKamera =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void dispose() {
    for (final c in [_laenge, _gewicht, _gewaesser, _koeder, _notiz,
        _ausruestung, _geschichte]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Warnung, wenn der Fisch geschont oder untermaßig ist.
  String? _warnung() {
    if (_zurueck) return null;
    final regel = fischById(_fischId)!.regel(_land);
    if (regel.istGeschont(_datum) == true) {
      return 'Achtung: Dieser Fisch hat am ${datumText(_datum)} Schonzeit in '
          '${_land.name} – zurücksetzen!';
    }
    final laenge = double.tryParse(_laenge.text.replaceAll(',', '.'));
    final mindest = regel.mindestmassCm;
    if (laenge != null && mindest != null && laenge < mindest) {
      return 'Achtung: Unter dem Brittelmaß von $mindest cm in ${_land.name} '
          '– zurücksetzen!';
    }
    return null;
  }

  Future<void> _fotoWaehlen(ImageSource quelle) async {
    final datei = await ImagePicker().pickImage(
      source: quelle,
      maxWidth: 900,
      maxHeight: 900,
      imageQuality: 60,
    );
    if (datei == null) return;
    final bytes = await datei.readAsBytes();
    setState(() {
      _neuesFoto = bytes;
      _fotoEntfernen = false;
    });
  }

  Fang _ausFormular(String id) {
    final konto = KontoScope.of(context);
    return Fang(
      id: id,
      fischId: _fischId,
      datum: _datum,
      laengeCm: double.tryParse(_laenge.text.replaceAll(',', '.')),
      gewichtG: int.tryParse(_gewicht.text),
      gewaesser: _gewaesser.text.trim(),
      bundesland: _land.name,
      koeder: _koeder.text.trim(),
      notiz: _notiz.text.trim(),
      zurueckgesetzt: _zurueck,
      ausruestung: _ausruestung.text.trim(),
      geschichte: _geschichte.text.trim(),
      verein: konto?.verein ?? '',
      uid: konto?.uid ?? '',
      nutzerName: konto?.name ?? '',
      oeffentlich: _oeffentlich,
      wetter: widget.fang?.datum == _datum ? widget.fang?.wetter : null,
    );
  }

  Future<void> _speichern() async {
    setState(() => _speichert = true);
    try {
      if (_online) {
        var fang = _ausFormular(widget.fang?.id ?? '');
        // Wetter zur Fangzeit automatisch dazuholen (wenn noch keins da ist).
        if (fang.wetter == null || _ortGeaendert) {
          final w = await wetterZurZeit(_wetterOrt, _datum);
          if (w != null) fang = fang.kopie(wetter: w);
        }
        final id = await fangDienst.speichern(
          fang,
          vorher: widget.fang,
          foto: _neuesFoto,
          fotoEntfernen: _fotoEntfernen,
          video: _neuesVideo,
          videoEntfernen: _videoEntfernen,
        );
        if (_ortGeaendert) {
          await fangDienst.fangortSpeichern(fang.uid, id, _ort);
        }
      } else {
        final speicher = SpeicherScope.of(context);
        await speicher.fangSpeichern(
          _ausFormular(widget.fang?.id ?? speicher.neueId()),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _speichert = false);
        meldung(context, 'Speichern fehlgeschlagen: $e');
      }
    }
  }

  Future<void> _loeschen() async {
    final fang = widget.fang!;
    if (_online) {
      await fangDienst.loeschen(fang);
    } else {
      await SpeicherScope.of(context).fangLoeschen(fang.id);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final warnung = _warnung();
    final online = _online;
    final zeigeAltesFoto =
        widget.fang?.hatFoto == true && _neuesFoto == null && !_fotoEntfernen;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fang == null ? 'Neuer Fang' : 'Fang bearbeiten'),
        actions: [
          if (widget.fang != null)
            IconButton(
              tooltip: 'Als Bild teilen',
              icon: const Icon(Icons.share_outlined),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => StoryScreen(widget.fang!))),
            ),
          if (widget.fang != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _loeschen,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (online) ...[
            if (_neuesFoto != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(_neuesFoto!, height: 220,
                    fit: BoxFit.cover),
              )
            else if (zeigeAltesFoto)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FangFoto(widget.fang!.id),
              ),
            Row(
              children: [
                if (_hatKamera)
                  TextButton.icon(
                    onPressed: () => _fotoWaehlen(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Foto'),
                  ),
                TextButton.icon(
                  onPressed: () => _fotoWaehlen(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galerie'),
                ),
                if (_neuesFoto != null || zeigeAltesFoto)
                  IconButton(
                    tooltip: 'Foto entfernen',
                    onPressed: () => setState(() {
                      _neuesFoto = null;
                      _fotoEntfernen = true;
                    }),
                    icon: const Icon(Icons.hide_image_outlined),
                  ),
              ],
            ),
            if (videoMoeglich) ...[
              if (_neuesVideo != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: VideoAbspieler(
                      key: ValueKey(_neuesVideo!.length), bytes: _neuesVideo),
                )
              else if (widget.fang?.hatVideo == true && !_videoEntfernen)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('🎬 Dieser Fang hat ein Video.'),
                ),
              Row(
                children: [
                  if (_videoLaedt)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  else ...[
                    TextButton.icon(
                      onPressed: () => _videoAufnehmen(ImageSource.camera),
                      icon: const Icon(Icons.videocam),
                      label: const Text('Video (max. 10 s)'),
                    ),
                    TextButton.icon(
                      onPressed: () => _videoAufnehmen(ImageSource.gallery),
                      icon: const Icon(Icons.video_library),
                      label: const Text('Aus Galerie'),
                    ),
                  ],
                  if (_neuesVideo != null ||
                      (widget.fang?.hatVideo == true && !_videoEntfernen))
                    IconButton(
                      tooltip: 'Video entfernen',
                      onPressed: () => setState(() {
                        _neuesVideo = null;
                        _videoEntfernen = true;
                      }),
                      icon: const Icon(Icons.videocam_off_outlined),
                    ),
                ],
              ),
            ],
          ],
          DropdownButtonFormField<String>(
            initialValue: _fischId,
            decoration: const InputDecoration(labelText: 'Fischart'),
            items: [
              for (final f in fische)
                DropdownMenuItem(value: f.id, child: Text(f.name)),
            ],
            onChanged: (v) => setState(() => _fischId = v!),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _laenge,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Länge (cm)',
                    suffixIcon: IconButton(
                      tooltip: 'Per Foto messen',
                      icon: const Icon(Icons.straighten),
                      onPressed: () async {
                        final cm = await Navigator.of(context).push<double>(
                            MaterialPageRoute(
                                builder: (_) => const MessenScreen()));
                        if (cm != null) {
                          setState(() => _laenge.text = cm.toStringAsFixed(0));
                        }
                      },
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _gewicht,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Gewicht (g)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GewaesserFeld(
            anfang: _gewaesser.text,
            geaendert: (name, g) {
              _gewaesser.text = name;
              if (g != null && g.land != _land) setState(() => _land = g.land);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Bundesland>(
            key: ValueKey(_land),
            initialValue: _land,
            decoration: const InputDecoration(labelText: 'Bundesland'),
            items: [
              for (final b in Bundesland.values)
                DropdownMenuItem(value: b, child: Text(b.name)),
            ],
            onChanged: (v) => setState(() => _land = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _koeder,
            decoration: InputDecoration(
              labelText: 'Köder',
              suffixIcon: online
                  ? IconButton(
                      tooltip: 'Aus der Köder-Box',
                      icon: const Icon(Icons.phishing),
                      onPressed: () async {
                        final k = await Navigator.of(context).push<String>(
                          MaterialPageRoute(
                              builder: (_) =>
                                  const KoederScreen(auswahl: true)),
                        );
                        if (k != null) setState(() => _koeder.text = k);
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(datumText(_datum)),
                  subtitle: const Text('Datum'),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _datum,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) {
                      setState(() => _datum = DateTime(d.year, d.month, d.day,
                          _datum.hour, _datum.minute));
                    }
                  },
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule),
                  title: Text(uhrText(_datum)),
                  subtitle: const Text('Uhrzeit'),
                  onTap: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_datum),
                    );
                    if (t != null) {
                      setState(() => _datum = DateTime(_datum.year,
                          _datum.month, _datum.day, t.hour, t.minute));
                    }
                  },
                ),
              ),
            ],
          ),
          if (online)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.place_outlined),
              title: Text(_ort == null
                  ? 'Fangort auf der Karte wählen (optional)'
                  : 'Fangort gewählt ✓'),
              subtitle: const Text('Bleibt privat – nur du siehst ihn'),
              trailing: _ort == null
                  ? const Icon(Icons.chevron_right)
                  : IconButton(
                      tooltip: 'Ort entfernen',
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() {
                        _ort = null;
                        _ortGeaendert = true;
                      }),
                    ),
              onTap: () async {
                final p = await Navigator.of(context).push<LatLng>(
                  MaterialPageRoute(builder: (_) => OrtWaehlen(start: _ort)),
                );
                if (p != null) {
                  setState(() {
                    _ort = p;
                    _ortGeaendert = true;
                  });
                }
              },
            ),
          if (widget.fang?.wetter case final w?)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Wetter beim Fang: ${wetterKurz(w)}'),
            ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Zurückgesetzt'),
            subtitle: const Text('Catch & Release – Tipps unter Statistik'),
            value: _zurueck,
            onChanged: (v) => setState(() => _zurueck = v),
          ),
          if (online)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Öffentlich teilen'),
              subtitle: const Text('In der Community sichtbar'),
              value: _oeffentlich,
              onChanged: (v) => setState(() => _oeffentlich = v),
            ),
          TextField(
            controller: _notiz,
            maxLines: 3,
            maxLength: 500,
            decoration: const InputDecoration(labelText: 'Notiz (Wetter …)'),
          ),
          Autocomplete<String>(
            initialValue: TextEditingValue(text: _ausruestung.text),
            optionsBuilder: (v) => _meineAusruestung.where((n) =>
                n.toLowerCase().contains(v.text.toLowerCase())),
            onSelected: (v) => _ausruestung.text = v,
            fieldViewBuilder: (context, controller, focus, _) => TextField(
              controller: controller,
              focusNode: focus,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: 'Ausrüstung (optional)',
                hintText: 'z. B. Spinnrute 2,40 m',
                counterText: '',
              ),
              onChanged: (v) => _ausruestung.text = v,
            ),
          ),
          const SizedBox(height: 8),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            initiallyExpanded: _geschichte.text.isNotEmpty,
            leading: const Icon(Icons.auto_stories_outlined),
            title: const Text('Fang-Geschichte erzählen (optional)'),
            children: [
              TextField(
                controller: _geschichte,
                maxLines: 8,
                minLines: 4,
                maxLength: 3000,
                decoration: const InputDecoration(
                  hintText: 'Wie war der Drill? Was ist passiert? '
                      'Geschichten werden im Feed hervorgehoben.',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          if (warnung != null) ...[
            const SizedBox(height: 12),
            HinweisKarte(warnung, icon: Icons.warning_amber),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _speichert ? null : _speichern,
            child: _speichert
                ? const SizedBox.square(
                    dimension: 20, child: CircularProgressIndicator())
                : const Text('Speichern'),
          ),
        ],
      ),
    );
  }
}
