import 'package:app_basis/app_basis.dart';
import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/srs.dart';
import '../logik/streak.dart';
import '../widgets/pro.dart';

class MehrScreen extends StatelessWidget {
  const MehrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    void oeffnen(Widget seite) =>
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => seite));
    return Scaffold(
      appBar: AppBar(title: Text(l.tabMehr)),
      body: ListView(
        children: [
          ListenableBuilder(
            listenable: kauf,
            builder: (context, _) => kauf.gekauft
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.workspace_premium, size: 36),
                        title: Text(
                          l.proTitel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(l.proKurz),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => proSeiteOeffnen(context),
                      ),
                    ),
                  ),
          ),
          ListTile(
            leading: const Icon(Icons.insights),
            title: Text(l.statistik),
            onTap: () => oeffnen(const StatistikScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(l.einstellungen),
            onTap: () => oeffnen(const EinstellungenScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.apps),
            title: Text(BasisLocalizations.of(context).mehrApps),
            onTap: () =>
                oeffnen(MehrAppsScreen(aktuellePaketId: appInfo.paketId)),
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: Text(BasisLocalizations.of(context).appBewerten),
            onTap: () => oeffneStoreEintrag(appInfo.paketId),
          ),
        ],
      ),
    );
  }
}

class StatistikScreen extends StatelessWidget {
  const StatistikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.statistik)),
      body: StreamBuilder<Map<DateTime, Lerntag>>(
        stream: db.lerntageBeobachten(),
        builder: (context, snap) => StreamBuilder<List<StapelInfo>>(
          stream: db.stapelBeobachten(),
          builder: (context, s) {
            if (!snap.hasData || !s.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final tage = snap.data!;
            final karten = {
              for (final e in tage.entries) e.key: e.value.karten,
            };
            final heute = tagBeginn(DateTime.now());
            final gesamt = tage.values.fold(0, (a, t) => a + t.karten);
            final richtig = tage.values.fold(0, (a, t) => a + t.richtig);
            final gefestigt = s.data!.fold(0, (a, i) => a + i.gefestigt);
            final gelernt = s.data!.fold(0, (a, i) => a + i.gelernt);
            final letzte30 = [
              for (var i = 29; i >= 0; i--)
                (
                  DateTime(heute.year, heute.month, heute.day - i),
                  karten[DateTime(heute.year, heute.month, heute.day - i)] ?? 0,
                ),
            ];
            final maxWert = letzte30.fold(1, (m, e) => e.$2 > m ? e.$2 : m);
            Widget kachel(String titel, String wert) => Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    children: [
                      Text(
                        wert,
                        style: t.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        titel,
                        style: t.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    kachel(
                      l.aktuelleSerie,
                      '🔥 ${streak(karten, lernen.tagesziel, heute)}',
                    ),
                    const SizedBox(width: 12),
                    kachel(
                      l.laengsteSerie,
                      '${laengsteStreak(karten, lernen.tagesziel)}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    kachel(l.wiederholungen, '$gesamt'),
                    const SizedBox(width: 12),
                    kachel(
                      l.trefferquote,
                      gesamt == 0
                          ? '–'
                          : '${(richtig * 100 / gesamt).round()} %',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    kachel(l.kartenGelernt, '$gelernt'),
                    const SizedBox(width: 12),
                    kachel(l.kartenGefestigt, '$gefestigt'),
                  ],
                ),
                Abschnitt(l.letzte30Tage),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                    child: SizedBox(
                      height: 120,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (final (tag, anzahl) in letzte30)
                            Expanded(
                              child: Tooltip(
                                message: '${tag.day}.${tag.month}.: $anzahl',
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 1,
                                  ),
                                  child: FractionallySizedBox(
                                    heightFactor: (anzahl / maxWert).clamp(
                                      0.02,
                                      1.0,
                                    ),
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: anzahl >= lernen.tagesziel
                                            ? t.colorScheme.primary
                                            : t.colorScheme.primary.withValues(
                                                alpha: 0.35,
                                              ),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(4),
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(l.diagrammHilfe, style: t.textTheme.bodySmall),
              ],
            );
          },
        ),
      ),
    );
  }
}

class EinstellungenScreen extends StatelessWidget {
  const EinstellungenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.einstellungen)),
      body: ListenableBuilder(
        listenable: lernen,
        builder: (context, _) => ListView(
          children: [
            Abschnitt(l.lernen),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(l.tagesziel),
              subtitle: Text(l.kartenProTag(lernen.tagesziel)),
            ),
            Slider(
              value: lernen.tagesziel.toDouble(),
              min: 5,
              max: 100,
              divisions: 19,
              label: '${lernen.tagesziel}',
              onChanged: (v) => lernen.setzen(ziel: v.round()),
            ),
            ListTile(
              leading: const Icon(Icons.fiber_new_outlined),
              title: Text(l.neueProTag),
              subtitle: Text(l.neueProTagText(lernen.neueProTag)),
            ),
            Slider(
              value: lernen.neueProTag.toDouble(),
              min: 0,
              max: 50,
              divisions: 10,
              label: '${lernen.neueProTag}',
              onChanged: (v) => lernen.setzen(neue: v.round()),
            ),
            FutureBuilder<bool>(
              future: werbung.datenschutzOptionenNoetig(),
              builder: (context, snap) => snap.data == true
                  ? ListTile(
                      leading: const Icon(Icons.ads_click),
                      title: Text(l.werbeEinwilligung),
                      onTap: werbung.datenschutzOptionenZeigen,
                    )
                  : const SizedBox.shrink(),
            ),
            Abschnitt(l.app),
            AppInfoKacheln(info: appInfo, designModus: designModus),
          ],
        ),
      ),
    );
  }
}
