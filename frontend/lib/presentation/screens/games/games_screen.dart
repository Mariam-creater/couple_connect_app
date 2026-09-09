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

  // Active game modal demo state
  String _currentTruthOrDare = 'What is the most endearing habit your partner has that always makes you smile?';
  String _cardMode = 'Truth';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
            Tab(text: '1v1 Intimate Games'),
            Tab(text: 'Couple vs Couple (2v2)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _build1v1GamesTab(),
          _buildMultiplayerBattlesTab(),
        ],
      ),
    );
  }

  Widget _build1v1GamesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Featured Game: Truth or Dare Interactive Card
        Container(
          decoration: AppTheme.glassBox(context: context, borderColor: AppTheme.primaryRose.withOpacity(0.4)),
          padding: const EdgeInsets.all(24),
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
                    child: Text('🔥 $_cardMode Card', style: const TextStyle(color: AppTheme.primaryRose, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const Text('Round 4 of 10', style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _currentTruthOrDare,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A273C)),
                    onPressed: () {
                      setState(() {
                        _cardMode = 'Truth';
                        _currentTruthOrDare = 'If we could relive one 24-hour day of our relationship, which day would you pick?';
                      });
                    },
                    child: const Text('Next Truth', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose),
                    onPressed: () {
                      setState(() {
                        _cardMode = 'Dare';
                        _currentTruthOrDare = 'Give your partner a 60-second gentle shoulder massage while whispering your favorite thing about them.';
                      });
                    },
                    child: const Text('Next Dare', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text('All 1-on-1 Games', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),

        _buildGameListTile('♟️ Speed Chess', 'Real-time turns & couple move history', 'Play Chess', Colors.blueAccent),
        const SizedBox(height: 12),
        _buildGameListTile('🎲 Couple Ludo', 'Custom 2-player board with fun relationship powerups', 'Roll Dice', Colors.greenAccent),
        const SizedBox(height: 12),
        _buildGameListTile('🧠 Love Trivia & Quiz', 'Guess how well you know your partner’s memories', 'Start Quiz', Colors.orangeAccent),
        const SizedBox(height: 12),
        _buildGameListTile('🤔 Would You Rather?', 'Fun, deep, and hilarious dilemma prompts', 'Pick Choices', Colors.purpleAccent),
      ],
    );
  }

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
                    Text('Season 4: 12 Wins / 3 Losses', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        ElevatedButton.icon(
          icon: const Icon(Icons.group_add_rounded),
          label: const Text('Find Opponent Couple (Matchmaking)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryRose,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Searching for opponent couples in Gold Tier...')),
            );
          },
        ),
        const SizedBox(height: 28),

        Text('Global Couple Leaderboard', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),

        _buildLeaderboardRow('1', 'Team Stargazers (You & Sophia)', '1,480 Elo', '👑 Gold I'),
        _buildLeaderboardRow('2', 'Team Celestial Hearts', '1,445 Elo', '🥈 Gold II'),
        _buildLeaderboardRow('3', 'Team Moonlight Wanderers', '1,410 Elo', '🥉 Gold III'),
        _buildLeaderboardRow('4', 'Team Cozy Duo', '1,385 Elo', 'Silver I'),
      ],
    );
  }

  Widget _buildGameListTile(String title, String desc, String btnText, Color accentColor) {
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
                Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor.withOpacity(0.2),
              foregroundColor: accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {},
            child: Text(btnText),
          )
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(String rank, String teamName, String elo, String tier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1C2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
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
}
