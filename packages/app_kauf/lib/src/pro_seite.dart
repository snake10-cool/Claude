import 'package:flutter/material.dart';

import 'kauf_dienst.dart';
import 'l10n/kauf_localizations.dart';

/// Ein Vorteil von Pro, z. B. „Unbegrenzt viele Produkte“.
class ProVorteil {
  const ProVorteil(this.symbol, this.text);
  final IconData symbol;
  final String text;
}

/// Fertiger Bildschirm „Pro holen“: Vorteile, Preise aus Google Play,
/// Kaufen und Wiederherstellen.
class ProSeite extends StatelessWidget {
  const ProSeite({
    super.key,
    required this.dienst,
    required this.titel,
    required this.vorteile,
  });

  final KaufDienst dienst;
  final String titel;
  final List<ProVorteil> vorteile;

  @override
  Widget build(BuildContext context) {
    final l = KaufLocalizations.of(context);
    final farben = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(titel)),
      body: ListenableBuilder(
        listenable: dienst,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Icon(Icons.workspace_premium, size: 64, color: farben.primary),
            const SizedBox(height: 12),
            Text(
              dienst.gekauft ? l.proAktiv : l.proHolen,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    for (final v in vorteile)
                      ListTile(
                        leading: Icon(v.symbol, color: farben.primary),
                        title: Text(v.text),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (!dienst.kaufPflicht && !dienst.gekauft)
              _Hinweis(text: l.allesFreiTestphase)
            else if (!KaufDienst.plattformMitKauf)
              _Hinweis(text: l.nurImPlayStore)
            else if (!dienst.gekauft) ...[
              if (dienst.produkte.isEmpty)
                _Hinweis(
                  text: dienst.verfuegbar ? l.keineProdukte : l.storeFehlt,
                ),
              for (final p in dienst.produkte.where(
                (p) => dienst.proIds.contains(p.id),
              ))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FilledButton(
                    onPressed: dienst.laedt ? null : () => dienst.kaufen(p),
                    child: Text('${p.title.split(' (').first} · ${p.price}'),
                  ),
                ),
              Text(
                l.aboKuendbar,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (dienst.fehler != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  dienst.fehler!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: farben.error),
                ),
              ),
            const SizedBox(height: 8),
            if (KaufDienst.plattformMitKauf)
              TextButton(
                onPressed: dienst.wiederherstellen,
                child: Text(l.wiederherstellen),
              ),
          ],
        ),
      ),
    );
  }
}

class _Hinweis extends StatelessWidget {
  const _Hinweis({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.secondaryContainer,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}
