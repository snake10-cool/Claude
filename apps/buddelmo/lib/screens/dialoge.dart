import 'package:app_basis/app_basis.dart';
import 'package:flutter/material.dart';

import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/zahlen.dart';

/// „Willkommen zurück“ mit Offline-Ertrag und Video zum Verdoppeln.
Future<void> offlineDialog(
  BuildContext context,
  double gold,
  Duration zeit,
) async {
  final l = context.l;
  final verdoppeln = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Text('⛏️', style: TextStyle(fontSize: 48)),
      title: Text(l.willkommenZurueck),
      content: Text(l.offlineText(dauerText(zeit), grosseZahl(gold))),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.einsammeln),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.ondemand_video),
          label: Text(l.verdoppeln),
        ),
      ],
    ),
  );
  if (verdoppeln == true) {
    final ok = await werbung.belohnungZeigen();
    if (ok) {
      spiel.s.bonusGutschreiben(gold);
      spiel.geaendert();
    } else if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l.videoNichtVerfuegbar)));
    }
  }
}

/// Tagesbonus: 7 Tage, Tag 7 mit Glitzerstein.
Future<void> tagesbonusDialog(BuildContext context) async {
  final l = context.l;
  final t = Theme.of(context);
  final jetzt = DateTime.now();
  final s = spiel.s;
  final verfuegbar = s.tagesbonusVerfuegbar(jetzt);
  final heute = verfuegbar ? s.bonusTagNummer(jetzt) : spiel.stand.bonusSerie;
  final abholen = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.tagesbonus),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                for (var tag = 1; tag <= 7; tag++)
                  Container(
                    width: 72,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: tag == heute
                          ? t.colorScheme.primaryContainer
                          : tag < heute
                          ? t.colorScheme.surfaceContainerHighest
                          : t.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: tag == heute
                          ? Border.all(color: t.colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(l.tagNummer(tag), style: t.textTheme.labelSmall),
                        Text(
                          tag < heute || (tag == heute && !verfuegbar)
                              ? '✅'
                              : tag == 7
                              ? '✨'
                              : '🪙',
                          style: const TextStyle(fontSize: 22),
                        ),
                        Text(
                          grosseZahl(s.bonusGold(tag, jetzt)),
                          style: t.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              verfuegbar ? l.tagesbonusText : l.tagesbonusMorgen,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        if (verfuegbar)
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.abholen),
          )
        else
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.ok),
          ),
      ],
    ),
  );
  if (abholen == true) {
    final ergebnis = s.tagesbonusAbholen(DateTime.now());
    spiel.geaendert();
    if (ergebnis != null && context.mounted) {
      final (g, glitzer) = ergebnis;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            glitzer > 0
                ? l.bonusMitGlitzer(grosseZahl(g))
                : l.bonusErhalten(grosseZahl(g)),
          ),
        ),
      );
    }
  }
}

/// Video ansehen → 10 Minuten doppelte Produktion.
Future<void> boostDialog(BuildContext context) async {
  final l = context.l;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Text('⚡', style: TextStyle(fontSize: 48)),
      title: Text(l.boostTitel),
      content: Text(l.boostText),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.spaeter),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.ondemand_video),
          label: Text(l.videoAnsehen),
        ),
      ],
    ),
  );
  if (ok != true) return;
  final belohnt = await werbung.belohnungZeigen();
  if (belohnt) {
    spiel.boostStarten();
  } else if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l.videoNichtVerfuegbar)));
  }
}

Future<void> prestigeDialog(BuildContext context, int neu) async {
  final l = context.l;
  if (await bestaetigen(
    context,
    titel: l.neuerHuegel,
    text: l.prestigeWarnung(neu, neu * 10),
    ja: l.losGehts,
  )) {
    spiel.s.prestigeMachen();
    spiel.geaendert();
  }
}
