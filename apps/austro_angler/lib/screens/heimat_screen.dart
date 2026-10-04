import 'package:flutter/material.dart';

import '../main.dart';
import '../models/bundesland.dart';
import '../services/alle_gewaesser.dart';
import 'widgets.dart';

/// Heimatort selbst wählen – die App fragt nie nach dem GPS-Standort.
class HeimatScreen extends StatefulWidget {
  const HeimatScreen({super.key});

  @override
  State<HeimatScreen> createState() => _HeimatScreenState();
}

class _HeimatScreenState extends State<HeimatScreen> {
  late Bundesland _land;
  String _bezirk = '';
  String _gemeinde = '';
  bool _start = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_start) return;
    _start = false;
    final speicher = SpeicherScope.of(context);
    final teile = speicher.heimat.split('|');
    _land = Bundesland.ausName(teile.first) ?? speicher.bundesland;
    if (teile.length == 3) {
      _bezirk = teile[1];
      _gemeinde = teile[2];
    } else {
      _bezirk = speicher.bezirk;
    }
  }

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final bezirke = alleGewaesser.bezirke[_land] ?? const <String>[];
    final gemeinden =
        _bezirk.isEmpty ? const <String>[] : alleGewaesser.gemeindenVon(_land, _bezirk);
    final mitte = _gemeinde.isEmpty
        ? null
        : alleGewaesser.mitteVon(_land, _bezirk, _gemeinde);
    return Scaffold(
      appBar: AppBar(title: const Text('Mein Heimatort')),
      body: ListenableBuilder(
        listenable: alleGewaesser,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const HinweisKarte(
              'Wähl deinen Ort selbst aus – die App verwendet nie GPS. Danach '
              'kannst du Gewässer nach Entfernung zu deinem Ort sortieren, und '
              'Widget und Wetter beziehen sich auf deinen Ort.',
              icon: Icons.home_outlined,
            ),
            const SizedBox(height: 16),
            DropdownMenu<Bundesland>(
              expandedInsets: EdgeInsets.zero,
              initialSelection: _land,
              label: const Text('Bundesland'),
              dropdownMenuEntries: [
                for (final b in Bundesland.values)
                  DropdownMenuEntry(value: b, label: b.name),
              ],
              onSelected: (b) => setState(() {
                if (b == null) return;
                _land = b;
                _bezirk = '';
                _gemeinde = '';
              }),
            ),
            const SizedBox(height: 12),
            DropdownMenu<String>(
              key: ValueKey('b-${_land.name}'),
              expandedInsets: EdgeInsets.zero,
              initialSelection: _bezirk.isEmpty ? null : _bezirk,
              label: const Text('Bezirk'),
              enableFilter: true,
              requestFocusOnTap: true,
              menuHeight: 360,
              dropdownMenuEntries: [
                for (final b in bezirke) DropdownMenuEntry(value: b, label: b),
              ],
              onSelected: (b) => setState(() {
                _bezirk = b ?? '';
                _gemeinde = '';
              }),
            ),
            const SizedBox(height: 12),
            DropdownMenu<String>(
              key: ValueKey('g-${_land.name}-$_bezirk'),
              expandedInsets: EdgeInsets.zero,
              enabled: gemeinden.isNotEmpty,
              initialSelection: _gemeinde.isEmpty ? null : _gemeinde,
              label: const Text('Ort / Gemeinde'),
              enableFilter: true,
              requestFocusOnTap: true,
              menuHeight: 360,
              dropdownMenuEntries: [
                for (final g in gemeinden) DropdownMenuEntry(value: g, label: g),
              ],
              onSelected: (g) => setState(() => _gemeinde = g ?? ''),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: mitte == null
                  ? null
                  : () async {
                      await speicher.heimatSetzen(
                          '${_land.name}|$_bezirk|$_gemeinde',
                          mitte.latitude,
                          mitte.longitude);
                      if (context.mounted) {
                        meldung(context, '$_gemeinde ist jetzt dein Heimatort.');
                        Navigator.pop(context);
                      }
                    },
              icon: const Icon(Icons.check),
              label: const Text('Speichern'),
            ),
            if (speicher.heimat.isNotEmpty)
              TextButton(
                onPressed: () async {
                  await speicher.heimatLoeschen();
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Heimatort entfernen'),
              ),
          ],
        ),
      ),
    );
  }
}
