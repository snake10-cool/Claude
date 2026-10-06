import 'dart:convert';

import 'package:app_basis/app_basis.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../l10n/l.dart';
import '../logik/typen.dart';
import '../widgets/code_ansicht.dart';
import '../widgets/snippet_aus_karte.dart';

IconData typSymbol(KartenTyp t) => switch (t) {
  KartenTyp.begriff => Icons.lightbulb_outline,
  KartenTyp.ausgabe => Icons.terminal,
  KartenTyp.luecke => Icons.space_bar,
};

/// Alle Karten eines Stapels (bei gesperrten Stapeln nur eine Vorschau).
class KartenScreen extends StatelessWidget {
  const KartenScreen({
    super.key,
    required this.stapel,
    this.nurVorschau = false,
  });

  final Stapel stapel;
  final bool nurVorschau;

  static const vorschauAnzahl = 5;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(stapel.name)),
      floatingActionButton: stapel.eigen
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => KarteBearbeitenScreen(stapel: stapel),
                ),
              ),
              icon: const Icon(Icons.add),
              label: Text(l.karteHinzufuegen),
            )
          : null,
      body: StreamBuilder<List<Karte>>(
        stream: db.kartenBeobachten(stapel.id),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var karten = snap.data!;
          if (karten.isEmpty) {
            return LeerHinweis(
              symbol: Icons.style,
              titel: l.keineKarten,
              text: stapel.eigen ? l.keineKartenText : null,
            );
          }
          final gesperrt = nurVorschau && karten.length > vorschauAnzahl;
          if (nurVorschau) karten = karten.take(vorschauAnzahl).toList();
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              for (final k in karten)
                ListTile(
                  leading: Icon(typSymbol(KartenTyp.values.byName(k.typ))),
                  title: Text(
                    k.frage,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: k.code == null
                      ? null
                      : Text(
                          k.code!.split('\n').first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          KarteAnsichtScreen(karte: k, stapel: stapel),
                    ),
                  ),
                ),
              if (gesperrt)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l.mehrNachFreischalten,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Eine Karte mit Antwort und Erklärung.
class KarteAnsichtScreen extends StatelessWidget {
  const KarteAnsichtScreen({
    super.key,
    required this.karte,
    required this.stapel,
  });

  final Karte karte;
  final Stapel stapel;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    final typ = KartenTyp.values.byName(karte.typ);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l.alsSnippet,
            icon: const Icon(Icons.bookmark_add_outlined),
            onPressed: () =>
                karteAlsSnippet(context, karte, stapel.sprache, stapel.name),
          ),
          if (stapel.eigen)
            IconButton(
              tooltip: l.bearbeiten,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      KarteBearbeitenScreen(stapel: stapel, karte: karte),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(karte.frage, style: t.textTheme.titleLarge),
          if (karte.code != null) ...[
            const SizedBox(height: 16),
            CodeAnsicht(
              code: typ == KartenTyp.luecke
                  ? karte.code!.replaceAll('___', karte.antwort)
                  : karte.code!,
              sprache: stapel.sprache,
            ),
          ],
          const SizedBox(height: 16),
          Card(
            color: t.colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.antwort, style: t.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    karte.antwort,
                    style: typ == KartenTyp.begriff
                        ? t.textTheme.bodyLarge
                        : const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 16,
                          ),
                  ),
                ],
              ),
            ),
          ),
          if (karte.erklaerung.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(karte.erklaerung, style: t.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// Eigene Karte anlegen oder ändern.
class KarteBearbeitenScreen extends StatefulWidget {
  const KarteBearbeitenScreen({super.key, required this.stapel, this.karte});

  final Stapel stapel;
  final Karte? karte;

  @override
  State<KarteBearbeitenScreen> createState() => _KarteBearbeitenScreenState();
}

class _KarteBearbeitenScreenState extends State<KarteBearbeitenScreen> {
  final _form = GlobalKey<FormState>();
  late KartenTyp _typ = widget.karte == null
      ? KartenTyp.begriff
      : KartenTyp.values.byName(widget.karte!.typ);
  late final _frage = TextEditingController(text: widget.karte?.frage);
  late final _code = TextEditingController(text: widget.karte?.code);
  late final _antwort = TextEditingController(text: widget.karte?.antwort);
  late final _erklaerung = TextEditingController(
    text: widget.karte?.erklaerung,
  );
  late final List<TextEditingController> _falsch = () {
    final alle = widget.karte?.optionenListe ?? const <String>[];
    final falsche = alle.where((o) => o != widget.karte?.antwort).toList();
    return [
      for (var i = 0; i < 3; i++)
        TextEditingController(text: i < falsche.length ? falsche[i] : ''),
    ];
  }();

  @override
  void dispose() {
    for (final c in [_frage, _code, _antwort, _erklaerung, ..._falsch]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _speichern() async {
    if (!_form.currentState!.validate()) return;
    final optionen = _typ == KartenTyp.begriff
        ? const <String>[]
        : [
            _antwort.text.trim(),
            for (final c in _falsch)
              if (c.text.trim().isNotEmpty) c.text.trim(),
          ];
    await db.karteSpeichern(
      KarteTabelleCompanion(
        id: widget.karte == null
            ? const Value.absent()
            : Value(widget.karte!.id),
        stapelId: Value(widget.stapel.id),
        typ: Value(_typ.name),
        frage: Value(_frage.text.trim()),
        antwort: Value(_antwort.text.trim()),
        code: Value(_code.text.trim().isEmpty ? null : _code.text),
        optionen: Value(jsonEncode(optionen)),
        erklaerung: Value(_erklaerung.text.trim()),
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _loeschen() async {
    final l = context.l;
    if (!await bestaetigen(
      context,
      titel: l.karteLoeschen,
      text: l.karteLoeschenText,
    )) {
      return;
    }
    await db.karteLoeschen(widget.karte!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final codePflicht = _typ != KartenTyp.begriff;
    const mono = TextStyle(fontFamily: 'monospace', fontSize: 14);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.karte == null ? l.karteHinzufuegen : l.karteBearbeiten,
        ),
        actions: [
          if (widget.karte != null)
            IconButton(
              tooltip: l.loeschen,
              icon: const Icon(Icons.delete_outline),
              onPressed: _loeschen,
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: _speichern,
            icon: const Icon(Icons.check),
            label: Text(l.speichern),
          ),
        ),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<KartenTyp>(
              segments: [
                ButtonSegment(
                  value: KartenTyp.begriff,
                  label: Text(l.typBegriff),
                ),
                ButtonSegment(
                  value: KartenTyp.ausgabe,
                  label: Text(l.typAusgabe),
                ),
                ButtonSegment(
                  value: KartenTyp.luecke,
                  label: Text(l.typLuecke),
                ),
              ],
              selected: {_typ},
              onSelectionChanged: (s) => setState(() {
                _typ = s.first;
                if (_frage.text.isEmpty && _typ == KartenTyp.ausgabe) {
                  _frage.text = l.wasGibtAus;
                }
              }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _frage,
              maxLines: null,
              decoration: InputDecoration(labelText: l.frage),
              validator: (t) => (t ?? '').trim().isEmpty ? l.pflichtfeld : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _code,
              maxLines: null,
              minLines: 4,
              style: mono,
              decoration: InputDecoration(
                labelText: codePflicht ? l.code : l.codeOptional,
                helperText: _typ == KartenTyp.luecke ? l.lueckeHilfe : null,
                alignLabelWithHint: true,
              ),
              validator: (t) {
                if (!codePflicht) return null;
                if ((t ?? '').trim().isEmpty) return l.pflichtfeld;
                if (_typ == KartenTyp.luecke && !t!.contains('___')) {
                  return l.lueckeFehlt;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _antwort,
              maxLines: null,
              style: _typ == KartenTyp.begriff ? null : mono,
              decoration: InputDecoration(
                labelText: _typ == KartenTyp.begriff
                    ? l.antwort
                    : l.richtigeAntwort,
              ),
              validator: (t) => (t ?? '').trim().isEmpty ? l.pflichtfeld : null,
            ),
            if (_typ != KartenTyp.begriff) ...[
              const SizedBox(height: 12),
              for (final (i, c) in _falsch.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: c,
                    style: mono,
                    decoration: InputDecoration(
                      labelText: l.falscheAntwort(i + 1),
                    ),
                    validator: (t) => i == 0 && (t ?? '').trim().isEmpty
                        ? l.mindestensEineFalsche
                        : null,
                  ),
                ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _erklaerung,
              maxLines: null,
              decoration: InputDecoration(labelText: l.erklaerungOptional),
            ),
          ],
        ),
      ),
    );
  }
}
