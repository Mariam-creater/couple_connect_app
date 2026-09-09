import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final memories = _selectedCategory == 'all'
        ? appState.memories
        : appState.memories.where((m) => m.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Love Memories Vault', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined, color: AppTheme.primaryRose, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildTab('all', 'All Vault (${appState.memories.length})'),
                _buildTab('photo', '📸 Photos'),
                _buildTab('letter', '💌 Letters'),
                _buildTab('voice_note', '🎙️ Voice Memos'),
              ],
            ),
          ),

          // Memories Grid
          Expanded(
            child: memories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.photo_library_outlined, size: 56, color: Colors.white24),
                        const SizedBox(height: 12),
                        Text('Vault is waiting for your treasured moments.', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: memories.length,
                    itemBuilder: (context, index) {
                      final mem = memories[index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: const Color(0xFF1E1C2B),
                          image: mem.mediaPath != null
                              ? DecorationImage(image: NetworkImage(mem.mediaPath!), fit: BoxFit.cover)
                              : null,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.85),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (mem.category == 'letter') ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentGold.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('💌 Love Letter', style: TextStyle(color: AppTheme.accentGold, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 6),
                              ],
                              Text(
                                mem.title,
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${DateFormat('MMM yyyy').format(mem.memoryDate)} • ${mem.albumName}',
                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String key, String label) {
    final isSelected = _selectedCategory == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        backgroundColor: const Color(0xFF1E1C2B),
        selectedColor: AppTheme.primaryRose.withOpacity(0.3),
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 13),
        side: BorderSide(color: isSelected ? AppTheme.primaryRose : Colors.white12),
        onSelected: (_) => setState(() => _selectedCategory = key),
      ),
    );
  }
}
