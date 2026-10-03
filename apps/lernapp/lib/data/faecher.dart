import 'package:flutter/material.dart';

import '../models/lehrplan.dart';
import 'deutsch.dart';
import 'englisch.dart';
import 'mathe.dart';

/// Hauptfächer – gratis.
const hauptfaecher = [
  Fach(id: 'deutsch', name: 'Deutsch', icon: Icons.menu_book,
      farbe: Color(0xFFE53935)),
  Fach(id: 'mathe', name: 'Mathematik', icon: Icons.calculate,
      farbe: Color(0xFF1E88E5)),
  Fach(id: 'englisch', name: 'Englisch', icon: Icons.translate,
      farbe: Color(0xFF43A047)),
];

/// Nebenfächer – später mit Premium.
List<Fach> nebenfaecher(Stufe stufe) => stufe.volksschule
    ? const [
        Fach(id: 'sachunterricht', name: 'Sachunterricht', icon: Icons.eco,
            farbe: Color(0xFF8D6E63), premium: true),
        Fach(id: 'musik', name: 'Musik', icon: Icons.music_note,
            farbe: Color(0xFF8E24AA), premium: true),
        Fach(id: 'kunst', name: 'Kunst und Gestaltung', icon: Icons.palette,
            farbe: Color(0xFFFB8C00), premium: true),
        Fach(id: 'technik', name: 'Technik und Design', icon: Icons.build,
            farbe: Color(0xFF546E7A), premium: true),
        Fach(id: 'sport', name: 'Bewegung und Sport',
            icon: Icons.directions_run, farbe: Color(0xFF00897B),
            premium: true),
      ]
    : const [
        Fach(id: 'geografie', name: 'Geografie', icon: Icons.public,
            farbe: Color(0xFF00897B), premium: true),
        Fach(id: 'geschichte', name: 'Geschichte', icon: Icons.account_balance,
            farbe: Color(0xFF6D4C41), premium: true),
        Fach(id: 'biologie', name: 'Biologie', icon: Icons.eco,
            farbe: Color(0xFF7CB342), premium: true),
        Fach(id: 'physik', name: 'Physik', icon: Icons.bolt,
            farbe: Color(0xFFFDD835), premium: true),
        Fach(id: 'chemie', name: 'Chemie', icon: Icons.science,
            farbe: Color(0xFF26C6DA), premium: true),
        Fach(id: 'digital', name: 'Digitale Grundbildung',
            icon: Icons.computer, farbe: Color(0xFF5C6BC0), premium: true),
        Fach(id: 'musik', name: 'Musik', icon: Icons.music_note,
            farbe: Color(0xFF8E24AA), premium: true),
        Fach(id: 'kunst', name: 'Kunst und Gestaltung', icon: Icons.palette,
            farbe: Color(0xFFFB8C00), premium: true),
      ];

List<Thema> themen(Fach fach, Stufe stufe) => switch (fach.id) {
      'deutsch' => deutsch[stufe] ?? const [],
      'mathe' => mathe[stufe] ?? const [],
      'englisch' => englisch[stufe] ?? const [],
      _ => const [],
    };
