import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../constants/api_constants.dart';
import 'secure_token_storage.dart';

typedef RealtimeMessageCallback = void Function(Map<String, dynamic> messageData);
typedef RealtimeReactionCallback = void Function(Map<String, dynamic> reactionData);
typedef RealtimeReadCallback = void Function(Map<String, dynamic> readData);

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  bool _isInitialized = false;
  bool _isConnected = false;
  int? _subscribedSpaceId;

  RealtimeMessageCallback? onMessageReceived;
  RealtimeReactionCallback? onReactionReceived;
  RealtimeReadCallback? onReadReceived;

  bool get isConnected => _isConnected;
  int? get subscribedSpaceId => _subscribedSpaceId;

  /// Initialize and connect to Pusher WebSocket server over secure WSS
  Future<void> connect({
    String? appKey,
    String? cluster,
    String? authEndpoint,
  }) async {
    try {
      final token = await SecureTokenStorage().getToken();
      final endpoint = authEndpoint ?? ApiConstants.broadcastAuth;
      final key = appKey ?? ApiConstants.pusherAppKey;
      final clusterName = cluster ?? ApiConstants.pusherCluster;

      if (!_isInitialized) {
        await _pusher.init(
          apiKey: key,
          cluster: clusterName,
          useTLS: true,
          authEndpoint: endpoint,
          authParams: {
            'headers': {
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          },
          onConnectionStateChange: (currentState, previousState) {
            debugPrint('WebSocket connection state: $previousState -> $currentState');
            _isConnected = (currentState.toLowerCase() == 'connected');
          },
          onError: (message, code, error) {
            debugPrint('WebSocket error [$code]: $message ($error)');
          },
          onSubscriptionSucceeded: (channelName, data) {
            debugPrint('WebSocket subscribed successfully: $channelName');
          },
          onEvent: _onEvent,
          onSubscriptionError: (message, error) {
            debugPrint('WebSocket subscription error: $message ($error)');
          },
          onDecryptionFailure: (event, reason) {
            debugPrint('WebSocket decryption failure: $reason');
          },
        );
        _isInitialized = true;
      }

      await _pusher.connect();
      _isConnected = true;
      debugPrint('WebSocketService: Connected to WebSockets');
    } catch (e) {
      debugPrint('WebSocketService: Connection error: $e');
      _isConnected = false;
    }
  }

  /// Subscribe to private couple space channel: private-couple.{spaceId}
  Future<void> subscribeToCoupleSpace(int spaceId) async {
    if (_subscribedSpaceId == spaceId) return;

    try {
      if (_subscribedSpaceId != null) {
        await unsubscribeFromCoupleSpace();
      }

      final channelName = 'private-couple.$spaceId';
      debugPrint('WebSocketService: Subscribing to $channelName');
      await _pusher.subscribe(channelName: channelName);
      _subscribedSpaceId = spaceId;
    } catch (e) {
      debugPrint('WebSocketService: Subscription error: $e');
    }
  }

  /// Unsubscribe from active space
  Future<void> unsubscribeFromCoupleSpace() async {
    if (_subscribedSpaceId == null) return;
    try {
      final channelName = 'private-couple.$_subscribedSpaceId';
      await _pusher.unsubscribe(channelName: channelName);
      _subscribedSpaceId = null;
    } catch (e) {
      debugPrint('WebSocketService: Unsubscribe error: $e');
    }
  }

  /// Disconnect completely
  Future<void> disconnect() async {
    try {
      await unsubscribeFromCoupleSpace();
      await _pusher.disconnect();
      _isConnected = false;
      _isInitialized = false;
    } catch (e) {
      debugPrint('WebSocketService: Disconnect error: $e');
    }
  }

  void _onEvent(PusherEvent event) {
    debugPrint('WebSocket event received: ${event.eventName} on ${event.channelName}');

    if (event.data == null) return;
    Map<String, dynamic> payload = {};

    if (event.data is Map) {
      payload = Map<String, dynamic>.from(event.data as Map);
    } else if (event.data is String) {
      try {
        payload = jsonDecode(event.data as String) as Map<String, dynamic>;
      } catch (_) {
        return;
      }
    }

    if (event.eventName == 'message.new' || event.eventName == 'NewMessageEvent') {
      onMessageReceived?.call(payload);
    } else if (event.eventName == 'message.reaction' || event.eventName == 'MessageReactionEvent') {
      onReactionReceived?.call(payload);
    } else if (event.eventName == 'message.read' || event.eventName == 'MessageReadEvent') {
      onReadReceived?.call(payload);
    }
  }
}
