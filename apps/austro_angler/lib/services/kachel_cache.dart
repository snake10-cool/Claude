import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Offline-Karte: Jede angesehene Kartenkachel wird auf dem Gerät gespeichert
/// und ohne Netz wieder angezeigt. (Massen-Download verbietet die
/// OpenStreetMap-Nutzungsrichtlinie – darum nur, was man sich angesehen hat.)
class KachelCache {
  KachelCache._();

  static Directory? _ordner;

  static Future<Directory> ordner() async {
    if (_ordner != null) return _ordner!;
    final basis = await getApplicationSupportDirectory();
    _ordner = Directory('${basis.path}/kacheln');
    await _ordner!.create(recursive: true);
    return _ordner!;
  }

  static Future<File> datei(TileCoordinates c) async =>
      File('${(await ordner()).path}/${c.z}_${c.x}_${c.y}.png');

  /// Belegter Speicher in Byte und Anzahl Kacheln.
  static Future<(int, int)> groesse() async {
    var bytes = 0, anzahl = 0;
    await for (final e in (await ordner()).list()) {
      if (e is File) {
        bytes += await e.length();
        anzahl++;
      }
    }
    return (bytes, anzahl);
  }

  static Future<void> leeren() async {
    final o = await ordner();
    if (await o.exists()) await o.delete(recursive: true);
    _ordner = null;
  }
}

class CacheTileProvider extends TileProvider {
  CacheTileProvider()
      : super(headers: {
          'User-Agent': 'AustroAngler/1.0 (com.snake10.austroangler)',
        });

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      _KachelBild(getTileUrl(coordinates, options), coordinates, headers);
}

class _KachelBild extends ImageProvider<_KachelBild> {
  const _KachelBild(this.url, this.koordinaten, this.headers);

  final String url;
  final TileCoordinates koordinaten;
  final Map<String, String> headers;

  /// Nach 30 Tagen wird eine Kachel neu geladen, wenn Netz da ist.
  static const _alter = Duration(days: 30);

  @override
  Future<_KachelBild> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(_KachelBild key, ImageDecoderCallback decode) =>
      MultiFrameImageStreamCompleter(codec: _laden(decode), scale: 1);

  Future<ui.Codec> _laden(ImageDecoderCallback decode) async {
    final datei = await KachelCache.datei(koordinaten);
    Uint8List? bytes;
    final vorhanden = await datei.exists();
    if (vorhanden) {
      bytes = await datei.readAsBytes();
      final frisch =
          DateTime.now().difference(await datei.lastModified()) < _alter;
      if (frisch) return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
    }
    try {
      final antwort = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));
      if (antwort.statusCode == 200 && antwort.bodyBytes.isNotEmpty) {
        bytes = antwort.bodyBytes;
        await datei.writeAsBytes(bytes, flush: false);
      }
    } catch (_) {
      // Offline: alte Kachel nehmen, falls es eine gibt.
    }
    if (bytes == null) throw StateError('Kachel nicht verfügbar: $url');
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) => other is _KachelBild && other.url == url;

  @override
  int get hashCode => url.hashCode;
}

/// Gemeinsamer Provider für alle Karten der App.
final kachelProvider = CacheTileProvider();
