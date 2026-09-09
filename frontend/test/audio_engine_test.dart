import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:couple_connect_frontend/core/audio/wav_audio_engine.dart';

void main() {
  group('WavAudioEngine Voice Recording & Playback Tests', () {
    test('createWavHeader produces valid 44-byte RIFF WAVE header', () {
      final header = WavAudioEngine.createWavHeader(1000);
      expect(header.length, 44);

      // Verify 'RIFF' signature (ASCII: 0x52, 0x49, 0x46, 0x46)
      expect(utf8.decode(header.sublist(0, 4)), 'RIFF');

      // Verify 'WAVE' format signature
      expect(utf8.decode(header.sublist(8, 12)), 'WAVE');

      // Verify 'fmt ' subchunk
      expect(utf8.decode(header.sublist(12, 16)), 'fmt ');

      // Verify 'data' subchunk
      expect(utf8.decode(header.sublist(36, 40)), 'data');
    });

    test('generateWavVoiceNote produces non-empty playable audio bytes', () {
      final duration = 3;
      final wavBytes = WavAudioEngine.generateWavVoiceNote(
        durationSeconds: duration,
        waveform: [10, 25, 30, 15, 20],
      );

      expect(wavBytes.isNotEmpty, isTrue);
      expect(wavBytes.length > 44, isTrue);

      // Verify RIFF and WAVE signatures
      expect(utf8.decode(wavBytes.sublist(0, 4)), 'RIFF');
      expect(utf8.decode(wavBytes.sublist(8, 12)), 'WAVE');

      // Check byte length matches 44 bytes header + sampleRate * duration * 2 bytes
      final expectedDataLength = WavAudioEngine.sampleRate * duration * 2;
      expect(wavBytes.length, 44 + expectedDataLength);

      // Verify PCM audio samples are not silent (non-zero bytes present)
      final nonZeroSamples = wavBytes.skip(44).where((b) => b != 0).length;
      expect(nonZeroSamples > 1000, isTrue);
    });

    test('createPlayer returns working AudioPlayerPlatform instance', () {
      final player = WavAudioEngine.createPlayer();
      expect(player.isPlaying, isFalse);
    });
  });
}
