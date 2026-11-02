import 'package:flutter/material.dart';

import '../main.dart';
import '../models/buch.dart';
import '../services/buchsuche.dart';
import '../widgets/buch_kachel.dart';
import 'scanner_screen.dart';
import 'start_screen.dart';

/// Sucht in Open Library bzw. Google Books und legt Treffer als eigene
/// Bücher an. Bücher aus dem Katalog werden erkannt (die haben ein Quiz).
class OnlineSucheScreen extends StatefulWidget {
  const OnlineSucheScreen({super.key, this.text = '', this.scannen = false});

  final String text;

  /// Gleich mit dem Scanner starten.
  final bool scannen;

  @override
  State<OnlineSucheScreen> createState() => _OnlineSucheScreenState();
}

class _OnlineSucheScreenState extends State<OnlineSucheScreen> {
  final _suche = BuchSuche();
  late final _feld = TextEditingController(text: widget.text);
  List<Treffer>? _treffer;
  String? _fehler;
  var _laedt = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scannen) {
        _scannen();
      } else if (widget.text.isNotEmpty) {
        _los();
      }
    });
  }

  @override
  void dispose() {
    _feld.dispose();
    super.dispose();
  }

  Future<void> _los() async {
    if (_feld.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _laedt = true;
      _fehler = null;
    });
    try {
      final t = await _suche.suchen(_feld.text);
      if (mounted) setState(() => _treffer = t);
    } on SuchFehler catch (e) {
      if (mounted) setState(() => _fehler = e.text);
    } finally {
      if (mounted) setState(() => _laedt = false);
    }
  }

  Future<void> _scannen() async {
    final isbn = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
    if (isbn == null || !mounted) return;
    _feld.text = isbn;
    await _los();
    if (mounted && _treffer?.length == 1) _anzeigen(_treffer!.first);
  }

  void _anzeigen(Treffer t) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _TrefferDetails(t, beiFertig: (id) {
        Navigator.of(context).pop();
        buchOeffnen(context, id);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final treffer = _treffer;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _feld,
          autofocus: widget.text.isEmpty && !widget.scannen,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(hintText: 'Titel, Autor oder ISBN', border: InputBorder.none),
          onSubmitted: (_) => _los(),
        ),
        actions: [
          IconButton(tooltip: 'Suchen', icon: const Icon(Icons.search), onPressed: _los),
          IconButton(tooltip: 'ISBN scannen', icon: const Icon(Icons.qr_code_scanner), onPressed: _scannen),
        ],
      ),
      body: _laedt
          ? const Center(child: CircularProgressIndicator())
          : _fehler != null
              ? _Hinweis(Icons.wifi_off, '$_fehler\nBist du mit dem Internet verbunden?')
              : treffer == null
                  ? const _Hinweis(Icons.travel_explore,
                      'Finde jedes Buch der Welt – per Titel, Autor oder Strichcode.')
                  : treffer.isEmpty
                      ? const _Hinweis(Icons.search_off, 'Nichts gefunden. Versuch es mit weniger Wörtern.')
                      : ListView.builder(
                          itemCount: treffer.length,
                          itemBuilder: (context, i) {
                            final t = treffer[i];
                            return ListTile(
                              leading: _TrefferCover(t, breite: 40),
                              title: Text(t.titel),
                              subtitle: Text([t.autor, if (t.jahr > 0) '${t.jahr}'].join(' · ')),
                              trailing: t.imKatalog != null
                                  ? const Tooltip(message: 'Mit Quiz', child: Icon(Icons.quiz_outlined))
                                  : null,
                              onTap: () => _anzeigen(t),
                            );
                          },
                        ),
    );
  }
}

class _Hinweis extends StatelessWidget {
  const _Hinweis(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// Cover eines Treffers: das Katalog-Buch oder ein vorläufiges Buch-Objekt.
class _TrefferCover extends StatelessWidget {
  const _TrefferCover(this.t, {required this.breite});

  final Treffer t;
  final double breite;

  @override
  Widget build(BuildContext context) => BuchCover(
        Buch(
          id: '',
          titel: t.titel,
          autor: t.autor,
          jahr: t.jahr,
          seiten: t.seiten,
          zielgruppe: t.zielgruppe,
          tags: t.tags,
          beschreibung: t.beschreibung,
          coverUrl: t.coverUrl,
        ),
        breite: breite,
      );
}

class _TrefferDetails extends StatelessWidget {
  const _TrefferDetails(this.t, {required this.beiFertig});

  final Treffer t;

  /// Wird mit der ID des angelegten (oder im Katalog gefundenen) Buchs aufgerufen.
  final ValueChanged<String> beiFertig;

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final theme = Theme.of(context);
    final katalogBuch = t.imKatalog;

    Future<void> hinzufuegen(Status status) async {
      var id = katalogBuch?.id;
      if (id == null) {
        // Dasselbe Buch nicht doppelt anlegen.
        for (final b in speicher.eigeneBuecher) {
          if ((t.isbn != null && b.isbn == t.isbn) || (b.titel == t.titel && b.autor == t.autor)) id = b.id;
        }
        id ??= (await speicher.eigenesBuchAnlegen(
          t.titel,
          t.autor,
          t.seiten,
          jahr: t.jahr,
          tags: t.tags,
          zielgruppe: t.zielgruppe,
          beschreibung: t.beschreibung.isEmpty ? 'Aus der Online-Suche.' : t.beschreibung,
          coverUrl: t.coverUrl,
          isbn: t.isbn,
        ))
            .id;
      }
      await speicher.eintragSetzen(
        id,
        Eintrag(
          status: status,
          format: speicher.lieblingsFormat == 1 ? Format.gehoert : Format.gelesen,
        ),
      );
      beiFertig(id);
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TrefferCover(t, breite: 80),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.titel, style: theme.textTheme.titleLarge),
                      Text(t.autor, style: theme.textTheme.titleSmall),
                      Text(
                        [
                          if (t.jahr > 0) '${t.jahr}',
                          if (t.seiten > 0) '${t.seiten} Seiten',
                          if (t.isbn != null) 'ISBN ${t.isbn}',
                        ].join(' · '),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (katalogBuch != null) ...[
              const SizedBox(height: 12),
              Card(
                color: theme.colorScheme.secondaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.quiz),
                  title: const Text('Dieses Buch hat ein Quiz!'),
                  subtitle: Text('Gefunden als „${katalogBuch.titel}"'),
                ),
              ),
            ],
            if (t.beschreibung.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(t.beschreibung),
            ],
            if (t.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final tag in t.tags)
                    Chip(label: Text(Tags.namen[tag] ?? tag), visualDensity: VisualDensity.compact),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => hinzufuegen(Status.gelesen),
                  icon: const Icon(Icons.check),
                  label: const Text('Gelesen'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => hinzufuegen(Status.wunschliste),
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Wunschliste'),
                ),
                OutlinedButton.icon(
                  onPressed: () => hinzufuegen(Status.lese),
                  icon: const Icon(Icons.auto_stories_outlined),
                  label: const Text('Lese ich gerade'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
