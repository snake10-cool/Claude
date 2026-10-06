import 'package:flutter/material.dart';

import 'l10n/basis_localizations.dart';
import 'meine_apps.dart';
import 'store_links.dart';

/// „Mehr Apps von mir“: alle veröffentlichten Apps außer der aktuellen.
class MehrAppsScreen extends StatelessWidget {
  const MehrAppsScreen({super.key, required this.aktuellePaketId});

  final String aktuellePaketId;

  static List<MeineApp> andereApps(String aktuellePaketId) => [
        for (final app in meineApps)
          if (app.veroeffentlicht && app.paketId != aktuellePaketId) app,
      ];

  @override
  Widget build(BuildContext context) {
    final l = BasisLocalizations.of(context);
    final apps = andereApps(aktuellePaketId);
    final locale = Localizations.localeOf(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.mehrApps)),
      body: apps.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(l.mehrAppsBaldMehr, textAlign: TextAlign.center),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: apps.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final app = apps[i];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: app.farbe,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(app.symbol, color: Colors.white),
                    ),
                    title: Text(app.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(app.beschreibung(locale)),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => oeffneStoreEintrag(app.paketId),
                  ),
                );
              },
            ),
    );
  }
}
