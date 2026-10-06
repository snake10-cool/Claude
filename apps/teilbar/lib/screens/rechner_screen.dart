import 'package:flutter/material.dart';

import '../l10n/l.dart';
import '../logik/geld.dart';
import '../widgets/format.dart';

/// Trinkgeld- und Rechnungsteiler fürs Restaurant.
class RechnerScreen extends StatefulWidget {
  const RechnerScreen({super.key});

  @override
  State<RechnerScreen> createState() => _RechnerScreenState();
}

class _RechnerScreenState extends State<RechnerScreen> {
  final _betrag = TextEditingController();
  double _trinkgeld = 10;
  int _personen = 2;
  bool _runden = true;

  @override
  void dispose() {
    _betrag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    final betrag = parseEuro(_betrag.text) ?? 0;
    final r = rechnungTeilen(
      betragCent: betrag,
      trinkgeldProzent: _trinkgeld,
      personen: _personen,
      aufrundenAufCent: _runden ? 50 : 0,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l.rechner)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EuroFeld(
            controller: _betrag,
            label: l.rechnungsbetrag,
            autofocus: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Text(
            l.trinkgeldProzent(_trinkgeld.round()),
            style: t.textTheme.titleSmall,
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final p in [0, 5, 10, 15, 20])
                ChoiceChip(
                  label: Text('$p %'),
                  selected: _trinkgeld.round() == p,
                  onSelected: (_) => setState(() => _trinkgeld = p.toDouble()),
                ),
            ],
          ),
          Slider(
            value: _trinkgeld,
            min: 0,
            max: 30,
            divisions: 30,
            label: '${_trinkgeld.round()} %',
            onChanged: (v) => setState(() => _trinkgeld = v),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text(l.personen, style: t.textTheme.titleSmall)),
              IconButton.filledTonal(
                onPressed: _personen > 1
                    ? () => setState(() => _personen--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  '$_personen',
                  textAlign: TextAlign.center,
                  style: t.textTheme.headlineSmall,
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => setState(() => _personen++),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.aufrunden),
            subtitle: Text(l.aufrundenText),
            value: _runden,
            onChanged: (v) => setState(() => _runden = v),
          ),
          const SizedBox(height: 12),
          Card(
            color: t.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(l.proPerson, style: t.textTheme.titleMedium),
                  Text(
                    euro(r.proPersonCent),
                    style: t.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.rechnerErgebnis(
                      euro(r.gesamtCent),
                      euro(r.trinkgeldCent),
                    ),
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
