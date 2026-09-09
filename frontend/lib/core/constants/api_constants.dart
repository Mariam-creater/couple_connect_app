class ApiConstants {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  static const String wsUrl = 'ws://localhost:8080/app/couple_connect_key';

  // Auth
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String me = '$baseUrl/auth/me';
  static const String security = '$baseUrl/auth/security';
  static const String logout = '$baseUrl/auth/logout';

  // Couple
  static const String coupleSearch = '$baseUrl/couple/search';
  static const String coupleRequest = '$baseUrl/couple/request';
  static const String coupleRequests = '$baseUrl/couple/requests';
  static const String coupleSpace = '$baseUrl/couple/space';

  // Chat
  static const String chatMessages = '$baseUrl/chat/messages';
  static const String chatRead = '$baseUrl/chat/messages/read';
  static const String chatUpload = '$baseUrl/chat/upload';

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
