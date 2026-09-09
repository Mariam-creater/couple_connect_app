class UserModel {
  final int id;
  final String name;
  final String username;
  final String email;
  final String? avatarUrl;
  final String coupleId;
  final String relationshipStatus;
  final int? coupleSpaceId;
  final String? publicKey;
  final bool biometricEnabled;
  final String onlineStatus;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.coupleId,
    required this.relationshipStatus,
    this.coupleSpaceId,
    this.publicKey,
    this.biometricEnabled = false,
    this.onlineStatus = 'offline',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'],
      coupleId: json['couple_id'] ?? '',
      relationshipStatus: json['relationship_status'] ?? 'single',
      coupleSpaceId: json['couple_space_id'],
      publicKey: json['public_key'],
      biometricEnabled: json['biometric_enabled'] ?? false,
      onlineStatus: json['online_status'] ?? 'offline',
    );
  }
}

class CoupleSpaceModel {
  final int id;
  final String uuid;
  final String spaceName;
  final String themePreset;
  final DateTime connectedAt;
  final String? anniversaryDate;
  final UserModel? userOne;
  final UserModel? userTwo;

  CoupleSpaceModel({
    required this.id,
    required this.uuid,
    required this.spaceName,
    required this.themePreset,
    required this.connectedAt,
    this.anniversaryDate,
    this.userOne,
    this.userTwo,
  });

  factory CoupleSpaceModel.fromJson(Map<String, dynamic> json) {
    return CoupleSpaceModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      spaceName: json['space_name'] ?? 'Our Space',
      themePreset: json['theme_preset'] ?? 'rose_gold',
      connectedAt: DateTime.tryParse(json['connected_at'] ?? '') ?? DateTime.now(),
      anniversaryDate: json['anniversary_date'],
      userOne: json['user_one'] != null ? UserModel.fromJson(json['user_one']) : null,
      userTwo: json['user_two'] != null ? UserModel.fromJson(json['user_two']) : null,
    );
  }
}

class MessageModel {
  final int id;
  final String messageUuid;
  final int senderId;
  final String type;
  final String encryptedPayload;
  final String iv;
  final String? mac;
  final bool isPinned;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  String? decryptedText;

  MessageModel({
    required this.id,
    required this.messageUuid,
    required this.senderId,
    required this.type,
    required this.encryptedPayload,
    required this.iv,
    this.mac,
    this.isPinned = false,
    this.status = 'sent',
    required this.createdAt,
    this.metadata,
    this.decryptedText,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      messageUuid: json['message_uuid'] ?? '',
      senderId: json['sender_id'] ?? 0,
      type: json['type'] ?? 'text',
      encryptedPayload: json['encrypted_payload'] ?? '',
      iv: json['iv'] ?? '',
      mac: json['mac'],
      isPinned: json['is_pinned'] ?? false,
      status: json['status'] ?? 'sent',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      metadata: json['metadata'],
    );
  }
}

class CalendarEventModel {
  final int id;
  final String title;
  final String? description;
  final String category;
  final String colorHex;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCountdown;
  final String? location;

  CalendarEventModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.colorHex,
    required this.startTime,
    this.endTime,
    this.isCountdown = false,
    this.location,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'date_night',
      colorHex: json['color_hex'] ?? '#E91E63',
      startTime: DateTime.tryParse(json['start_time'] ?? '') ?? DateTime.now(),
      endTime: json['end_time'] != null ? DateTime.tryParse(json['end_time']) : null,
      isCountdown: json['is_countdown'] ?? false,
      location: json['location'],
    );
  }
}

class MemoryModel {
  final int id;
  final String title;
  final String category;
  final String albumName;
  final String? mediaPath;
  final String? encryptedBody;
  final DateTime memoryDate;
  final bool isFavorite;
  final String? locationName;

  MemoryModel({
    required this.id,
    required this.title,
    required this.category,
    required this.albumName,
    this.mediaPath,
    this.encryptedBody,
    required this.memoryDate,
    this.isFavorite = false,
    this.locationName,
  });

  factory MemoryModel.fromJson(Map<String, dynamic> json) {
    return MemoryModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      category: json['category'] ?? 'photo',
      albumName: json['album_name'] ?? 'Main',
      mediaPath: json['media_path'],
      encryptedBody: json['encrypted_body'],
      memoryDate: DateTime.tryParse(json['memory_date'] ?? '') ?? DateTime.now(),
      isFavorite: json['is_favorite'] ?? false,
      locationName: json['location_name'],
    );
  }
}

class VisionBoardModel {
  final int id;
  final String title;
  final String category;
  final String? description;
  final String? coverImageUrl;
  final double? targetAmount;
  final double currentAmount;
  final int progressPercentage;
  final String status;
  final List<VisionItemModel> items;

  VisionBoardModel({
    required this.id,
    required this.title,
    required this.category,
    this.description,
    this.coverImageUrl,
    this.targetAmount,
    this.currentAmount = 0,
    this.progressPercentage = 0,
    this.status = 'dream',
    this.items = const [],
  });

  factory VisionBoardModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List? ?? [];
    List<VisionItemModel> itemsList = rawItems.map((i) => VisionItemModel.fromJson(i)).toList();

    return VisionBoardModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      category: json['category'] ?? 'life_goals',
      description: json['description'],
      coverImageUrl: json['cover_image_url'],
      targetAmount: json['target_amount'] != null ? double.tryParse(json['target_amount'].toString()) : null,
      currentAmount: double.tryParse(json['current_amount']?.toString() ?? '0') ?? 0,
      progressPercentage: json['progress_percentage'] ?? 0,
      status: json['status'] ?? 'dream',
      items: itemsList,
    );
  }
}

class VisionItemModel {
  final int id;
  final String title;
  final String type;
  final bool isCompleted;

  VisionItemModel({
    required this.id,
    required this.title,
    required this.type,
    required this.isCompleted,
  });

  factory VisionItemModel.fromJson(Map<String, dynamic> json) {
    return VisionItemModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? 'checklist',
      isCompleted: json['is_completed'] ?? false,
    );
  }
}

class StreakModel {
  final int currentStreakDays;
  final int longestStreakDays;
  final String? lastActivityDate;
  final List<String> badges;
  final int totalMessagesCount;
  final int totalGamesPlayed;
  final int totalMemoriesAdded;
  final int totalGoalsCompleted;

  StreakModel({
    this.currentStreakDays = 1,
    this.longestStreakDays = 1,
    this.lastActivityDate,
    this.badges = const [],
    this.totalMessagesCount = 0,
    this.totalGamesPlayed = 0,
    this.totalMemoriesAdded = 0,
    this.totalGoalsCompleted = 0,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    var rawBadges = json['badges'];
    List<String> badgeList = [];
    if (rawBadges is List) {
      badgeList = rawBadges.map((e) => e.toString()).toList();
    }
    return StreakModel(
      currentStreakDays: json['current_streak_days'] ?? 1,
      longestStreakDays: json['longest_streak_days'] ?? 1,
      lastActivityDate: json['last_activity_date'],
      badges: badgeList,
      totalMessagesCount: json['total_messages_count'] ?? 0,
      totalGamesPlayed: json['total_games_played'] ?? 0,
      totalMemoriesAdded: json['total_memories_added'] ?? 0,
      totalGoalsCompleted: json['total_goals_completed'] ?? 0,
    );
  }
}
