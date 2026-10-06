import 'package:app_basis/app_basis.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../daten/datenbank.dart';
import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/geld.dart';
import '../widgets/format.dart';
import 'ausgabe_screen.dart';

class GruppeScreen extends StatelessWidget {
  const GruppeScreen({super.key, required this.gruppeId});
  final String gruppeId;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return StreamBuilder<Gruppe?>(
      stream: db.gruppeBeobachten(gruppeId),
      builder: (context, gs) {
        final g = gs.data;
        if (g == null || g.geloescht) return Scaffold(appBar: AppBar());
        return StreamBuilder<List<Person>>(
          stream: db.personenBeobachten(gruppeId),
          builder: (context, ps) {
            final personen = ps.data ?? const <Person>[];
            return DefaultTabController(
              length: 3,
              child: Scaffold(
                appBar: AppBar(
                  title: Text(g.name),
                  actions: [
                    PopupMenuButton<String>(
                      onSelected: (w) => _menue(context, w, g),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'umbenennen',
                          child: Text(l.umbenennen),
                        ),
                        PopupMenuItem(
                          value: 'loeschen',
                          child: Text(l.gruppeLoeschen),
                        ),
                      ],
                    ),
                  ],
                  bottom: TabBar(
                    tabs: [
                      Tab(text: l.ausgaben),
                      Tab(text: l.wersSchuldet),
                      Tab(text: l.mitglieder),
                    ],
                  ),
                ),
                floatingActionButton: personen.isEmpty
                    ? null
                    : FloatingActionButton.extended(
                        heroTag: null,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                AusgabeScreen(gruppe: g, personen: personen),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: Text(l.ausgabe),
                      ),
                body: TabBarView(
                  children: [
                    _Ausgaben(g, personen),
                    _Salden(g, personen),
                    _Mitglieder(g, personen),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _menue(BuildContext context, String w, Gruppe g) async {
    final l = context.l;
    if (w == 'umbenennen') {
      final c = TextEditingController(text: g.name);
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
        await db.gruppeSpeichern(g.copyWith(name: c.text.trim()));
      }
    } else if (w == 'loeschen') {
      if (await bestaetigen(
        context,
        titel: l.gruppeLoeschen,
        text: g.online ? l.gruppeLoeschenOnline : l.gruppeLoeschenText,
      )) {
        await db.gruppeLoeschen(g.id);
        if (context.mounted) Navigator.pop(context);
      }
    }
  }
}

class _Ausgaben extends StatelessWidget {
  const _Ausgaben(this.g, this.personen);
  final Gruppe g;
  final List<Person> personen;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final namen = {for (final p in personen) p.id: p};
    return StreamBuilder<List<Ausgabe>>(
      stream: db.ausgabenBeobachten(g.id),
      builder: (context, snap) {
        final liste = snap.data ?? const <Ausgabe>[];
        if (snap.hasData && liste.isEmpty) {
          return LeerHinweis(
            symbol: Icons.receipt_long_outlined,
            titel: l.keineAusgaben,
            text: l.keineAusgabenText,
          );
        }
        final summe = liste
            .where((a) => a.art == 'ausgabe')
            .fold(0, (s, a) => s + a.betragCent);
        return ListView(
          padding: const EdgeInsets.only(bottom: 88),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l.gesamtAusgaben(euro(summe)),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final a in liste)
              ListTile(
                leading: a.art == 'zahlung'
                    ? const CircleAvatar(child: Icon(Icons.swap_horiz))
                    : PersonKreis(
                        name: namen[a.zahlerId]?.name ?? '?',
                        farbe: namen[a.zahlerId]?.farbe ?? 0xFF9E9E9E,
                      ),
                title: Text(a.titel),
                subtitle: Text(
                  '${datumKurz(a.datum)} · ${l.bezahltVon(namen[a.zahlerId]?.name ?? '?')}',
                ),
                trailing: Text(
                  euro(a.betragCent),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AusgabeScreen(
                      gruppe: g,
                      personen: personen,
                      ausgabe: a,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Salden extends StatelessWidget {
  const _Salden(this.g, this.personen);
  final Gruppe g;
  final List<Person> personen;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    final namen = {for (final p in personen) p.id: p};
    return StreamBuilder<Map<String, int>>(
      stream: db.saldenBeobachten(g.id),
      builder: (context, snap) {
        final s = snap.data ?? const <String, int>{};
        final vorschlaege = ausgleichen(s);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final p in personen)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: PersonKreis(name: p.name, farbe: p.farbe),
                title: Text(
                  p.id == g.ichPersonId ? '${p.name} (${l.ich})' : p.name,
                ),
                trailing: Text(
                  euro(s[p.id] ?? 0),
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: (s[p.id] ?? 0) > 0
                        ? Colors.green.shade700
                        : (s[p.id] ?? 0) < 0
                        ? t.colorScheme.error
                        : null,
                  ),
                ),
              ),
            const Divider(height: 32),
            Text(l.soGleichtIhrAus, style: t.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (vorschlaege.isEmpty)
              Text(l.allesAusgeglichen)
            else
              for (final u in vorschlaege)
                Card(
                  child: ListTile(
                    title: Text(
                      l.zahltAn(
                        namen[u.von]?.name ?? '?',
                        namen[u.an]?.name ?? '?',
                      ),
                    ),
                    subtitle: Text(
                      euro(u.betragCent),
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        if (await bestaetigen(
                          context,
                          titel: l.alsBezahltMarkieren,
                          text: l.alsBezahltText(
                            namen[u.von]?.name ?? '?',
                            euro(u.betragCent),
                            namen[u.an]?.name ?? '?',
                          ),
                          ja: l.bezahlt,
                        )) {
                          await db.ausgabeAnlegen(
                            gruppeId: g.id,
                            titel: l.rueckzahlung,
                            betragCent: u.betragCent,
                            zahlerId: u.von,
                            anteile: {u.an: 1},
                            art: 'zahlung',
                          );
                        }
                      },
                      child: Text(l.bezahlt),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _Mitglieder extends StatelessWidget {
  const _Mitglieder(this.g, this.personen);
  final Gruppe g;
  final List<Person> personen;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        Padding(padding: const EdgeInsets.all(16), child: _Einladen(g)),
        Abschnitt(
          l.mitglieder,
          trailing: TextButton.icon(
            onPressed: () async {
              final c = TextEditingController();
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l.personHinzufuegen),
                  content: TextField(
                    controller: c,
                    autofocus: true,
                    decoration: InputDecoration(labelText: l.name),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l.abbrechen),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l.hinzufuegen),
                    ),
                  ],
                ),
              );
              if (ok == true && c.text.trim().isNotEmpty) {
                await db.personHinzufuegen(g.id, c.text.trim());
              }
            },
            icon: const Icon(Icons.person_add_alt),
            label: Text(l.person),
          ),
        ),
        for (final p in personen)
          ListTile(
            leading: PersonKreis(name: p.name, farbe: p.farbe),
            title: Text(p.name),
            subtitle: p.id == g.ichPersonId ? Text(l.dasBistDu) : null,
            trailing: p.id == g.ichPersonId
                ? Icon(Icons.check_circle, color: t.colorScheme.primary)
                : TextButton(
                    onPressed: () => db.ichSetzen(g.id, p.id),
                    child: Text(l.dasBinIch),
                  ),
          ),
      ],
    );
  }
}

/// Einladen: Code, QR-Code und Teilen – oder die Gruppe erst online stellen.
class _Einladen extends StatefulWidget {
  const _Einladen(this.g);
  final Gruppe g;

  @override
  State<_Einladen> createState() => _EinladenState();
}

class _EinladenState extends State<_Einladen> {
  bool _laedt = false;

  Future<void> _online() async {
    final s = sync;
    if (s == null) return;
    setState(() => _laedt = true);
    try {
      await s.onlineStellen(widget.g.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l.keinInternet)));
      }
    } finally {
      if (mounted) setState(() => _laedt = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    final g = widget.g;
    if (!g.online || g.code == null) {
      return Card(
        color: t.colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.gemeinsamNutzen, style: t.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                sync == null
                    ? l.onlineNichtEingerichtet
                    : l.gemeinsamNutzenText,
              ),
              if (sync != null) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _laedt ? null : _online,
                  icon: _laedt
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(l.onlineTeilen),
                ),
              ],
            ],
          ),
        ),
      );
    }
    final code = g.code!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(l.einladungscode, style: t.textTheme.titleMedium),
            const SizedBox(height: 8),
            SelectableText(
              code,
              style: t.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: QrImageView(data: 'teilbar:$code', size: 160),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => SharePlus.instance.share(
                ShareParams(text: l.einladungText(g.name, code)),
              ),
              icon: const Icon(Icons.share),
              label: Text(l.einladen),
            ),
          ],
        ),
      ),
    );
  }
}
