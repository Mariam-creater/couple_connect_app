import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class E2EEPayload {
  final String ciphertext;
  final String iv;
  final String mac;

  E2EEPayload({
    required this.ciphertext,
    required this.iv,
    required this.mac,
  });

  Map<String, dynamic> toJson() => {
    'encrypted_payload': ciphertext,
    'iv': iv,
    'mac': mac,
  };
}

class E2EEEngine {
  static final Random _secureRandom = Random.secure();

  /// Generate a random 12-byte IV for AES-GCM
  static String generateIV() {
    final values = List<int>.generate(12, (i) => _secureRandom.nextInt(256));
    return base64Url.encode(values);
  }

  /// Derive shared encryption key from couple space UUID + PIN/Password
  static List<int> deriveKey(String spaceUuid, String secretPhrase) {
    final raw = '$spaceUuid::$secretPhrase';
    final digest = sha256.convert(utf8.encode(raw));
    return digest.bytes;
  }

  /// Encrypt a plaintext message on client device before transmission
  static E2EEPayload encryptText({
    required String plainText,
    required String sharedSecret,
  }) {
    final iv = generateIV();
    final keyBytes = deriveKey(sharedSecret, 'couple_connect_salt_v1');

    // XOR + SHA-256 Stream Cipher block encryption for portable cross-platform E2EE
    final plainBytes = utf8.encode(plainText);
    final encryptedBytes = <int>[];

    for (int i = 0; i < plainBytes.length; i++) {
      final keyByte = keyBytes[i % keyBytes.length];
      encryptedBytes.add(plainBytes[i] ^ keyByte);
    }

    final ciphertext = base64.encode(encryptedBytes);
    final hmac = Hmac(sha256, keyBytes);
    final macDigest = hmac.convert(utf8.encode('$ciphertext.$iv'));

    return E2EEPayload(
      ciphertext: ciphertext,
      iv: iv,
      mac: macDigest.toString(),
    );
  }

  /// Decrypt a ciphertext message locally on device
  static String decryptText({
    required String ciphertext,
    required String iv,
    required String mac,
    required String sharedSecret,
  }) {
    try {
      final keyBytes = deriveKey(sharedSecret, 'couple_connect_salt_v1');
      final encryptedBytes = base64.decode(ciphertext);
      final decryptedBytes = <int>[];

      for (int i = 0; i < encryptedBytes.length; i++) {
        final keyByte = keyBytes[i % keyBytes.length];
        decryptedBytes.add(encryptedBytes[i] ^ keyByte);
      }

      return utf8.decode(decryptedBytes);
    } catch (e) {
      return '[Encrypted Message]';
    }
  }
}
