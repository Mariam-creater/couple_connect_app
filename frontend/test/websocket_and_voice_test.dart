import 'package:flutter_test/flutter_test.dart';
import 'package:couple_connect_frontend/presentation/providers/app_state.dart';
import 'package:couple_connect_frontend/data/models/models.dart';
import 'package:couple_connect_frontend/core/crypto/e2ee_engine.dart';

void main() {
  group('WebSocket & Voice Real-time Tests', () {
    test('AppState handles onRealtimeMessageReceived and decrypts E2EE voice notes', () {
      final appState = AppState();
      appState.currentUser = UserModel(
        id: 1,
        name: 'Saam',
        username: 'saam',
        email: 'saam@example.com',
        coupleId: 'CP-SAAM-01',
        relationshipStatus: 'connected',
      );
      appState.coupleSpace = CoupleSpaceModel(
        id: 101,
        uuid: 'test-secret-uuid-101',
        spaceName: 'Our Love Space',
        themePreset: 'rose_gold',
        connectedAt: DateTime.now(),
        userOne: UserModel(id: 1, name: 'Saam', username: 'saam', email: 'saam@example.com', coupleId: 'CP-01', relationshipStatus: 'connected'),
        userTwo: UserModel(id: 2, name: 'Boqran', username: 'boqran', email: 'boqran@example.com', coupleId: 'CP-02', relationshipStatus: 'connected'),
      );

      // Encrypt voice note message with shared secret
      final plainText = 'Voice note (14.2s)';
      final encrypted = E2EEEngine.encryptText(
        plainText: plainText,
        sharedSecret: appState.sharedSecret,
      );

      final realtimePayload = {
        'id': 999,
        'message_uuid': 'msg-uuid-999',
        'couple_space_id': 101,
        'sender_id': 2,
        'type': 'voice',
        'encrypted_payload': encrypted.ciphertext,
        'iv': encrypted.iv,
        'mac': encrypted.mac,
        'status': 'sent',
        'is_pinned': false,
        'is_edited': false,
        'created_at': DateTime.now().toIso8601String(),
        'metadata': {
          'file_path': 'https://media.coupleconnect.app/chat_voices/101/voice_999.m4a',
          'file_name': 'voice_999.m4a',
          'mime_type': 'audio/mp4',
          'duration_seconds': 14.2,
        },
        'sender': {
          'id': 2,
          'name': 'Boqran',
          'username': 'boqran',
          'avatar_url': null,
        },
        'attachments': [],
        'reactions': [],
      };

      // Receive real-time event
      appState.onRealtimeMessageReceived(realtimePayload);

      expect(appState.messages.length, 1);
      expect(appState.messages.first.id, 999);
      expect(appState.messages.first.type, 'voice');
      expect(appState.messages.first.decryptedText, 'Voice note (14.2s)');
      expect(appState.messages.first.metadata?['file_path'], 'https://media.coupleconnect.app/chat_voices/101/voice_999.m4a');
      expect(appState.messages.first.metadata?['duration_seconds'], 14.2);
    });

    test('AppState handles onRealtimeReactionReceived and updates message model', () {
      final appState = AppState();
      final message = MessageModel(
        id: 500,
        messageUuid: 'msg-500',
        senderId: 1,
        type: 'text',
        encryptedPayload: 'abc',
        iv: 'def',
        status: 'sent',
        createdAt: DateTime.now(),
        reactions: [],
      );
      appState.messages = [message];

      // Add reaction
      appState.onRealtimeReactionReceived({
        'message_id': 500,
        'user_id': 2,
        'reaction': '❤️',
        'is_removed': false,
      });

      expect(appState.messages.first.reactions.length, 1);
      expect(appState.messages.first.reactions.first.reaction, '❤️');

      // Remove reaction
      appState.onRealtimeReactionReceived({
        'message_id': 500,
        'user_id': 2,
        'reaction': '❤️',
        'is_removed': true,
      });

      expect(appState.messages.first.reactions.length, 0);
    });
  });
}
