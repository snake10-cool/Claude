import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../main.dart';
import '../data/bilder.dart';
import '../models/bundesland.dart';
import '../services/fang_dienst.dart';
import 'konto_screen.dart';

/// Auswahl des Bundeslands, die dauerhaft gespeichert wird.
class BundeslandWahl extends StatelessWidget {
  const BundeslandWahl({super.key});

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    return DropdownMenu<Bundesland>(
      key: ValueKey(speicher.bundesland),
      initialSelection: speicher.bundesland,
      label: const Text('Bundesland'),
      leadingIcon: const Icon(Icons.place_outlined),
      expandedInsets: EdgeInsets.zero,
      dropdownMenuEntries: [
        for (final b in Bundesland.values)
          DropdownMenuEntry(value: b, label: b.name),
      ],
      onSelected: (b) {
        if (b != null) speicher.bundeslandSetzen(b);
      },
    );
  }
}

class HinweisKarte extends StatelessWidget {
  const HinweisKarte(this.text, {super.key, this.icon = Icons.info_outline});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    return Card(
      color: farben.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: farben.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: farben.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hinweis mit Knopf zum Anmelden.
class AnmeldenKarte extends StatelessWidget {
  const AnmeldenKarte(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.account_circle_outlined, size: 48),
            const SizedBox(height: 8),
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const KontoScreen()),
              ),
              child: const Text('Anmelden oder registrieren'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lädt das Foto eines Fangs aus Firestore.
class FangFoto extends StatelessWidget {
  const FangFoto(this.fangId, {super.key, this.hoehe = 220});

  final String fangId;
  final double hoehe;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: fangDienst.foto(fangId),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return SizedBox(
            height: hoehe,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        final bytes = snap.data;
        if (bytes == null) return const SizedBox.shrink();
        return Image.memory(
          bytes,
          height: hoehe,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      },
    );
  }
}

/// Nutzername mit @ davor.
String at(String name) => name.isEmpty ? '' : '@$name';

String datumText(DateTime d) => '${d.day}.${d.month}.${d.year}';

String uhrText(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

void meldung(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

/// Bild aus den App-Daten mit Quellenangabe darunter.
class QuellenBild extends StatelessWidget {
  const QuellenBild(this.quelle, {super.key, this.hoehe = 200});

  final BildQuelle quelle;
  final double hoehe;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Colors.white,
            height: hoehe,
            child: Image.asset(
              quelle.pfad,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  const Center(child: Icon(Icons.image_not_supported)),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(quelle.text,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
