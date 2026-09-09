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

  // Truth or Dare
  String _currentTruthOrDare = 'What is the single most endearing habit your partner has that always makes you smile?';
  String _cardMode = 'Truth';
  String _todCategory = 'Romantic';

  // Ludo
  int _diceValue = 6;
  bool _isRollingDice = false;
  int _ludoPlayer1Pos = 14;
  int _ludoPlayer2Pos = 18;

  // Quiz
  int _quizCurrentIndex = 0;
  int _quizScore = 2;
  String? _selectedQuizAnswer;

  // Memory Match (4x4)
  late List<String> _memoryCards;
  late List<bool> _memoryFlipped;
  late List<bool> _memoryMatched;
  int? _firstFlippedIndex;
  int _memoryScore = 0;

  // Would you rather
  int _wyrIndex = 0;
  int? _wyrSelectedOption;

  // XP & Daily Reward
  bool _dailyRewardClaimed = false;
  int _playerXp = 1850;
  final int _xpToNextLevel = 2500;
  final int _currentLevel = 14;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initMemoryMatch();
  }

  void _initMemoryMatch() {
    final symbols = ['💍', '❤️', '💌', '✈️', '🍿', '🍷', '🌟', '👑'];
    _memoryCards = [...symbols, ...symbols]..shuffle(Random(42));
    _memoryFlipped = List.filled(16, false);
    _memoryMatched = List.filled(16, false);
    _firstFlippedIndex = null;
    _memoryScore = 0;
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
        // Featured Interactive Game Carousel / Selector
        Container(
          decoration: AppTheme.glassBox(context: context, borderColor: AppTheme.primaryRose.withOpacity(0.4)),
          padding: const EdgeInsets.all(20),
          child: Column(
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
                    child: Text('🔥 $_cardMode • $_todCategory', style: const TextStyle(color: AppTheme.primaryRose, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  Row(
                    children: ['Romantic', 'Deep', 'Spicy', 'Funny'].map((cat) {
                      final isSel = _todCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _todCategory = cat),
                        child: Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isSel ? AppTheme.accentGold : Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(cat, style: TextStyle(color: isSel ? Colors.black : Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _currentTruthOrDare,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600, height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.psychology_rounded, size: 16),
                    label: const Text('New Truth'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A273C)),
                    onPressed: () {
                      final truths = [
                        'What was the exact moment you realized you were falling in love with me?',
                        'If we could relive one 24-hour day of our relationship, which day would you pick?',
                        'What is one secret fantasy or dream you haven’t told me yet?',
                        'What is your favorite physical feature of mine?',
                      ];
                      setState(() {
                        _cardMode = 'Truth';
                        _currentTruthOrDare = truths[Random().nextInt(truths.length)];
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.local_fire_department_rounded, size: 16),
                    label: const Text('New Dare'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose),
                    onPressed: () {
                      final dares = [
                        'Give your partner a 60-second gentle shoulder massage while whispering your favorite memory.',
                        'Re-enact our first kiss right now with full dramatic passion!',
                        'Write a 4-line rhyming love poem dedicated to your partner in under 2 minutes.',
                        'Feed your partner a delicious treat with your eyes closed.',
                      ];
                      setState(() {
                        _cardMode = 'Dare';
                        _currentTruthOrDare = dares[Random().nextInt(dares.length)];
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text('All 1-on-1 Mini Games', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),

        // 1. Relationship Quiz
        _buildGameCard(
          title: '🧠 Relationship Quiz & Trivia',
          subtitle: 'Guess how well you truly know your partner’s memories and secrets',
          actionText: 'Play Quiz',
          color: Colors.orangeAccent,
          onTap: () => _openQuizModal(context),
        ),
        const SizedBox(height: 12),

        // 2. Memory Match Puzzle
        _buildGameCard(
          title: '🧩 Love Memory Match',
          subtitle: 'Flip cards and find matching couple icons together against the clock',
          actionText: 'Start Match',
          color: Colors.pinkAccent,
          onTap: () => _openMemoryMatchModal(context),
        ),
        const SizedBox(height: 12),

        // 3. Would You Rather
        _buildGameCard(
          title: '🤔 Would You Rather?',
          subtitle: 'Hilarious, romantic, and deep dilemma questions for couples',
          actionText: 'Pick Dilemmas',
          color: Colors.purpleAccent,
          onTap: () => _openWouldYouRatherModal(context),
        ),
        const SizedBox(height: 12),

        // 4. Couple Ludo
        _buildGameCard(
          title: '🎲 Couple Ludo Adventure',
          subtitle: 'Roll the dice and race along the romantic powerup board',
          actionText: 'Roll & Play',
          color: Colors.greenAccent,
          onTap: () => _openLudoModal(context),
        ),
        const SizedBox(height: 12),

        // 5. Speed Chess
        _buildGameCard(
          title: '♟️ Couple Speed Chess',
          subtitle: 'Real-time turn-based board with move timestamps and chat',
          actionText: 'Play Chess',
          color: Colors.blueAccent,
          onTap: () => _openChessModal(context),
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
        // Team Rating Banner
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

        // Multiplayer Action Buttons
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
        // Level & XP Bar
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

        // Daily Reward Box
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

  // ==========================================
  // GAME MODALS (Interactive Implementations)
  // ==========================================

  // Quiz Modal
  void _openQuizModal(BuildContext context) {
    final questions = [
      {
        'q': 'Where did we share our very first official date together?',
        'options': ['Cozy Corner Cafe', 'Sunset Beach Boardwalk', 'Downtown Cinema', 'Italian Bistro'],
        'correct': 'Cozy Corner Cafe',
      },
      {
        'q': 'What is your partner’s ultimate comfort meal after a long day?',
        'options': ['Steaming Ramen', 'Handmade Pizza', 'Chocolate Ice Cream', 'Spicy Noodles'],
        'correct': 'Steaming Ramen',
      },
      {
        'q': 'What dream travel destination do we talk about visiting the most?',
        'options': ['Kyoto in Cherry Blossom season', 'Santorini Cliffside', 'Swiss Alps Cozy Cabin', 'Amalfi Coast'],
        'correct': 'Kyoto in Cherry Blossom season',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1C2B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setQuizState) {
            final q = questions[_quizCurrentIndex % questions.length];
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
                        Text('Score: $_quizScore pts', style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    Text('Question ${_quizCurrentIndex + 1} of ${questions.length}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(q['q'] as String, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ...options.map((opt) {
                      final isSelected = _selectedQuizAnswer == opt;
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
                            setQuizState(() {
                              _selectedQuizAnswer = opt;
                              if (isCorrect) _quizScore += 10;
                            });
                            Future.delayed(const Duration(milliseconds: 600), () {
                              setQuizState(() {
                                _quizCurrentIndex = (_quizCurrentIndex + 1) % questions.length;
                                _selectedQuizAnswer = null;
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
          },
        );
      },
    );
  }

  // Memory Match Modal
  void _openMemoryMatchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1C2B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setMatchState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🧩 Memory Match', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Matches: $_memoryScore / 8', style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
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
                        final isRevealed = _memoryFlipped[index] || _memoryMatched[index];
                        return GestureDetector(
                          onTap: () {
                            if (_memoryMatched[index] || _memoryFlipped[index]) return;
                            setMatchState(() {
                              _memoryFlipped[index] = true;
                              if (_firstFlippedIndex == null) {
                                _firstFlippedIndex = index;
                              } else {
                                final first = _firstFlippedIndex!;
                                if (_memoryCards[first] == _memoryCards[index]) {
                                  _memoryMatched[first] = true;
                                  _memoryMatched[index] = true;
                                  _memoryScore++;
                                  _firstFlippedIndex = null;
                                } else {
                                  Future.delayed(const Duration(milliseconds: 600), () {
                                    setMatchState(() {
                                      _memoryFlipped[first] = false;
                                      _memoryFlipped[index] = false;
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
                            child: Text(isRevealed ? _memoryCards[index] : '❓', style: const TextStyle(fontSize: 24)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      icon: const Icon(Icons.refresh_rounded, color: AppTheme.accentGold),
                      label: const Text('Reset Board', style: TextStyle(color: AppTheme.accentGold)),
                      onPressed: () => setMatchState(() => _initMemoryMatch()),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Would You Rather Modal
  void _openWouldYouRatherModal(BuildContext context) {
    final pairs = [
      ['Always know what your partner is thinking', 'Always know how to make your partner laugh'],
      ['Take a spontaneous weekend flight to Paris', 'Spend an entire cozy weekend in bed watching movies'],
      ['Relive our very first date over again', 'Fast forward 20 years to see our happy future home'],
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1C2B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setWyrState) {
            final pair = pairs[_wyrIndex % pairs.length];
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🤔 Would You Rather?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildWyrOption(pair[0], 0, setWyrState),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('— OR —', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    _buildWyrOption(pair[1], 1, setWyrState),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setWyrState(() {
                          _wyrIndex = (_wyrIndex + 1) % pairs.length;
                          _wyrSelectedOption = null;
                        });
                      },
                      child: const Text('Next Dilemma →', style: TextStyle(color: AppTheme.primaryRose, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWyrOption(String text, int optionIndex, StateSetter setWyrState) {
    final isSelected = _wyrSelectedOption == optionIndex;
    return GestureDetector(
      onTap: () => setWyrState(() => _wyrSelectedOption = optionIndex),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryRose.withOpacity(0.25) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppTheme.primaryRose : Colors.white10),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }

  // Ludo Modal
  void _openLudoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1C2B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLudoState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎲 Couple Ludo Adventure', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('You (Alex)', style: TextStyle(color: AppTheme.primaryRose, fontWeight: FontWeight.bold)),
                            Text('Tile $_ludoPlayer1Pos / 30', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Partner (Sophia)', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
                            Text('Tile $_ludoPlayer2Pos / 30', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primaryRose.withOpacity(0.5)),
                      ),
                      alignment: Alignment.center,
                      child: _isRollingDice
                          ? const CircularProgressIndicator(color: AppTheme.primaryRose)
                          : Text('$_diceValue', style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.casino_rounded),
                      label: const Text('Roll Dice & Move'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                      onPressed: () {
                        setLudoState(() => _isRollingDice = true);
                        Future.delayed(const Duration(milliseconds: 400), () {
                          setLudoState(() {
                            _diceValue = Random().nextInt(6) + 1;
                            _ludoPlayer1Pos = min(30, _ludoPlayer1Pos + _diceValue);
                            _isRollingDice = false;
                          });
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Chess Modal
  void _openChessModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1C2B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('♟️ Speed Chess', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                      child: const Text('Your Turn (White)', style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 20),
                // 8x8 Mini Chessboard representation
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(border: Border.all(color: Colors.white24, width: 2)),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 64,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                    itemBuilder: (context, index) {
                      final row = index ~/ 8;
                      final col = index % 8;
                      final isWhiteCell = (row + col) % 2 == 0;
                      return Container(
                        color: isWhiteCell ? const Color(0xFFDDD2C4) : const Color(0xFF865D48),
                        alignment: Alignment.center,
                        child: Text(
                          _getChessSymbol(row, col),
                          style: TextStyle(
                            fontSize: 18,
                            color: row < 2 ? Colors.black : (row > 5 ? Colors.white : Colors.transparent),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Move e2 to e4 recorded. Turn passed to Sophia.', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getChessSymbol(int row, int col) {
    if (row == 1 || row == 6) return '♟';
    if (row == 0 || row == 7) {
      if (col == 0 || col == 7) return '♜';
      if (col == 1 || col == 6) return '♞';
      if (col == 2 || col == 5) return '♝';
      if (col == 3) return '♛';
      if (col == 4) return '♚';
    }
    return '';
  }

  // Create Private Multiplayer Room Modal
  void _showCreateRoomModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1C2B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Create Private 2v2 Room', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                const Text('Share this Room Code with another couple to challenge them:', style: TextStyle(color: Colors.white70, fontSize: 13)),
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
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Room created! Waiting for opponent couple to join...')),
                    );
                  },
                  child: const Text('Start Private Match', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper Widgets
  Widget _buildGameCard({required String title, required String subtitle, required String actionText, required Color color, required VoidCallback onTap}) {
    return Container(
      decoration: AppTheme.glassBox(context: context, radius: 20),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
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
            child: Text(actionText, style: const TextStyle(fontWeight: FontWeight.bold)),
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
