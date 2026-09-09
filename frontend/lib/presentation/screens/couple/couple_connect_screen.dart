import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../providers/app_state.dart';
import '../home/home_screen.dart';

class CoupleConnectScreen extends StatefulWidget {
  const CoupleConnectScreen({super.key});

  @override
  State<CoupleConnectScreen> createState() => _CoupleConnectScreenState();
}

class _CoupleConnectScreenState extends State<CoupleConnectScreen> {
  final _searchController = TextEditingController(text: 'sophia');
  UserModel? _searchedPartner;
  bool _isSearching = false;
  String? _statusMessage;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F0E17),
              const Color(0xFF1E1C2B),
              AppTheme.primaryRose.withOpacity(0.12),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                decoration: AppTheme.glassBox(context: context, radius: 28),
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top user card showing their Couple ID
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppTheme.primaryRose,
                            child: Text(user?.name.substring(0, 1) ?? 'U', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user?.name ?? 'My Profile', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('Couple ID: ${user?.coupleId ?? 'CP-XXXX'}', style: TextStyle(color: AppTheme.accentGold, fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout_rounded, color: Colors.white54),
                            onPressed: () => appState.logout(),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    Text(
                      'Connect With Your Partner',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Search by your partner’s unique Username or Couple ID to create your private universe.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    // Search input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Enter partner username or ID',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryRose),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRose,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _isSearching
                              ? null
                              : () async {
                                  setState(() {
                                    _isSearching = true;
                                    _statusMessage = null;
                                  });
                                  final partner = await appState.searchPartner(_searchController.text.trim());
                                  setState(() {
                                    _searchedPartner = partner;
                                    _isSearching = false;
                                    if (partner == null) {
                                      _statusMessage = 'No matching single user found.';
                                    }
                                  });
                                },
                          child: _isSearching
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Search'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (_statusMessage != null)
                      Text(_statusMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.amberAccent, fontSize: 13)),

                    // Searched Partner Result Card
                    if (_searchedPartner != null) ...[
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRose.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primaryRose.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppTheme.primaryRose,
                              backgroundImage: _searchedPartner!.avatarUrl != null ? NetworkImage(_searchedPartner!.avatarUrl!) : null,
                              child: _searchedPartner!.avatarUrl == null ? Text(_searchedPartner!.name[0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)) : null,
                            ),
                            const SizedBox(height: 10),
                            Text(_searchedPartner!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('@${_searchedPartner!.username} • ${_searchedPartner!.coupleId}', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.favorite_rounded, size: 18),
                              label: const Text('Send Couple Request'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryRose,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () async {
                                final sent = await appState.sendCoupleRequest(_searchedPartner!.id);
                                if (sent && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Couple request sent to ${_searchedPartner!.name}! Waiting for them to accept.'),
                                      backgroundColor: AppTheme.primaryRose,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Direct Demo Shortcut
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppTheme.accentGold, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tip: In the demo, both Alex & Sophia are pre-connected so you can explore the complete live features!',
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const HomeScreen()),
                              );
                            },
                            child: const Text('Enter Space', style: TextStyle(color: AppTheme.accentGold)),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
