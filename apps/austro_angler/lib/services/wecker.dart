import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_daten;
import 'package:timezone/timezone.dart' as tz;

import '../data/fische.dart';
import '../models/bundesland.dart';
import '../models/fisch.dart';

/// Schonzeit-Wecker: Erinnerung am Morgen, wenn die Schonzeit eines Fisches
/// endet. Funktioniert am Handy (Android), am PC nicht.
class Wecker {
  Wecker._();

  static final instanz = Wecker._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _bereit = false;

  static bool get unterstuetzt =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> _starten() async {
    if (_bereit || !unterstuetzt) return;
    tz_daten.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Vienna'));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _bereit = true;
  }

  /// Sofort-Hinweis (z. B. Unwetter am geplanten Angeltag). Jeder
  /// [schluessel] wird nur einmal gemeldet.
  Future<void> hinweisEinmal(String schluessel, String titel, String text) async {
    if (!unterstuetzt) return;
    final p = await SharedPreferences.getInstance();
    final gemeldet = p.getStringList('gemeldet') ?? const [];
    if (gemeldet.contains(schluessel)) return;
    await _starten();
    await _plugin.show(
      id: 5000 + schluessel.hashCode % 1000,
      title: titel,
      body: text,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'warnungen',
          'Wetter-Warnungen',
          channelDescription: 'Unwetter an geplanten Angeltagen',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
    await p.setStringList(
        'gemeldet', [...gemeldet.reversed.take(50).toList().reversed, schluessel]);
  }

  Future<Set<String>> fische() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList('wecker') ?? const []).toSet();
  }

  /// Schaltet den Wecker für einen Fisch um. Gibt den neuen Zustand zurück.
  Future<bool> umschalten(String fischId, Bundesland land) async {
    final p = await SharedPreferences.getInstance();
    final aktiv = await fische();
    final an = !aktiv.contains(fischId);
    if (an) {
      aktiv.add(fischId);
      await _starten();
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else {
      aktiv.remove(fischId);
    }
    await p.setStringList('wecker', aktiv.toList());
    await alleEinplanen(land);
    return an;
  }

  // ── Lizenzen ──

  Future<List<Lizenz>> lizenzen() async {
    final p = await SharedPreferences.getInstance();
    final roh = p.getString('lizenzen');
    if (roh == null) return [];
    return [
      for (final j in jsonDecode(roh) as List)
        Lizenz(j['name'] as String, DateTime.parse(j['ablauf'] as String)),
    ]..sort((a, b) => a.ablauf.compareTo(b.ablauf));
  }

  Future<void> lizenzenSpeichern(List<Lizenz> liste, Bundesland land) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        'lizenzen',
        jsonEncode([
          for (final l in liste)
            {'name': l.name, 'ablauf': l.ablauf.toIso8601String()},
        ]));
    if (unterstuetzt && liste.isNotEmpty) {
      await _starten();
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
    await alleEinplanen(land);
  }

  /// Plant alle Erinnerungen (Schonzeiten und Lizenzen) neu.
  Future<void> alleEinplanen(Bundesland land) async {
    if (!unterstuetzt) return;
    await _starten();
    await _plugin.cancelAll();
    final jetzt = DateTime.now();
    var id = 0;
    for (final l in await lizenzen()) {
      for (final (tageVorher, text) in [
        (14, 'läuft in 2 Wochen ab'),
        (1, 'läuft morgen ab'),
      ]) {
        final tag = l.ablauf.subtract(Duration(days: tageVorher));
        final termin = tz.TZDateTime(tz.local, tag.year, tag.month, tag.day, 9);
        if (termin.isBefore(tz.TZDateTime.now(tz.local))) continue;
        await _plugin.zonedSchedule(
          id: 1000 + id++,
          title: '🪪 ${l.name} $text',
          body: 'Gültig bis ${l.ablauf.day}.${l.ablauf.month}.${l.ablauf.year} '
              '– rechtzeitig verlängern!',
          scheduledDate: termin,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'lizenzen',
              'Lizenz-Erinnerung',
              channelDescription: 'Erinnert vor dem Ablauf von Lizenzen',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
    id = 0;
    for (final fischId in await fische()) {
      final fisch = fischById(fischId);
      final ende = fisch == null ? null : _naechstesEnde(fisch.regel(land), jetzt);
      if (ende == null) continue;
      final termin = tz.TZDateTime(tz.local, ende.year, ende.month, ende.day, 8);
      await _plugin.zonedSchedule(
        id: id++,
        title: '🎣 ${fisch!.name} ist wieder offen!',
        body: 'Die Schonzeit in ${land.name} ist vorbei. Petri Heil! '
            '(Brittelmaß: ${fisch.regel(land).mindestmassText})',
        scheduledDate: termin,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'schonzeit',
            'Schonzeit-Wecker',
            channelDescription: 'Erinnert, wenn eine Schonzeit endet',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  /// Erster Tag nach dem Ende der nächsten Schonzeit (oder null).
  static DateTime? _naechstesEnde(Regel regel, DateTime ab) {
    if (regel.von == null || regel.bis == null) return null;
    for (var jahr = ab.year; jahr <= ab.year + 1; jahr++) {
      final ende = DateTime(jahr, regel.bis!.monat, regel.bis!.tag)
          .add(const Duration(days: 1));
      if (ende.isAfter(ab)) return ende;
    }
    return null;
  }
}

class Lizenz {
  const Lizenz(this.name, this.ablauf);

  final String name;
  final DateTime ablauf;
}
