import 'package:app_basis/app_basis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../daten/datenbank.dart';
import '../l10n/l.dart';
import '../logik/artikel_text.dart';
import '../widgets/format.dart';

/// Eine Liste: Artikel hinzufügen, abhaken (in Gruppen mit Betrag).
class ListeScreen extends StatefulWidget {
  const ListeScreen({super.key, required this.listeId});
  final String listeId;

  @override
  State<ListeScreen> createState() => _ListeScreenState();
}

class _ListeScreenState extends State<ListeScreen> {
  final _eingabe = TextEditingController();
  final _fokus = FocusNode();

  @override
  void dispose() {
    _eingabe.dispose();
    _fokus.dispose();
    super.dispose();
  }

  Future<void> _hinzufuegen(Liste liste) async {
    final text = _eingabe.text.trim();
    if (text.isEmpty) return;
    final (menge, name) = artikelLesen(text);
    await db.artikelHinzufuegen(liste, name: name, menge: menge);
    _eingabe.clear();
    _fokus.requestFocus();
  }

  Future<void> _umschalten(Artikel a, Liste liste) async {
    HapticFeedback.selectionClick();
    if (a.erledigt) {
      await db.artikelAbhaken(a, liste, erledigt: false);
      return;
    }
    final gruppe = liste.gruppeId == null
        ? null
        : await db.gruppeLaden(liste.gruppeId!);
    if (gruppe == null || liste.art == 'packliste') {
      await db.artikelAbhaken(a, liste, erledigt: true);
      return;
    }
    // Gruppenliste: optional Betrag → landet in der Abrechnung.
    if (!mounted) return;
    final ich = gruppe.ichPersonId ?? await _werBinIch(gruppe);
    if (ich == null || !mounted) return;
    final betrag = await _betragFragen(a);
    if (betrag == null) return; // abgebrochen
    await db.artikelAbhaken(
      a,
      liste,
      erledigt: true,
      vonPersonId: ich,
      betragCent: betrag == 0 ? null : betrag,
    );
  }

  Future<String?> _werBinIch(Gruppe g) async {
    final personen = await db.personenLaden(g.id);
    if (!mounted) return null;
    final p = await showDialog<Person>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l.werBistDu),
        children: [
          for (final p in personen)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, p),
              child: Text(p.name),
            ),
        ],
      ),
    );
    if (p != null) await db.ichSetzen(g.id, p.id);
    return p?.id;
  }

  /// `null` = abgebrochen, 0 = ohne Betrag.
  Future<int?> _betragFragen(Artikel a) async {
    final l = context.l;
    final c = TextEditingController();
    final form = GlobalKey<FormState>();
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.gekauft(a.name),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(l.betragHilfe),
              const SizedBox(height: 12),
              EuroFeld(controller: c, label: l.betragOptional, autofocus: true),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, 0),
                      child: Text(l.ohneBetrag),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (c.text.trim().isEmpty) {
                          Navigator.pop(context, 0);
                        } else if (form.currentState!.validate()) {
                          Navigator.pop(context, parseEuro(c.text));
                        }
                      },
                      child: Text(l.abhaken),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _bearbeiten(Artikel a) async {
    final l = context.l;
    final name = TextEditingController(text: a.name);
    final menge = TextEditingController(text: a.menge);
    final aktion = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.artikelBearbeiten),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: l.name),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: menge,
              decoration: InputDecoration(labelText: l.menge),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'loeschen'),
            child: Text(l.loeschen),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'ok'),
            child: Text(l.speichern),
          ),
        ],
      ),
    );
    if (aktion == 'ok' && name.text.trim().isNotEmpty) {
      await db.artikelSpeichern(
        a.copyWith(name: name.text.trim(), menge: menge.text.trim()),
      );
    } else if (aktion == 'loeschen') {
      await db.artikelLoeschen(a);
    }
  }

  Future<void> _menue(String wahl, Liste liste, List<Artikel> artikel) async {
    final l = context.l;
    switch (wahl) {
      case 'erledigte':
        await db.erledigteEntfernen(liste.id);
      case 'zuruecksetzen':
        await db.alleZuruecksetzen(liste.id);
      case 'vorlage':
        await db.alsVorlageSpeichern(liste);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l.vorlageGespeichert)));
        }
      case 'teilen':
        final text = [
          liste.name,
          for (final a in artikel.where((a) => !a.erledigt))
            '• ${[a.menge, a.name].where((s) => s.isNotEmpty).join(' ')}',
        ].join('\n');
        await SharePlus.instance.share(ShareParams(text: text));
      case 'umbenennen':
        final c = TextEditingController(text: liste.name);
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l.umbenennen),
            content: TextField(controller: c, autofocus: true),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.abbrechen),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.speichern),
              ),
            ],
          ),
        );
        if (ok == true && c.text.trim().isNotEmpty) {
          await db.listeSpeichern(liste.copyWith(name: c.text.trim()));
        }
      case 'loeschen':
        if (await bestaetigen(
          context,
          titel: l.listeLoeschen,
          text: liste.name,
        )) {
          await db.listeLoeschen(liste.id);
          if (mounted) Navigator.pop(context);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    return StreamBuilder<Liste?>(
      stream: db.listeBeobachten(widget.listeId),
      builder: (context, ls) {
        final liste = ls.data;
        if (liste == null || liste.geloescht) {
          return Scaffold(appBar: AppBar());
        }
        final pack = liste.art == 'packliste';
        return StreamBuilder<List<Artikel>>(
          stream: db.artikelBeobachten(liste.id),
          builder: (context, as) {
            final artikel = as.data ?? const <Artikel>[];
            final offen = artikel.where((a) => !a.erledigt).toList();
            final erledigt = artikel.where((a) => a.erledigt).toList();
            return Scaffold(
              appBar: AppBar(
                title: Text('${liste.symbol} ${liste.name}'),
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (w) => _menue(w, liste, artikel),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'teilen',
                        child: Text(l.alsTextTeilen),
                      ),
                      if (pack)
                        PopupMenuItem(
                          value: 'zuruecksetzen',
                          child: Text(l.alleZuruecksetzen),
                        )
                      else
                        PopupMenuItem(
                          value: 'erledigte',
                          child: Text(l.erledigteEntfernen),
                        ),
                      if (pack)
                        PopupMenuItem(
                          value: 'vorlage',
                          child: Text(l.alsVorlageSpeichern),
                        ),
                      PopupMenuItem(
                        value: 'umbenennen',
                        child: Text(l.umbenennen),
                      ),
                      PopupMenuItem(
                        value: 'loeschen',
                        child: Text(l.listeLoeschen),
                      ),
                    ],
                  ),
                ],
                bottom: pack && artikel.isNotEmpty
                    ? PreferredSize(
                        preferredSize: const Size.fromHeight(4),
                        child: LinearProgressIndicator(
                          value: erledigt.length / artikel.length,
                        ),
                      )
                    : null,
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: TextField(
                      controller: _eingabe,
                      focusNode: _fokus,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _hinzufuegen(liste),
                      decoration: InputDecoration(
                        hintText: l.artikelHinzufuegenHinweis,
                        prefixIcon: const Icon(Icons.add),
                        suffixIcon: IconButton(
                          tooltip: l.hinzufuegen,
                          icon: const Icon(Icons.keyboard_return),
                          onPressed: () => _hinzufuegen(liste),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: artikel.isEmpty
                        ? LeerHinweis(
                            symbol: pack
                                ? Icons.luggage
                                : Icons.shopping_basket_outlined,
                            titel: l.listeLeer,
                            text: l.listeLeerText,
                          )
                        : ListView(
                            padding: const EdgeInsets.only(bottom: 24),
                            children: [
                              ..._zeilen(offen, liste, pack),
                              if (erledigt.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    16,
                                    16,
                                    4,
                                  ),
                                  child: Text(
                                    l.erledigtAnzahl(erledigt.length),
                                    style: t.textTheme.labelLarge?.copyWith(
                                      color: t.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                for (final a in erledigt) _zeile(a, liste),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _zeilen(List<Artikel> offen, Liste liste, bool pack) {
    if (!pack) return [for (final a in offen) _zeile(a, liste)];
    final nachKategorie = <String, List<Artikel>>{};
    for (final a in offen) {
      nachKategorie.putIfAbsent(a.kategorie, () => []).add(a);
    }
    return [
      for (final e in nachKategorie.entries) ...[
        if (e.key.isNotEmpty) Abschnitt(e.key),
        for (final a in e.value) _zeile(a, liste),
      ],
    ];
  }

  Widget _zeile(Artikel a, Liste liste) {
    final t = Theme.of(context);
    return ListTile(
      key: ValueKey(a.id),
      leading: Checkbox(
        value: a.erledigt,
        onChanged: (_) => _umschalten(a, liste),
      ),
      title: Text(
        a.name,
        style: a.erledigt
            ? TextStyle(
                decoration: TextDecoration.lineThrough,
                color: t.colorScheme.onSurfaceVariant,
              )
            : null,
      ),
      subtitle: a.menge.isEmpty ? null : Text(a.menge),
      trailing: a.ausgabeId != null
          ? Icon(Icons.receipt_long, size: 18, color: t.colorScheme.primary)
          : null,
      onTap: () => _umschalten(a, liste),
      onLongPress: () => _bearbeiten(a),
    );
  }
}
