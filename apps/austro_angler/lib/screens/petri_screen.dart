import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../data/fische.dart';
import '../design.dart';
import '../main.dart';
import '../services/fang_dienst.dart';
import '../services/fern_konfig.dart';
import '../services/ki.dart';
import 'fangbuch_screen.dart';
import 'konto_screen.dart';
import 'lexikon_screen.dart';
import 'regeln_screen.dart';
import 'widgets.dart';

/// Beispielfragen für den Einstieg.
const petriBeispiele = [
  'Was beißt heute bei mir?',
  'Welcher Köder für Zander im November?',
  'Darf ich heute einen Hecht mitnehmen?',
  'Wie binde ich ein Stahlvorfach?',
  'Tipps für meine Fischerprüfung',
];

/// Petri-KI: Chat mit dem KI-Angelguide.
class PetriScreen extends StatefulWidget {
  const PetriScreen({super.key, this.frage});

  /// Wird beim Öffnen gleich gefragt (z. B. „KI-Tipp“ aus Zielfisch).
  final String? frage;

  @override
  State<PetriScreen> createState() => _PetriScreenState();
}

class _PetriScreenState extends State<PetriScreen> {
  final _eingabe = TextEditingController();
  final _liste = ScrollController();

  @override
  void initState() {
    super.initState();
    final frage = widget.frage;
    if (frage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fragen(frage);
      });
    }
  }

  @override
  void dispose() {
    _eingabe.dispose();
    _liste.dispose();
    super.dispose();
  }

  /// Was Petri wissen soll – angemeldet mit den Fängen aus der Cloud und dem
  /// Wetter am Heimatort.
  Future<String> _kontext() async {
    final s = SpeicherScope.of(context);
    final uid = KontoScope.of(context)?.uid;
    final land = s.bundesland;
    final heimatName = s.heimatName;
    final lieblinge = s.lieblingsfische;
    final heimat = s.heimatLat == null || s.heimatLon == null
        ? null
        : LatLng(s.heimatLat!, s.heimatLon!);
    var faenge = s.faenge;
    if (uid != null && !PetriKi.testModus) {
      try {
        faenge = await fangDienst
            .meineFaenge(uid)
            .first
            .timeout(const Duration(seconds: 6));
      } catch (e) {
        debugPrint('Petri-Fänge: $e');
      }
    }
    final wetter =
        heimat == null || PetriKi.testModus ? null : await kiWetter(heimat);
    return kiKontext(
      jetzt: DateTime.now(),
      land: land,
      heimat: heimatName,
      lieblinge: lieblinge,
      faenge: faenge,
      wetter: wetter,
    );
  }

  void _nachUnten() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_liste.hasClients) {
        _liste.animateTo(_liste.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _fragen(String text) async {
    if (text.trim().isEmpty || petriKi.denkt) return;
    _eingabe.clear();
    _nachUnten();
    try {
      await petriKi.fragen(text,
          konto: KontoScope.of(context), kontext: _kontext);
      _nachUnten();
    } on KiFehler catch (e) {
      if (!mounted) return;
      _eingabe.text = text;
      meldung(context, e.text);
    }
  }

  void _foto() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const PetriFotoScreen()));

  @override
  Widget build(BuildContext context) {
    if (!funktionAn('ki')) return const FunktionAusSeite('Petri-KI');
    final konto = KontoScope.of(context);
    final angemeldet =
        konto?.angemeldet == true || PetriKi.testModus;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Petri-KI'),
        actions: [
          IconButton(
            tooltip: 'Fisch per Foto bestimmen',
            icon: const Icon(Icons.photo_camera_outlined),
            onPressed: _foto,
          ),
          ListenableBuilder(
            listenable: petriKi,
            builder: (context, _) => petriKi.verlauf.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Neuer Chat',
                    icon: const Icon(Icons.refresh),
                    onPressed: petriKi.denkt ? null : petriKi.neuerChat,
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: petriKi,
              builder: (context, _) => ListView(
                controller: _liste,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                children: [
                  if (petriKi.verlauf.isEmpty && !petriKi.denkt)
                    _Willkommen(onFrage: _fragen, onFoto: _foto),
                  for (final n in petriKi.verlauf) _Blase(n),
                  if (petriKi.denkt) const _Denkt(),
                ],
              ),
            ),
          ),
          if (angemeldet)
            _Eingabe(controller: _eingabe, onSenden: _fragen, onFoto: _foto)
          else
            const _AnmeldenLeiste(),
        ],
      ),
    );
  }
}

class _Willkommen extends StatelessWidget {
  const _Willkommen({required this.onFrage, required this.onFoto});

  final void Function(String) onFrage;
  final VoidCallback onFoto;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final akzent = DesignInfo.von(context).akzent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🎣', style: TextStyle(fontSize: 34)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('KI-ANGELGUIDE',
                              style: text.labelMedium?.copyWith(
                                  color: akzent, letterSpacing: 1.3)),
                          Text('Frag Petri', style: text.headlineSmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                    'Petri kennt die Schonzeiten und Brittelmaße deines '
                    'Bundeslands, dein Fangbuch und den heutigen Tag. Frag '
                    'einfach drauflos – wie einen erfahrenen Angelfreund.'),
                const SizedBox(height: 14),
                FilledButton.tonalIcon(
                  onPressed: onFoto,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Fisch per Foto bestimmen'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text('PROBIER ZUM BEISPIEL', style: text.labelMedium),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final b in petriBeispiele)
              ActionChip(label: Text(b), onPressed: () => onFrage(b)),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Petri ist eine KI und kann sich irren. Bei Regeln gelten das '
          'Landesgesetz und die Revierordnung.',
          style: text.bodySmall,
        ),
      ],
    );
  }
}

/// Eine Chat-Blase. **fett** wird fett dargestellt.
class _Blase extends StatelessWidget {
  const _Blase(this.n);

  final KiNachricht n;

  @override
  Widget build(BuildContext context) {
    final schema = Theme.of(context).colorScheme;
    final akzent = DesignInfo.von(context).akzent;
    final ich = n.vonMir;
    final farbeText = ich ? schema.onPrimary : schema.onSurface;
    final teile = n.text.split('**');
    final blase = Container(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * (ich ? 0.78 : 0.86)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ich ? schema.primary : schema.surfaceContainerHigh,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(ich ? 18 : 4),
          bottomRight: Radius.circular(ich ? 4 : 18),
        ),
      ),
      child: SelectableText.rich(
        TextSpan(
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: farbeText, height: 1.35),
          children: [
            for (var i = 0; i < teile.length; i++)
              TextSpan(
                text: teile[i],
                style: i.isOdd
                    ? const TextStyle(fontWeight: FontWeight.w700)
                    : null,
              ),
          ],
        ),
      ),
    );
    if (ich) return Align(alignment: Alignment.centerRight, child: blase);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 6),
          child: CircleAvatar(
            radius: 15,
            backgroundColor: akzent.withValues(alpha: 0.2),
            child: const Text('🎣', style: TextStyle(fontSize: 15)),
          ),
        ),
        Flexible(child: blase),
      ],
    );
  }
}

class _Denkt extends StatelessWidget {
  const _Denkt();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
          const SizedBox(width: 10),
          Text('Petri denkt nach …',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _Eingabe extends StatelessWidget {
  const _Eingabe(
      {required this.controller, required this.onSenden, required this.onFoto});

  final TextEditingController controller;
  final void Function(String) onSenden;
  final VoidCallback onFoto;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 8, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Foto',
                    icon: const Icon(Icons.photo_camera_outlined),
                    onPressed: onFoto,
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 2000,
                      textInputAction: TextInputAction.send,
                      onSubmitted: onSenden,
                      decoration: const InputDecoration(
                        hintText: 'Frag Petri …',
                        counterText: '',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  ListenableBuilder(
                    listenable: petriKi,
                    builder: (context, _) => IconButton.filled(
                      tooltip: 'Senden',
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: petriKi.denkt
                          ? null
                          : () => onSenden(controller.text),
                    ),
                  ),
                ],
              ),
              ListenableBuilder(
                listenable: petriKi,
                builder: (context, _) => petriKi.rest == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          petriKi.rest == 1
                              ? 'Heute noch 1 KI-Frage'
                              : 'Heute noch ${petriKi.rest} KI-Fragen',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnmeldenLeiste extends StatelessWidget {
  const _AnmeldenLeiste();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FilledButton.icon(
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const KontoScreen())),
          icon: const Icon(Icons.login),
          label: const Text('Anmelden, um Petri zu fragen'),
        ),
      ),
    );
  }
}

/// Foto-Bestimmung: Foto aufnehmen oder wählen, Petri sagt, welcher Fisch
/// das ist – die App ergänzt Schonzeit und Brittelmaß.
class PetriFotoScreen extends StatefulWidget {
  const PetriFotoScreen({super.key, this.testBild});

  /// Nur für Tests und Store-Bilder: dieses Bild gleich bestimmen.
  @visibleForTesting
  final Uint8List? testBild;

  @override
  State<PetriFotoScreen> createState() => _PetriFotoScreenState();
}

class _PetriFotoScreenState extends State<PetriFotoScreen> {
  Uint8List? _bild;
  FotoErgebnis? _ergebnis;
  String? _fehler;
  bool _laeuft = false;

  @override
  void initState() {
    super.initState();
    final t = widget.testBild;
    if (t != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _bestimmen(t));
    }
  }

  Future<void> _waehlen(ImageSource quelle) async {
    final datei = await ImagePicker().pickImage(
      source: quelle,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 80,
    );
    if (datei == null) return;
    await _bestimmen(await datei.readAsBytes());
  }

  Future<void> _bestimmen(Uint8List bild) async {
    if (!mounted) return;
    final konto = KontoScope.of(context);
    setState(() {
      _bild = bild;
      _ergebnis = null;
      _fehler = null;
      _laeuft = true;
    });
    try {
      final e = await petriKi.fotoBestimmen(bild, konto: konto);
      if (mounted) setState(() => _ergebnis = e);
    } on KiFehler catch (e) {
      if (mounted) setState(() => _fehler = e.text);
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!funktionAn('ki')) return const FunktionAusSeite('Petri-KI');
    final angemeldet = KontoScope.of(context)?.angemeldet == true ||
        PetriKi.testModus;
    final text = Theme.of(context).textTheme;
    final bild = _bild;
    final ergebnis = _ergebnis;
    return Scaffold(
      appBar: AppBar(title: const Text('Fisch bestimmen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (bild == null) ...[
            Text('Welcher Fisch ist das?', style: text.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Mach ein Foto vom ganzen Fisch, am besten von der Seite. Petri '
              'erkennt ${fische.where((f) => !f.ausgestorben).length} heimische '
              'Arten – und die App sagt dir gleich, ob die Art heute bei dir '
              'geschont ist.',
            ),
            const SizedBox(height: 18),
          ] else
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.memory(bild, fit: BoxFit.cover),
              ),
            ),
          if (_laeuft)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Petri schaut genau hin …'),
                ],
              ),
            ),
          if (_fehler != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: HinweisKarte(_fehler!, icon: Icons.error_outline),
            ),
          if (ergebnis != null) ...[
            const SizedBox(height: 12),
            FotoErgebnisKarte(ergebnis),
          ],
          if (!_laeuft) ...[
            const SizedBox(height: 16),
            if (!angemeldet)
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const KontoScreen())),
                icon: const Icon(Icons.login),
                label: const Text('Anmelden, um Fotos zu bestimmen'),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _waehlen(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(bild == null ? 'Foto machen' : 'Neues Foto'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _waehlen(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Aus Galerie'),
                    ),
                  ),
                ],
              ),
          ],
          const SizedBox(height: 14),
          Text(
            'KI-Bestimmung ohne Gewähr. Im Zweifel den Fisch schonend '
            'zurücksetzen.',
            style: text.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Ergebnis der Foto-Bestimmung mit Regeln fürs eigene Bundesland.
class FotoErgebnisKarte extends StatelessWidget {
  const FotoErgebnisKarte(this.e, {super.key});

  final FotoErgebnis e;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final f = e.fischId == null ? null : fischById(e.fischId!);
    if (!e.erkannt || f == null) {
      return HinweisKarte(
        e.hinweis.isEmpty
            ? 'Petri erkennt auf diesem Foto keinen Fisch. Versuch es mit '
                'einem schärferen Foto von der Seite.'
            : e.hinweis,
        icon: Icons.help_outline,
      );
    }
    final land = SpeicherScope.of(context).bundesland;
    final regel = f.regel(land);
    final status = RegelStatus.von(f, land, DateTime.now());
    final akzent = DesignInfo.von(context).akzent;
    final sicherheitFarbe = switch (e.sicherheit) {
      'hoch' => Colors.green.shade500,
      'mittel' => Colors.orange.shade600,
      _ => Theme.of(context).colorScheme.error,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PETRI ERKENNT',
                style: text.labelMedium
                    ?.copyWith(color: akzent, letterSpacing: 1.3)),
            Row(
              children: [
                Expanded(
                  child: Text(f.name.split(' (').first,
                      style: text.headlineMedium),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: sicherheitFarbe, width: 1.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(e.sicherheitText,
                      style: text.labelMedium?.copyWith(
                          color: sicherheitFarbe, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            Text(f.familie, style: text.bodySmall),
            if (e.merkmale.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Daran erkannt', style: text.titleSmall),
              const SizedBox(height: 4),
              for (final m in e.merkmale)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check, size: 18, color: akzent),
                      const SizedBox(width: 6),
                      Expanded(child: Text(m)),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text('Heute in ${land.name}',
                              style: text.titleSmall)),
                      StatusPille(status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Schonzeit: ${regel.schonzeitText}'),
                  Text('Brittelmaß: ${regel.mindestmassText}'),
                ],
              ),
            ),
            if (e.hinweis.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(e.hinweis, style: text.bodyMedium),
            ],
            if (e.alternativen.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Könnte auch sein', style: text.titleSmall),
              const SizedBox(height: 4),
              for (final (id, grund) in e.alternativen)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.compare_arrows),
                  title: Text(fischById(id)!.name.split(' (').first),
                  subtitle: grund.isEmpty ? null : Text(grund),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => FischDetail(fischById(id)!))),
                ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => FangFormular(vorFischId: f.id))),
              icon: const Icon(Icons.add),
              label: const Text('Ins Fangbuch eintragen'),
            ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => FischDetail(f))),
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('Im Fischlexikon ansehen'),
            ),
          ],
        ),
      ),
    );
  }
}
