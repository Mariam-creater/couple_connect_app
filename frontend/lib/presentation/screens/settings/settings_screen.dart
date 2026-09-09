import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricsEnabled = true;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    final space = appState.coupleSpace;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Security', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile & Space Card
          Container(
            decoration: AppTheme.glassBox(context: context),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryRose,
                  backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                  child: user?.avatarUrl == null ? Text(user?.name[0] ?? 'U', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('@${user?.username} • ${user?.coupleId}', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('Space: ${space?.spaceName ?? 'Connected'}', style: const TextStyle(color: AppTheme.accentGold, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Security Section
          Text('Privacy & Encryption', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            decoration: AppTheme.glassBox(context: context),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Biometric Login (Face ID / Fingerprint)', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text('Lock access with biometric security', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  value: _biometricsEnabled,
                  activeColor: AppTheme.primaryRose,
                  onChanged: (val) => setState(() => _biometricsEnabled = val),
                ),
                const Divider(color: Colors.white10, height: 1),
                ListTile(
                  title: const Text('End-to-End Encryption Keys', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text('Device key: ${user?.publicKey?.substring(0, 20) ?? 'Verified Curve25519'}...', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  trailing: const Icon(Icons.verified_user_rounded, color: Colors.greenAccent),
                ),
                const Divider(color: Colors.white10, height: 1),
                ListTile(
                  title: const Text('Change App PIN Lock', style: TextStyle(color: Colors.white, fontSize: 14)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white54),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notifications & Theme Section
          Text('Preferences', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            decoration: AppTheme.glassBox(context: context),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text('Real-time alerts for partner messages & game invites', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  value: _notificationsEnabled,
                  activeColor: AppTheme.primaryRose,
                  onChanged: (val) => setState(() => _notificationsEnabled = val),
                ),
                const Divider(color: Colors.white10, height: 1),
                ListTile(
                  title: const Text('Couple Space Theme', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('Rose Gold & Velvet Midnight', style: TextStyle(color: AppTheme.primaryRose, fontSize: 12)),
                  trailing: const Icon(Icons.color_lens_outlined, color: AppTheme.primaryRose),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Sign Out Button
          ElevatedButton.icon(
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out of Space'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.15),
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.red.withOpacity(0.3)),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              await appState.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
