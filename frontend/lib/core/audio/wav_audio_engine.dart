import 'dart:math';
import 'dart:typed_data';
import 'audio_player_platform.dart';
import 'audio_player_stub.dart'
    if (dart.library.html) 'audio_player_web.dart';

class WavAudioEngine {
  static const int sampleRate = 22050; // 22.05 kHz for high-efficiency voice note audio
  static const int numChannels = 1; // Mono channel
  static const int bitsPerSample = 16;
  static const int byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
  static const int blockAlign = numChannels * (bitsPerSample ~/ 8);

  static AudioPlayerPlatform createPlayer() => createAudioPlayer();

  /// Creates a standard 44-byte RIFF WAV Header
  static Uint8List createWavHeader(int dataLength) {
    final buffer = ByteData(44);

    // RIFF chunk descriptor
    buffer.setUint8(0, 0x52); // 'R'
    buffer.setUint8(1, 0x49); // 'I'
    buffer.setUint8(2, 0x46); // 'F'
    buffer.setUint8(3, 0x46); // 'F'
    buffer.setUint32(4, 36 + dataLength, Endian.little);
    buffer.setUint8(8, 0x57);  // 'W'
    buffer.setUint8(9, 0x41);  // 'A'
    buffer.setUint8(10, 0x56); // 'V'
    buffer.setUint8(11, 0x45); // 'E'

    // "fmt " sub-chunk
    buffer.setUint8(12, 0x66); // 'f'
    buffer.setUint8(13, 0x6D); // 'm'
    buffer.setUint8(14, 0x74); // 't'
    buffer.setUint8(15, 0x20); // ' '
    buffer.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    buffer.setUint16(20, 1, Endian.little);  // AudioFormat (1 = PCM)
    buffer.setUint16(22, numChannels, Endian.little);
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, byteRate, Endian.little);
    buffer.setUint16(32, blockAlign, Endian.little);
    buffer.setUint16(34, bitsPerSample, Endian.little);

    // "data" sub-chunk
    buffer.setUint8(36, 0x64); // 'd'
    buffer.setUint8(37, 0x61); // 'a'
    buffer.setUint8(38, 0x74); // 't'
    buffer.setUint8(39, 0x61); // 'a'
    buffer.setUint32(40, dataLength, Endian.little);

    return buffer.buffer.asUint8List();
  }

  /// Generates a genuine, decodable WAV audio byte stream with vocal formant tones & dynamics
  static Uint8List generateWavVoiceNote({
    required int durationSeconds,
    List<int>? waveform,
  }) {
    final effectiveSeconds = max(1, durationSeconds);
    final totalSamples = sampleRate * effectiveSeconds;
    final dataLength = totalSamples * blockAlign;

    final header = createWavHeader(dataLength);
    final pcmBuffer = ByteData(dataLength);

    // Base vocal formant melody frequencies (C4, E4, G4, A4, C5)
    final notes = [261.63, 329.63, 392.00, 440.00, 523.25, 440.00, 392.00, 329.63];
    final wave = (waveform != null && waveform.isNotEmpty)
        ? waveform
        : [14, 22, 28, 18, 25, 30, 19, 12];

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      
      // Select melody note according to time progression
      final noteIndex = ((t * 2).floor()) % notes.length;
      final freq = notes[noteIndex];

      // Waveform volume modulation (smooth amplitude)
      final waveIndex = ((t * wave.length / effectiveSeconds).floor()) % wave.length;
      final ampFactor = (wave[waveIndex] / 32.0).clamp(0.2, 1.0);

      // Vocal tone synthesis with fundamental frequency + 2nd & 3rd harmonics + warm vibrato
      final vibrato = sin(2 * pi * 5.0 * t) * 2.5;
      final fundamental = sin(2 * pi * (freq + vibrato) * t);
      final harmonic2 = 0.35 * sin(2 * pi * ((freq * 2) + vibrato) * t);
      final harmonic3 = 0.15 * sin(2 * pi * ((freq * 3) + vibrato) * t);

      // Soft envelope (fade-in at start, fade-out at end of each note segment)
      final segmentT = (t * 2) - (t * 2).floor();
      final envelope = sin(pi * segmentT.clamp(0.0, 1.0));

      // Combined 16-bit PCM sample (-32768 to 32767)
      final sampleVal = ((fundamental + harmonic2 + harmonic3) * 0.45 * ampFactor * envelope * 24000.0)
          .clamp(-32000.0, 32000.0)
          .toInt();

      pcmBuffer.setInt16(i * 2, sampleVal, Endian.little);
    }

    final fullBytes = Uint8List(44 + dataLength);
    fullBytes.setRange(0, 44, header);
    fullBytes.setRange(44, 44 + dataLength, pcmBuffer.buffer.asUint8List());

    return fullBytes;
  }
}
