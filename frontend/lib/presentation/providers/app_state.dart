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

  List<MessageModel> messages = [];
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

  Future<bool> register(String name, String username, String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final res = await ApiClient.post(ApiConstants.register, {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
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

  Future<void> fetchProfile() async {
    final res = await ApiClient.get(ApiConstants.me);
    if (res.isSuccess && res.data != null) {
      currentUser = UserModel.fromJson(res.data['user']);
      if (res.data['partner'] != null) {
        partner = UserModel.fromJson(res.data['partner']);
      }
      if (res.data['user']['couple_space'] != null) {
        coupleSpace = CoupleSpaceModel.fromJson(res.data['user']['couple_space']);
      }
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await ApiClient.post(ApiConstants.logout, {});
    await ApiClient.clearAuthToken();
    currentUser = null;
    partner = null;
    coupleSpace = null;
    messages = [];
    calendarEvents = [];
    memories = [];
    visionBoards = [];
    notifyListeners();
  }

  // --- COUPLE CONNECTION HANDSHAKE ---
  Future<UserModel?> searchPartner(String query) async {
    final res = await ApiClient.get('${ApiConstants.coupleSearch}?query=$query');
    if (res.isSuccess && res.data != null) {
      return UserModel.fromJson(res.data);
    }
    return null;
  }

  Future<bool> sendCoupleRequest(int receiverId) async {
    final res = await ApiClient.post(ApiConstants.coupleRequest, {'receiver_id': receiverId});
    if (res.isSuccess) {
      currentUser = UserModel(
        id: currentUser!.id,
        name: currentUser!.name,
        username: currentUser!.username,
        email: currentUser!.email,
        coupleId: currentUser!.coupleId,
        relationshipStatus: 'pending',
      );
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

  // --- INITIAL DATA LOAD ---
  Future<void> fetchInitialData() async {
    if (!isConnectedWithPartner) return;
    await Future.wait([
      fetchMessages(),
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

  Future<void> sendTextMessage(String plainText) async {
    final payload = E2EEEngine.encryptText(
      plainText: plainText,
      sharedSecret: sharedSecret,
    );

    final res = await ApiClient.post(ApiConstants.chatMessages, {
      'type': 'text',
      'encrypted_payload': payload.ciphertext,
      'iv': payload.iv,
      'mac': payload.mac,
    });

    if (res.isSuccess && res.data != null) {
      final model = MessageModel.fromJson(res.data);
      model.decryptedText = plainText;
      messages.insert(0, model);
      notifyListeners();
    }
  }

  Future<void> reactToMessage(int messageId, String emoji) async {
    await ApiClient.post('${ApiConstants.chatMessages}/$messageId/react', {'reaction': emoji});
    await fetchMessages();
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
