import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logik/spiel.dart';

/// Hält den Spielstand, lässt die Zeit laufen und speichert regelmäßig.
class SpielDienst extends ChangeNotifier with WidgetsBindingObserver {
  static const _schluessel = 'spielstand';

  Spiel _spiel = Spiel(Spielstand());
  Spiel get s => _spiel;
  Spielstand get stand => _spiel.stand;

  Timer? _takt;
  DateTime _letzterTick = DateTime.now();
  int _seitSpeichern = 0;
  final _zufall = Random();

  /// Offline-Ertrag, der beim Start angezeigt werden soll.
  (double, Duration)? offlineMeldung;

  /// Neue Erfolge für eine kurze Meldung.
  final erfolgeNeu = StreamController<Erfolg>.broadcast();

  /// Glücksklumpen: Position (0–1) und bis wann er sichtbar ist.
  (Offset, DateTime)? kluempchen;
  DateTime _naechsterKlumpen = DateTime.now().add(const Duration(seconds: 45));

  Future<void> laden() async {
    final p = await SharedPreferences.getInstance();
    final text = p.getString(_schluessel);
    if (text != null) {
      try {
        _spiel = Spiel(
          Spielstand.ausJson(jsonDecode(text) as Map<String, dynamic>),
        );
      } catch (_) {
        // Kaputter Spielstand: lieber neu anfangen als abstürzen.
      }
    }
    _offlineGutschreiben();
    WidgetsBinding.instance.addObserver(this);
    _starten();
  }

  void _offlineGutschreiben() {
    final jetzt = DateTime.now();
    final (gold, zeit) = s.offlineErtrag(jetzt);
    if (gold >= 1 && zeit.inMinutes >= 1) {
      s.bonusGutschreiben(gold);
      offlineMeldung = (gold, zeit);
    }
    stand.letzterBesuch = jetzt;
  }

  void _starten() {
    _takt?.cancel();
    _letzterTick = DateTime.now();
    _takt = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
  }

  void _tick() {
    final jetzt = DateTime.now();
    s.tick(jetzt.difference(_letzterTick), jetzt);
    _letzterTick = jetzt;
    stand.letzterBesuch = jetzt;
    if (kluempchen != null && jetzt.isAfter(kluempchen!.$2)) kluempchen = null;
    if (kluempchen == null && jetzt.isAfter(_naechsterKlumpen)) {
      kluempchen = (
        Offset(
          0.15 + _zufall.nextDouble() * 0.7,
          0.15 + _zufall.nextDouble() * 0.6,
        ),
        jetzt.add(const Duration(seconds: 12)),
      );
      _naechsterKlumpen = jetzt.add(
        Duration(seconds: 60 + _zufall.nextInt(90)),
      );
    }
    if (++_seitSpeichern >= 50) {
      _seitSpeichern = 0;
      for (final e in s.erfolgePruefen()) {
        erfolgeNeu.add(e);
      }
      speichern();
    }
    notifyListeners();
  }

  Future<void> speichern() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_schluessel, jsonEncode(stand.toJson()));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _takt?.cancel();
      stand.letzterBesuch = DateTime.now();
      speichern();
    } else if (state == AppLifecycleState.resumed) {
      _offlineGutschreiben();
      _starten();
      notifyListeners();
    }
  }

  // ───────────────────────── Aktionen ─────────────────────────

  double tippen() {
    final w = s.tippen();
    notifyListeners();
    return w;
  }

  /// Glücksklumpen erwischt: 7 × Produktion für 30 s (mind. 50 Tipps).
  double klumpenFangen() {
    kluempchen = null;
    final gold = max(s.tippWert() * 50, s.proSekunde() * 30 * 7);
    s.bonusGutschreiben(gold);
    notifyListeners();
    return gold;
  }

  void geaendert() {
    for (final e in s.erfolgePruefen()) {
      erfolgeNeu.add(e);
    }
    notifyListeners();
    speichern();
  }

  /// Video angesehen: doppelte Produktion für 10 Minuten (verlängert).
  void boostStarten() {
    final jetzt = DateTime.now();
    final ab = s.boostAktiv(jetzt) ? stand.boostBis! : jetzt;
    stand.boostBis = ab.add(const Duration(minutes: 10));
    geaendert();
  }

  /// Gekauftes Booster-Paket gutschreiben.
  void paketGutschreiben(String id) {
    if (id == 'goldsack') {
      s.bonusGutschreiben(max(10000, s.proSekunde() * 3600 * 2));
    } else if (id == 'glitzerpaket') {
      stand.glitzer += 5;
    }
    geaendert();
  }

  Future<void> zuruecksetzen() async {
    _spiel = Spiel(Spielstand());
    await speichern();
    notifyListeners();
  }

  @override
  void dispose() {
    _takt?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    erfolgeNeu.close();
    super.dispose();
  }
}
