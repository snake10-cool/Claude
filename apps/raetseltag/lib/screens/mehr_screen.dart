import 'package:app_basis/app_basis.dart';
import 'package:flutter/material.dart';

import '../dienste.dart';
import '../l10n/l.dart';
import '../widgets/pro.dart';

class MehrScreen extends StatelessWidget {
  const MehrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.mehr)),
      body: ListenableBuilder(
        listenable: kauf,
        builder: (context, _) => ListView(
          children: [
            if (!kauf.gekauft)
              Padding(
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
                Icons.delete_forever,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(l.statistikLoeschen),
              onTap: () async {
                if (await bestaetigen(
                  context,
                  titel: l.statistikLoeschen,
                  text: l.statistikLoeschenText,
                )) {
                  await fortschritt.allesLoeschen();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
