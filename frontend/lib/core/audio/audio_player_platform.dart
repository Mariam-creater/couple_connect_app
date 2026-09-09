import 'dart:typed_data';

abstract class AudioPlayerPlatform {
  Future<void> playBytes(
    Uint8List bytes, {
    double speed = 1.0,
    double startProgress = 0.0,
    void Function(double progress)? onProgress,
    void Function()? onComplete,
  });

  Future<void> playUrl(
    String url, {
    double speed = 1.0,
    double startProgress = 0.0,
    void Function(double progress)? onProgress,
    void Function()? onComplete,
  });

  void pause();
  void stop();
  void setPlaybackRate(double speed);
  void seekTo(double progress);
  bool get isPlaying;
}
