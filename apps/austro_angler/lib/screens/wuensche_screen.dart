import 'package:flutter/material.dart';

import '../main.dart';
import '../data/fische.dart';
import '../services/fang_dienst.dart';
import '../services/konto.dart';
import 'widgets.dart';
import '../services/fern_konfig.dart';

const _status = {
  'neu': ('🆕', 'Neu'),
  'geplant': ('🛠️', 'Geplant'),
  'erledigt': ('✅', 'Erledigt'),
  'abgelehnt': ('❌', 'Abgelehnt'),
};

class WuenscheScreen extends StatelessWidget {
  const WuenscheScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context);
    if (konto == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wünsche')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: HinweisKarte(
            'Hier kannst du bald Wünsche für die App abschicken – sobald die '
            'Online-Funktionen aktiv sind.',
            icon: Icons.lightbulb_outline,
          ),
        ),
      );
    }
    if (!konto.angemeldet) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wünsche')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: AnmeldenKarte(
            'Melde dich an, um Wünsche für die App abzuschicken: neue '
            'Gewässer, Funktionen, Fehler …',
          ),
        ),
      );
    }
    if (konto.istAdmin) return _AdminAnsicht(konto);
    return Scaffold(
      appBar: AppBar(title: const Text('Wünsche')),
      body: _WunschListe(konto, admin: false),
    );
  }
}

class _AdminAnsicht extends StatelessWidget {
  const _AdminAnsicht(this.konto);

  final Konto konto;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin 🛡️'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            tabs: [
              Tab(icon: Icon(Icons.lightbulb), text: 'Wünsche'),
              Tab(icon: Icon(Icons.euro), text: 'Preise'),
              Tab(icon: Icon(Icons.water), text: 'Infos'),
              Tab(icon: Icon(Icons.flag), text: 'Meldungen'),
              Tab(icon: Icon(Icons.tune), text: 'Steuerung'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _WunschListe(konto, admin: true),
            const _PreisPruefung(),
            const _InfoPruefung(),
            const _MeldungenListe(),
            const _Steuerung(),
          ],
        ),
      ),
    );
  }
}

class _WunschListe extends StatefulWidget {
  const _WunschListe(this.konto, {required this.admin});

  final Konto konto;
  final bool admin;

  @override
  State<_WunschListe> createState() => _WunschListeState();
}

class _WunschListeState extends State<_WunschListe>
    with AutomaticKeepAliveClientMixin {
  late final _stream =
      fangDienst.wuensche(uid: widget.konto.uid!, admin: widget.admin);
  final _text = TextEditingController();
  bool _sendet = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _senden() async {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    setState(() => _sendet = true);
    try {
      await fangDienst.wunschSenden(
        uid: widget.konto.uid!,
        nutzerName: widget.konto.name ?? '',
        text: text,
      );
      _text.clear();
      if (mounted) meldung(context, 'Danke für deinen Wunsch! 🙏');
    } catch (_) {
      if (mounted) meldung(context, 'Senden fehlgeschlagen.');
    } finally {
      if (mounted) setState(() => _sendet = false);
    }
  }

  Future<void> _antworten(Eintrag w) async {
    final controller = TextEditingController(text: w.antwort ?? '');
    final antwort = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Antwort'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          maxLength: 500,
          decoration: const InputDecoration(hintText: 'Sichtbar für den Nutzer'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
    if (antwort != null) {
      await fangDienst.wunschBeantworten(w.id, antwort: antwort);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final text = Theme.of(context).textTheme;
    return StreamBuilder<List<Eintrag>>(
      stream: _stream,
      builder: (context, snap) {
        final liste = snap.data ?? const <Eintrag>[];
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (!widget.admin) ...[
              Text('Was wünschst du dir für Austro Angler?',
                  style: text.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _text,
                maxLines: 4,
                maxLength: 1000,
                decoration: const InputDecoration(
                  hintText: 'Z. B. ein neues Gewässer, eine Funktion oder '
                      'einen Fehler, der dir aufgefallen ist',
                  border: OutlineInputBorder(),
                ),
              ),
              FilledButton.icon(
                onPressed: _sendet ? null : _senden,
                icon: const Icon(Icons.send),
                label: const Text('Wunsch senden'),
              ),
              const SizedBox(height: 24),
              Text('Meine Wünsche', style: text.titleMedium),
            ],
            if (snap.hasError)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Laden fehlgeschlagen.'),
              )
            else if (!snap.hasData)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (liste.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Noch keine Wünsche.'),
              ),
            for (final w in liste)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_status[w.status]?.$1 ?? '🆕'),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              [
                                _status[w.status]?.$2 ?? w.status,
                                if (widget.admin) at(w.nutzerName),
                                datumText(w.erstellt),
                              ].join(' · '),
                              style: text.labelMedium,
                            ),
                          ),
                          if (widget.admin)
                            PopupMenuButton<String>(
                              onSelected: (wahl) async {
                                if (wahl == 'antworten') return _antworten(w);
                                if (wahl == 'loeschen') {
                                  return fangDienst.wunschLoeschen(w.id);
                                }
                                await fangDienst.wunschBeantworten(w.id,
                                    status: wahl);
                              },
                              itemBuilder: (_) => [
                                for (final e in _status.entries)
                                  PopupMenuItem(
                                    value: e.key,
                                    child: Text('${e.value.$1} ${e.value.$2}'),
                                  ),
                                const PopupMenuDivider(),
                                const PopupMenuItem(
                                    value: 'antworten',
                                    child: Text('💬 Antworten')),
                                const PopupMenuItem(
                                    value: 'loeschen',
                                    child: Text('🗑️ Löschen')),
                              ],
                            )
                          else if (w.status == 'neu')
                            IconButton(
                              tooltip: 'Zurückziehen',
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () => fangDienst.wunschLoeschen(w.id),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(w.text),
                      if (w.antwort != null && w.antwort!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('💬 Antwort: ${w.antwort}',
                            style: const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MeldungenListe extends StatefulWidget {
  const _MeldungenListe();

  @override
  State<_MeldungenListe> createState() => _MeldungenListeState();
}

class _MeldungenListeState extends State<_MeldungenListe>
    with AutomaticKeepAliveClientMixin {
  final _stream = fangDienst.meldungen();

  @override
  bool get wantKeepAlive => true;

  static const _typen = {
    'fang': '🎣 Fang gemeldet',
    'gewaesser-korrektur': '📝 Gewässer-Korrektur',
    'neues-gewaesser': '📍 Neues Gewässer',
    'nutzer': '👤 Nutzer gemeldet',
    'kommentar': '💬 Kommentar gemeldet',
    'neues-geschaeft': '🏪 Neues Geschäft',
  };

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final text = Theme.of(context).textTheme;
    return StreamBuilder<List<Eintrag>>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(child: Text('Laden fehlgeschlagen.'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final liste = snap.data!;
        if (liste.isEmpty) {
          return const Center(child: Text('Keine Meldungen. 👍'));
        }
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (final m in liste)
              Card(
                child: ListTile(
                  title: Text(_typen[m.typ] ?? m.typ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.text),
                      const SizedBox(height: 4),
                      Text('Bezug: ${m.bezug} · ${datumText(m.erstellt)}',
                          style: text.bodySmall),
                    ],
                  ),
                  trailing: IconButton(
                    tooltip: 'Erledigt',
                    icon: const Icon(Icons.check),
                    onPressed: () => fangDienst.meldungLoeschen(m.id),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Admin: vorgeschlagene Preise freigeben oder ablehnen.
class _PreisPruefung extends StatefulWidget {
  const _PreisPruefung();

  @override
  State<_PreisPruefung> createState() => _PreisPruefungState();
}

class _PreisPruefungState extends State<_PreisPruefung>
    with AutomaticKeepAliveClientMixin {
  final _stream = fangDienst.preisVorschlaege();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final text = Theme.of(context).textTheme;
    return StreamBuilder<List<PreisVorschlag>>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(child: Text('Laden fehlgeschlagen.'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final liste = snap.data!;
        if (liste.isEmpty) {
          return const Center(child: Text('Keine Preise zu prüfen. 👍'));
        }
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (final v in liste)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.gewaesserName, style: text.titleMedium),
                      Text('${v.art}: € ${v.euro.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: text.titleLarge),
                      Text('von ${at(v.nutzerName)}', style: text.bodySmall),
                      if (v.notiz.isNotEmpty) Text('Quelle: ${v.notiz}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          FilledButton.icon(
                            onPressed: () async {
                              await fangDienst.preisFreigeben(v);
                              if (context.mounted) {
                                meldung(context, 'Freigegeben ✓');
                              }
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Freigeben'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => fangDienst.preisAblehnen(v),
                            icon: const Icon(Icons.close),
                            label: const Text('Ablehnen'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Admin: von Anglern ergänzte Gewässer-Infos prüfen.
class _InfoPruefung extends StatefulWidget {
  const _InfoPruefung();

  @override
  State<_InfoPruefung> createState() => _InfoPruefungState();
}

class _InfoPruefungState extends State<_InfoPruefung>
    with AutomaticKeepAliveClientMixin {
  final _stream = fangDienst.infoVorschlaege();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final text = Theme.of(context).textTheme;
    return StreamBuilder<List<InfoVorschlag>>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(child: Text('Laden fehlgeschlagen.'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final liste = snap.data!;
        if (liste.isEmpty) {
          return const Center(child: Text('Keine Gewässer-Infos zu prüfen. 👍'));
        }
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (final v in liste)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.gewaesserName, style: text.titleMedium),
                      Text('von ${at(v.nutzerName)}', style: text.bodySmall),
                      if (v.fische.isNotEmpty)
                        Text('🐟 ${v.fische.map((id) => fischById(id)?.name ?? id).join(', ')}'),
                      if (v.verkauf.isNotEmpty) Text('🎫 ${v.verkauf}'),
                      if (v.url.isNotEmpty) Text('🔗 ${v.url}'),
                      if (v.text.isNotEmpty) Text(v.text),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          FilledButton.icon(
                            onPressed: () async {
                              await fangDienst.infoFreigeben(v);
                              if (context.mounted) {
                                meldung(context, 'Freigegeben ✓');
                              }
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Freigeben'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => fangDienst.infoAblehnen(v),
                            icon: const Icon(Icons.close),
                            label: const Text('Ablehnen'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Admin: Funktionen aus der Ferne abschalten und Hinweis-Banner setzen.
/// Wirkt sofort bei allen Nutzern – ohne App-Update.
class _Steuerung extends StatefulWidget {
  const _Steuerung();

  @override
  State<_Steuerung> createState() => _SteuerungState();
}

class _SteuerungState extends State<_Steuerung> {
  late final _text =
      TextEditingController(text: fernKonfig.daten.banner?.text ?? '');
  late bool _warnung = fernKonfig.daten.banner?.warnung ?? false;
  bool _sendet = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _ausfuehren(Future<void> Function() aktion, String ok) async {
    setState(() => _sendet = true);
    try {
      await aktion();
      if (mounted) meldung(context, ok);
    } catch (e) {
      if (mounted) meldung(context, 'Fehlgeschlagen: $e');
    } finally {
      if (mounted) setState(() => _sendet = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: fernKonfig,
      builder: (context, _) {
        final d = fernKonfig.daten;
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const HinweisKarte(
              'Änderungen hier gelten sofort für alle Nutzer – ohne '
              'App-Update.',
              icon: Icons.bolt,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Titel('📢 Hinweis-Banner'),
                    Text(
                        d.banner == null
                            ? 'Gerade kein Banner aktiv.'
                            : 'Aktiv: „${d.banner!.text}“',
                        style: text.bodySmall),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _text,
                      maxLength: 140,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'z. B. Wetter gerade gestört – wird repariert.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _warnung,
                      onChanged: (v) => setState(() => _warnung = v),
                      title: const Text('Als Warnung (rot)'),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilledButton(
                          onPressed: _sendet
                              ? null
                              : () => _ausfuehren(
                                  () => fernKonfig.bannerSetzen(_text.text,
                                      warnung: _warnung),
                                  'Banner gespeichert'),
                          child: const Text('Banner zeigen'),
                        ),
                        OutlinedButton(
                          onPressed: _sendet || d.banner == null
                              ? null
                              : () {
                                  _text.clear();
                                  _ausfuehren(
                                      () => fernKonfig.bannerSetzen('',
                                          warnung: false),
                                      'Banner entfernt');
                                },
                          child: const Text('Entfernen'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Titel('🔌 Funktionen'),
                    Text('Ausgeschaltete Funktionen zeigen „vorübergehend nicht '
                        'verfügbar“.', style: text.bodySmall),
                    for (final f in fernFunktionen.entries)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: !d.aus.contains(f.key),
                        onChanged: _sendet
                            ? null
                            : (an) => _ausfuehren(
                                () => fernKonfig.funktionSetzen(f.key, an: an),
                                '${f.value} ${an ? 'an' : 'aus'}'),
                        title: Text(f.value),
                      ),
                  ],
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.dataset_outlined),
                title: const Text('Daten-Korrekturen'),
                subtitle: Text('${d.gewaesser.length} Gewässer · '
                    '${d.schonzeiten.length} Fischarten mit Schonzeit-Korrektur'),
              ),
            ),
          ],
        );
      },
    );
  }
}
