import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';

class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final streak = appState.streak;
    final currentStreak = streak?.currentStreakDays ?? 42;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Couple Streak & Milestones', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Hero Flame Streak Animation Card
          Container(
            decoration: AppTheme.glassBox(context: context, borderColor: Colors.orangeAccent.withOpacity(0.5)),
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.redAccent]),
                    boxShadow: [
                      BoxShadow(color: Colors.orangeAccent.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 54),
                ),
                const SizedBox(height: 20),
                Text(
                  '$currentStreak Day Streak',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your longest connection streak: ${streak?.longestStreakDays ?? 42} days',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Complete Daily Check-in'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    await appState.performDailyCheckIn();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Streak validated for today! 🔥')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Unlocked Badges Section
          Text('Unlocked Badges', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.25,
            children: [
              _buildBadgeCard('🌱', 'First Step', 'Started on Couple Connect', true),
              _buildBadgeCard('✨', '7-Day Spark', 'One week of love', true),
              _buildBadgeCard('🔥', '30-Day Flame', 'Full month devotion', true),
              _buildBadgeCard('🎲', 'Playful Duo', '10+ games played', true),
              _buildBadgeCard('📸', 'Memory Curator', '25+ memories captured', true),
              _buildBadgeCard('👑', 'Golden 365', '1 Year unbroken streak', false),
            ],
          ),
          const SizedBox(height: 28),

          // Activity Recap Stats
          Text('Activity Breakdown', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          Container(
            decoration: AppTheme.glassBox(context: context),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildStatRow('Messages Exchanged', '${streak?.totalMessagesCount ?? 1420}'),
                const Divider(color: Colors.white12, height: 20),
                _buildStatRow('Games Played Together', '${streak?.totalGamesPlayed ?? 18}'),
                const Divider(color: Colors.white12, height: 20),
                _buildStatRow('Memories Vaulted', '${streak?.totalMemoriesAdded ?? 34}'),
                const Divider(color: Colors.white12, height: 20),
                _buildStatRow('Life Goals Completed', '${streak?.totalGoalsCompleted ?? 7}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(String emoji, String title, String desc, bool isUnlocked) {
    return Container(
      decoration: BoxDecoration(
        color: isUnlocked ? const Color(0xFF1E1C2B) : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isUnlocked ? AppTheme.accentGold.withOpacity(0.3) : Colors.white10),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              if (!isUnlocked)
                const Icon(Icons.lock_rounded, size: 16, color: Colors.white30),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: isUnlocked ? Colors.white : Colors.white38, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            desc,
            style: TextStyle(color: isUnlocked ? Colors.white60 : Colors.white24, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }
}
