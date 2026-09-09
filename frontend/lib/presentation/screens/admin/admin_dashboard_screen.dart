import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedTab = 'overview';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin System Control Panel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryRose),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Admin telemetry refreshed')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Navigation Tabs
          Row(
            children: [
              _buildTabButton('overview', 'Overview', Icons.dashboard_rounded),
              const SizedBox(width: 8),
              _buildTabButton('users', 'Users & Couples', Icons.people_alt_rounded),
              const SizedBox(width: 8),
              _buildTabButton('moderation', 'Reports', Icons.gavel_rounded),
              const SizedBox(width: 8),
              _buildTabButton('server', 'System Health', Icons.dns_rounded),
            ],
          ),
          const SizedBox(height: 20),

          if (_selectedTab == 'overview') _buildOverviewTab(context),
          if (_selectedTab == 'users') _buildUsersTab(context),
          if (_selectedTab == 'moderation') _buildModerationTab(context),
          if (_selectedTab == 'server') _buildSystemHealthTab(context),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabId, String label, IconData icon) {
    final isSelected = _selectedTab == tabId;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = tabId),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryRose : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? AppTheme.primaryRose : Colors.white10),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.white60),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // System Quick Metrics
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildMetricTile('Total Registered Users', '12,840', Icons.people_rounded, const Color(0xFF42A5F5), '+14% this month'),
            _buildMetricTile('Active Couple Spaces', '6,410', Icons.favorite_rounded, AppTheme.primaryRose, '1-to-1 Isolated'),
            _buildMetricTile('E2EE Messages Routed', '1.42M', Icons.lock_rounded, const Color(0xFF66BB6A), 'AES-256 Encrypted'),
            _buildMetricTile('AI Requests Processed', '84,200', Icons.auto_awesome_rounded, AppTheme.accentGold, 'Gemini 2.5 Flash'),
          ],
        ),
        const SizedBox(height: 20),

        // Live Infrastructure Status
        Container(
          decoration: AppTheme.glassBox(context: context, radius: 20),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: Colors.greenAccent, size: 20),
                  SizedBox(width: 8),
                  Text('Core Services Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 14),
              _buildServiceStatusRow('Laravel 12 API Engine', 'Operational (99.99%)', Colors.greenAccent),
              const Divider(color: Colors.white10, height: 16),
              _buildServiceStatusRow('WebSocket Real-Time Reverb', 'Connected (4,210 Sockets)', Colors.greenAccent),
              const Divider(color: Colors.white10, height: 16),
              _buildServiceStatusRow('MySQL Database Pool', 'Healthy (14ms latency)', Colors.greenAccent),
              const Divider(color: Colors.white10, height: 16),
              _buildServiceStatusRow('E2EE Key Exchange Registry', '100% Verified', Colors.greenAccent),
              const Divider(color: Colors.white10, height: 16),
              _buildServiceStatusRow('Google Gemini AI Integration', 'Active (API v1beta)', Colors.greenAccent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsersTab(BuildContext context) {
    return Container(
      decoration: AppTheme.glassBox(context: context, radius: 20),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent User Accounts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildUserRow('Mariam Creater', '@mariam', 'CPL-9824', 'Connected', Colors.greenAccent),
          const Divider(color: Colors.white10, height: 16),
          _buildUserRow('Maxamad Yasin', '@maxamad', 'CPL-9824', 'Connected', Colors.greenAccent),
          const Divider(color: Colors.white10, height: 16),
          _buildUserRow('Ahmed Ali', '@ahmed_ali', 'CPL-1102', 'Single', Colors.orangeAccent),
          const Divider(color: Colors.white10, height: 16),
          _buildUserRow('Hodan Nur', '@hodan_nur', 'CPL-5541', 'Pending Request', Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _buildModerationTab(BuildContext context) {
    return Container(
      decoration: AppTheme.glassBox(context: context, radius: 20),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Moderation & Safety Queue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent),
                SizedBox(width: 10),
                Expanded(
                  child: Text('All clean! 0 pending harassment or policy violation reports.', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemHealthTab(BuildContext context) {
    return Container(
      decoration: AppTheme.glassBox(context: context, radius: 20),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Production Telemetry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 14),
          _buildTelemetryMetric('Server CPU Load', '12% / 8 vCPU', 0.12, Colors.greenAccent),
          const SizedBox(height: 12),
          _buildTelemetryMetric('RAM Memory Utilization', '3.8 GB / 16.0 GB', 0.24, Colors.greenAccent),
          const SizedBox(height: 12),
          _buildTelemetryMetric('Storage (Encrypted Vaults)', '48.2 GB / 500 GB', 0.10, Colors.blueAccent),
          const SizedBox(height: 12),
          _buildTelemetryMetric('SSL TLS Certificate', 'Valid (Let\'s Encrypt Wildcard)', 1.0, Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, IconData icon, Color color, String sub) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1C2B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildServiceStatusRow(String name, String status, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildUserRow(String name, String username, String coupleId, String status, Color statusColor) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppTheme.primaryRose.withOpacity(0.2),
          child: Text(name[0], style: const TextStyle(color: AppTheme.primaryRose, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text('$username • $coupleId', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildTelemetryMetric(String title, String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
