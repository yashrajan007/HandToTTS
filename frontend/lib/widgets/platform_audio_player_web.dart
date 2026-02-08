import 'dart:typed_data';
import 'dart:convert';
import 'dart:html' as html;

/// Web audio player using the HTML5 AudioElement API.
class PlatformAudioPlayer {
  html.AudioElement? _element;

  bool get isInitialized => _element != null;

  void init(
    Uint8List data, {
    required void Function() onCanPlay,
    required void Function() onPlay,
    required void Function() onPause,
    required void Function() onEnded,
    required void Function(double currentTime, double duration) onTimeUpdate,
  }) {
    dispose();
    final b64 = base64Encode(data);
    _element = html.AudioElement()..src = 'data:audio/mpeg;base64,$b64';
    _element!.onCanPlay.listen((_) => onCanPlay());
    _element!.onPlay.listen((_) => onPlay());
    _element!.onPause.listen((_) => onPause());
    _element!.onEnded.listen((_) => onEnded());
    _element!.onTimeUpdate.listen((_) {
      final dur = _element!.duration;
      onTimeUpdate(
        _element!.currentTime.toDouble(),
        dur.isNaN ? 0.0 : dur.toDouble(),
      );
    });
  }

  void play() => _element?.play();
  void pause() => _element?.pause();

  void seekTo(double seconds) {
    if (_element != null) _element!.currentTime = seconds;
  }

  void setPlaybackRate(double rate) {
    if (_element != null) _element!.playbackRate = rate;
  }

  double get currentTime => _element?.currentTime.toDouble() ?? 0.0;

  double get duration {
    final d = _element?.duration ?? 0;
    return d.isNaN ? 0.0 : d.toDouble();
  }

  String get currentSrc => _element?.src ?? '';

  void dispose() {
    _element?.pause();
    _element?.src = '';
    _element = null;
  }
}

/// Downloads audio as MP3 via browser download (web only).
void webDownloadAudio(PlatformAudioPlayer player) {
  if (!player.isInitialized) return;
  try {
    final src = player.currentSrc;
    final parts = src.split(',');
    if (parts.length == 2) {
      final bytes = base64Decode(parts[1]);
      final blob = html.Blob([bytes], 'audio/mpeg');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'scanned_text.mp3')
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  } catch (_) {}
}
