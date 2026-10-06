import 'package:app_basis/app_basis.dart';
import 'package:app_kauf/app_kauf.dart';
import 'package:flutter/material.dart';

import '../dienste.dart';
import '../l10n/l.dart';

class MehrScreen extends StatelessWidget {
  const MehrScreen({super.key});

  void _plus(BuildContext context) {
    final l = context.l;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProSeite(
          dienst: kauf,
          titel: l.plusTitel,
          vorteile: [
            ProVorteil(Icons.groups, l.plusVorteilGruppen),
            ProVorteil(Icons.block, l.plusVorteilWerbefrei),
            ProVorteil(Icons.favorite, l.plusVorteilUnterstuetzen),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.tabMehr)),
      body: ListenableBuilder(
        listenable: Listenable.merge([kauf, profil]),
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
                      l.plusTitel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(l.plusKurz),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _plus(context),
                  ),
                ),
              ),
            if (!kauf.gekauft && !kauf.besitzt('werbefrei'))
              ListTile(
                leading: const Icon(Icons.block),
                title: Text(l.werbefrei),
                subtitle: Text(
                  kauf.produkt('werbefrei')?.price ?? l.einmalkauf,
                ),
                onTap: () {
                  final p = kauf.produkt('werbefrei');
                  if (p != null) kauf.kaufen(p);
                },
              ),
            Abschnitt(l.profil),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(l.deinName),
              subtitle: Text(
                profil.name.isEmpty ? l.nichtGesetzt : profil.name,
              ),
              onTap: () async {
                final c = TextEditingController(text: profil.name);
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l.deinName),
                    content: TextField(controller: c, autofocus: true),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l.abbrechen),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(l.speichern),
                      ),
                    ],
                  ),
                );
                if (ok == true) await profil.nameSetzen(c.text);
              },
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
