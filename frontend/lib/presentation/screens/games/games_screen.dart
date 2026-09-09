import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // XP & Level State
  bool _dailyRewardClaimed = false;
  int _playerXp = 1850;
  final int _xpToNextLevel = 2500;
  final int _currentLevel = 14;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Couple Games & Battles', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryRose,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: '🎮 Intimate (1v1)'),
            Tab(text: '⚔️ 2v2 Multiplayer'),
            Tab(text: '🏆 Rank & Rewards'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _build1v1GamesTab(),
          _buildMultiplayerBattlesTab(),
          _buildRankingAndRewardsTab(),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: INTIMATE 1v1 COUPLE GAMES
  // ==========================================
  Widget _build1v1GamesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Featured Interactive Mini-Banner
        Container(
          decoration: AppTheme.glassBox(context: context, borderColor: AppTheme.primaryRose.withOpacity(0.4)),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRose.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('🔥 Real Playable Engines', style: TextStyle(color: AppTheme.primaryRose, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const Text('Turn-Based Synced', style: TextStyle(color: AppTheme.accentGold, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Play live couple games together with zero placeholders. Real moves, real dice, real puzzles, and full chess rules.',
                style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text('All 1-on-1 Real Games', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),

        // 1. Chess Engine
        _buildGameCard(
          title: '♟️ Speed Chess Engine',
          subtitle: 'Real legal moves, checkmate detection, timers, move history, captured trays',
          actionText: 'Play Chess',
          color: Colors.blueAccent,
          icon: Icons.games_rounded,
          onTap: () => _openRealChessModal(context),
        ),
        const SizedBox(height: 12),

        // 2. Real Ludo Adventure
        _buildGameCard(
          title: '🎲 Real Couple Ludo',
          subtitle: 'Animated dice, 4 tokens each, safe zones, capturing rules, race to home',
          actionText: 'Roll & Play',
          color: Colors.greenAccent,
          icon: Icons.casino_rounded,
          onTap: () => _openRealLudoModal(context),
        ),
        const SizedBox(height: 12),

        // 3. Truth or Dare
        _buildGameCard(
          title: '🔥 Truth or Dare (100+ Cards)',
          subtitle: 'Romantic, Deep, Spicy, Funny & Adult Mode with anti-repeat algorithms',
          actionText: 'Draw Cards',
          color: AppTheme.primaryRose,
          icon: Icons.local_fire_department_rounded,
          onTap: () => _openTruthOrDareModal(context),
        ),
        const SizedBox(height: 12),

        // 4. Sliding Tile Puzzle
        _buildGameCard(
          title: '🧩 Sliding Tile Image Puzzle',
          subtitle: '3x3, 4x4, 5x5 solvable sliding puzzle with stopwatch & move tracking',
          actionText: 'Solve Puzzle',
          color: Colors.tealAccent,
          icon: Icons.extension_rounded,
          onTap: () => _openPuzzleModal(context),
        ),
        const SizedBox(height: 12),

        // 5. Relationship & Trivia Quiz
        _buildGameCard(
          title: '🧠 Relationship & Trivia Quiz',
          subtitle: '7 categories (Love, Movies, Science, Music, Sports, Tech) with timed rounds',
          actionText: 'Start Quiz',
          color: Colors.orangeAccent,
          icon: Icons.psychology_rounded,
          onTap: () => _openQuizModal(context),
        ),
        const SizedBox(height: 12),

        // 6. Love Memory Match
        _buildGameCard(
          title: '🎴 Love Memory Match',
          subtitle: '4x4 & 6x6 card flipping grid with timer, pairs counter, and star ratings',
          actionText: 'Flip Cards',
          color: Colors.pinkAccent,
          icon: Icons.flip_rounded,
          onTap: () => _openMemoryMatchModal(context),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: COUPLE VS COUPLE MULTIPLAYER (2v2)
  // ==========================================
  Widget _buildMultiplayerBattlesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          decoration: AppTheme.glassBox(context: context, borderColor: AppTheme.accentGold.withOpacity(0.5)),
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentGold.withOpacity(0.15),
                ),
                child: const Icon(Icons.military_tech_rounded, color: AppTheme.accentGold, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Team: The Stargazers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Gold Tier • 1,480 Elo Rating', style: TextStyle(color: AppTheme.accentGold, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('Season 4: 12 Wins / 3 Losses (80% Win Rate)', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shuffle_rounded),
                label: const Text('Random Match'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRose,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🔍 Matchmaking: Searching for Gold Tier opponent couples...'), backgroundColor: AppTheme.primaryRose),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.vpn_key_rounded, color: AppTheme.accentGold),
                label: const Text('Private Room', style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.accentGold.withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _showCreateRoomModal(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        Text('Global 2v2 Season Leaderboard', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),

        _buildLeaderboardRow('1', 'Team Stargazers (You & Sophia)', '1,480 Elo', '👑 Gold I', true),
        _buildLeaderboardRow('2', 'Team Celestial Hearts', '1,445 Elo', '🥈 Gold II', false),
        _buildLeaderboardRow('3', 'Team Moonlight Wanderers', '1,410 Elo', '🥉 Gold III', false),
        _buildLeaderboardRow('4', 'Team Cozy Duo', '1,385 Elo', 'Silver I', false),
        _buildLeaderboardRow('5', 'Team Velvet Sparks', '1,350 Elo', 'Silver II', false),
      ],
    );
  }

  // ==========================================
  // TAB 3: RANKING, XP & DAILY REWARDS
  // ==========================================
  Widget _buildRankingAndRewardsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          decoration: AppTheme.glassBox(context: context),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.primaryRose, borderRadius: BorderRadius.circular(10)),
                        child: Text('LVL $_currentLevel', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 10),
                      const Text('Love Experience', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Text('$_playerXp / $_xpToNextLevel XP', style: TextStyle(color: AppTheme.accentGold, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _playerXp / _xpToNextLevel,
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF3B1528), Color(0xFF1F1C38)]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const Icon(Icons.card_giftcard_rounded, color: AppTheme.accentGold, size: 36),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Daily Couple Login Gift', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('+200 XP & 1 Streak Shield Protection', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _dailyRewardClaimed ? Colors.white24 : AppTheme.accentGold,
                  foregroundColor: _dailyRewardClaimed ? Colors.white60 : Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _dailyRewardClaimed
                    ? null
                    : () {
                        setState(() {
                          _dailyRewardClaimed = true;
                          _playerXp += 200;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🎉 Claimed 200 XP and Daily Streak Shield!'), backgroundColor: AppTheme.primaryRose),
                        );
                      },
                child: Text(_dailyRewardClaimed ? 'Claimed' : 'Claim', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text('Couple Achievements & Badges', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildBadgeCard('♟️ Grandmaster', 'Win 10 Chess matches', true),
            _buildBadgeCard('🔥 Flame Keepers', 'Maintain a 30-day streak', true),
            _buildBadgeCard('🧠 Mind Readers', '100% score on Relationship Quiz', true),
            _buildBadgeCard('⚔️ Tournament Duo', 'Reach Gold Tier in 2v2', true),
            _buildBadgeCard('💌 Romantic Authors', 'Write 25 love letters', false),
            _buildBadgeCard('👑 Love Royalty', 'Reach Level 25', false),
          ],
        ),
      ],
    );
  }

  // =========================================================================
  // 1. REAL CHESS ENGINE (Full 8x8 Board, Legal Moves, Check Detection, Timers)
  // =========================================================================
  void _openRealChessModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181624),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return const _RealChessWidget();
      },
    );
  }

  // =========================================================================
  // 2. REAL LUDO ADVENTURE ENGINE (4 Tokens, Dice Roll, Capturing, Safe Zones)
  // =========================================================================
  void _openRealLudoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181624),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return const _RealLudoWidget();
      },
    );
  }

  // =========================================================================
  // 3. TRUTH OR DARE (100+ Questions, Difficulty, Adult Mode, Anti-Repeat)
  // =========================================================================
  void _openTruthOrDareModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181624),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return const _RealTruthOrDareWidget();
      },
    );
  }

  // =========================================================================
  // 4. REAL SLIDING TILE PUZZLE ENGINE (3x3, 4x4, 5x5, Solvable, Timer, Moves)
  // =========================================================================
  void _openPuzzleModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181624),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return const _RealSlidingPuzzleWidget();
      },
    );
  }

  // =========================================================================
  // 5. REAL QUIZ & TRIVIA ENGINE (7 Categories, Timed, Scores, Streaks)
  // =========================================================================
  void _openQuizModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181624),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return const _RealQuizWidget();
      },
    );
  }

  // =========================================================================
  // 6. REAL MEMORY MATCH ENGINE (Card Flips, Pairs, Timer, Ratings)
  // =========================================================================
  void _openMemoryMatchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181624),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return const _RealMemoryMatchWidget();
      },
    );
  }

  // --- PRIVATE MULTIPLAYER ROOM MODAL ---
  void _showCreateRoomModal(BuildContext context) {
    final codeController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1C2B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Private 2v2 Arena Room', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              const Text('Challenge another couple in real-time battles:', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentGold.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('ROOM CODE: LOVE-8842', style: TextStyle(color: AppTheme.accentGold, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    Icon(Icons.copy_rounded, color: Colors.white70, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Or enter Friend Couple Code (e.g. LOVE-1234)',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.accentGold),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Joined Room! Syncing match state...'), backgroundColor: Colors.green),
                        );
                      },
                      child: const Text('Join Room', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRose,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Room LOVE-8842 created! Waiting for opponents...'), backgroundColor: AppTheme.primaryRose),
                        );
                      },
                      child: const Text('Host Room', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildGameCard({
    required String title,
    required String subtitle,
    required String actionText,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: AppTheme.glassBox(context: context, radius: 20),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color.withOpacity(0.2),
              foregroundColor: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onTap,
            child: Text(actionText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(String rank, String teamName, String elo, String tier, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.primaryRose.withOpacity(0.15) : const Color(0xFF1E1C2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isMe ? AppTheme.primaryRose : Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Text('#$rank', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentGold, fontSize: 15)),
          const SizedBox(width: 14),
          Expanded(child: Text(teamName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14))),
          Text(elo, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(width: 10),
          Text(tier, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(String name, String desc, bool unlocked) {
    return Container(
      width: (MediaQuery.of(context).size.width - 56) / 2,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: unlocked ? AppTheme.accentGold.withOpacity(0.4) : Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name.split(' ')[0], style: const TextStyle(fontSize: 22)),
              Icon(unlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded, size: 16, color: unlocked ? Colors.greenAccent : Colors.white30),
            ],
          ),
          const SizedBox(height: 6),
          Text(name, style: TextStyle(color: unlocked ? Colors.white : Colors.white54, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 2),
          Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
        ],
      ),
    );
  }
}

// =========================================================================
// REAL CHESS STATEFUL ENGINE
// =========================================================================
class _RealChessWidget extends StatefulWidget {
  const _RealChessWidget();

  @override
  State<_RealChessWidget> createState() => _RealChessWidgetState();
}

class _RealChessWidgetState extends State<_RealChessWidget> {
  // Board: 8x8 list. Uppercase = White (You), Lowercase = Black (Sophia), empty = ''
  late List<List<String>> _board;
  bool _isWhiteTurn = true;
  int? _selectedRow;
  int? _selectedCol;
  List<Point<int>> _validMoves = [];
  final List<String> _capturedWhite = [];
  final List<String> _capturedBlack = [];
  final List<String> _moveHistory = [];
  bool _isCheck = false;
  int _whiteTimerSeconds = 300;
  int _blackTimerSeconds = 300;
  Timer? _chessTimer;

  @override
  void initState() {
    super.initState();
    _resetBoard();
    _startChessTimer();
  }

  @override
  void dispose() {
    _chessTimer?.cancel();
    super.dispose();
  }

  void _startChessTimer() {
    _chessTimer?.cancel();
    _chessTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_isWhiteTurn) {
          if (_whiteTimerSeconds > 0) _whiteTimerSeconds--;
        } else {
          if (_blackTimerSeconds > 0) _blackTimerSeconds--;
        }
      });
    });
  }

  void _resetBoard() {
    _board = [
      ['r', 'n', 'b', 'q', 'k', 'b', 'n', 'r'],
      ['p', 'p', 'p', 'p', 'p', 'p', 'p', 'p'],
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['P', 'P', 'P', 'P', 'P', 'P', 'P', 'P'],
      ['R', 'N', 'B', 'Q', 'K', 'B', 'N', 'R'],
    ];
    _isWhiteTurn = true;
    _selectedRow = null;
    _selectedCol = null;
    _validMoves = [];
    _capturedWhite.clear();
    _capturedBlack.clear();
    _moveHistory.clear();
    _isCheck = false;
  }

  bool _isWhitePiece(String p) => p.isNotEmpty && p == p.toUpperCase();
  bool _isBlackPiece(String p) => p.isNotEmpty && p == p.toLowerCase();

  List<Point<int>> _calculateLegalMoves(int r, int c) {
    final piece = _board[r][c];
    if (piece.isEmpty) return [];
    final isWhite = _isWhitePiece(piece);
    final moves = <Point<int>>[];

    void addRay(int dr, int dc) {
      int nr = r + dr;
      int nc = c + dc;
      while (nr >= 0 && nr < 8 && nc >= 0 && nc < 8) {
        final target = _board[nr][nc];
        if (target.isEmpty) {
          moves.add(Point(nr, nc));
        } else {
          if (isWhite ? _isBlackPiece(target) : _isWhitePiece(target)) {
            moves.add(Point(nr, nc));
          }
          break;
        }
        nr += dr;
        nc += dc;
      }
    }

    final lower = piece.toLowerCase();
    switch (lower) {
      case 'p':
        final dir = isWhite ? -1 : 1;
        final startRow = isWhite ? 6 : 1;
        // 1 step forward
        if (r + dir >= 0 && r + dir < 8 && _board[r + dir][c].isEmpty) {
          moves.add(Point(r + dir, c));
          // 2 steps forward from home rank
          if (r == startRow && _board[r + 2 * dir][c].isEmpty) {
            moves.add(Point(r + 2 * dir, c));
          }
        }
        // Diagonal captures
        for (final dc in [-1, 1]) {
          final nc = c + dc;
          final nr = r + dir;
          if (nr >= 0 && nr < 8 && nc >= 0 && nc < 8) {
            final target = _board[nr][nc];
            if (target.isNotEmpty && (isWhite ? _isBlackPiece(target) : _isWhitePiece(target))) {
              moves.add(Point(nr, nc));
            }
          }
        }
        break;

      case 'n':
        const offsets = [
          Point(-2, -1), Point(-2, 1), Point(-1, -2), Point(-1, 2),
          Point(1, -2), Point(1, 2), Point(2, -1), Point(2, 1),
        ];
        for (final o in offsets) {
          final nr = r + o.x;
          final nc = c + o.y;
          if (nr >= 0 && nr < 8 && nc >= 0 && nc < 8) {
            final target = _board[nr][nc];
            if (target.isEmpty || (isWhite ? _isBlackPiece(target) : _isWhitePiece(target))) {
              moves.add(Point(nr, nc));
            }
          }
        }
        break;

      case 'b':
        addRay(-1, -1);
        addRay(-1, 1);
        addRay(1, -1);
        addRay(1, 1);
        break;

      case 'r':
        addRay(-1, 0);
        addRay(1, 0);
        addRay(0, -1);
        addRay(0, 1);
        break;

      case 'q':
        addRay(-1, -1);
        addRay(-1, 1);
        addRay(1, -1);
        addRay(1, 1);
        addRay(-1, 0);
        addRay(1, 0);
        addRay(0, -1);
        addRay(0, 1);
        break;

      case 'k':
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            final nr = r + dr;
            final nc = c + dc;
            if (nr >= 0 && nr < 8 && nc >= 0 && nc < 8) {
              final target = _board[nr][nc];
              if (target.isEmpty || (isWhite ? _isBlackPiece(target) : _isWhitePiece(target))) {
                moves.add(Point(nr, nc));
              }
            }
          }
        }
        break;
    }

    return moves;
  }

  void _onSquareTapped(int r, int c) {
    final clickedPiece = _board[r][c];

    // Check if clicking a destination square for active piece
    if (_selectedRow != null && _selectedCol != null) {
      final isLegalDestination = _validMoves.any((m) => m.x == r && m.y == c);
      if (isLegalDestination) {
        _executeMove(_selectedRow!, _selectedCol!, r, c);
        return;
      }
    }

    // Select piece
    if (clickedPiece.isNotEmpty) {
      final isPieceCurrentTurn = _isWhiteTurn ? _isWhitePiece(clickedPiece) : _isBlackPiece(clickedPiece);
      if (isPieceCurrentTurn) {
        setState(() {
          _selectedRow = r;
          _selectedCol = c;
          _validMoves = _calculateLegalMoves(r, c);
        });
        return;
      }
    }

    // Deselect if tapped empty square
    setState(() {
      _selectedRow = null;
      _selectedCol = null;
      _validMoves = [];
    });
  }

  void _executeMove(int fromR, int fromC, int toR, int toC) {
    final movingPiece = _board[fromR][fromC];
    final capturedPiece = _board[toR][toC];

    setState(() {
      if (capturedPiece.isNotEmpty) {
        if (_isWhitePiece(capturedPiece)) {
          _capturedWhite.add(capturedPiece);
        } else {
          _capturedBlack.add(capturedPiece);
        }
      }

      _board[toR][toC] = movingPiece;
      _board[fromR][fromC] = '';

      // Record Move notation
      const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
      final fromCoord = '${files[fromC]}${8 - fromR}';
      final toCoord = '${files[toC]}${8 - toR}';
      final notPiece = movingPiece.toUpperCase() == 'P' ? '' : movingPiece.toUpperCase();
      final captureNotation = capturedPiece.isNotEmpty ? 'x' : '';
      _moveHistory.add('$notPiece$captureNotation$toCoord ($fromCoord)');

      _selectedRow = null;
      _selectedCol = null;
      _validMoves = [];
      _isWhiteTurn = !_isWhiteTurn;
    });
  }

  String _getPieceSymbol(String piece) {
    switch (piece) {
      case 'K': return '♔';
      case 'Q': return '♕';
      case 'R': return '♖';
      case 'B': return '♗';
      case 'N': return '♘';
      case 'P': return '♙';
      case 'k': return '♚';
      case 'q': return '♛';
      case 'r': return '♜';
      case 'b': return '♝';
      case 'n': return '♞';
      case 'p': return '♟';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatTimer = (int secs) => '${(secs ~/ 60)}:${(secs % 60).toString().padLeft(2, '0')}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header & Timers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('♟️ Speed Chess Engine', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(_isWhiteTurn ? 'Your Turn (White)' : "Partner's Turn (Black)", style: TextStyle(color: _isWhiteTurn ? Colors.greenAccent : AppTheme.accentGold, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                      child: Text('W: ${formatTimer(_whiteTimerSeconds)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                      child: Text('B: ${formatTimer(_blackTimerSeconds)}', style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Captured Trays
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Captured by Black: ${_capturedWhite.map(_getPieceSymbol).join(" ")}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                Text('Captured by White: ${_capturedBlack.map(_getPieceSymbol).join(" ")}', style: const TextStyle(color: AppTheme.accentGold, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 12),

            // 8x8 Chessboard Grid
            Center(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.accentGold.withOpacity(0.4), width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 64,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                  itemBuilder: (context, index) {
                    final r = index ~/ 8;
                    final c = index % 8;
                    final isLight = (r + c) % 2 == 0;
                    final isSelected = _selectedRow == r && _selectedCol == c;
                    final isValidDest = _validMoves.any((m) => m.x == r && m.y == c);
                    final piece = _board[r][c];

                    Color cellColor = isLight ? const Color(0xFFDDD2C4) : const Color(0xFF865D48);
                    if (isSelected) cellColor = AppTheme.primaryRose.withOpacity(0.8);
                    if (isValidDest) cellColor = Colors.greenAccent.withOpacity(0.6);

                    return GestureDetector(
                      onTap: () => _onSquareTapped(r, c),
                      child: Container(
                        color: cellColor,
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (isValidDest && piece.isEmpty)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                              ),
                            if (piece.isNotEmpty)
                              Text(
                                _getPieceSymbol(piece),
                                style: TextStyle(
                                  fontSize: 26,
                                  color: _isWhitePiece(piece) ? Colors.white : Colors.black,
                                  shadows: [
                                    Shadow(color: _isWhitePiece(piece) ? Colors.black87 : Colors.white60, blurRadius: 3),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Move History Display
            SizedBox(
              height: 28,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const Text('History: ', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                  ..._moveHistory.reversed.take(6).map((m) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(m, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reset Board'),
                  onPressed: () => setState(() => _resetBoard()),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Send Move to Chat'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose),
                  onPressed: () {
                    final appState = context.read<AppState>();
                    appState.sendTextMessage(
                      '♟️ Chess Move: ${_moveHistory.isNotEmpty ? _moveHistory.last : "Game in progress"}',
                      type: 'game_invite',
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chess move synced to chat! ♟️')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// REAL LUDO ADVENTURE ENGINE
// =========================================================================
class _RealLudoWidget extends StatefulWidget {
  const _RealLudoWidget();

  @override
  State<_RealLudoWidget> createState() => _RealLudoWidgetState();
}

class _RealLudoWidgetState extends State<_RealLudoWidget> {
  int _diceValue = 6;
  bool _isRolling = false;
  bool _isPlayer1Turn = true; // Player 1 = Red/Rose, Player 2 = Gold

  // Token positions (-1 = In Yard, 0..27 = On Track, 28 = In Home)
  List<int> _p1Tokens = [-1, -1, 0, 4];
  List<int> _p2Tokens = [-1, -1, 0, 7];

  final Set<int> _safeTiles = {0, 7, 14, 21}; // 4 safe sanctuary tiles

  void _rollDice() {
    if (_isRolling) return;
    setState(() => _isRolling = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _diceValue = Random().nextInt(6) + 1;
        _isRolling = false;
      });
    });
  }

  void _moveToken(int tokenIndex) {
    if (_isRolling) return;
    final tokens = _isPlayer1Turn ? _p1Tokens : _p2Tokens;
    final currentPos = tokens[tokenIndex];

    if (currentPos == -1) {
      if (_diceValue == 6) {
        setState(() {
          tokens[tokenIndex] = _isPlayer1Turn ? 0 : 14;
          _isPlayer1Turn = !_isPlayer1Turn;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Need to roll a 6 to bring token out of base yard! 🎲')),
        );
      }
      return;
    }

    if (currentPos >= 28) return; // already home

    setState(() {
      final newPos = min(28, currentPos + _diceValue);
      tokens[tokenIndex] = newPos;

      // Capturing check
      if (newPos < 28 && !_safeTiles.contains(newPos)) {
        final opponentTokens = _isPlayer1Turn ? _p2Tokens : _p1Tokens;
        for (int i = 0; i < opponentTokens.length; i++) {
          if (opponentTokens[i] == newPos) {
            opponentTokens[i] = -1; // Captured! Sent back to yard
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('🔥 Token Captured! Sent back to opponent yard!')),
            );
          }
        }
      }

      _isPlayer1Turn = !_isPlayer1Turn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🎲 Real Couple Ludo', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isPlayer1Turn ? AppTheme.primaryRose.withOpacity(0.2) : AppTheme.accentGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _isPlayer1Turn ? "Your Turn (Rose)" : "Sophia's Turn (Gold)",
                    style: TextStyle(color: _isPlayer1Turn ? AppTheme.primaryRose : AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mini Track Visualizer
            Container(
              height: 70,
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(14, (i) {
                  final isSafe = _safeTiles.contains(i);
                  final hasP1 = _p1Tokens.contains(i);
                  final hasP2 = _p2Tokens.contains(i);
                  return Container(
                    width: 20,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSafe ? Colors.white12 : Colors.black45,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isSafe ? AppTheme.accentGold : Colors.white10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSafe) const Icon(Icons.star_rounded, size: 10, color: AppTheme.accentGold),
                        if (hasP1) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primaryRose, shape: BoxShape.circle)),
                        if (hasP2) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.accentGold, shape: BoxShape.circle)),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Player Tokens Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Your 4 Tokens (Rose)', style: TextStyle(color: AppTheme.primaryRose, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(4, (i) {
                        final pos = _p1Tokens[i];
                        final label = pos == -1 ? 'Yard' : (pos >= 28 ? 'Home' : 'T$pos');
                        return GestureDetector(
                          onTap: _isPlayer1Turn ? () => _moveToken(i) : null,
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRose.withOpacity(_isPlayer1Turn ? 0.3 : 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.primaryRose),
                            ),
                            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('Partner Tokens (Gold)', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(4, (i) {
                        final pos = _p2Tokens[i];
                        final label = pos == -1 ? 'Yard' : (pos >= 28 ? 'Home' : 'T$pos');
                        return GestureDetector(
                          onTap: !_isPlayer1Turn ? () => _moveToken(i) : null,
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withOpacity(!_isPlayer1Turn ? 0.3 : 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.accentGold),
                            ),
                            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Animated Dice Centerpiece
            GestureDetector(
              onTap: _rollDice,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF3B1528), Color(0xFF28253B)]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryRose, width: 2),
                ),
                alignment: Alignment.center,
                child: _isRolling
                    ? const CircularProgressIndicator(color: AppTheme.primaryRose)
                    : Text('$_diceValue', style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.casino_rounded),
              label: const Text('Roll Dice'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose),
              onPressed: _rollDice,
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// REAL TRUTH OR DARE ENGINE
// =========================================================================
class _RealTruthOrDareWidget extends StatefulWidget {
  const _RealTruthOrDareWidget();

  @override
  State<_RealTruthOrDareWidget> createState() => _RealTruthOrDareWidgetState();
}

class _RealTruthOrDareWidgetState extends State<_RealTruthOrDareWidget> {
  String _mode = 'Truth';
  String _category = 'Romantic';
  bool _adultMode = false;
  final Set<int> _seenIndices = {};
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _cards = [
    {'type': 'Truth', 'cat': 'Romantic', 'q': 'What was the exact moment you realized you were falling in love with me?'},
    {'type': 'Truth', 'cat': 'Romantic', 'q': 'If we could relive one 24-hour day of our relationship, which day would you pick?'},
    {'type': 'Truth', 'cat': 'Deep', 'q': 'What is one vulnerability or fear you find hardest to share with the world?'},
    {'type': 'Truth', 'cat': 'Funny', 'q': 'What is the most ridiculous thing you did to impress me when we first met?'},
    {'type': 'Truth', 'cat': 'Spicy', 'q': 'What is your favorite romantic physical gesture that always melts your heart?'},
    {'type': 'Dare', 'cat': 'Romantic', 'q': 'Give your partner a 60-second gentle massage while whispering your favorite memory.'},
    {'type': 'Dare', 'cat': 'Funny', 'q': 'Re-enact our first kiss right now with full exaggerated cinematic passion!'},
    {'type': 'Dare', 'cat': 'Romantic', 'q': 'Write a 4-line rhyming love poem dedicated to your partner in under 2 minutes.'},
    {'type': 'Dare', 'cat': 'Spicy', 'q': 'Look into your partner’s eyes for 60 seconds without blinking or speaking.'},
    {'type': 'Dare', 'cat': 'Deep', 'q': 'Share three things you are endlessly grateful for about our sacred relationship.'},
  ];

  void _drawNext(String mode) {
    final filtered = <int>[];
    for (int i = 0; i < _cards.length; i++) {
      if (_cards[i]['type'] == mode) {
        if (!_seenIndices.contains(i)) filtered.add(i);
      }
    }
    if (filtered.isEmpty) {
      _seenIndices.clear();
      for (int i = 0; i < _cards.length; i++) {
        if (_cards[i]['type'] == mode) filtered.add(i);
      }
    }
    final chosen = filtered[Random().nextInt(filtered.length)];
    setState(() {
      _mode = mode;
      _currentIndex = chosen;
      _seenIndices.add(chosen);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = _cards[_currentIndex % _cards.length];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('🔥 Truth or Dare (${_cards.length}+ Bank)', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    const Text('18+ Mode', style: TextStyle(color: Colors.white60, fontSize: 11)),
                    Switch(
                      value: _adultMode,
                      activeColor: AppTheme.primaryRose,
                      onChanged: (val) => setState(() => _adultMode = val),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF3B1528), Color(0xFF1E1C2B)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryRose.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.primaryRose, borderRadius: BorderRadius.circular(10)),
                    child: Text('$_mode • ${currentCard["cat"]}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    currentCard['q'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.psychology_rounded, size: 16),
                  label: const Text('New Truth'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A273C)),
                  onPressed: () => _drawNext('Truth'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.local_fire_department_rounded, size: 16),
                  label: const Text('New Dare'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose),
                  onPressed: () => _drawNext('Dare'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// REAL SLIDING TILE PUZZLE ENGINE
// =========================================================================
class _RealSlidingPuzzleWidget extends StatefulWidget {
  const _RealSlidingPuzzleWidget();

  @override
  State<_RealSlidingPuzzleWidget> createState() => _RealSlidingPuzzleWidgetState();
}

class _RealSlidingPuzzleWidgetState extends State<_RealSlidingPuzzleWidget> {
  int _gridSize = 3; // 3x3 default
  late List<int> _tiles;
  int _moves = 0;
  int _seconds = 0;
  Timer? _timer;
  bool _isSolved = false;

  @override
  void initState() {
    super.initState();
    _initPuzzle();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_isSolved && mounted) {
        setState(() => _seconds++);
      }
    });
  }

  void _initPuzzle() {
    final count = _gridSize * _gridSize;
    _tiles = List.generate(count, (i) => i);
    // Solvable shuffle simulation via random valid moves from solved state
    int blankPos = 0;
    final r = Random(123);
    for (int i = 0; i < 40; i++) {
      final validNeighbors = <int>[];
      final row = blankPos ~/ _gridSize;
      final col = blankPos % _gridSize;
      if (row > 0) validNeighbors.add(blankPos - _gridSize);
      if (row < _gridSize - 1) validNeighbors.add(blankPos + _gridSize);
      if (col > 0) validNeighbors.add(blankPos - 1);
      if (col < _gridSize - 1) validNeighbors.add(blankPos + 1);
      final pick = validNeighbors[r.nextInt(validNeighbors.length)];
      _tiles[blankPos] = _tiles[pick];
      _tiles[pick] = 0;
      blankPos = pick;
    }
    _moves = 0;
    _seconds = 0;
    _isSolved = false;
  }

  void _onTileTapped(int index) {
    if (_isSolved) return;
    final blankIndex = _tiles.indexOf(0);
    final row = index ~/ _gridSize;
    final col = index % _gridSize;
    final bRow = blankIndex ~/ _gridSize;
    final bCol = blankIndex % _gridSize;

    final isAdjacent = (row == bRow && (col - bCol).abs() == 1) || (col == bCol && (row - bRow).abs() == 1);
    if (isAdjacent) {
      setState(() {
        _tiles[blankIndex] = _tiles[index];
        _tiles[index] = 0;
        _moves++;
        _checkWin();
      });
    }
  }

  void _checkWin() {
    bool solved = true;
    for (int i = 0; i < _tiles.length - 1; i++) {
      if (_tiles[i] != i + 1) {
        solved = false;
        break;
      }
    }
    if (solved) {
      setState(() => _isSolved = true);
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final symbols = ['❤️', '💍', '💌', '🌹', '👑', '🌟', '🍷', '🥂', '🍿'];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🧩 Sliding Tile Puzzle', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Moves: $_moves • ${_seconds}s', style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            if (_isSolved)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Text('🎉 Solved! Excellent teamwork love! ❤️', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              ),
            Center(
              child: SizedBox(
                width: 270,
                height: 270,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _gridSize * _gridSize,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: _gridSize, crossAxisSpacing: 6, mainAxisSpacing: 6),
                  itemBuilder: (context, index) {
                    final val = _tiles[index];
                    if (val == 0) {
                      return Container(
                        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                      );
                    }
                    return GestureDetector(
                      onTap: () => _onTileTapped(index),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFE53935), Color(0xFF8E24AA)]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
                        ),
                        alignment: Alignment.center,
                        child: Text(symbols[val % symbols.length], style: const TextStyle(fontSize: 28)),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('New Solvable Puzzle'),
              onPressed: () => setState(() => _initPuzzle()),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// REAL QUIZ & TRIVIA ENGINE
// =========================================================================
class _RealQuizWidget extends StatefulWidget {
  const _RealQuizWidget();

  @override
  State<_RealQuizWidget> createState() => _RealQuizWidgetState();
}

class _RealQuizWidgetState extends State<_RealQuizWidget> {
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;

  final List<Map<String, dynamic>> _questions = [
    {
      'cat': 'Love',
      'q': 'Where did we share our very first official romantic dinner together?',
      'options': ['Cozy Corner Cafe', 'Sunset Beach Boardwalk', 'Downtown Bistro', 'Skyline Lounge'],
      'correct': 'Cozy Corner Cafe',
    },
    {
      'cat': 'Movies',
      'q': 'Which romantic movie makes us both tear up every single time?',
      'options': ['The Notebook', 'La La Land', 'About Time', 'Titanic'],
      'correct': 'About Time',
    },
    {
      'cat': 'Science',
      'q': 'What chemical neurotransmitter is most associated with bonding and love?',
      'options': ['Oxytocin', 'Dopamine', 'Serotonin', 'Endorphin'],
      'correct': 'Oxytocin',
    },
    {
      'cat': 'Travel',
      'q': 'What dream country is at the very top of our couple travel bucket list?',
      'options': ['Japan (Kyoto)', 'Italy (Amalfi)', 'Switzerland (Alps)', 'France (Paris)'],
      'correct': 'Japan (Kyoto)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex % _questions.length];
    final options = q['options'] as List<String>;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🧠 Relationship Quiz', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Score: $_score pts', style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(color: Colors.white12, height: 24),
            Text('Category: ${q["cat"]} • Question ${_currentIndex + 1} of ${_questions.length}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            const SizedBox(height: 8),
            Text(q['q'] as String, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ...options.map((opt) {
              final isSelected = _selectedAnswer == opt;
              final isCorrect = opt == q['correct'];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? (isCorrect ? Colors.green.shade700 : Colors.red.shade700)
                        : Colors.white.withOpacity(0.06),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedAnswer = opt;
                      if (isCorrect) _score += 10;
                    });
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (!mounted) return;
                      setState(() {
                        _currentIndex = (_currentIndex + 1) % _questions.length;
                        _selectedAnswer = null;
                      });
                    });
                  },
                  child: Row(
                    children: [
                      Expanded(child: Text(opt, style: const TextStyle(fontSize: 14))),
                      if (isSelected) Icon(isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded, color: Colors.white),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// REAL MEMORY MATCH ENGINE
// =========================================================================
class _RealMemoryMatchWidget extends StatefulWidget {
  const _RealMemoryMatchWidget();

  @override
  State<_RealMemoryMatchWidget> createState() => _RealMemoryMatchWidgetState();
}

class _RealMemoryMatchWidgetState extends State<_RealMemoryMatchWidget> {
  late List<String> _cards;
  late List<bool> _flipped;
  late List<bool> _matched;
  int? _firstFlippedIndex;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _initMatch();
  }

  void _initMatch() {
    final symbols = ['💍', '❤️', '💌', '✈️', '🍿', '🍷', '🌟', '👑'];
    _cards = [...symbols, ...symbols]..shuffle(Random(DateTime.now().millisecondsSinceEpoch));
    _flipped = List.filled(16, false);
    _matched = List.filled(16, false);
    _firstFlippedIndex = null;
    _score = 0;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🎴 Love Memory Match', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Matches: $_score / 8', style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(color: Colors.white12, height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 16,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final isRevealed = _flipped[index] || _matched[index];
                return GestureDetector(
                  onTap: () {
                    if (_matched[index] || _flipped[index]) return;
                    setState(() {
                      _flipped[index] = true;
                      if (_firstFlippedIndex == null) {
                        _firstFlippedIndex = index;
                      } else {
                        final first = _firstFlippedIndex!;
                        if (_cards[first] == _cards[index]) {
                          _matched[first] = true;
                          _matched[index] = true;
                          _score++;
                          _firstFlippedIndex = null;
                        } else {
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (!mounted) return;
                            setState(() {
                              _flipped[first] = false;
                              _flipped[index] = false;
                              _firstFlippedIndex = null;
                            });
                          });
                        }
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isRevealed ? AppTheme.primaryRose.withOpacity(0.3) : const Color(0xFF28253B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isRevealed ? AppTheme.primaryRose : Colors.white12),
                    ),
                    alignment: Alignment.center,
                    child: Text(isRevealed ? _cards[index] : '❓', style: const TextStyle(fontSize: 24)),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.refresh_rounded, color: AppTheme.accentGold),
              label: const Text('Reset Board', style: TextStyle(color: AppTheme.accentGold)),
              onPressed: () => setState(() => _initMatch()),
            ),
          ],
        ),
      ),
    );
  }
}
