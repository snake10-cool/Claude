import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app_info.dart';
import 'design_modus.dart';
import 'l10n/basis_localizations.dart';
import 'mehr_apps_screen.dart';
import 'store_links.dart';

/// Die Einträge, die in jeder App unter „Einstellungen“ stehen:
/// Design, Mehr Apps, Bewerten, Kontakt, Datenschutz, Lizenzen, Version.
class AppInfoKacheln extends StatelessWidget {
  const AppInfoKacheln({
    super.key,
    required this.info,
    required this.designModus,
  });

  final AppInfo info;
  final DesignModus designModus;

  @override
  Widget build(BuildContext context) {
    final l = BasisLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListenableBuilder(
          listenable: designModus,
          builder: (context, _) => ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(l.design),
            subtitle: Text(switch (designModus.modus) {
              ThemeMode.light => l.designHell,
              ThemeMode.dark => l.designDunkel,
              ThemeMode.system => l.designSystem,
            }),
            onTap: () => _designWaehlen(context),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.apps),
          title: Text(l.mehrApps),
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => MehrAppsScreen(aktuellePaketId: info.paketId),
          )),
        ),
        ListTile(
          leading: const Icon(Icons.star_outline),
          title: Text(l.appBewerten),
          subtitle: Text(l.appBewertenText),
          onTap: () => oeffneStoreEintrag(info.paketId),
        ),
        ListTile(
          leading: const Icon(Icons.mail_outline),
          title: Text(l.kontakt),
          subtitle: Text(info.kontaktEmail),
          onTap: () => oeffneEmail(info.kontaktEmail, betreff: info.name),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: Text(l.datenschutz),
          onTap: () => _datenschutz(context),
        ),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snap) => ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.ueberApp(info.name)),
            subtitle: Text(snap.hasData
                ? l.version(snap.data!.version)
                : ''),
            onTap: () => showLicensePage(
              context: context,
              applicationName: info.name,
              applicationVersion: snap.data?.version,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _designWaehlen(BuildContext context) async {
    final l = BasisLocalizations.of(context);
    final gewaehlt = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l.design),
        children: [
          for (final (modus, text) in [
            (ThemeMode.system, l.designSystem),
            (ThemeMode.light, l.designHell),
            (ThemeMode.dark, l.designDunkel),
          ])
            ListTile(
              leading: Icon(modus == designModus.modus
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked),
              title: Text(text),
              onTap: () => Navigator.pop(context, modus),
            ),
        ],
      ),
    );
    if (gewaehlt != null) await designModus.setzen(gewaehlt);
  }

  void _datenschutz(BuildContext context) {
    final url = info.datenschutzUrl;
    if (url != null) {
      oeffneWebseite(url);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text(BasisLocalizations.of(context).datenschutz)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(info.datenschutzText ?? ''),
        ),
      ),
    ));
  }
}
