import 'package:flutter/material.dart';

import '../main.dart';
import '../models/fang.dart';
import '../services/fang_dienst.dart';
import 'fangbuch_screen.dart';
import 'melden.dart';
import 'widgets.dart';

/// Öffentliches Profil eines Nutzers mit seinen geteilten Fängen.
class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key, required this.uid, required this.name});

  final String uid;
  final String name;

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  late final Future<List<Fang>> _faenge = fangDienst.faengeVon(widget.uid);
  Stream<Map<String, String>>? _freunde;

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context);
    final ich = konto?.uid;
    if (ich != null) _freunde ??= fangDienst.freunde(ich);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(at(widget.name))),
      body: FutureBuilder<List<Fang>>(
        future: _faenge,
        builder: (context, snap) {
          final faenge = snap.data ?? const <Fang>[];
          final groesster = faenge
              .where((f) => f.laengeCm != null)
              .fold<double>(0, (m, f) => f.laengeCm! > m ? f.laengeCm! : m);
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Icon(Icons.account_circle, size: 72),
              Text(at(widget.name),
                  style: text.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(
                '${faenge.length} Fänge · größter ${groesster.toStringAsFixed(0)} cm',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (ich != null && ich != widget.uid)
                StreamBuilder<Map<String, String>>(
                  stream: _freunde,
                  builder: (context, s) {
                    final istFreund = s.data?.containsKey(widget.uid) ?? false;
                    return Center(
                      child: istFreund
                          ? OutlinedButton.icon(
                              onPressed: () =>
                                  fangDienst.freundEntfernen(ich, widget.uid),
                              icon: const Icon(Icons.person_remove),
                              label: const Text('Freund entfernen'),
                            )
                          : FilledButton.icon(
                              onPressed: () async {
                                await fangDienst.freundHinzufuegen(
                                    ich, widget.name);
                                if (context.mounted) {
                                  meldung(context,
                                      '${at(widget.name)} ist jetzt dein Freund.');
                                }
                              },
                              icon: const Icon(Icons.person_add),
                              label: const Text('Als Freund hinzufügen'),
                            ),
                    );
                  },
                ),
              if (ich != null && ich != widget.uid)
                Center(
                  child: konto!.istBlockiert(widget.uid)
                      ? TextButton.icon(
                          onPressed: () =>
                              fangDienst.entblocken(ich, widget.uid),
                          icon: const Icon(Icons.lock_open),
                          label: const Text('Blockierung aufheben'),
                        )
                      : TextButton.icon(
                          onPressed: () => blockierenDialog(
                              context, widget.uid, widget.name),
                          icon: const Icon(Icons.block),
                          label: const Text('Blockieren'),
                        ),
                ),
              const SizedBox(height: 12),
              if (konto?.istBlockiert(widget.uid) ?? false)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Du hast diese Person blockiert.',
                      textAlign: TextAlign.center),
                )
              else if (snap.connectionState != ConnectionState.done)
                const Center(child: CircularProgressIndicator())
              else if (faenge.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Noch keine geteilten Fänge.',
                      textAlign: TextAlign.center),
                ),
              if (!(konto?.istBlockiert(widget.uid) ?? false))
                for (final f in faenge) FangKarte(f),
            ],
          );
        },
      ),
    );
  }
}
