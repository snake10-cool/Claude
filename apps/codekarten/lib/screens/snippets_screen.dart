import 'package:app_basis/app_basis.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../l10n/l.dart';
import '../logik/suche.dart';
import '../logik/typen.dart';
import '../widgets/code_ansicht.dart';
import '../widgets/sprach_abzeichen.dart';

/// Eigene Code-Schnipsel: suchen, nach Tags filtern, kopieren.
class SnippetsScreen extends StatefulWidget {
  const SnippetsScreen({super.key});

  @override
  State<SnippetsScreen> createState() => _SnippetsScreenState();
}

class _SnippetsScreenState extends State<SnippetsScreen> {
  final _suche = TextEditingController();
  String? _tag;

  @override
  void dispose() {
    _suche.dispose();
    super.dispose();
  }

  void _oeffnen([Snippet? s]) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => s == null
          ? const SnippetBearbeitenScreen()
          : SnippetScreen(snippetId: s.id),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.tabSnippets),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _suche,
              decoration: InputDecoration(
                hintText: l.snippetsSuchen,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _suche.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l.leeren,
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(_suche.clear),
                      ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: _oeffnen,
        icon: const Icon(Icons.add),
        label: Text(l.neuesSnippet),
      ),
      body: StreamBuilder<List<Snippet>>(
        stream: db.snippetsBeobachten(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final alle = snap.data!;
          if (alle.isEmpty) {
            return LeerHinweis(
              symbol: Icons.code,
              titel: l.keineSnippets,
              text: l.keineSnippetsText,
              knopf: l.neuesSnippet,
              aktion: _oeffnen,
            );
          }
          final tags = {for (final s in alle) ...tagsLesen(s.tags)}.toList()
            ..sort();
          final liste = alle
              .where(
                (s) =>
                    (_tag == null || tagsLesen(s.tags).contains(_tag)) &&
                    passtZurSuche(
                      suche: _suche.text,
                      titel: s.titel,
                      code: s.code,
                      notiz: s.notiz,
                      tags: s.tags,
                    ),
              )
              .toList();
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              if (tags.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      for (final t in tags)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text('#$t'),
                            selected: _tag == t,
                            onSelected: (an) =>
                                setState(() => _tag = an ? t : null),
                          ),
                        ),
                    ],
                  ),
                ),
              if (liste.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(l.nichtsGefunden, textAlign: TextAlign.center),
                ),
              for (final s in liste)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Card(
                    child: InkWell(
                      onTap: () => _oeffnen(s),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SprachAbzeichen(s.sprache),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    s.titel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                ),
                                if (s.favorit)
                                  const Icon(
                                    Icons.star,
                                    size: 18,
                                    color: Colors.amber,
                                  ),
                                IconButton(
                                  tooltip: l.kopieren,
                                  icon: const Icon(Icons.copy, size: 20),
                                  onPressed: () => kopieren(context, s.code),
                                ),
                              ],
                            ),
                            CodeAnsicht(
                              code: s.code,
                              sprache: s.sprache,
                              kopierbar: false,
                              groesse: 12,
                              maxZeilen: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Ein Snippet ansehen: Code, Notiz, Tags, kopieren, als Lernkarte.
class SnippetScreen extends StatelessWidget {
  const SnippetScreen({super.key, required this.snippetId});
  final int snippetId;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    return StreamBuilder<List<Snippet>>(
      stream: db.snippetsBeobachten(),
      builder: (context, snap) {
        final s = snap.data?.where((x) => x.id == snippetId).firstOrNull;
        if (s == null) {
          return Scaffold(appBar: AppBar());
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(s.titel),
            actions: [
              IconButton(
                tooltip: l.favorit,
                icon: Icon(s.favorit ? Icons.star : Icons.star_outline),
                onPressed: () => db.snippetSpeichern(
                  s.toCompanion(true).copyWith(favorit: Value(!s.favorit)),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (w) async {
                  switch (w) {
                    case 'bearbeiten':
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => SnippetBearbeitenScreen(snippet: s),
                        ),
                      );
                    case 'karte':
                      await snippetAlsKarte(context, s);
                    case 'loeschen':
                      if (await bestaetigen(
                        context,
                        titel: l.snippetLoeschen,
                        text: s.titel,
                      )) {
                        await db.snippetLoeschen(s.id);
                        if (context.mounted) Navigator.pop(context);
                      }
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'bearbeiten', child: Text(l.bearbeiten)),
                  PopupMenuItem(value: 'karte', child: Text(l.alsLernkarte)),
                  PopupMenuItem(value: 'loeschen', child: Text(l.loeschen)),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [SprachAbzeichen(s.sprache, gross: true)]),
              const SizedBox(height: 12),
              CodeAnsicht(code: s.code, sprache: s.sprache),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => kopieren(context, s.code),
                icon: const Icon(Icons.copy),
                label: Text(l.codeKopieren),
              ),
              if (s.notiz.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(s.notiz, style: t.textTheme.bodyLarge),
              ],
              if (s.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final tag in tagsLesen(s.tags))
                      Chip(label: Text('#$tag')),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => snippetAlsKarte(context, s),
                icon: const Icon(Icons.style_outlined),
                label: Text(l.alsLernkarte),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Macht aus einem Snippet eine Lernkarte im eigenen Stapel „Meine Snippets“.
Future<void> snippetAlsKarte(BuildContext context, Snippet s) async {
  final l = context.l;
  final stapelId = await db.eigenerStapel(l.stapelMeineSnippets, s.sprache);
  await db.karteSpeichern(
    KarteTabelleCompanion.insert(
      stapelId: stapelId,
      typ: KartenTyp.begriff.name,
      frage: l.wasMachtDieserCode,
      antwort: s.notiz.isNotEmpty ? '${s.titel}\n\n${s.notiz}' : s.titel,
      code: Value(s.code),
    ),
  );
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.alsKarteGespeichert)));
  }
}

class SnippetBearbeitenScreen extends StatefulWidget {
  const SnippetBearbeitenScreen({super.key, this.snippet});
  final Snippet? snippet;

  @override
  State<SnippetBearbeitenScreen> createState() =>
      _SnippetBearbeitenScreenState();
}

class _SnippetBearbeitenScreenState extends State<SnippetBearbeitenScreen> {
  final _form = GlobalKey<FormState>();
  late final _titel = TextEditingController(text: widget.snippet?.titel);
  late final _code = TextEditingController(text: widget.snippet?.code);
  late final _tags = TextEditingController(
    text: widget.snippet?.tags.replaceAll(',', ', '),
  );
  late final _notiz = TextEditingController(text: widget.snippet?.notiz);
  late String _sprache = widget.snippet?.sprache ?? 'java';

  @override
  void dispose() {
    for (final c in [_titel, _code, _tags, _notiz]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _speichern() async {
    if (!_form.currentState!.validate()) return;
    final jetzt = DateTime.now();
    await db.snippetSpeichern(
      SnippetTabelleCompanion(
        id: widget.snippet == null
            ? const Value.absent()
            : Value(widget.snippet!.id),
        titel: Value(_titel.text.trim()),
        sprache: Value(_sprache),
        code: Value(_code.text),
        tags: Value(tagsLesen(_tags.text).join(',')),
        notiz: Value(_notiz.text.trim()),
        erstellt: Value(widget.snippet?.erstellt ?? jetzt),
        geaendert: Value(jetzt),
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.snippet == null ? l.neuesSnippet : l.snippetBearbeiten,
        ),
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
            TextFormField(
              controller: _titel,
              decoration: InputDecoration(
                labelText: l.titel,
                hintText: l.snippetTitelBeispiel,
              ),
              validator: (t) => (t ?? '').trim().isEmpty ? l.pflichtfeld : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _sprache,
              decoration: InputDecoration(labelText: l.sprache),
              items: [
                for (final s in sprachen)
                  DropdownMenuItem(value: s, child: Text(spracheName(s))),
              ],
              onChanged: (v) => setState(() => _sprache = v ?? _sprache),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _code,
              maxLines: null,
              minLines: 8,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              decoration: InputDecoration(
                labelText: l.code,
                alignLabelWithHint: true,
              ),
              validator: (t) => (t ?? '').trim().isEmpty ? l.pflichtfeld : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tags,
              decoration: InputDecoration(
                labelText: l.tags,
                helperText: l.tagsHilfe,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notiz,
              maxLines: null,
              minLines: 2,
              decoration: InputDecoration(labelText: l.notiz),
            ),
          ],
        ),
      ),
    );
  }
}
