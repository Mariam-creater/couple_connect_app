import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';
import '../space/space_dashboard_screen.dart';
import '../chat/chat_screen.dart';
import '../calendar/calendar_screen.dart';
import '../memories/memories_screen.dart';
import '../games/games_screen.dart';
import '../vision/vision_board_screen.dart';
import '../streak/streak_screen.dart';
import '../ai/ai_assistant_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SpaceDashboardScreen(),
    const ChatScreen(),
    const CalendarScreen(),
    const MemoriesScreen(),
    const GamesScreen(),
    const VisionBoardScreen(),
    const StreakScreen(),
    const AiAssistantScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().fetchInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: Row(
        children: [
          // Desktop / Web Side Navigation Rail
          if (isWide)
            NavigationRail(
              backgroundColor: isDark ? const Color(0xFF161522) : Colors.white,
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [AppTheme.primaryRose, AppTheme.accentGold]),
                  ),
                  child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
                ),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home_rounded), label: Text('Space')),
                NavigationRailDestination(icon: Icon(Icons.chat_bubble_rounded), label: Text('Chat')),
                NavigationRailDestination(icon: Icon(Icons.calendar_month_rounded), label: Text('Calendar')),
                NavigationRailDestination(icon: Icon(Icons.photo_library_rounded), label: Text('Memories')),
                NavigationRailDestination(icon: Icon(Icons.sports_esports_rounded), label: Text('Games')),
                NavigationRailDestination(icon: Icon(Icons.dashboard_customize_rounded), label: Text('Vision')),
                NavigationRailDestination(icon: Icon(Icons.local_fire_department_rounded), label: Text('Streak')),
                NavigationRailDestination(icon: Icon(Icons.auto_awesome_rounded), label: Text('AI Assistant')),
                NavigationRailDestination(icon: Icon(Icons.settings_rounded), label: Text('Settings')),
              ],
            ),

          // Main Viewport
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),

      // Mobile Bottom Navigation Bar with Glassmorphic Floating Style
      bottomNavigationBar: isWide
          ? null
          : Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161522).withOpacity(0.95) : Colors.white.withOpacity(0.95),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex > 4 ? 4 : _currentIndex,
                onTap: (index) {
                  if (index == 4) {
                    _showMoreFeaturesModal(context);
                  } else {
                    setState(() => _currentIndex = index);
                  }
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                selectedItemColor: AppTheme.primaryRose,
                unselectedItemColor: isDark ? Colors.white54 : Colors.grey,
                elevation: 0,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Space'),
                  BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
                  BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Calendar'),
                  BottomNavigationBarItem(icon: Icon(Icons.photo_library_rounded), label: 'Memories'),
                  BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'More'),
                ],
              ),
            ),
    );
  }

  void _showMoreFeaturesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1C2B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text('More Couple Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildModalFeatureTile('Games', Icons.sports_esports_rounded, Colors.purpleAccent, 4),
                  _buildModalFeatureTile('Vision Board', Icons.dashboard_customize_rounded, Colors.amberAccent, 5),
                  _buildModalFeatureTile('Streak', Icons.local_fire_department_rounded, Colors.orangeAccent, 6),
                  _buildModalFeatureTile('AI Coach', Icons.auto_awesome_rounded, Colors.pinkAccent, 7),
                  _buildModalFeatureTile('Settings', Icons.settings_rounded, Colors.blueGrey, 8),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalFeatureTile(String label, IconData icon, Color color, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        setState(() => _currentIndex = index);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
