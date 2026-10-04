import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../services/fang_dienst.dart';

/// Videos gibt es nur am Handy (Aufnehmen und Abspielen).
bool get videoMoeglich =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// Höchstens so lang und so groß (nach dem Komprimieren).
const videoMaxSekunden = 10;
const videoMaxBytes = 3 * 1024 * 1024;

/// Nimmt ein Video auf oder wählt eines aus und komprimiert es.
/// Gibt die Bytes zurück oder wirft eine verständliche Fehlermeldung.
Future<Uint8List?> videoWaehlen(ImageSource quelle) async {
  final datei = await ImagePicker().pickVideo(
    source: quelle,
    maxDuration: const Duration(seconds: videoMaxSekunden),
  );
  if (datei == null) return null;
  final info = await VideoCompress.compressVideo(
    datei.path,
    quality: VideoQuality.LowQuality,
    duration: videoMaxSekunden,
    includeAudio: true,
    frameRate: 24,
  );
  final pfad = info?.path;
  if (pfad == null) throw Exception('Video konnte nicht verarbeitet werden.');
  final bytes = await File(pfad).readAsBytes();
  if (bytes.length > videoMaxBytes) {
    throw Exception('Video ist zu groß – bitte kürzer aufnehmen '
        '(max. $videoMaxSekunden Sekunden).');
  }
  return bytes;
}

/// Spielt ein Video aus Bytes ab (z. B. Vorschau im Formular).
class VideoAbspieler extends StatefulWidget {
  const VideoAbspieler({super.key, this.bytes, this.fangId});

  /// Entweder direkt die Bytes …
  final Uint8List? bytes;

  /// … oder die Fang-ID, dann wird das Video aus dem Internet geladen.
  final String? fangId;

  @override
  State<VideoAbspieler> createState() => _VideoAbspielerState();
}

class _VideoAbspielerState extends State<VideoAbspieler> {
  VideoPlayerController? _player;
  Object? _fehler;

  @override
  void initState() {
    super.initState();
    _starten();
  }

  Future<void> _starten() async {
    if (!videoMoeglich) return;
    try {
      final bytes = widget.bytes ??
          await fangDienst.videoLaden(widget.fangId!) ??
          (throw Exception('Video nicht gefunden'));
      final ordner = await getTemporaryDirectory();
      final datei = File('${ordner.path}/video_'
          '${widget.fangId ?? bytes.length}.mp4');
      await datei.writeAsBytes(bytes, flush: true);
      final player = VideoPlayerController.file(datei);
      await player.initialize();
      await player.setLooping(true);
      if (!mounted) {
        await player.dispose();
        return;
      }
      setState(() => _player = player);
      await player.play();
    } catch (e) {
      if (mounted) setState(() => _fehler = e);
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!videoMoeglich) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('🎬 Videos kannst du in der Handy-App ansehen.'),
      );
    }
    if (_fehler != null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Video konnte nicht geladen werden.'),
      );
    }
    final p = _player;
    if (p == null) {
      return const SizedBox(
          height: 180, child: Center(child: CircularProgressIndicator()));
    }
    return GestureDetector(
      onTap: () => setState(() => p.value.isPlaying ? p.pause() : p.play()),
      child: AspectRatio(
        aspectRatio: p.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(p),
            if (!p.value.isPlaying)
              const Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoProgressIndicator(p, allowScrubbing: true),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vollbild-Ansicht für das Video eines Fangs.
class VideoScreen extends StatelessWidget {
  const VideoScreen(this.fangId, {super.key, this.titel = 'Video'});

  final String fangId;
  final String titel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(titel),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(child: VideoAbspieler(fangId: fangId)),
    );
  }
}
