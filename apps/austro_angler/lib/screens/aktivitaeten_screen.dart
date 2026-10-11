import 'package:flutter/material.dart';

import '../main.dart';
import '../services/fang_dienst.dart';
import 'profil_screen.dart';
import 'widgets.dart';

/// Zählt ungelesene Neuigkeiten; baut [builder] mit der Anzahl.
class NeuigkeitenZaehler extends StatefulWidget {
  const NeuigkeitenZaehler({super.key, required this.builder});

  final Widget Function(BuildContext context, int anzahl) builder;

  @override
  State<NeuigkeitenZaehler> createState() => _NeuigkeitenZaehlerState();
}

class _NeuigkeitenZaehlerState extends State<NeuigkeitenZaehler> {
  String? _schluessel;
  Stream<int>? _stream;

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context);
    final speicher = SpeicherScope.of(context);
    final uid = konto?.angemeldet == true ? konto?.uid : null;
    if (uid == null) return widget.builder(context, 0);
    final schluessel = '$uid/${speicher.neuigkeitenGesehen}';
    if (schluessel != _schluessel) {
      _schluessel = schluessel;
      _stream = fangDienst.neueAktivitaeten(uid, speicher.neuigkeitenGesehen);
    }
    return StreamBuilder<int>(
      stream: _stream,
      builder: (context, snap) => widget.builder(context, snap.data ?? 0),
    );
  }
}

/// Glocke mit Zahl – öffnet die Neuigkeiten.
class NeuigkeitenGlocke extends StatelessWidget {
  const NeuigkeitenGlocke({super.key});

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context);
    if (konto?.angemeldet != true) return const SizedBox.shrink();
    return NeuigkeitenZaehler(
      builder: (context, n) => IconButton(
        tooltip: 'Neuigkeiten',
        icon: Badge(
          isLabelVisible: n > 0,
          label: Text(n >= 20 ? '20+' : '$n'),
          child: Icon(n > 0
              ? Icons.notifications_active
              : Icons.notifications_outlined),
        ),
        onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AktivitaetenScreen())),
      ),
    );
  }
}

/// Neuigkeiten: Petri Heil, Kommentare, Freundschaftsanfragen …
class AktivitaetenScreen extends StatefulWidget {
  const AktivitaetenScreen({super.key});

  @override
  State<AktivitaetenScreen> createState() => _AktivitaetenScreenState();
}

class _AktivitaetenScreenState extends State<AktivitaetenScreen> {
  Stream<List<Eintrag>>? _stream;

  /// Stand beim Öffnen – damit Neues hervorgehoben bleibt, solange man schaut.
  DateTime? _gesehenBisher;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_gesehenBisher == null) {
      final speicher = SpeicherScope.of(context);
      _gesehenBisher = speicher.neuigkeitenGesehen;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => speicher.neuigkeitenGelesen());
    }
  }

  static (String, String) _art(Eintrag a) => switch (a.typ) {
        'petri' => ('👍', '${at(a.nutzerName)} sagt Petri Heil!'),
        'kommentar' => ('💬', '${at(a.nutzerName)} hat kommentiert'),
        'anfrage' => ('🤝', '${at(a.nutzerName)} möchte dein Freund sein'),
        'freund' => ('🎉', '${at(a.nutzerName)} hat deine Anfrage angenommen'),
        'wettfischen' => ('🏆', '${at(a.nutzerName)}: Wettfischen'),
        _ => ('🔔', at(a.nutzerName)),
      };

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context)!;
    _stream ??= fangDienst.aktivitaeten(konto.uid!);
    final farben = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neuigkeiten'),
        actions: [
          IconButton(
            tooltip: 'Alle löschen',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () async {
              if (await loeschenBestaetigen(
                      context, 'Alle Neuigkeiten') &&
                  context.mounted) {
                await fangDienst.aktivitaetenLeeren(konto.uid!);
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Eintrag>>(
        stream: _stream,
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(child: Text('Laden fehlgeschlagen.'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final liste = snap.data!;
          if (liste.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Noch nichts Neues. Teile Fänge, dann bekommst du '
                    'hier Petri Heil und Kommentare! 🎣',
                    textAlign: TextAlign.center),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              for (final a in liste)
                Builder(builder: (context) {
                  final (symbol, titel) = _art(a);
                  final neu = a.erstellt.isAfter(_gesehenBisher!);
                  return Card(
                    color: neu ? farben.primaryContainer : null,
                    child: ListTile(
                      leading:
                          Text(symbol, style: const TextStyle(fontSize: 26)),
                      title: Text(titel),
                      subtitle: Text([
                        if (a.text.isNotEmpty) '"${a.text}"',
                        '${datumText(a.erstellt)} ${uhrText(a.erstellt)}',
                      ].join('\n')),
                      trailing: neu
                          ? const Badge(label: Text('neu'))
                          : const Icon(Icons.person_outline),
                      onTap: a.uid.isEmpty
                          ? null
                          : () => profilOeffnen(context, a.uid, a.nutzerName),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
