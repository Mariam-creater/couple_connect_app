import 'package:flutter/material.dart';
import '../../core/constants/api_constants.dart';
import '../../core/crypto/e2ee_engine.dart';
import '../../core/network/api_client.dart';
import '../../data/models/models.dart';

class AppState extends ChangeNotifier {
  UserModel? currentUser;
  UserModel? partner;
  CoupleSpaceModel? coupleSpace;
  StreakModel? streak;

  bool isLoading = false;
  String? errorMessage;

  List<CoupleRequestModel> incomingRequests = [];
  List<CoupleRequestModel> outgoingRequests = [];

  List<MessageModel> messages = [];
  List<MessageModel> pinnedMessages = [];
  List<CalendarEventModel> calendarEvents = [];
  List<MemoryModel> memories = [];
  List<VisionBoardModel> visionBoards = [];

  // Active Game State
  Map<String, dynamic>? activeGameState;
  String? activeGameType;

  // AI State
  Map<String, dynamic>? lastAiToneAnalysis;
  Map<String, dynamic>? lastAiGeneratedRomance;
  Map<String, dynamic>? lastAiDatePlan;
  bool isAiLoading = false;

  bool get isAuthenticated => currentUser != null;
  bool get isConnectedWithPartner => currentUser?.relationshipStatus == 'connected' && coupleSpace != null;

  String get sharedSecret => coupleSpace?.uuid ?? 'couple_connect_secret';

  // --- AUTHENTICATION ---
  Future<bool> login(String login, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final res = await ApiClient.post(ApiConstants.login, {
      'login': login,
      'password': password,
    });

    isLoading = false;
    if (res.isSuccess && res.data != null) {
      final token = res.data['token'];
      await ApiClient.setAuthToken(token);
      currentUser = UserModel.fromJson(res.data['user']);
      if (res.data['partner'] != null) {
        partner = UserModel.fromJson(res.data['partner']);
      }
      if (res.data['user']['couple_space'] != null) {
        coupleSpace = CoupleSpaceModel.fromJson(res.data['user']['couple_space']);
      }
      notifyListeners();
      await fetchInitialData();
      return true;
    } else {
      errorMessage = res.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> socialLogin({required String provider, required String token, String? name, String? email}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final res = await ApiClient.post(ApiConstants.socialLogin, {
      'provider': provider,
      'token': token,
      'name': name ?? (provider == 'google' ? 'Google User' : 'Apple User'),
      'email': email ?? (provider == 'google' ? 'googleuser@coupleconnect.app' : 'appleuser@coupleconnect.app'),
    });

    isLoading = false;
    if (res.isSuccess && res.data != null) {
      final authToken = res.data['token'];
      await ApiClient.setAuthToken(authToken);
      currentUser = UserModel.fromJson(res.data['user']);
      if (res.data['partner'] != null) {
        partner = UserModel.fromJson(res.data['partner']);
      }
      if (res.data['user']['couple_space'] != null) {
        coupleSpace = CoupleSpaceModel.fromJson(res.data['user']['couple_space']);
      }
      notifyListeners();
      await fetchInitialData();
      return true;
    } else {
      errorMessage = res.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String username, String email, String password, {String? bio, String? gender, String? birthday}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final res = await ApiClient.post(ApiConstants.register, {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'bio': bio,
      'gender': gender,
      'birthday': birthday,
    });

    isLoading = false;
    if (res.isSuccess && res.data != null) {
      final token = res.data['token'];
      await ApiClient.setAuthToken(token);
      currentUser = UserModel.fromJson(res.data['user']);
      notifyListeners();
      return true;
    } else {
      errorMessage = res.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final res = await ApiClient.post(ApiConstants.forgotPassword, {'email': email});
    isLoading = false;
    notifyListeners();
    return res.isSuccess;
  }

  Future<bool> resetPassword({required String email, required String token, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final res = await ApiClient.post(ApiConstants.resetPassword, {
      'email': email,
      'token': token,
      'password': password,
    });
    isLoading = false;
    notifyListeners();
    return res.isSuccess;
  }

  Future<void> fetchProfile() async {
    final res = await ApiClient.get(ApiConstants.me);
    if (res.isSuccess && res.data != null) {
      currentUser = UserModel.fromJson(res.data['user']);
      if (res.data['partner'] != null) {
        partner = UserModel.fromJson(res.data['partner']);
      } else {
        partner = null;
      }
      if (res.data['user']['couple_space'] != null) {
        coupleSpace = CoupleSpaceModel.fromJson(res.data['user']['couple_space']);
      } else {
        coupleSpace = null;
      }
      notifyListeners();
    }
  }

  Future<bool> updateProfile({String? name, String? bio, String? gender, String? birthday, String? phone, String? avatarUrl}) async {
    isLoading = true;
    notifyListeners();

    final res = await ApiClient.put(ApiConstants.profile, {
      if (name != null) 'name': name,
      if (bio != null) 'bio': bio,
      if (gender != null) 'gender': gender,
      if (birthday != null) 'birthday': birthday,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    });

    isLoading = false;
    if (res.isSuccess && res.data != null) {
      currentUser = UserModel.fromJson(res.data['user'] ?? res.data);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updatePrivacy({bool? showOnlineStatus, bool? showReadReceipts}) async {
    final res = await ApiClient.put(ApiConstants.privacy, {
      if (showOnlineStatus != null) 'privacy_show_online_status': showOnlineStatus,
      if (showReadReceipts != null) 'privacy_show_read_receipts': showReadReceipts,
    });
    if (res.isSuccess && res.data != null) {
      currentUser = UserModel.fromJson(res.data['user'] ?? res.data);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteAccount(String password) async {
    isLoading = true;
    notifyListeners();

    final res = await ApiClient.delete(ApiConstants.deleteAccount, data: {'password': password});
    isLoading = false;
    if (res.isSuccess) {
      await logout();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await ApiClient.post(ApiConstants.logout, {});
    await ApiClient.clearAuthToken();
    currentUser = null;
    partner = null;
    coupleSpace = null;
    messages = [];
    pinnedMessages = [];
    calendarEvents = [];
    memories = [];
    visionBoards = [];
    incomingRequests = [];
    outgoingRequests = [];
    notifyListeners();
  }

  // --- COUPLE CONNECTION & REQUESTS ---
  Future<UserModel?> searchPartner(String query) async {
    final res = await ApiClient.get('${ApiConstants.coupleSearch}?query=$query');
    if (res.isSuccess && res.data != null) {
      return UserModel.fromJson(res.data);
    }
    return null;
  }

  Future<void> fetchCoupleRequests() async {
    final res = await ApiClient.get(ApiConstants.coupleRequests);
    if (res.isSuccess && res.data != null) {
      final inList = (res.data['incoming'] as List? ?? []);
      final outList = (res.data['outgoing'] as List? ?? []);
      incomingRequests = inList.map((r) => CoupleRequestModel.fromJson(r)).toList();
      outgoingRequests = outList.map((r) => CoupleRequestModel.fromJson(r)).toList();
      notifyListeners();
    }
  }

  Future<bool> sendCoupleRequest(int receiverId) async {
    final res = await ApiClient.post(ApiConstants.coupleRequest, {'receiver_id': receiverId});
    if (res.isSuccess) {
      currentUser = currentUser?.copyWith(relationshipStatus: 'pending');
      await fetchCoupleRequests();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> cancelCoupleRequest(int requestId) async {
    final res = await ApiClient.post('${ApiConstants.baseUrl}/couple/request/$requestId/cancel', {});
    if (res.isSuccess) {
      currentUser = currentUser?.copyWith(relationshipStatus: 'single');
      await fetchCoupleRequests();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> acceptCoupleRequest(int requestId) async {
    final res = await ApiClient.post('${ApiConstants.baseUrl}/couple/request/$requestId/accept', {});
    if (res.isSuccess && res.data != null) {
      coupleSpace = CoupleSpaceModel.fromJson(res.data);
      await fetchProfile();
      await fetchInitialData();
      return true;
    }
    return false;
  }

  Future<bool> rejectCoupleRequest(int requestId) async {
    final res = await ApiClient.post('${ApiConstants.baseUrl}/couple/request/$requestId/reject', {});
    if (res.isSuccess) {
      await fetchCoupleRequests();
      return true;
    }
    return false;
  }

  Future<bool> removePartner() async {
    final res = await ApiClient.post(ApiConstants.coupleRemovePartner, {});
    if (res.isSuccess) {
      coupleSpace = null;
      partner = null;
      currentUser = currentUser?.copyWith(relationshipStatus: 'single');
      messages = [];
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> blockUser(int userId, {String? reason}) async {
    final res = await ApiClient.post(ApiConstants.coupleBlock, {
      'blocked_user_id': userId,
      'reason': reason ?? 'User blocked by partner',
    });
    return res.isSuccess;
  }

  Future<bool> reportUser(int userId, {required String reason, required String category}) async {
    final res = await ApiClient.post(ApiConstants.coupleReport, {
      'reported_user_id': userId,
      'reason': reason,
      'category': category,
    });
    return res.isSuccess;
  }

  // --- INITIAL DATA LOAD ---
  Future<void> fetchInitialData() async {
    if (!isConnectedWithPartner) {
      await fetchCoupleRequests();
      return;
    }
    await Future.wait([
      fetchMessages(),
      fetchPinnedMessages(),
      fetchCalendarEvents(),
      fetchMemories(),
      fetchVisionBoards(),
      fetchStreakStatus(),
    ]);
  }

  // --- CHAT & E2EE MESSAGES ---
  Future<void> fetchMessages() async {
    final res = await ApiClient.get(ApiConstants.chatMessages);
    if (res.isSuccess && res.data != null) {
      final rawList = (res.data['data'] ?? res.data) as List;
      messages = rawList.map((m) {
        final model = MessageModel.fromJson(m);
        model.decryptedText = E2EEEngine.decryptText(
          ciphertext: model.encryptedPayload,
          iv: model.iv,
          mac: model.mac ?? '',
          sharedSecret: sharedSecret,
        );
        return model;
      }).toList();
      notifyListeners();
    }
  }

  Future<void> fetchPinnedMessages() async {
    final res = await ApiClient.get(ApiConstants.chatPinned);
    if (res.isSuccess && res.data != null) {
      final rawList = res.data as List;
      pinnedMessages = rawList.map((m) {
        final model = MessageModel.fromJson(m);
        model.decryptedText = E2EEEngine.decryptText(
          ciphertext: model.encryptedPayload,
          iv: model.iv,
          mac: model.mac ?? '',
          sharedSecret: sharedSecret,
        );
        return model;
      }).toList();
      notifyListeners();
    }
  }

  Future<void> sendTextMessage(String plainText, {String type = 'text', Map<String, dynamic>? metadata}) async {
    final payload = E2EEEngine.encryptText(
      plainText: plainText,
      sharedSecret: sharedSecret,
    );

    final res = await ApiClient.post(ApiConstants.chatMessages, {
      'type': type,
      'encrypted_payload': payload.ciphertext,
      'iv': payload.iv,
      'mac': payload.mac,
      if (metadata != null) 'metadata': metadata,
    });

    if (res.isSuccess && res.data != null) {
      final model = MessageModel.fromJson(res.data);
      model.decryptedText = plainText;
      messages.insert(0, model);
      notifyListeners();
    }
  }

  Future<bool> editMessage(int messageId, String newPlainText) async {
    final payload = E2EEEngine.encryptText(
      plainText: newPlainText,
      sharedSecret: sharedSecret,
    );

    final res = await ApiClient.put('${ApiConstants.chatMessages}/$messageId', {
      'encrypted_payload': payload.ciphertext,
      'iv': payload.iv,
      'mac': payload.mac,
    });

    if (res.isSuccess) {
      final index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        messages[index].decryptedText = newPlainText;
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  Future<bool> deleteMessage(int messageId) async {
    final res = await ApiClient.delete('${ApiConstants.chatMessages}/$messageId');
    if (res.isSuccess) {
      messages.removeWhere((m) => m.id == messageId);
      pinnedMessages.removeWhere((m) => m.id == messageId);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> togglePinMessage(int messageId) async {
    final res = await ApiClient.post('${ApiConstants.chatMessages}/$messageId/pin', {});
    if (res.isSuccess) {
      await fetchMessages();
      await fetchPinnedMessages();
      return true;
    }
    return false;
  }

  Future<void> reactToMessage(int messageId, String emoji) async {
    await ApiClient.post('${ApiConstants.chatMessages}/$messageId/react', {'reaction': emoji});
    await fetchMessages();
  }

  Future<void> markMessagesAsRead() async {
    await ApiClient.post(ApiConstants.chatRead, {});
  }

  // --- CALENDAR ---
  Future<void> fetchCalendarEvents() async {
    final res = await ApiClient.get(ApiConstants.calendarEvents);
    if (res.isSuccess && res.data != null) {
      final list = res.data as List;
      calendarEvents = list.map((e) => CalendarEventModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<bool> addCalendarEvent(String title, String category, DateTime startTime, {bool isCountdown = false, String? location}) async {
    final res = await ApiClient.post(ApiConstants.calendarEvents, {
      'title': title,
      'category': category,
      'start_time': startTime.toIso8601String(),
      'is_countdown': isCountdown,
      'location': location,
    });
    if (res.isSuccess) {
      await fetchCalendarEvents();
      return true;
    }
    return false;
  }

  // --- MEMORIES ---
  Future<void> fetchMemories() async {
    final res = await ApiClient.get(ApiConstants.memories);
    if (res.isSuccess && res.data != null) {
      final list = (res.data['data'] ?? res.data) as List;
      memories = list.map((m) => MemoryModel.fromJson(m)).toList();
      notifyListeners();
    }
  }

  // --- VISION BOARD ---
  Future<void> fetchVisionBoards() async {
    final res = await ApiClient.get(ApiConstants.visionBoards);
    if (res.isSuccess && res.data != null) {
      final list = res.data as List;
      visionBoards = list.map((b) => VisionBoardModel.fromJson(b)).toList();
      notifyListeners();
    }
  }

  Future<void> toggleVisionItem(int itemId) async {
    final res = await ApiClient.post('${ApiConstants.baseUrl}/vision-boards/items/$itemId/toggle', {});
    if (res.isSuccess) {
      await fetchVisionBoards();
    }
  }

  // --- STREAK ---
  Future<void> fetchStreakStatus() async {
    final res = await ApiClient.get(ApiConstants.streakStatus);
    if (res.isSuccess && res.data != null && res.data['streak'] != null) {
      streak = StreakModel.fromJson(res.data['streak']);
      notifyListeners();
    }
  }

  Future<void> performDailyCheckIn() async {
    final res = await ApiClient.post(ApiConstants.streakCheckIn, {});
    if (res.isSuccess) {
      await fetchStreakStatus();
    }
  }

  // --- AI ASSISTANT ---
  Future<void> analyzeTone(String conversationText) async {
    isAiLoading = true;
    notifyListeners();

    final res = await ApiClient.post(ApiConstants.aiAnalyzeTone, {
      'message_text': conversationText,
    });

    isAiLoading = false;
    if (res.isSuccess && res.data != null) {
      lastAiToneAnalysis = Map<String, dynamic>.from(res.data);
    }
    notifyListeners();
  }

  Future<void> generateRomanticMessage({
    required String type,
    String? style,
    String? keyMoments,
    String? intent,
  }) async {
    isAiLoading = true;
    notifyListeners();

    final res = await ApiClient.post(ApiConstants.aiGenerateRomance, {
      'type': type,
      'partner_name': partner?.name ?? 'My Love',
      'style': style,
      'key_moments': keyMoments,
      'intent': intent,
    });

    isAiLoading = false;
    if (res.isSuccess && res.data != null) {
      lastAiGeneratedRomance = Map<String, dynamic>.from(res.data);
    }
    notifyListeners();
  }

  Future<void> planDate({
    String? location,
    String? budget,
    String? vibe,
  }) async {
    isAiLoading = true;
    notifyListeners();

    final res = await ApiClient.post(ApiConstants.aiPlanDate, {
      'location': location ?? 'Our City',
      'budget': budget ?? 'Romantic',
      'vibe': vibe ?? 'Intimate & Cozy',
    });

    isAiLoading = false;
    if (res.isSuccess && res.data != null) {
      lastAiDatePlan = Map<String, dynamic>.from(res.data);
    }
    notifyListeners();
  }
}
