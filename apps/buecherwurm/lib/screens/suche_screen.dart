import 'package:flutter/material.dart';

import '../main.dart';
import '../models/buch.dart';
import '../widgets/buch_kachel.dart';
import 'online_suche_screen.dart';
import 'start_screen.dart';

class SucheScreen extends StatefulWidget {
  const SucheScreen({super.key});

  @override
  State<SucheScreen> createState() => _SucheScreenState();
}

class _SucheScreenState extends State<SucheScreen> {
  var _text = '';
  String? _tag;

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final s = _text.toLowerCase();
    final buecher = speicher.alleBuecher
        .where((b) =>
            (s.isEmpty || b.titel.toLowerCase().contains(s) || b.autor.toLowerCase().contains(s)) &&
            (_tag == null || b.tags.contains(_tag)))
        .toList()
      ..sort((a, b) => a.titel.compareTo(b.titel));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'ISBN scannen',
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const OnlineSucheScreen(scannen: true),
            )),
          ),
        ],
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Titel oder Autor', border: InputBorder.none),
          onChanged: (t) => setState(() => _text = t),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final MapEntry(:key, :value) in Tags.namen.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(value),
                      selected: _tag == key,
                      onSelected: (an) => setState(() => _tag = an ? key : null),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: buecher.length + 1,
              itemBuilder: (context, i) {
                if (i == buecher.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => OnlineSucheScreen(text: _text),
                      )),
                      icon: const Icon(Icons.travel_explore),
                      label: Text(_text.isEmpty
                          ? 'Nicht dabei? Alle Bücher der Welt durchsuchen'
                          : '„$_text" online suchen'),
                    ),
                  );
                }
                final buch = buecher[i];
                final status = speicher.eintraege[buch.id]?.status;
                return ListTile(
                  leading: BuchCover(buch, breite: 36),
                  title: Text(buch.titel),
                  subtitle: Text(status == null ? buch.autor : '${buch.autor} · ${status.text}'),
                  trailing: status == null
                      ? IconButton(
                          tooltip: 'Auf die Wunschliste',
                          icon: const Icon(Icons.bookmark_add_outlined),
                          onPressed: () => speicher.eintragSetzen(buch.id, Eintrag(status: Status.wunschliste)),
                        )
                      : null,
                  onTap: () => buchOeffnen(context, buch.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
