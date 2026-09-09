import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../providers/app_state.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  String _selectedCategory = 'all';
  String _viewMode = 'grid'; // 'grid' or 'timeline'
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  final Map<String, String> _categories = {
    'all': 'All Vault',
    'photo': '📸 Photos',
    'video': '🎥 Videos',
    'letter': '💌 Letters',
    'voice_note': '🎙️ Voice Memos',
    'text_note': '📝 Notes',
    'pdf_document': '📄 Documents',
  };

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final allMemories = appState.memories;

    // Filter by search and category
    final filterQuery = _searchController.text.trim().toLowerCase();
    final memories = allMemories.where((m) {
      final matchesCategory = _selectedCategory == 'all' || m.category == _selectedCategory;
      final matchesQuery = filterQuery.isEmpty ||
          m.title.toLowerCase().contains(filterQuery) ||
          m.albumName.toLowerCase().contains(filterQuery) ||
          (m.locationName ?? '').toLowerCase().contains(filterQuery);
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search memories, albums, letters...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              )
            : const Text('Love Memories Vault', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded, color: Colors.white70),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
          IconButton(
            icon: Icon(_viewMode == 'grid' ? Icons.timeline_rounded : Icons.grid_view_rounded, color: AppTheme.accentGold),
            tooltip: _viewMode == 'grid' ? 'Switch to Love Timeline' : 'Switch to Gallery Grid',
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == 'grid' ? 'timeline' : 'grid';
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined, color: AppTheme.primaryRose, size: 28),
            onPressed: () => _showAddMemoryModal(context, appState),
          ),
        ],
      ),
      body: Column(
        children: [
          // Storage & Cloud Indicator Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_done_rounded, color: AppTheme.accentGold, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Private Encrypted Cloud Vault', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('${allMemories.length} Memories • 48.2 MB / 5.0 GB', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          value: 0.08,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRose),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filter Categories Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: _categories.entries.map((e) => _buildTab(e.key, e.value)).toList(),
            ),
          ),

          // Memories Content (Grid vs Timeline)
          Expanded(
            child: memories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.photo_library_outlined, size: 56, color: Colors.white24),
                        const SizedBox(height: 12),
                        Text(
                          _isSearching ? 'No memories match your query.' : 'Vault is waiting for your treasured moments.',
                          style: TextStyle(color: Colors.white.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  )
                : _viewMode == 'grid'
                    ? _buildGridView(memories, appState)
                    : _buildTimelineView(memories, appState),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<MemoryModel> memories, AppState appState) {
    return GridView.builder(
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
        return GestureDetector(
          onTap: () => _showMemoryPreview(context, mem, appState),
          child: Container(
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
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top category tag and favorite button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _getCategoryIcon(mem.category),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          mem.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: mem.isFavorite ? AppTheme.primaryRose : Colors.white60,
                          size: 20,
                        ),
                        onPressed: () => appState.toggleMemoryFavorite(mem.id),
                      ),
                    ],
                  ),

                  // Bottom Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mem.title,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMM d, y').format(mem.memoryDate),
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                          ),
                          Text(
                            mem.albumName,
                            style: const TextStyle(color: AppTheme.accentGold, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineView(List<MemoryModel> memories, AppState appState) {
    // Sort chronological
    final sorted = List<MemoryModel>.from(memories)..sort((a, b) => b.memoryDate.compareTo(a.memoryDate));

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final mem = sorted[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline track & icon
            Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [AppTheme.primaryRose, AppTheme.accentGold]),
                  ),
                  child: Center(
                    child: Text(_getCategoryIcon(mem.category), style: const TextStyle(fontSize: 16)),
                  ),
                ),
                if (index < sorted.length - 1)
                  Container(
                    width: 2,
                    height: 90,
                    color: Colors.white12,
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Timeline Card
            Expanded(
              child: GestureDetector(
                onTap: () => _showMemoryPreview(context, mem, appState),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.glassBox(context: context, radius: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('MMMM d, yyyy').format(mem.memoryDate), style: const TextStyle(color: AppTheme.accentGold, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(mem.albumName, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(mem.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      if (mem.encryptedBody != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          mem.encryptedBody!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontStyle: FontStyle.italic),
                        ),
                      ],
                      if (mem.locationName != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.place_outlined, size: 12, color: AppTheme.primaryRose),
                            const SizedBox(width: 4),
                            Text(mem.locationName!, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTab(String key, String label) {
    final isSelected = _selectedCategory == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedCategory = key),
        selectedColor: AppTheme.primaryRose,
        backgroundColor: Colors.white.withOpacity(0.05),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        side: BorderSide(color: isSelected ? AppTheme.primaryRose : Colors.white.withOpacity(0.1)),
      ),
    );
  }

  String _getCategoryIcon(String cat) {
    switch (cat) {
      case 'photo':
        return '📸';
      case 'video':
        return '🎥';
      case 'letter':
        return '💌';
      case 'voice_note':
        return '🎙️';
      case 'text_note':
        return '📝';
      case 'pdf_document':
        return '📄';
      default:
        return '💖';
    }
  }

  void _showAddMemoryModal(BuildContext context, AppState appState) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final albumController = TextEditingController(text: 'Main Memories');
    final locController = TextEditingController();
    String category = 'photo';
    DateTime selectedDate = DateTime.now();
    bool isFav = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1C2B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Save Love Memory', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                    const SizedBox(height: 20),

                    // Title
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Memory Title',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        prefixIcon: const Icon(Icons.favorite_rounded, color: AppTheme.primaryRose),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: category,
                          dropdownColor: const Color(0xFF1E1C2B),
                          isExpanded: true,
                          items: _categories.entries.where((e) => e.key != 'all').map((e) {
                            return DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(color: Colors.white)));
                          }).toList(),
                          onChanged: (val) => setModalState(() => category = val!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (category == 'letter' || category == 'text_note') ...[
                      TextField(
                        controller: bodyController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Love Letter / Note Content (Encrypted 🔒)',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Album Name
                    TextField(
                      controller: albumController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Album Name',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        prefixIcon: const Icon(Icons.photo_album_outlined, color: AppTheme.accentGold),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Location
                    TextField(
                      controller: locController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Location / City',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        prefixIcon: const Icon(Icons.place_outlined, color: AppTheme.primaryRose),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Favorite switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Mark as Favorite Memory ❤️', style: TextStyle(color: Colors.white, fontSize: 14)),
                      value: isFav,
                      activeColor: AppTheme.primaryRose,
                      onChanged: (val) => setModalState(() => isFav = val),
                    ),
                    const SizedBox(height: 18),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRose,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () async {
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;

                        await appState.addMemory(
                          title: title,
                          category: category,
                          albumName: albumController.text.trim(),
                          encryptedBody: bodyController.text.trim().isNotEmpty ? bodyController.text.trim() : null,
                          mediaPath: category == 'photo'
                              ? 'https://images.unsplash.com/photo-1518199266791-5375a83190b7?w=800&auto=format&fit=crop&q=60'
                              : null,
                          memoryDate: selectedDate,
                          locationName: locController.text.trim().isNotEmpty ? locController.text.trim() : null,
                          isFavorite: isFav,
                        );
                        if (mounted) Navigator.pop(ctx);
                      },
                      child: const Text('Save to Love Vault', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMemoryPreview(BuildContext context, MemoryModel mem, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1C2B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_getCategoryIcon(mem.category), style: const TextStyle(fontSize: 28)),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(mem.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: AppTheme.primaryRose),
                          onPressed: () {
                            appState.toggleMemoryFavorite(mem.id);
                            Navigator.pop(ctx);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          onPressed: () async {
                            await appState.deleteMemory(mem.id);
                            if (mounted) Navigator.pop(ctx);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(mem.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text(
                  '${DateFormat('MMMM d, yyyy').format(mem.memoryDate)} • ${mem.albumName}',
                  style: const TextStyle(color: AppTheme.accentGold, fontSize: 13),
                ),
                const SizedBox(height: 16),

                if (mem.category == 'letter' || mem.category == 'text_note') ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF282438),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.lock_rounded, size: 14, color: AppTheme.accentGold),
                            SizedBox(width: 6),
                            Text('End-to-End Encrypted Letter', style: TextStyle(color: AppTheme.accentGold, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          mem.encryptedBody ?? 'My dearest, every second with you is a blessing that I cherish forever.',
                          style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ] else if (mem.mediaPath != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(mem.mediaPath!, height: 220, fit: BoxFit.cover),
                  ),
                ],

                if (mem.locationName != null) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.place_rounded, size: 16, color: AppTheme.primaryRose),
                      const SizedBox(width: 6),
                      Text(mem.locationName!, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
