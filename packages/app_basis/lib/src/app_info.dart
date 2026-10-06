import 'package:flutter/material.dart';

/// Steckbrief der App, die gerade läuft. Jede App legt genau einen davon an
/// und gibt ihn an die gemeinsamen Bildschirme weiter.
class AppInfo {
  const AppInfo({
    required this.name,
    required this.paketId,
    required this.farbe,
    required this.kontaktEmail,
    this.datenschutzUrl,
    this.datenschutzText,
  });

  /// Name wie im Play Store, z. B. „Druckkasse“.
  final String name;

  /// Android-Paket-ID, z. B. `com.snake10.druckkasse`.
  final String paketId;

  /// Hauptfarbe der App. Daraus entsteht das ganze Farbschema.
  final Color farbe;

  final String kontaktEmail;

  /// Webseite mit der Datenschutzerklärung. Solange es keine gibt, wird
  /// [datenschutzText] in der App angezeigt.
  final String? datenschutzUrl;
  final String? datenschutzText;
}
