import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_daten;
import 'package:timezone/timezone.dart' as tz;

import 'speicher.dart';

/// Sanfte Lese-Erinnerung – bewusst nicht nervig:
/// • aus, bis man sie selbst einschaltet
/// • höchstens einmal am Tag, zur Wunschzeit
/// • keine Erinnerung an Tagen, an denen schon gelesen wurde
/// • nur für die nächsten 7 Tage geplant: Wer die App eine Woche nicht
///   öffnet, bekommt danach gar keine Erinnerungen mehr.
class Erinnerung {
  Erinnerung._();

  static final instanz = Erinnerung._();

  static const _tage = 7;
  static const _texte = [
    'Lust auf ein paar Seiten? 📖',
    'Dein Buch wartet schon auf dich 🐛',
    'Zeit für eine kleine Lesepause? ☕',
    'Wie geht\'s in deiner Geschichte weiter? ✨',
    'Ein Kapitel vor dem Schlafen? 🌙',
  ];

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _bereit = false;

  static bool get unterstuetzt => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> _starten() async {
    if (_bereit || !unterstuetzt) return;
    tz_daten.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Vienna'));
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    );
    _bereit = true;
  }

  static Future<(bool, int, int)> einstellungen() async {
    final p = await SharedPreferences.getInstance();
    return (p.getBool('erinnerung') ?? false, p.getInt('erinnerungStunde') ?? 19, p.getInt('erinnerungMinute') ?? 0);
  }

  Future<void> setzen(Speicher speicher, {required bool an, required int stunde, required int minute}) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('erinnerung', an);
    await p.setInt('erinnerungStunde', stunde);
    await p.setInt('erinnerungMinute', minute);
    if (an && unterstuetzt) {
      await _starten();
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
    await planen(speicher);
  }

  /// Plant die nächsten 7 Tage neu (beim App-Start und nach jedem Lese-Tag).
  Future<void> planen(Speicher speicher) async {
    if (!unterstuetzt) return;
    final (an, stunde, minute) = await einstellungen();
    await _starten();
    await _plugin.cancelAll();
    if (!an) return;
    final jetzt = tz.TZDateTime.now(tz.local);
    for (var i = 0; i < _tage; i++) {
      final tag = jetzt.add(Duration(days: i));
      final termin = tz.TZDateTime(tz.local, tag.year, tag.month, tag.day, stunde, minute);
      if (termin.isBefore(jetzt)) continue;
      if (i == 0 && speicher.heuteGelesen) continue;
      await _plugin.zonedSchedule(
        id: 100 + i,
        title: _texte[(tag.day + tag.month) % _texte.length],
        body: 'Schon 10 Minuten zählen. Wenn heute nicht, dann eben morgen 🙂',
        scheduledDate: termin,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'lesen',
            'Lese-Erinnerung',
            channelDescription: 'Eine freundliche Erinnerung am Tag – nur wenn du sie eingeschaltet hast',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
