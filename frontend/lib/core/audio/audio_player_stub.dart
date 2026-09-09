import 'dart:async';
import 'dart:typed_data';
import 'audio_player_platform.dart';

AudioPlayerPlatform createAudioPlayer() => AudioPlayerStub();

class AudioPlayerStub implements AudioPlayerPlatform {
  Timer? _timer;
  bool _isPlaying = false;
  double _currentProgress = 0.0;
  double _currentSpeed = 1.0;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Future<void> playBytes(
    Uint8List bytes, {
    double speed = 1.0,
    double startProgress = 0.0,
    void Function(double progress)? onProgress,
    void Function()? onComplete,
  }) async {
    _playSimulated(speed: speed, startProgress: startProgress, onProgress: onProgress, onComplete: onComplete);
  }

  @override
  Future<void> playUrl(
    String url, {
    double speed = 1.0,
    double startProgress = 0.0,
    void Function(double progress)? onProgress,
    void Function()? onComplete,
  }) async {
    _playSimulated(speed: speed, startProgress: startProgress, onProgress: onProgress, onComplete: onComplete);
  }

  void _playSimulated({
    required double speed,
    required double startProgress,
    void Function(double progress)? onProgress,
    void Function()? onComplete,
  }) {
    _timer?.cancel();
    _isPlaying = true;
    _currentProgress = startProgress;
    _currentSpeed = speed;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _currentProgress += (0.02 * _currentSpeed);
      if (_currentProgress >= 1.0) {
        _currentProgress = 0.0;
        _isPlaying = false;
        timer.cancel();
        onProgress?.call(0.0);
        onComplete?.call();
      } else {
        onProgress?.call(_currentProgress);
      }
    });
  }

  @override
  void pause() {
    _timer?.cancel();
    _isPlaying = false;
  }

  @override
  void stop() {
    _timer?.cancel();
    _isPlaying = false;
    _currentProgress = 0.0;
  }

  @override
  void setPlaybackRate(double speed) {
    _currentSpeed = speed;
  }

  @override
  void seekTo(double progress) {
    _currentProgress = progress.clamp(0.0, 1.0);
  }
}
