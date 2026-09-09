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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().fetchCoupleRequests();
    });
  }

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
                constraints: const BoxConstraints(maxWidth: 540),
                decoration: AppTheme.glassBox(context: context, radius: 28),
                padding: const EdgeInsets.all(28.0),
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
                            radius: 26,
                            backgroundColor: AppTheme.primaryRose,
                            backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                            child: user?.avatarUrl == null ? Text(user?.name.substring(0, 1) ?? 'U', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)) : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user?.name ?? 'My Profile', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                Text('Couple ID: ${user?.coupleId ?? 'CP-XXXX'}', style: const TextStyle(color: AppTheme.accentGold, fontSize: 13, fontWeight: FontWeight.w600)),
                                Text('Status: ${user?.relationshipStatus.toUpperCase() ?? 'SINGLE'}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
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
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Connect With Your Partner',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Search by your partner’s unique Username or Couple ID to create your private universe.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),

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
                            foregroundColor: Colors.white,
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
                    const SizedBox(height: 16),

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
                              child: _searchedPartner!.avatarUrl == null ? Text(_searchedPartner!.name[0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)) : null,
                            ),
                            const SizedBox(height: 10),
                            Text(_searchedPartner!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('@${_searchedPartner!.username} • ${_searchedPartner!.coupleId}', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                            if (_searchedPartner!.bio != null) ...[
                              const SizedBox(height: 6),
                              Text('"${_searchedPartner!.bio}"', style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 12), textAlign: TextAlign.center),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.favorite_rounded, size: 18),
                                  label: const Text('Send Couple Request'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryRose,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                                const SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
                                  color: const Color(0xFF1E1C2B),
                                  onSelected: (val) {
                                    if (val == 'block') {
                                      _showBlockDialog(context, appState, _searchedPartner!);
                                    } else if (val == 'report') {
                                      _showReportDialog(context, appState, _searchedPartner!);
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(value: 'block', child: Text('Block User', style: TextStyle(color: Colors.amberAccent))),
                                    const PopupMenuItem(value: 'report', child: Text('Report User', style: TextStyle(color: Colors.redAccent))),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Incoming Requests Section
                    if (appState.incomingRequests.isNotEmpty) ...[
                      Text('Incoming Requests', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      ...appState.incomingRequests.map((req) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppTheme.accentGold,
                                radius: 20,
                                child: Text(req.sender?.name.substring(0, 1) ?? 'P', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(req.sender?.name ?? 'Partner Request', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    Text('@${req.sender?.username ?? ''} • ${req.sender?.coupleId ?? ''}', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 28),
                                onPressed: () async {
                                  final accepted = await appState.acceptCoupleRequest(req.id);
                                  if (accepted && mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 28),
                                onPressed: () => appState.rejectCoupleRequest(req.id),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 14),
                    ],

                    // Outgoing Requests Section
                    if (appState.outgoingRequests.isNotEmpty) ...[
                      Text('Pending Sent Requests', style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      ...appState.outgoingRequests.map((req) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.hourglass_top_rounded, color: AppTheme.accentGold, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text('Request sent to ${req.receiver?.name ?? 'Partner'}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              ),
                              TextButton(
                                onPressed: () => appState.cancelCoupleRequest(req.id),
                                child: const Text('Cancel', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                              )
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 14),
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

  void _showBlockDialog(BuildContext context, AppState appState, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C2B),
        title: Text('Block ${user.name}?', style: const TextStyle(color: Colors.white)),
        content: const Text('They will not be able to search for you or send you couple requests.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white60))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800),
            onPressed: () async {
              await appState.blockUser(user.id);
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${user.name} has been blocked.')),
                );
              }
            },
            child: const Text('Block User', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context, AppState appState, UserModel user) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C2B),
        title: Text('Report ${user.name}', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please describe why you are reporting this account:', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Reason for report...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
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
              await appState.reportUser(user.id, reason: reasonController.text.trim(), category: 'harassment');
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Report submitted against ${user.name}.')),
                );
              }
            },
            child: const Text('Submit Report', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
