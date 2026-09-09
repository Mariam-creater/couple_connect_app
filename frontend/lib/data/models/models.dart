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
  final String? googleId;
  final bool hasPassword;
  final bool isGoogleLinked;

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
    this.googleId,
    this.hasPassword = true,
    this.isGoogleLinked = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic val, bool defaultVal) {
      if (val == null) return defaultVal;
      if (val is bool) return val;
      if (val is num) return val == 1;
      if (val is String) return val == '1' || val.toLowerCase() == 'true';
      return defaultVal;
    }

    return UserModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? json['avatar']?.toString(),
      coupleId: json['couple_id']?.toString() ?? '',
      relationshipStatus: json['relationship_status']?.toString() ?? 'single',
      coupleSpaceId: json['couple_space_id'] is num ? (json['couple_space_id'] as num).toInt() : int.tryParse(json['couple_space_id']?.toString() ?? ''),
      publicKey: json['public_key']?.toString(),
      biometricEnabled: parseBool(json['biometric_enabled'], false),
      onlineStatus: json['online_status']?.toString() ?? 'offline',
      bio: json['bio']?.toString(),
      gender: json['gender']?.toString(),
      birthday: json['birthday']?.toString(),
      phone: json['phone']?.toString(),
      privacyShowOnlineStatus: parseBool(json['privacy_show_online_status'], true),
      privacyShowReadReceipts: parseBool(json['privacy_show_read_receipts'], true),
      googleId: json['google_id']?.toString(),
      hasPassword: json['has_password'] != null ? parseBool(json['has_password'], true) : (json['google_id'] == null || json['password'] != null),
      isGoogleLinked: json['is_google_linked'] != null ? parseBool(json['is_google_linked'], false) : (json['google_id'] != null),
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
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      senderId: json['sender_id'] is num ? (json['sender_id'] as num).toInt() : 0,
      receiverId: json['receiver_id'] is num ? (json['receiver_id'] as num).toInt() : 0,
      status: json['status']?.toString() ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      sender: json['sender'] != null ? UserModel.fromJson(Map<String, dynamic>.from(json['sender'])) : null,
      receiver: json['receiver'] != null ? UserModel.fromJson(Map<String, dynamic>.from(json['receiver'])) : null,
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
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      uuid: json['uuid']?.toString() ?? '',
      spaceName: json['space_name']?.toString() ?? 'Our Space',
      themePreset: json['theme_preset']?.toString() ?? 'rose_gold',
      connectedAt: DateTime.tryParse(json['connected_at']?.toString() ?? '') ?? DateTime.now(),
      anniversaryDate: json['anniversary_date']?.toString(),
      userOne: json['user_one'] != null ? UserModel.fromJson(Map<String, dynamic>.from(json['user_one'])) : null,
      userTwo: json['user_two'] != null ? UserModel.fromJson(Map<String, dynamic>.from(json['user_two'])) : null,
    );
  }
}

class MessageReactionModel {
  final int id;
  final int userId;
  final String reaction;

  MessageReactionModel({
    required this.id,
    required this.userId,
    required this.reaction,
  });

  factory MessageReactionModel.fromJson(Map<String, dynamic> json) {
    return MessageReactionModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      userId: json['user_id'] is num ? (json['user_id'] as num).toInt() : 0,
      reaction: json['reaction']?.toString() ?? '❤️',
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
  final bool isEdited;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  final List<MessageReactionModel> reactions;
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
    this.isEdited = false,
    this.status = 'sent',
    required this.createdAt,
    this.metadata,
    this.reactions = const [],
    this.decryptedText,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is num) return val == 1;
      if (val is String) return val == '1' || val.toLowerCase() == 'true';
      return false;
    }

    final rawReactions = (json['reactions'] as List? ?? []);
    return MessageModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      messageUuid: json['message_uuid']?.toString() ?? '',
      senderId: json['sender_id'] is num ? (json['sender_id'] as num).toInt() : 0,
      type: json['type']?.toString() ?? 'text',
      encryptedPayload: json['encrypted_payload']?.toString() ?? '',
      iv: json['iv']?.toString() ?? '',
      mac: json['mac']?.toString(),
      isPinned: parseBool(json['is_pinned']),
      isEdited: parseBool(json['is_edited']),
      status: json['status']?.toString() ?? 'sent',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
      reactions: rawReactions.map((r) => MessageReactionModel.fromJson(Map<String, dynamic>.from(r))).toList(),
    );
  }

  MessageModel copyWith({
    int? id,
    String? messageUuid,
    int? senderId,
    String? type,
    String? encryptedPayload,
    String? iv,
    String? mac,
    bool? isPinned,
    bool? isEdited,
    String? status,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
    List<MessageReactionModel>? reactions,
    String? decryptedText,
  }) {
    return MessageModel(
      id: id ?? this.id,
      messageUuid: messageUuid ?? this.messageUuid,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      encryptedPayload: encryptedPayload ?? this.encryptedPayload,
      iv: iv ?? this.iv,
      mac: mac ?? this.mac,
      isPinned: isPinned ?? this.isPinned,
      isEdited: isEdited ?? this.isEdited,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      reactions: reactions ?? this.reactions,
      decryptedText: decryptedText ?? this.decryptedText,
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
    bool parseBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is num) return val == 1;
      if (val is String) return val == '1' || val.toLowerCase() == 'true';
      return false;
    }

    return CalendarEventModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      category: json['category']?.toString() ?? 'date_night',
      colorHex: json['color_hex']?.toString() ?? '#E91E63',
      startTime: DateTime.tryParse(json['start_time']?.toString() ?? '') ?? DateTime.now(),
      endTime: json['end_time'] != null ? DateTime.tryParse(json['end_time'].toString()) : null,
      isAllDay: parseBool(json['is_all_day']),
      isCountdown: parseBool(json['is_countdown']),
      recurrence: json['recurrence']?.toString() ?? 'none',
      reminderMinutesBefore: json['reminder_minutes_before'] is num ? (json['reminder_minutes_before'] as num).toInt() : 60,
      location: json['location']?.toString(),
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
    bool parseBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is num) return val == 1;
      if (val is String) return val == '1' || val.toLowerCase() == 'true';
      return false;
    }

    return MemoryModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      uuid: json['uuid']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'photo',
      albumName: json['album_name']?.toString() ?? 'Main Memories',
      mediaPath: json['media_path']?.toString(),
      thumbnailPath: json['thumbnail_path']?.toString(),
      encryptedBody: json['encrypted_body']?.toString(),
      fileSizeBytes: json['file_size_bytes'] is num ? (json['file_size_bytes'] as num).toInt() : null,
      memoryDate: DateTime.tryParse(json['memory_date']?.toString() ?? '') ?? DateTime.now(),
      isFavorite: parseBool(json['is_favorite']),
      isArchived: parseBool(json['is_archived']),
      locationName: json['location_name']?.toString(),
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
    List<VisionItemModel> itemsList = rawItems.map((i) => VisionItemModel.fromJson(Map<String, dynamic>.from(i))).toList();

    return VisionBoardModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'life_goals',
      description: json['description']?.toString(),
      coverImageUrl: json['cover_image_url']?.toString(),
      targetDate: json['target_date'] != null ? DateTime.tryParse(json['target_date'].toString()) : null,
      targetAmount: json['target_amount'] != null ? double.tryParse(json['target_amount'].toString()) : null,
      currentAmount: double.tryParse(json['current_amount']?.toString() ?? '0') ?? 0,
      progressPercentage: json['progress_percentage'] is num ? (json['progress_percentage'] as num).toInt() : 0,
      status: json['status']?.toString() ?? 'dream',
      priority: json['priority']?.toString() ?? 'medium',
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
    bool parseBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is num) return val == 1;
      if (val is String) return val == '1' || val.toLowerCase() == 'true';
      return false;
    }

    return VisionItemModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString(),
      type: json['type']?.toString() ?? 'checklist',
      colorHex: json['color_hex']?.toString() ?? '#FFE082',
      isCompleted: parseBool(json['is_completed']),
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
    final msgs = json['total_messages_count'] is num ? (json['total_messages_count'] as num).toInt() : 0;
    final games = json['total_games_played'] is num ? (json['total_games_played'] as num).toInt() : 0;
    final mems = json['total_memories_added'] is num ? (json['total_memories_added'] as num).toInt() : 0;
    final goals = json['total_goals_completed'] is num ? (json['total_goals_completed'] as num).toInt() : 0;
    final currentDays = json['current_streak_days'] is num ? (json['current_streak_days'] as num).toInt() : 1;
    final longestDays = json['longest_streak_days'] is num ? (json['longest_streak_days'] as num).toInt() : 1;

    final calcXp = (msgs * 5) + (games * 25) + (mems * 20) + (goals * 50) + (currentDays * 30);
    final calcLevel = (calcXp / 250).floor() + 1;

    return StreakModel(
      currentStreakDays: currentDays,
      longestStreakDays: longestDays,
      lastActivityDate: json['last_activity_date']?.toString(),
      badges: badgeList,
      totalMessagesCount: msgs,
      totalGamesPlayed: games,
      totalMemoriesAdded: mems,
      totalGoalsCompleted: goals,
      voiceCallMinutes: json['voice_call_minutes'] is num ? (json['voice_call_minutes'] as num).toInt() : 45,
      videoCallMinutes: json['video_call_minutes'] is num ? (json['video_call_minutes'] as num).toInt() : 120,
      xp: json['xp'] is num ? (json['xp'] as num).toInt() : calcXp,
      level: json['level'] is num ? (json['level'] as num).toInt() : calcLevel,
    );
  }
}
