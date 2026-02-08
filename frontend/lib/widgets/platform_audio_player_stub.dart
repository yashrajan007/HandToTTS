import 'dart:typed_data';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

/// Native audio player using just_audio for Android/iOS/desktop.
class PlatformAudioPlayer {
  final AudioPlayer _player = AudioPlayer();
  bool _initialized = false;
  String? _tempFilePath;

  bool get isInitialized => _initialized;

  void init(
    Uint8List data, {
    required void Function() onCanPlay,
    required void Function() onPlay,
    required void Function() onPause,
    required void Function() onEnded,
    required void Function(double currentTime, double duration) onTimeUpdate,
  }) async {
    dispose();
    try {
      // Write audio bytes to a temp file
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/tts_audio_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await file.writeAsBytes(data);
      _tempFilePath = file.path;

      // Load audio
      await _player.setFilePath(file.path);
      _initialized = true;
      onCanPlay();

      // Listen for state changes
      _player.playerStateStream.listen((state) {
        if (state.playing) {
          onPlay();
        } else {
          onPause();
        }
        if (state.processingState == ProcessingState.completed) {
          onEnded();
        }
      });

      // Listen for position updates
      _player.positionStream.listen((pos) {
        final dur = _player.duration ?? Duration.zero;
        onTimeUpdate(
          pos.inMilliseconds / 1000.0,
          dur.inMilliseconds / 1000.0,
        );
      });
    } catch (e) {
      _initialized = false;
    }
  }

  void play() => _player.play();
  void pause() => _player.pause();

  void seekTo(double seconds) {
    _player.seek(Duration(milliseconds: (seconds * 1000).toInt()));
  }

  void setPlaybackRate(double rate) {
    _player.setSpeed(rate);
  }

  double get currentTime => (_player.position.inMilliseconds / 1000.0);

  double get duration {
    final d = _player.duration;
    return d == null ? 0 : d.inMilliseconds / 1000.0;
  }

  String get currentSrc => _tempFilePath ?? '';

  void dispose() {
    _player.stop();
    _initialized = false;
    // Clean up temp file
    if (_tempFilePath != null) {
      try {
        File(_tempFilePath!).deleteSync();
      } catch (_) {}
      _tempFilePath = null;
    }
  }
}

/// No-op on non-web platforms (download not applicable).
void webDownloadAudio(PlatformAudioPlayer player) {}
