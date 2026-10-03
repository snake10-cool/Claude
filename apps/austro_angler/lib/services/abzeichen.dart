import '../models/fang.dart';

class Abzeichen {
  const Abzeichen(this.icon, this.name, this.beschreibung, this.erreicht,
      {this.premium = false});

  final String icon;
  final String name;
  final String beschreibung;
  final bool Function(List<Fang>) erreicht;
  final bool premium;
}

int _arten(List<Fang> f) => f.map((x) => x.fischId).toSet().length;
int _gewaesser(List<Fang> f) =>
    f.map((x) => x.gewaesser).where((g) => g.isNotEmpty).toSet().length;
bool _laenger(List<Fang> f, String fisch, double cm) =>
    f.any((x) => x.fischId == fisch && (x.laengeCm ?? 0) >= cm);

/// Jahreszeit 0–3 (Frühling, Sommer, Herbst, Winter).
int _jahreszeit(DateTime d) => switch (d.month) {
      3 || 4 || 5 => 0,
      6 || 7 || 8 => 1,
      9 || 10 || 11 => 2,
      _ => 3,
    };

final alleAbzeichen = <Abzeichen>[
  Abzeichen('🎣', 'Petri Heil!', 'Ersten Fang eingetragen', (f) => f.isNotEmpty),
  Abzeichen('🔟', 'Fleißig', '10 Fänge', (f) => f.length >= 10),
  Abzeichen('🥈', 'Stammgast am Wasser', '50 Fänge', (f) => f.length >= 50),
  Abzeichen('🥇', 'Angel-Profi', '100 Fänge', (f) => f.length >= 100),
  Abzeichen('🐠', 'Artenkenner', '5 verschiedene Fischarten', (f) => _arten(f) >= 5),
  Abzeichen('🧠', 'Fischprofessor', '10 verschiedene Fischarten',
      (f) => _arten(f) >= 10),
  Abzeichen('🗺️', 'Entdecker', 'An 5 verschiedenen Gewässern gefangen',
      (f) => _gewaesser(f) >= 5),
  Abzeichen('🐊', 'Krokodil', 'Hecht ab 80 cm', (f) => _laenger(f, 'hecht', 80)),
  Abzeichen('🐋', 'Wallerbändiger', 'Waller ab 1 m', (f) => _laenger(f, 'wels', 100)),
  Abzeichen('🐷', 'Karpfenkönig', 'Karpfen ab 70 cm',
      (f) => _laenger(f, 'karpfen', 70)),
  Abzeichen('🌅', 'Frühaufsteher', 'Fang vor 6 Uhr früh',
      (f) => f.any((x) => x.datum.hour < 6)),
  Abzeichen('🦉', 'Nachteule', 'Fang nach 22 Uhr',
      (f) => f.any((x) => x.datum.hour >= 22)),
  Abzeichen('🤝', 'Fair Play', '10 Fische schonend zurückgesetzt',
      (f) => f.where((x) => x.zurueckgesetzt).length >= 10),
  Abzeichen('📸', 'Fotograf', '10 Fänge mit Foto',
      (f) => f.where((x) => x.hatFoto).length >= 10),
  Abzeichen('🍂', 'Ganzjahresangler', 'In allen 4 Jahreszeiten gefangen',
      (f) => f.map((x) => _jahreszeit(x.datum)).toSet().length == 4,
      premium: true),
  Abzeichen('🏆', 'Rekordjäger', 'Bei 5 Fischarten über 50 cm',
      (f) => f
              .where((x) => (x.laengeCm ?? 0) >= 50)
              .map((x) => x.fischId)
              .toSet()
              .length >=
          5,
      premium: true),
];
