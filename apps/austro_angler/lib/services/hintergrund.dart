import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:latlong2/latlong.dart';

import '../data/fische.dart';

import 'alle_gewaesser.dart';
import 'beisszeit.dart';
import 'fang_dienst.dart';
import 'konto.dart';
import 'speicher.dart';
import 'wecker.dart';
import 'wetter.dart';

/// Prüft beim Start, ob an geplanten Angeltagen Unwetter droht, und meldet
/// das einmal als Benachrichtigung.
Future<void> angeltageWarnen(Konto? konto) async {
  final uid = konto?.uid;
  if (uid == null) return;
  try {
    await alleGewaesser.laden();
    final treffen = await fangDienst.kommendeTreffen().first;
    final jetzt = DateTime.now();
    for (final t in treffen) {
      final meins = t.uid == uid || t.zusagen.containsKey(uid);
      if (!meins || t.zeit.difference(jetzt).inDays > 6) continue;
      final ort = alleGewaesser.zuName(t.gewaesser)?.position;
      if (ort == null) continue;
      final warnung = await unwetterWarnung(
          ort, t.zeit, t.zeit.add(const Duration(hours: 6)));
      if (warnung == null) continue;
      await Wecker.instanz.hinweisEinmal(
        'treffen-${t.id}-${t.zeit.millisecondsSinceEpoch}',
        '⚠️ Unwetter am Angeltag',
        '${t.gewaesser}, ${t.zeit.day}.${t.zeit.month}.: $warnung angesagt. '
            'Sicherheit geht vor!',
      );
    }
  } catch (e) {
    debugPrint('Warnungen: $e');
  }
}

/// Schreibt Beißzeit und Wetter für das Startbildschirm-Widget (Android).
Future<void> startbildschirmAktualisieren(Speicher speicher) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  try {
    final ort = speicher.heimatLat == null
        ? const LatLng(48.258, 13.040)
        : LatLng(speicher.heimatLat!, speicher.heimatLon!);
    final name = speicher.heimat.isEmpty ? 'Braunau' : speicher.heimatName;
    final wetter = await wetterLaden(ort);
    final tage = beisszeit(await stundenWetter(ort));
    final heute = tage.isEmpty ? null : tage.first;
    final (icon, beschreibung) = wetter.beschreibung;
    final zeilen = [
      if (heute != null) 'Beißzeit heute: ${heute.fische}',
      '$icon ${wetter.temperatur.round()} °C, $beschreibung',
      'Wind ${wetter.wind.round()} km/h',
    ];
    final heuteDatum = DateTime.now();
    for (final id in speicher.lieblingsfische.take(2)) {
      final f = fischById(id);
      final tageBis = f?.regel(speicher.bundesland).tageBisOffen(heuteDatum);
      if (f != null && tageBis != null) zeilen.add('⏳ ${f.name}: noch $tageBis Tage');
    }
    await HomeWidget.saveWidgetData<String>('titel', '🎣 $name');
    await HomeWidget.saveWidgetData<String>('text', zeilen.join('\n'));
    await HomeWidget.updateWidget(androidName: 'AnglerWidget');
  } catch (e) {
    debugPrint('Widget: $e');
  }
}
