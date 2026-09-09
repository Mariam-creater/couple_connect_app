class ApiConstants {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  static const String wsUrl = 'ws://localhost:8080/app/couple_connect_key';

  // Pusher WebSockets Configuration (Render Free Tier Native Pusher Driver)
  static const String pusherAppKey = String.fromEnvironment('PUSHER_APP_KEY', defaultValue: 'couple_connect_key');
  static const String pusherCluster = String.fromEnvironment('PUSHER_APP_CLUSTER', defaultValue: 'mt1');

  // Auth & Profile
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String googleAuth = '$baseUrl/auth/google';
  static const String setCredentials = '$baseUrl/auth/set-credentials';
  static const String checkUsername = '$baseUrl/auth/check-username';
  static const String socialLogin = '$baseUrl/auth/social-login';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String resetPassword = '$baseUrl/auth/reset-password';
  static const String me = '$baseUrl/auth/me';
  static const String profile = '$baseUrl/auth/profile';
  static const String privacy = '$baseUrl/auth/privacy';
  static const String security = '$baseUrl/auth/security';
  static const String deleteAccount = '$baseUrl/auth/account';
  static const String logout = '$baseUrl/auth/logout';
  static const String broadcastAuth = '$baseUrl/broadcasting/auth';

  // Couple Connection
  static const String coupleSearch = '$baseUrl/couple/search';
  static const String coupleRequest = '$baseUrl/couple/request';
  static const String coupleRequests = '$baseUrl/couple/requests';
  static const String coupleRemovePartner = '$baseUrl/couple/remove-partner';
  static const String coupleBlock = '$baseUrl/couple/block';
  static const String coupleReport = '$baseUrl/couple/report';
  static const String coupleSpace = '$baseUrl/couple/space';

  // Chat
  static const String chatMessages = '$baseUrl/chat/messages';
  static const String chatPinned = '$baseUrl/chat/pinned';
  static const String chatRead = '$baseUrl/chat/messages/read';
  static const String chatUpload = '$baseUrl/chat/upload';
  static const String chatVoice = '$baseUrl/chat/voice';
  static const String chatDocuments = '$baseUrl/chat/documents';

  // Calendar
  static const String calendarEvents = '$baseUrl/calendar/events';

  // Memories
  static const String memories = '$baseUrl/memories';
  static const String memoryAlbums = '$baseUrl/memories/albums';

  // Games
  static const String gameSessions = '$baseUrl/games/sessions';
  static const String gameStart = '$baseUrl/games/start';
  static const String gameLeaderboard = '$baseUrl/games/leaderboard';

  // Vision Board
  static const String visionBoards = '$baseUrl/vision-boards';

  // Streak
  static const String streakStatus = '$baseUrl/streak/status';
  static const String streakCheckIn = '$baseUrl/streak/check-in';
  static const String streakSummary = '$baseUrl/streak/summary';

  // AI
  static const String aiAnalyzeTone = '$baseUrl/ai/analyze-tone';
  static const String aiGenerateRomance = '$baseUrl/ai/generate-romance';
  static const String aiPlanDate = '$baseUrl/ai/plan-date';

  // Admin
  static const String adminDashboard = '$baseUrl/admin/dashboard';
  static const String adminUsers = '$baseUrl/admin/users';
  static const String adminReports = '$baseUrl/admin/reports';
}
