import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/reste.dart';
import 'rezept_screen.dart';

List<Rezept>? _rezepte;

Future<List<Rezept>> rezepteLaden() async {
  if (_rezepte != null) return _rezepte!;
  final text = await rootBundle.loadString('assets/rezepte/rezepte.json');
  return _rezepte = [
    for (final r in jsonDecode(text) as List)
      Rezept.ausJson(Map<String, dynamic>.from(r as Map)),
  ];
}

/// Resteküche: Zutaten eingeben → passende Rezepte.
class KochenScreen extends StatefulWidget {
  const KochenScreen({super.key});

  @override
  State<KochenScreen> createState() => _KochenScreenState();
}

class _KochenScreenState extends State<KochenScreen> {
  late final Future<List<Rezept>> _laden = rezepteLaden();

  void _hinzu(String zutat) {
    final z = zutat.trim();
    if (z.isEmpty) return;
    final schluessel = zutatSchluessel(z);
    if (profil.zutaten.any((x) => zutatSchluessel(x) == schluessel)) return;
    profil.zutatenSetzen([...profil.zutaten, z]);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.resteKueche)),
      body: FutureBuilder<List<Rezept>>(
        future: _laden,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final rezepte = snap.data!;
          final vorschlaege = alleZutaten(rezepte);
          return ListenableBuilder(
            listenable: profil,
            builder: (context, _) {
              final treffer = rezepteFinden(rezepte, profil.zutaten);
              final tagesRezept = rezeptDesTages(rezepte, DateTime.now());
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: t.colorScheme.tertiaryContainer,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: const Text(
                        '👩‍🍳',
                        style: TextStyle(fontSize: 32),
                      ),
                      title: Text(
                        l.rezeptDesTages,
                        style: t.textTheme.labelLarge,
                      ),
                      subtitle: Text(
                        tagesRezept.name,
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _oeffnen(tagesRezept),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(l.wasHastDuDa, style: t.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Autocomplete<String>(
                    optionsBuilder: (wert) {
                      final q = wert.text.toLowerCase();
                      if (q.isEmpty) return const Iterable<String>.empty();
                      return vorschlaege
                          .where((z) => z.toLowerCase().contains(q))
                          .take(8);
                    },
                    onSelected: (z) {
                      _hinzu(z);
                    },
                    fieldViewBuilder: (context, c, fokus, absenden) =>
                        TextField(
                          controller: c,
                          focusNode: fokus,
                          decoration: InputDecoration(
                            hintText: l.zutatEingeben,
                            prefixIcon: const Icon(Icons.add),
                          ),
                          onSubmitted: (v) {
                            _hinzu(v);
                            c.clear();
                            fokus.requestFocus();
                          },
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final z in profil.zutaten)
                        InputChip(
                          label: Text(z),
                          onDeleted: () => profil.zutatenSetzen(
                            [...profil.zutaten]..remove(z),
                          ),
                        ),
                      if (profil.zutaten.isNotEmpty)
                        ActionChip(
                          avatar: const Icon(Icons.clear_all, size: 18),
                          label: Text(l.alleEntfernen),
                          onPressed: () => profil.zutatenSetzen([]),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    profil.zutaten.isEmpty
                        ? l.alleRezepte
                        : l.dazuPasst(treffer.length),
                    style: t.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  for (final tr
                      in profil.zutaten.isEmpty
                          ? rezepte.map((r) => RezeptTreffer(r, const [], 0))
                          : treffer)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(tr.rezept.name),
                        subtitle: Text(
                          profil.zutaten.isEmpty
                              ? l.minutenPortionen(
                                  tr.rezept.minuten,
                                  tr.rezept.portionen,
                                )
                              : tr.fehlend.isEmpty
                              ? l.allesDa
                              : l.esFehlt(
                                  tr.fehlend.map((z) => z.name).join(', '),
                                ),
                        ),
                        trailing: profil.zutaten.isEmpty
                            ? const Icon(Icons.chevron_right)
                            : CircularProgressIndicator(
                                value: tr.anteil,
                                strokeWidth: 5,
                                backgroundColor:
                                    t.colorScheme.surfaceContainerHighest,
                              ),
                        onTap: () => _oeffnen(tr.rezept),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _oeffnen(Rezept r) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => RezeptScreen(rezept: r)));
}
