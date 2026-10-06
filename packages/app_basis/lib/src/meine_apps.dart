import 'package:flutter/material.dart';

/// Eine meiner Apps für den Bildschirm „Mehr Apps von mir“.
class MeineApp {
  const MeineApp({
    required this.name,
    required this.paketId,
    required this.beschreibungDe,
    required this.beschreibungEn,
    required this.symbol,
    required this.farbe,
    this.veroeffentlicht = true,
  });

  final String name;
  final String paketId;
  final String beschreibungDe;
  final String beschreibungEn;
  final IconData symbol;
  final Color farbe;

  /// Erst auf `true` setzen, wenn die App im Play Store öffentlich ist.
  /// Sonst würde der Link ins Leere führen.
  final bool veroeffentlicht;

  String beschreibung(Locale locale) =>
      locale.languageCode == 'de' ? beschreibungDe : beschreibungEn;
}

/// Alle Apps. Neue App fertig → hier eintragen. Jede App zeigt alle anderen
/// an, die veröffentlicht sind. Sobald eine App im Play Store live ist:
/// `veroeffentlicht: false` entfernen und alle Apps neu hochladen.
const meineApps = <MeineApp>[
  MeineApp(
    name: 'Austro Angler',
    paketId: 'com.snake10.austroangler',
    beschreibungDe: 'Gewässer, Fangbuch und Schonzeiten für ganz Österreich',
    beschreibungEn: 'Waters, catch log and closed seasons for Austria',
    symbol: Icons.phishing,
    farbe: Color(0xFF1E6F5C),
    veroeffentlicht: false,
  ),
  MeineApp(
    name: 'Druckkasse',
    paketId: 'com.snake10.druckkasse',
    beschreibungDe: 'Kosten, Preise und Verkäufe für deine 3D-Drucke',
    beschreibungEn: 'Costs, prices and sales for your 3D prints',
    symbol: Icons.print,
    farbe: Color(0xFFE8622A),
    veroeffentlicht: false,
  ),
  MeineApp(
    name: 'Codekarten',
    paketId: 'com.snake10.codekarten',
    beschreibungDe: 'Programmieren lernen mit Karteikarten und Snippets',
    beschreibungEn: 'Learn to code with flashcards and snippets',
    symbol: Icons.code,
    farbe: Color(0xFF6C4DE6),
    veroeffentlicht: false,
  ),
  MeineApp(
    name: 'Teilbar',
    paketId: 'com.snake10.teilbar',
    beschreibungDe: 'WG-Einkaufsliste, Kosten teilen, Packlisten, Resteküche',
    beschreibungEn: 'Shared shopping lists, split costs, packing lists, recipes',
    symbol: Icons.shopping_basket,
    farbe: Color(0xFF1F9D6B),
    veroeffentlicht: false,
  ),
];
