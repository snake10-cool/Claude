import 'package:app_basis/app_basis.dart';
import 'package:flutter/material.dart';

import '../dienste.dart';
import '../l10n/l.dart';

/// Shop und Einstellungen.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    Widget produkt(String id, String symbol, String titel, String text) {
      final p = kauf.produkt(id);
      return ListTile(
        leading: Text(symbol, style: const TextStyle(fontSize: 30)),
        title: Text(titel),
        subtitle: Text(text),
        trailing: FilledButton(
          onPressed: p == null || kauf.laedt ? null : () => kauf.kaufen(p),
          child: Text(p?.price ?? '–'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.shop)),
      body: ListenableBuilder(
        listenable: kauf,
        builder: (context, _) => ListView(
          children: [
            if (kauf.produkte.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l.shopNichtVerfuegbar),
                  ),
                ),
              ),
            Abschnitt(l.angebote),
            if (!kauf.besitzt('werbefrei'))
              produkt('werbefrei', '🚫', l.werbefrei, l.werbefreiText),
            produkt('goldsack', '💰', l.goldsack, l.goldsackText),
            produkt('glitzerpaket', '✨', l.glitzerpaket, l.glitzerpaketText),
            if (kauf.fehler != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  kauf.fehler!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            TextButton(
              onPressed: kauf.wiederherstellen,
              child: Text(l.kaeufeWiederherstellen),
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
            Abschnitt(l.einstellungen),
            AppInfoKacheln(info: appInfo, designModus: designModus),
            ListTile(
              leading: Icon(
                Icons.restart_alt,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(l.spielZuruecksetzen),
              onTap: () async {
                if (await bestaetigen(
                  context,
                  titel: l.spielZuruecksetzen,
                  text: l.spielZuruecksetzenText,
                )) {
                  await spiel.zuruecksetzen();
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
