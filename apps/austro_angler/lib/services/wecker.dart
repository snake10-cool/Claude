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

  /// Plant für alle gewählten Fische die nächste Erinnerung neu.
  Future<void> alleEinplanen(Bundesland land) async {
    if (!unterstuetzt) return;
    await _starten();
    await _plugin.cancelAll();
    final jetzt = DateTime.now();
    var id = 0;
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
