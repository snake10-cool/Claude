import 'package:flutter/material.dart';

import '../main.dart';
import '../models/fang.dart';
import '../services/fang_dienst.dart';
import 'fangbuch_screen.dart';
import 'melden.dart';
import 'profil_screen.dart';
import 'widgets.dart';

class KommentareScreen extends StatefulWidget {
  const KommentareScreen(this.fang, {super.key});

  final Fang fang;

  @override
  State<KommentareScreen> createState() => _KommentareScreenState();
}

class _KommentareScreenState extends State<KommentareScreen> {
  late final _stream = fangDienst.kommentare(widget.fang.id);
  final _eingabe = TextEditingController();
  bool _sendet = false;

  @override
  void dispose() {
    _eingabe.dispose();
    super.dispose();
  }

  Future<void> _senden() async {
    final konto = KontoScope.of(context)!;
    final text = _eingabe.text.trim();
    if (text.isEmpty) return;
    setState(() => _sendet = true);
    try {
      await fangDienst.kommentieren(
        widget.fang,
        konto.uid!,
        konto.name ?? '',
        text,
      );
      _eingabe.clear();
    } catch (_) {
      if (mounted) meldung(context, 'Senden fehlgeschlagen.');
    } finally {
      if (mounted) setState(() => _sendet = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context)!;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Kommentare')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Eintrag>>(
              stream: _stream,
              builder: (context, snap) {
                final liste = snap.data ?? const <Eintrag>[];
                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    FangKarte(widget.fang),
                    const SizedBox(height: 8),
                    if (snap.hasError)
                      const Text('Laden fehlgeschlagen.')
                    else if (!snap.hasData)
                      const Center(child: CircularProgressIndicator())
                    else if (liste.isNotEmpty)
                      Text('Lange auf einen Kommentar drücken, um ihn zu melden.',
                          style: text.bodySmall)
                    else if (liste.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Noch keine Kommentare. Schreib den ersten!',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    for (final k in liste)
                      if (!konto.istBlockiert(k.uid))
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: NutzerLink(k.uid, k.nutzerName,
                              stil: text.labelLarge),
                          subtitle: Text(k.text),
                          onLongPress: k.uid == konto.uid
                              ? null
                              : () => meldenDialog(
                                    context,
                                    typ: 'kommentar',
                                    bezug: '${widget.fang.id}/${k.id}',
                                    titel: 'Kommentar melden',
                                    hinweis: 'Was ist das Problem?',
                                  ),
                          trailing:
                              k.uid == konto.uid ||
                                  konto.istAdmin ||
                                  widget.fang.uid == konto.uid
                              ? IconButton(
                                  tooltip: 'Löschen',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                  onPressed: () => fangDienst.kommentarLoeschen(
                                    widget.fang.id,
                                    k.id,
                                  ),
                                )
                              : null,
                        ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _eingabe,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        hintText: 'Kommentar schreiben …',
                        counterText: '',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _senden(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sendet ? null : _senden,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
