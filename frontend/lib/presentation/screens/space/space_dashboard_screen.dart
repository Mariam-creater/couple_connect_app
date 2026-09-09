import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';

class SpaceDashboardScreen extends StatelessWidget {
  const SpaceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final space = appState.coupleSpace;
    final user = appState.currentUser;
    final partner = appState.partner;
    final streak = appState.streak;

    // Calculate days connected
    final connectedDate = space?.connectedAt ?? DateTime.now().subtract(const Duration(days: 42));
    final daysTogether = DateTime.now().difference(connectedDate).inDays;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Elegant Header with Couple Avatars and Floating Badges
          SliverAppBar(
            expandedHeight: 260,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryRose.withOpacity(0.35),
                      const Color(0xFF161522),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Dual Connected Avatars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildAvatar(user?.name ?? 'Alex', user?.avatarUrl, AppTheme.primaryRose),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.12),
                              ),
                              child: const Icon(Icons.favorite_rounded, color: AppTheme.primaryRose, size: 24),
                            ),
                          ),
                          _buildAvatar(partner?.name ?? 'Sophia', partner?.avatarUrl, AppTheme.accentViolet),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        space?.spaceName ?? 'Our Private World',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Connected since ${DateFormat('MMMM d, yyyy').format(connectedDate)}',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Content
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Days Together Hero Counter
                Container(
                  decoration: AppTheme.glassBox(context: context),
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricTile('$daysTogether', 'Days Together', Icons.all_inclusive_rounded, AppTheme.primaryRose),
                      Container(width: 1, height: 48, color: Colors.white12),
                      _buildMetricTile('${streak?.currentStreakDays ?? 42} 🔥', 'Active Streak', Icons.local_fire_department_rounded, Colors.orangeAccent),
                      Container(width: 1, height: 48, color: Colors.white12),
                      _buildMetricTile('${appState.memories.length}', 'Memories', Icons.photo_library_rounded, AppTheme.accentGold),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Next Countdown Event
                if (appState.calendarEvents.any((e) => e.isCountdown)) ...[
                  Text('Upcoming Milestone', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...appState.calendarEvents.where((e) => e.isCountdown).take(1).map((event) {
                    final daysLeft = event.startTime.difference(DateTime.now()).inDays;
                    return Container(
                      decoration: AppTheme.glassBox(context: context, borderColor: AppTheme.primaryRose.withOpacity(0.4)),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRose.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.alarm_on_rounded, color: AppTheme.primaryRose, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(event.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 4),
                                Text(
                                  event.location ?? DateFormat('EEEE, MMM d @ h:mm a').format(event.startTime),
                                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRose,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              daysLeft <= 0 ? 'Today!' : '$daysLeft days',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],

                // 3. Quick Action Cards (Daily Check-in, Truth or Dare, AI Advice)
                Text('Quick Connection', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        title: 'Daily Check-in',
                        subtitle: 'Keep flame alive',
                        icon: Icons.check_circle_outline_rounded,
                        color: Colors.greenAccent,
                        onTap: () async {
                          await appState.performDailyCheckIn();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Daily check-in completed! Streak updated 🔥')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildActionCard(
                        title: 'AI Tone Check',
                        subtitle: 'Scan message',
                        icon: Icons.auto_awesome_rounded,
                        color: Colors.pinkAccent,
                        onTap: () {
                          // Trigger quick tone inspection
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. Love Memories Highlight
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Shared Memories', style: Theme.of(context).textTheme.titleLarge),
                    Text('${appState.memories.length} captured', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 140,
                  child: appState.memories.isEmpty
                      ? Center(child: Text('No memories yet. Add your first photo!', style: TextStyle(color: Colors.white54)))
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: appState.memories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 14),
                          itemBuilder: (ctx, idx) {
                            final mem = appState.memories[idx];
                            return Container(
                              width: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                image: mem.mediaPath != null
                                    ? DecorationImage(image: NetworkImage(mem.mediaPath!), fit: BoxFit.cover)
                                    : null,
                                color: const Color(0xFF2A273C),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                                  ),
                                ),
                                padding: const EdgeInsets.all(10),
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  mem.title,
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAvatar(String name, String? avatarUrl, Color fallbackColor) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 2.5),
        boxShadow: [
          BoxShadow(color: fallbackColor.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: CircleAvatar(
        radius: 36,
        backgroundColor: fallbackColor,
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null ? Text(name[0], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)) : null,
      ),
    );
  }

  Widget _buildMetricTile(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
