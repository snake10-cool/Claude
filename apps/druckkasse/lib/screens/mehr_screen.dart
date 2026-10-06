import 'package:app_basis/app_basis.dart';
import 'package:flutter/material.dart';

import '../dienste.dart';
import '../l10n/l.dart';
import '../widgets/allgemein.dart';
import 'drucker_screen.dart';
import 'einstellungen_screen.dart';
import 'extras_screen.dart';
import 'filamente_screen.dart';
import 'sparziele_screen.dart';

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
          Abschnitt(l.werkstatt),
          ListTile(
            leading: const Icon(Icons.print_outlined),
            title: Text(l.drucker),
            onTap: () => oeffnen(const DruckerScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.blur_circular),
            title: Text(l.filamente),
            onTap: () => oeffnen(const FilamenteScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.redeem_outlined),
            title: Text(l.extras),
            subtitle: Text(l.extrasUntertitel),
            onTap: () => oeffnen(const ExtrasScreen()),
          ),
          Abschnitt(l.ziele),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: Text(l.sparziele),
            onTap: () => oeffnen(const SparzieleScreen()),
          ),
          Abschnitt(l.app),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(l.einstellungen),
            subtitle: Text(l.einstellungenUntertitel),
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
