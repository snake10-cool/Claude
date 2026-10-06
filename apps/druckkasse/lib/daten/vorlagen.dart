import 'package:flutter/material.dart';

/// Druckermodell als Vorlage. Verbrauch = Durchschnitt beim PLA-Druck,
/// Preise ungefähr (Stand 2026). Alles lässt sich danach anpassen.
class DruckerVorlage {
  const DruckerVorlage(this.name, this.watt, this.preisEuro);
  final String name;
  final int watt;
  final int preisEuro;
}

const druckerVorlagen = [
  DruckerVorlage('Bambu Lab A1 mini', 80, 199),
  DruckerVorlage('Bambu Lab A1', 95, 299),
  DruckerVorlage('Bambu Lab P1S', 120, 549),
  DruckerVorlage('Bambu Lab P2S', 130, 599),
  DruckerVorlage('Bambu Lab X1 Carbon', 140, 1099),
  DruckerVorlage('Bambu Lab H2D', 200, 1899),
  DruckerVorlage('Creality Ender 3 V3 SE', 110, 189),
  DruckerVorlage('Creality K1C', 150, 399),
  DruckerVorlage('Prusa MK4S', 90, 799),
];

const standardLebensdauerStunden = 5000;

const materialien = [
  'PLA',
  'PLA Matt',
  'PLA Silk',
  'PLA-CF',
  'PETG',
  'TPU',
  'ABS',
  'ASA',
  'Sonstiges',
];

/// Farben zum Antippen für Filamente.
const filamentFarben = <(String, Color)>[
  ('Weiß', Color(0xFFF5F5F5)),
  ('Schwarz', Color(0xFF212121)),
  ('Grau', Color(0xFF9E9E9E)),
  ('Rot', Color(0xFFE53935)),
  ('Orange', Color(0xFFFB8C00)),
  ('Gelb', Color(0xFFFDD835)),
  ('Grün', Color(0xFF43A047)),
  ('Mint', Color(0xFF64FFDA)),
  ('Blau', Color(0xFF1E88E5)),
  ('Türkis', Color(0xFF00ACC1)),
  ('Lila', Color(0xFF8E24AA)),
  ('Pink', Color(0xFFEC407A)),
  ('Braun', Color(0xFF795548)),
  ('Gold', Color(0xFFFFC107)),
  ('Silber', Color(0xFFB0BEC5)),
  ('Transparent', Color(0xFFE0F7FA)),
];

/// Emojis für Produkt-Knöpfe.
const produktSymbole = [
  '🐉',
  '🦖',
  '🐙',
  '🦈',
  '🐱',
  '🐶',
  '🦊',
  '🐸',
  '🐢',
  '🦋',
  '⭐',
  '🌟',
  '💎',
  '🧊',
  '🎲',
  '🔑',
  '🗝️',
  '🖱️',
  '🎮',
  '🕹️',
  '🎃',
  '🎄',
  '🎅',
  '🐰',
  '❤️',
  '🌸',
  '🍀',
  '⚽',
  '🏆',
  '🎁',
  '📦',
  '🔧',
  '🧩',
  '🪴',
  '🕯️',
  '📱',
  '✏️',
  '🎨',
  '🚀',
  '🤖',
];
