import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> with SingleTickerProviderStateMixin {
  String _selectedReportType = 'monthly';
  late AnimationController _flameController;

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().fetchStreakStatus();
    });
  }

  @override
  void dispose() {
    _flameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final streak = appState.streak;
    final currentStreak = streak?.currentStreakDays ?? 42;
    final longestStreak = streak?.longestStreakDays ?? 42;
    final currentLevel = streak?.level ?? 4;
    final currentXp = streak?.xp ?? 480;
    final nextLevelXp = currentLevel * 250;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Couple Streak & Milestones', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Hero Flame Streak Card
          Container(
            decoration: AppTheme.glassBox(
              context: context,
              borderColor: Colors.orangeAccent.withOpacity(0.5),
              radius: 28,
            ),
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            child: Column(
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.08).animate(
                    CurvedAnimation(parent: _flameController, curve: Curves.easeInOut),
                  ),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFF5722), Color(0xFFE91E63)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orangeAccent.withOpacity(0.45),
                          blurRadius: 28,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 56),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$currentStreak',
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Days On Fire 🔥',
                      style: TextStyle(color: Colors.orangeAccent, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Longest Connection: $longestStreak Days • Keep your love bond glowing!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_rounded, color: Colors.black87),
                    label: const Text('Complete Daily Check-in (+50 XP)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 4,
                    ),
                    onPressed: () async {
                      await appState.performDailyCheckIn();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Streak validated! You earned +50 Couple XP 🔥✨'),
                            backgroundColor: Color(0xFF1E1C2B),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Couple Level & XP System
          Container(
            decoration: AppTheme.glassBox(context: context, radius: 24),
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.military_tech_rounded, color: AppTheme.accentGold, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level $currentLevel: ${_getLevelTitle(currentLevel)}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Couple Connection Rank',
                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
                      ),
                      child: Text(
                        '$currentXp XP',
                        style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (currentXp % 250) / 250,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${currentXp % 250} / 250 XP to Level ${currentLevel + 1}', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
                    Text('Next: ${_getLevelTitle(currentLevel + 1)}', style: const TextStyle(color: AppTheme.accentGold, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Monthly Streak Heatmap Calendar
          Container(
            decoration: AppTheme.glassBox(context: context, radius: 24),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('30-Day Activity Heatmap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('September 2026', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 1,
                  ),
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isActive = day <= 9 || (day >= 12 && day <= 24);
                    final isToday = day == 9;

                    return Container(
                      decoration: BoxDecoration(
                        color: isToday
                            ? Colors.orangeAccent
                            : isActive
                                ? AppTheme.primaryRose.withOpacity(0.35)
                                : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isToday
                              ? Colors.orangeAccent
                              : isActive
                                  ? AppTheme.primaryRose.withOpacity(0.6)
                                  : Colors.white10,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color: isToday ? Colors.black87 : isActive ? Colors.white : Colors.white30,
                            fontWeight: isActive || isToday ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(AppTheme.primaryRose.withOpacity(0.5), 'Active Day'),
                    const SizedBox(width: 16),
                    _buildLegendItem(Colors.orangeAccent, 'Today Checked-In'),
                    const SizedBox(width: 16),
                    _buildLegendItem(Colors.white.withOpacity(0.05), 'Rest Day'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Relationship Activity Breakdown & Statistics Dashboard
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Relationship Statistics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'monthly', label: Text('Month', style: TextStyle(fontSize: 12))),
                  ButtonSegment(value: 'yearly', label: Text('Year', style: TextStyle(fontSize: 12))),
                ],
                selected: {_selectedReportType},
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppTheme.primaryRose;
                    }
                    return Colors.white.withOpacity(0.04);
                  }),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                ),
                onSelectionChanged: (set) {
                  setState(() => _selectedReportType = set.first);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Statistics Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _buildStatCard(
                icon: Icons.chat_bubble_rounded,
                color: const Color(0xFF64B5F6),
                label: 'Messages Sent',
                value: _selectedReportType == 'monthly' ? '1,420' : '18,540',
                sub: '+12% vs last period',
              ),
              _buildStatCard(
                icon: Icons.photo_library_rounded,
                color: const Color(0xFF81C784),
                label: 'Memories Vaulted',
                value: _selectedReportType == 'monthly' ? '34' : '382',
                sub: '5.2 GB secured',
              ),
              _buildStatCard(
                icon: Icons.videocam_rounded,
                color: const Color(0xFFFFB74D),
                label: 'Voice & Video Calls',
                value: _selectedReportType == 'monthly' ? '48 hrs' : '412 hrs',
                sub: 'Average 96m / call',
              ),
              _buildStatCard(
                icon: Icons.sports_esports_rounded,
                color: const Color(0xFFBA68C8),
                label: 'Games Played',
                value: _selectedReportType == 'monthly' ? '28' : '240',
                sub: '14 Ludo, 10 Quizzes',
              ),
              _buildStatCard(
                icon: Icons.flag_rounded,
                color: const Color(0xFFFF8A80),
                label: 'Goals Achieved',
                value: _selectedReportType == 'monthly' ? '4' : '23',
                sub: '3 milestones pending',
              ),
              _buildStatCard(
                icon: Icons.event_available_rounded,
                color: const Color(0xFF4DD0E1),
                label: 'Calendar Dates',
                value: _selectedReportType == 'monthly' ? '12' : '98',
                sub: '100% attendance ❤️',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 5. Achievement Badges & Milestones
          const Text('Achievement Badges & Milestones', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 14),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              _buildBadgeCard('🌱', 'First Step', 'Created Couple Space', 'Unlocked Aug 2026', true),
              _buildBadgeCard('✨', '7-Day Spark', '7-Day connection streak', 'Unlocked Sep 2026', true),
              _buildBadgeCard('🔥', '30-Day Flame', 'Full month unbroken flame', 'Unlocked Sep 2026', true),
              _buildBadgeCard('💎', '100-Day Unbreakable', '100 days of devotion', 'Progress: 42/100', false),
              _buildBadgeCard('🎲', 'Playful Duo', 'Played 20+ games together', 'Unlocked Sep 2026', true),
              _buildBadgeCard('📸', 'Memory Curator', 'Vaulted 25+ memories', 'Unlocked Sep 2026', true),
              _buildBadgeCard('🎯', 'Dream Achiever', 'Completed 5+ shared goals', 'Progress: 4/5', false),
              _buildBadgeCard('👑', 'Golden 365', '1 Full year together', 'Progress: 42/365', false),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getLevelTitle(int level) {
    switch (level) {
      case 1:
        return 'New Sparks';
      case 2:
        return 'Sweet Companions';
      case 3:
        return 'Devoted Partners';
      case 4:
        return 'Soulmates In Harmony';
      case 5:
        return 'Eternal Flame';
      default:
        return 'Legendary Couple';
    }
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required String sub,
  }) {
    return Container(
      decoration: AppTheme.glassBox(context: context, radius: 20),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(String emoji, String title, String desc, String meta, bool isUnlocked) {
    return Container(
      decoration: BoxDecoration(
        color: isUnlocked ? const Color(0xFF1E1C2B) : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked ? AppTheme.accentGold.withOpacity(0.4) : Colors.white10,
        ),
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
                const Icon(Icons.lock_rounded, size: 16, color: Colors.white30)
              else
                const Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.accentGold),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: isUnlocked ? Colors.white : Colors.white38,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: TextStyle(
              color: isUnlocked ? Colors.white60 : Colors.white24,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            meta,
            style: TextStyle(
              color: isUnlocked ? AppTheme.accentGold : Colors.white24,
              fontSize: 10,
              fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
