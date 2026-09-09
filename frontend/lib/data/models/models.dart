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
  final String? bio;
  final String? gender;
  final String? birthday;
  final String? phone;
  final bool privacyShowOnlineStatus;
  final bool privacyShowReadReceipts;

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
    this.bio,
    this.gender,
    this.birthday,
    this.phone,
    this.privacyShowOnlineStatus = true,
    this.privacyShowReadReceipts = true,
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
      bio: json['bio'],
      gender: json['gender'],
      birthday: json['birthday'],
      phone: json['phone'],
      privacyShowOnlineStatus: json['privacy_show_online_status'] ?? true,
      privacyShowReadReceipts: json['privacy_show_read_receipts'] ?? true,
    );
  }

  UserModel copyWith({
    String? name,
    String? bio,
    String? gender,
    String? birthday,
    String? phone,
    String? avatarUrl,
    bool? privacyShowOnlineStatus,
    bool? privacyShowReadReceipts,
    String? relationshipStatus,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      username: username,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coupleId: coupleId,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      coupleSpaceId: coupleSpaceId,
      publicKey: publicKey,
      biometricEnabled: biometricEnabled,
      onlineStatus: onlineStatus,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      phone: phone ?? this.phone,
      privacyShowOnlineStatus: privacyShowOnlineStatus ?? this.privacyShowOnlineStatus,
      privacyShowReadReceipts: privacyShowReadReceipts ?? this.privacyShowReadReceipts,
    );
  }
}

class CoupleRequestModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String status;
  final DateTime createdAt;
  final UserModel? sender;
  final UserModel? receiver;

  CoupleRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    this.sender,
    this.receiver,
  });

  factory CoupleRequestModel.fromJson(Map<String, dynamic> json) {
    return CoupleRequestModel(
      id: json['id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      receiverId: json['receiver_id'] ?? 0,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      sender: json['sender'] != null ? UserModel.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? UserModel.fromJson(json['receiver']) : null,
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
  final bool isAllDay;
  final bool isCountdown;
  final String recurrence;
  final int reminderMinutesBefore;
  final String? location;

  CalendarEventModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.colorHex,
    required this.startTime,
    this.endTime,
    this.isAllDay = false,
    this.isCountdown = false,
    this.recurrence = 'none',
    this.reminderMinutesBefore = 60,
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
      isAllDay: json['is_all_day'] ?? false,
      isCountdown: json['is_countdown'] ?? false,
      recurrence: json['recurrence'] ?? 'none',
      reminderMinutesBefore: json['reminder_minutes_before'] ?? 60,
      location: json['location'],
    );
  }
}

class MemoryModel {
  final int id;
  final String uuid;
  final String title;
  final String category;
  final String albumName;
  final String? mediaPath;
  final String? thumbnailPath;
  final String? encryptedBody;
  final int? fileSizeBytes;
  final DateTime memoryDate;
  final bool isFavorite;
  final bool isArchived;
  final String? locationName;

  MemoryModel({
    required this.id,
    this.uuid = '',
    required this.title,
    required this.category,
    required this.albumName,
    this.mediaPath,
    this.thumbnailPath,
    this.encryptedBody,
    this.fileSizeBytes,
    required this.memoryDate,
    this.isFavorite = false,
    this.isArchived = false,
    this.locationName,
  });

  factory MemoryModel.fromJson(Map<String, dynamic> json) {
    return MemoryModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'photo',
      albumName: json['album_name'] ?? 'Main Memories',
      mediaPath: json['media_path'],
      thumbnailPath: json['thumbnail_path'],
      encryptedBody: json['encrypted_body'],
      fileSizeBytes: json['file_size_bytes'],
      memoryDate: DateTime.tryParse(json['memory_date'] ?? '') ?? DateTime.now(),
      isFavorite: json['is_favorite'] ?? false,
      isArchived: json['is_archived'] ?? false,
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
  final DateTime? targetDate;
  final double? targetAmount;
  final double currentAmount;
  final int progressPercentage;
  final String status;
  final String priority;
  final List<VisionItemModel> items;

  VisionBoardModel({
    required this.id,
    required this.title,
    required this.category,
    this.description,
    this.coverImageUrl,
    this.targetDate,
    this.targetAmount,
    this.currentAmount = 0,
    this.progressPercentage = 0,
    this.status = 'dream',
    this.priority = 'medium',
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
      targetDate: json['target_date'] != null ? DateTime.tryParse(json['target_date'].toString()) : null,
      targetAmount: json['target_amount'] != null ? double.tryParse(json['target_amount'].toString()) : null,
      currentAmount: double.tryParse(json['current_amount']?.toString() ?? '0') ?? 0,
      progressPercentage: json['progress_percentage'] ?? 0,
      status: json['status'] ?? 'dream',
      priority: json['priority'] ?? 'medium',
      items: itemsList,
    );
  }
}

class VisionItemModel {
  final int id;
  final String title;
  final String? content;
  final String type;
  final String colorHex;
  final bool isCompleted;

  VisionItemModel({
    required this.id,
    required this.title,
    this.content,
    required this.type,
    this.colorHex = '#FFE082',
    required this.isCompleted,
  });

  factory VisionItemModel.fromJson(Map<String, dynamic> json) {
    return VisionItemModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'],
      type: json['type'] ?? 'checklist',
      colorHex: json['color_hex'] ?? '#FFE082',
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
  final int voiceCallMinutes;
  final int videoCallMinutes;
  final int xp;
  final int level;

  StreakModel({
    this.currentStreakDays = 1,
    this.longestStreakDays = 1,
    this.lastActivityDate,
    this.badges = const [],
    this.totalMessagesCount = 0,
    this.totalGamesPlayed = 0,
    this.totalMemoriesAdded = 0,
    this.totalGoalsCompleted = 0,
    this.voiceCallMinutes = 45,
    this.videoCallMinutes = 120,
    this.xp = 480,
    this.level = 4,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    var rawBadges = json['badges'];
    List<String> badgeList = [];
    if (rawBadges is List) {
      badgeList = rawBadges.map((e) => e.toString()).toList();
    }
    final msgs = json['total_messages_count'] ?? 0;
    final games = json['total_games_played'] ?? 0;
    final mems = json['total_memories_added'] ?? 0;
    final goals = json['total_goals_completed'] ?? 0;
    final calcXp = (msgs * 5) + (games * 25) + (mems * 20) + (goals * 50) + ((json['current_streak_days'] ?? 1) * 30);
    final calcLevel = (calcXp / 250).floor() + 1;

    return StreakModel(
      currentStreakDays: json['current_streak_days'] ?? 1,
      longestStreakDays: json['longest_streak_days'] ?? 1,
      lastActivityDate: json['last_activity_date'],
      badges: badgeList,
      totalMessagesCount: msgs,
      totalGamesPlayed: games,
      totalMemoriesAdded: mems,
      totalGoalsCompleted: goals,
      voiceCallMinutes: json['voice_call_minutes'] ?? 45,
      videoCallMinutes: json['video_call_minutes'] ?? 120,
      xp: json['xp'] ?? calcXp,
      level: json['level'] ?? calcLevel,
    );
  }
}
