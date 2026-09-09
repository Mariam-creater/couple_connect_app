import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'audio_player_platform.dart';

AudioPlayerPlatform createAudioPlayer() => AudioPlayerWeb();

class AudioPlayerWeb implements AudioPlayerPlatform {
  html.AudioElement? _audioElement;
  StreamSubscription? _timeUpdateSub;
  StreamSubscription? _endedSub;
  StreamSubscription? _errorSub;
  bool _isPlaying = false;
  double _currentSpeed = 1.0;

  @override
  bool get isPlaying => _isPlaying;

  double get playbackRate => _currentSpeed;

  void _cleanup() {
    _timeUpdateSub?.cancel();
    _endedSub?.cancel();
    _errorSub?.cancel();
    if (_audioElement != null) {
      _audioElement!.pause();
      _audioElement!.src = '';
      _audioElement = null;
    }
    _isPlaying = false;
  }

  @override
  Future<void> playBytes(
    Uint8List bytes, {
    double speed = 1.0,
    double startProgress = 0.0,
    void Function(double progress)? onProgress,
    void Function()? onComplete,
  }) async {
    _cleanup();
    _currentSpeed = speed;

    final base64String = base64Encode(bytes);
    final dataUri = 'data:audio/wav;base64,$base64String';

    await _playSource(dataUri, speed: speed, startProgress: startProgress, onProgress: onProgress, onComplete: onComplete);
  }

  @override
  Future<void> playUrl(
    String url, {
    double speed = 1.0,
    double startProgress = 0.0,
    void Function(double progress)? onProgress,
    void Function()? onComplete,
  }) async {
    _cleanup();
    _currentSpeed = speed;
    await _playSource(url, speed: speed, startProgress: startProgress, onProgress: onProgress, onComplete: onComplete);
  }

  Future<void> _playSource(
    String src, {
    required double speed,
    required double startProgress,
    void Function(double progress)? onProgress,
    void Function()? onComplete,
  }) async {
    try {
      final audio = html.AudioElement(src);
      _audioElement = audio;
      audio.playbackRate = speed;
      audio.preload = 'auto';

      _timeUpdateSub = audio.onTimeUpdate.listen((_) {
        if (audio.duration > 0 && !audio.duration.isNaN) {
          final progress = (audio.currentTime / audio.duration).clamp(0.0, 1.0);
          onProgress?.call(progress);
        }
      });

      _endedSub = audio.onEnded.listen((_) {
        _isPlaying = false;
        onProgress?.call(0.0);
        onComplete?.call();
      });

      _errorSub = audio.onError.listen((e) {
        _isPlaying = false;
        onComplete?.call();
      });

      if (startProgress > 0.0) {
        audio.onLoadedMetadata.first.then((_) {
          if (audio.duration > 0) {
            audio.currentTime = audio.duration * startProgress.clamp(0.0, 1.0);
          }
        });
      }

      await audio.play();
      _isPlaying = true;
    } catch (e) {
      _isPlaying = false;
      onComplete?.call();
    }
  }

  @override
  void pause() {
    _audioElement?.pause();
    _isPlaying = false;
  }

  @override
  void stop() {
    _cleanup();
  }

  @override
  void setPlaybackRate(double speed) {
    _currentSpeed = speed;
    if (_audioElement != null) {
      _audioElement!.playbackRate = speed;
    }
  }

  @override
  void seekTo(double progress) {
    if (_audioElement != null && _audioElement!.duration > 0) {
      _audioElement!.currentTime = _audioElement!.duration * progress.clamp(0.0, 1.0);
    }
  }
}
