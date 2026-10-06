import 'package:app_basis/app_basis.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../dienste.dart';
import '../l10n/l.dart';
import '../widgets/pro.dart';
import '../widgets/sprach_abzeichen.dart';
import 'karten_screen.dart';
import 'lern_screen.dart';
import 'stapel_screen.dart';

class StapelDetailScreen extends StatelessWidget {
  const StapelDetailScreen({super.key, required this.stapelId});
  final int stapelId;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([lernen, kauf]),
      builder: (context, _) => StreamBuilder<List<StapelInfo>>(
        stream: db.stapelBeobachten(),
        builder: (context, snap) {
          final info = snap.data
              ?.where((s) => s.stapel.id == stapelId)
              .firstOrNull;
          if (info == null) {
            return Scaffold(
              appBar: AppBar(),
              body: snap.hasData
                  ? const SizedBox.shrink()
                  : const Center(child: CircularProgressIndicator()),
            );
          }
          final s = info.stapel;
          final offen = lernen.offen(s.produkt);
          final frei = s.produkt == null ? null : lernen.freiBis(s.produkt!);
          final perVideo =
              offen &&
              s.produkt != null &&
              !kauf.hat(s.produkt!) &&
              frei != null;
          return Scaffold(
            appBar: AppBar(
              title: Text(s.name),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (w) => _menue(context, w, info),
                  itemBuilder: (_) => [
                    if (s.eigen)
                      PopupMenuItem(
                        value: 'umbenennen',
                        child: Text(l.stapelBearbeiten),
                      ),
                    PopupMenuItem(
                      value: 'zuruecksetzen',
                      child: Text(l.fortschrittZuruecksetzen),
                    ),
                    if (s.eigen)
                      PopupMenuItem(
                        value: 'loeschen',
                        child: Text(l.stapelLoeschen),
                      ),
                  ],
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SprachAbzeichen(s.sprache, gross: true),
                    if (s.stufe.isNotEmpty) Chip(label: Text(s.stufe)),
                  ],
                ),
                if (s.beschreibung.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(s.beschreibung, style: t.textTheme.bodyLarge),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    _Zahl(l.karten, info.anzahl),
                    _Zahl(l.neuMehrzahl, info.neu),
                    _Zahl(l.faellig, info.faellig),
                    _Zahl(l.gefestigt, info.gefestigt),
                  ],
                ),
                const SizedBox(height: 20),
                if (offen) ...[
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: info.anzahl == 0
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => LernScreen(stapelIds: [s.id]),
                            ),
                          ),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(l.stapelLernen),
                  ),
                  if (perVideo)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l.freiBis(uhrzeitText(frei)),
                        textAlign: TextAlign.center,
                        style: t.textTheme.bodySmall,
                      ),
                    ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.inHeuteLernen),
                    subtitle: Text(l.inHeuteLernenText),
                    value: s.aktiv,
                    onChanged: (v) => db.stapelAktivSetzen(s.id, v),
                  ),
                ] else
                  _Freischalten(produkt: s.produkt!),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          KartenScreen(stapel: s, nurVorschau: !offen),
                    ),
                  ),
                  icon: const Icon(Icons.view_agenda_outlined),
                  label: Text(offen ? l.kartenAnsehen : l.vorschau),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _menue(
    BuildContext context,
    String wahl,
    StapelInfo info,
  ) async {
    final l = context.l;
    final s = info.stapel;
    switch (wahl) {
      case 'umbenennen':
        final e = await stapelDialog(context, name: s.name, sprache: s.sprache);
        if (e != null) {
          await db.stapelSpeichern(
            s
                .toCompanion(true)
                .copyWith(name: Value(e.$1), sprache: Value(e.$2)),
          );
        }
      case 'zuruecksetzen':
        if (await bestaetigen(
          context,
          titel: l.fortschrittZuruecksetzen,
          text: l.fortschrittZuruecksetzenText,
          ja: l.zuruecksetzen,
        )) {
          await db.stapelZuruecksetzen(s.id);
        }
      case 'loeschen':
        if (await bestaetigen(
          context,
          titel: l.stapelLoeschen,
          text: l.stapelLoeschenText,
        )) {
          await db.stapelLoeschen(s.id);
          if (context.mounted) Navigator.pop(context);
        }
    }
  }
}

String uhrzeitText(DateTime t) =>
    '${t.day}.${t.month}. ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

class _Zahl extends StatelessWidget {
  const _Zahl(this.titel, this.wert);
  final String titel;
  final int wert;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            '$wert',
            style: t.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(titel, style: t.textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Gesperrter Stapel: kaufen, per Video 24 h freischalten oder Abo.
class _Freischalten extends StatelessWidget {
  const _Freischalten({required this.produkt});
  final String produkt;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    final details = kauf.produkt(produkt);
    return Card(
      color: t.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_outline),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l.stapelGesperrt, style: t.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: details == null || kauf.laedt
                  ? null
                  : () => kauf.kaufen(details),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text(
                details == null
                    ? l.kaufenNichtVerfuegbar
                    : l.paketKaufen(details.price),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => videoFreischalten(context, produkt),
              icon: const Icon(Icons.ondemand_video),
              label: Text(l.videoFreischalten),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => proSeiteOeffnen(context),
              child: Text(l.allesAbo),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> videoFreischalten(BuildContext context, String produkt) async {
  final l = context.l;
  final messenger = ScaffoldMessenger.of(context);
  final belohnt = await werbung.belohnungZeigen();
  if (belohnt) {
    await lernen.perVideoFreischalten(produkt);
    messenger.showSnackBar(SnackBar(content: Text(l.freigeschaltet24)));
  } else {
    messenger.showSnackBar(SnackBar(content: Text(l.videoNichtVerfuegbar)));
  }
}
