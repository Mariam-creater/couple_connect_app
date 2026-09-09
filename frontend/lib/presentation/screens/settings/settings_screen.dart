import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricsEnabled = true;
  bool _notificationsEnabled = true;
  late bool _showOnlineStatus;
  late bool _showReadReceipts;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().currentUser;
    _showOnlineStatus = user?.privacyShowOnlineStatus ?? true;
    _showReadReceipts = user?.privacyShowReadReceipts ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    final partner = appState.partner;
    final space = appState.coupleSpace;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Privacy', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                  child: user?.avatarUrl == null ? Text(user?.name[0] ?? 'U', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)) : null,
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
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: AppTheme.accentGold),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Privacy & Online Visibility Section
          Text('Privacy Controls', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            decoration: AppTheme.glassBox(context: context),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Show Online Status', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text('Allow partner to see when you are active', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  value: _showOnlineStatus,
                  activeColor: AppTheme.primaryRose,
                  onChanged: (val) {
                    setState(() => _showOnlineStatus = val);
                    appState.updatePrivacy(showOnlineStatus: val);
                  },
                ),
                const Divider(color: Colors.white10, height: 1),
                SwitchListTile(
                  title: const Text('Read Receipts (Seen Indicator)', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text('Send blue checkmarks when you read partner messages', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  value: _showReadReceipts,
                  activeColor: AppTheme.primaryRose,
                  onChanged: (val) {
                    setState(() => _showReadReceipts = val);
                    appState.updatePrivacy(showReadReceipts: val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Security Section
          Text('Encryption & Security', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            decoration: AppTheme.glassBox(context: context),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Biometric Lock (Face ID / Fingerprint)', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text('Require biometrics to open Couple Connect', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  value: _biometricsEnabled,
                  activeColor: AppTheme.primaryRose,
                  onChanged: (val) => setState(() => _biometricsEnabled = val),
                ),
                const Divider(color: Colors.white10, height: 1),
                ListTile(
                  title: const Text('End-to-End Encryption Keys', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text('Curve25519 Key: ${user?.publicKey?.substring(0, 18) ?? 'Verified Active'}...', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  trailing: const Icon(Icons.verified_user_rounded, color: Colors.greenAccent),
                ),
                const Divider(color: Colors.white10, height: 1),
                SwitchListTile(
                  title: const Text('Push Notifications', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text('Instant alerts for partner messages & memories', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  value: _notificationsEnabled,
                  activeColor: AppTheme.primaryRose,
                  onChanged: (val) => setState(() => _notificationsEnabled = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Relationship & Space Management
          if (appState.isConnectedWithPartner) ...[
            Text('Couple Space Connection', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Container(
              decoration: AppTheme.glassBox(context: context),
              child: ListTile(
                leading: const Icon(Icons.heart_broken_rounded, color: Colors.amberAccent),
                title: const Text('Disconnect Partner / Remove Space', style: TextStyle(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text('Disconnect from ${partner?.name ?? 'partner'} and archive space', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                onTap: () => _showDisconnectDialog(context, appState),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Account Actions
          Text('Account & Session', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            decoration: AppTheme.glassBox(context: context),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.accentGold),
                  title: const Text('Admin System Control Panel', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Text('Manage users, moderation reports, and server telemetry', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white60),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                    );
                  },
                ),
                const Divider(color: Colors.white10, height: 1),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.white70),
                  title: const Text('Sign Out of Space', style: TextStyle(color: Colors.white, fontSize: 14)),
                  onTap: () async {
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
                const Divider(color: Colors.white10, height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                  title: const Text('Delete Account', style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Text('Permanently remove all data and encryption keys', style: TextStyle(color: Colors.redAccent.withOpacity(0.7), fontSize: 12)),
                  onTap: () => _showDeleteAccountDialog(context, appState),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C2B),
        title: const Text('Disconnect Partner?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to disconnect from your partner? Your shared space, messages, and memories will be archived and both accounts will return to single status.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white60))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800),
            onPressed: () async {
              final ok = await appState.removePartner();
              if (mounted) {
                Navigator.pop(ctx);
                if (ok) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
            child: const Text('Disconnect', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AppState appState) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C2B),
        title: const Text('Delete Account Permanently', style: TextStyle(color: Colors.redAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This action is irreversible. Enter your password to confirm account deletion:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white60))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final deleted = await appState.deleteAccount(passwordController.text);
              if (mounted) {
                Navigator.pop(ctx);
                if (deleted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
