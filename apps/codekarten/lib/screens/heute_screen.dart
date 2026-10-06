import 'package:app_werbung/app_werbung.dart';
import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/srs.dart';
import '../logik/streak.dart';
import '../widgets/sprach_abzeichen.dart';
import 'lern_screen.dart';
import 'stapel_detail_screen.dart';

/// Startseite: Tagesziel, Streak, „Jetzt lernen“ und aktive Stapel.
class HeuteScreen extends StatelessWidget {
  const HeuteScreen({super.key, required this.zuStapeln});
  final VoidCallback zuStapeln;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.heuteTitel)),
      bottomNavigationBar: WerbeBanner(dienst: werbung),
      body: ListenableBuilder(
        listenable: Listenable.merge([lernen, kauf]),
        builder: (context, _) => StreamBuilder<List<StapelInfo>>(
          stream: db.stapelBeobachten(),
          builder: (context, s) => StreamBuilder<Map<DateTime, Lerntag>>(
            stream: db.lerntageBeobachten(),
            builder: (context, tSnap) {
              if (!s.hasData || !tSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final heute = tagBeginn(DateTime.now());
              final tage = tSnap.data!;
              final heuteTag = tage[heute];
              final gelernt = heuteTag?.karten ?? 0;
              final neuHeute = heuteTag?.neu ?? 0;
              final serie = streak(
                {for (final e in tage.entries) e.key: e.value.karten},
                lernen.tagesziel,
                heute,
              );
              final aktive = s.data!
                  .where(
                    (i) => i.stapel.aktiv && lernen.offen(i.stapel.produkt),
                  )
                  .toList();
              final faellig = aktive.fold<int>(0, (a, i) => a + i.faellig);
              final int neuMoeglich = (lernen.neueProTag - neuHeute).clamp(
                0,
                aktive.fold(0, (a, i) => a + i.neu),
              );
              final zuLernen = faellig + neuMoeglich;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ZielKarte(
                    gelernt: gelernt,
                    ziel: lernen.tagesziel,
                    streak: serie,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(60),
                    ),
                    onPressed: zuLernen == 0
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => LernScreen(
                                stapelIds: [
                                  for (final a in aktive) a.stapel.id,
                                ],
                              ),
                            ),
                          ),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      zuLernen == 0
                          ? l.allesErledigt
                          : l.jetztLernen(faellig, neuMoeglich),
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                  if (zuLernen == 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      l.allesErledigtText,
                      textAlign: TextAlign.center,
                      style: t.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.deineStapel,
                          style: t.textTheme.titleMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: zuStapeln,
                        child: Text(l.alleStapel),
                      ),
                    ],
                  ),
                  for (final i in aktive)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: SprachAbzeichen(i.stapel.sprache),
                        title: Text(i.stapel.name),
                        subtitle: LinearProgressIndicator(
                          value: i.fortschritt,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        trailing: i.faellig > 0
                            ? Badge(
                                label: Text('${i.faellig}'),
                                child: const Icon(Icons.schedule),
                              )
                            : const Icon(Icons.check_circle_outline),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                StapelDetailScreen(stapelId: i.stapel.id),
                          ),
                        ),
                      ),
                    ),
                  if (aktive.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l.keineAktivenStapel,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ZielKarte extends StatelessWidget {
  const _ZielKarte({
    required this.gelernt,
    required this.ziel,
    required this.streak,
  });

  final int gelernt;
  final int ziel;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    final anteil = ziel == 0 ? 1.0 : (gelernt / ziel).clamp(0.0, 1.0);
    return Card(
      color: t.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 88,
              height: 88,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: anteil,
                    strokeWidth: 9,
                    strokeCap: StrokeCap.round,
                    backgroundColor: t.colorScheme.surface.withValues(
                      alpha: 0.6,
                    ),
                  ),
                  Center(
                    child: Text(
                      '$gelernt/$ziel',
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gelernt >= ziel ? l.zielGeschafft : l.tagesziel,
                    style: t.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        streak > 0 ? '🔥' : '🌱',
                        style: const TextStyle(fontSize: 26),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          streak > 0 ? l.streakTage(streak) : l.streakStarten,
                          style: t.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
