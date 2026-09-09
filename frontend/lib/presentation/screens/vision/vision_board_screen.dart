import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../providers/app_state.dart';

class VisionBoardScreen extends StatefulWidget {
  const VisionBoardScreen({super.key});

  @override
  State<VisionBoardScreen> createState() => _VisionBoardScreenState();
}

class _VisionBoardScreenState extends State<VisionBoardScreen> {
  String _selectedCategory = 'all';

  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'label': 'All Goals', 'icon': Icons.auto_awesome_rounded},
    {'id': 'dream_house', 'label': 'Dream House', 'icon': Icons.home_rounded},
    {'id': 'business', 'label': 'Business', 'icon': Icons.business_center_rounded},
    {'id': 'savings', 'label': 'Savings', 'icon': Icons.savings_rounded},
    {'id': 'travel', 'label': 'Travel', 'icon': Icons.flight_takeoff_rounded},
    {'id': 'wedding', 'label': 'Wedding', 'icon': Icons.favorite_rounded},
    {'id': 'education', 'label': 'Education', 'icon': Icons.school_rounded},
    {'id': 'children', 'label': 'Children', 'icon': Icons.child_friendly_rounded},
    {'id': 'life_goals', 'label': 'Life Goals', 'icon': Icons.flag_rounded},
    {'id': 'wishlist', 'label': 'Wishlist', 'icon': Icons.card_giftcard_rounded},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().fetchVisionBoards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final allBoards = appState.visionBoards.isNotEmpty
        ? appState.visionBoards
        : _getDemoBoards();

    final filteredBoards = _selectedCategory == 'all'
        ? allBoards
        : allBoards.where((b) => b.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Vision Board', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryRose, size: 28),
            tooltip: 'Add Vision Goal',
            onPressed: () => _showAddGoalModal(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat['id'];
                return ChoiceChip(
                  avatar: Icon(cat['icon'] as IconData, size: 16, color: isSelected ? Colors.white : Colors.white70),
                  label: Text(cat['label'] as String),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryRose,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = cat['id'] as String);
                    }
                  },
                );
              },
            ),
          ),

          // Main Vision Board Cards List
          Expanded(
            child: filteredBoards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, size: 64, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'No goals in this category yet',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to create your couple dream together!',
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _showAddGoalModal(context),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Dream Goal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRose,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBoards.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final board = filteredBoards[index];
                      return _buildVisionCard(context, board, appState);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryRose,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Goal', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showAddGoalModal(context),
      ),
    );
  }

  Widget _buildVisionCard(BuildContext context, VisionBoardModel board, AppState appState) {
    final catMeta = _categories.firstWhere((c) => c['id'] == board.category, orElse: () => {'label': board.category, 'icon': Icons.flag_rounded});
    final hasFinancial = board.targetAmount != null && board.targetAmount! > 0;

    return Container(
      decoration: AppTheme.glassBox(context: context, radius: 24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional Header Cover Image or Banner
          if (board.coverImageUrl != null && board.coverImageUrl!.isNotEmpty)
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(board.coverImageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    _buildCategoryBadge(catMeta['label'] as String, catMeta['icon'] as IconData),
                    const Spacer(),
                    _buildPriorityChip(board.priority),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  _buildCategoryBadge(catMeta['label'] as String, catMeta['icon'] as IconData),
                  const SizedBox(width: 8),
                  _buildPriorityChip(board.priority),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz_rounded, color: Colors.white60),
                    color: const Color(0xFF1E1C2B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _confirmDelete(context, board, appState);
                      } else if (value == 'add_item') {
                        _showAddItemModal(context, board.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'add_item',
                        child: Row(
                          children: [
                            Icon(Icons.playlist_add_rounded, color: AppTheme.primaryRose, size: 20),
                            SizedBox(width: 10),
                            Text('Add Task / Note', style: TextStyle(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            SizedBox(width: 10),
                            Text('Delete Goal', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Goal Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        board.title,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (board.coverImageUrl != null && board.coverImageUrl!.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.more_horiz_rounded, color: Colors.white60),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _showCardActions(context, board, appState),
                      ),
                  ],
                ),

                if (board.description != null && board.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    board.description!,
                    style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13, height: 1.4),
                  ),
                ],

                const SizedBox(height: 16),

                // Financial Progress or Task Progress
                if (hasFinancial) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${board.currentAmount.toStringAsFixed(0)} / \$${board.targetAmount!.toStringAsFixed(0)}',
                        style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        '${board.progressPercentage}% Saved',
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (board.progressPercentage / 100).clamp(0.0, 1.0),
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                      minHeight: 8,
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                      ),
                      Text(
                        '${board.progressPercentage}%',
                        style: const TextStyle(color: AppTheme.primaryRose, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (board.progressPercentage / 100).clamp(0.0, 1.0),
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryRose),
                      minHeight: 8,
                    ),
                  ),
                ],

                // Target Date / Deadline Banner
                if (board.targetDate != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 14, color: AppTheme.primaryRose),
                        const SizedBox(width: 6),
                        Text(
                          'Target: ${board.targetDate!.year}-${board.targetDate!.month.toString().padLeft(2, '0')}-${board.targetDate!.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],

                // Checklists, Sticky Notes & Milestones
                if (board.items.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tasks & Sticky Notes',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () => _showAddItemModal(context, board.id),
                        child: const Text(
                          '+ Add Item',
                          style: TextStyle(color: AppTheme.primaryRose, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...board.items.map((item) => _buildItemRow(context, board.id, item, appState)),
                ] else ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showAddItemModal(context, board.id),
                    icon: const Icon(Icons.add_task_rounded, size: 16),
                    label: const Text('Add Milestone Checklist or Note', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryRose,
                      side: BorderSide(color: AppTheme.primaryRose.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryRose.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primaryRose.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.primaryRose),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(color: AppTheme.primaryRose, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    String label;
    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.redAccent;
        label = '🔥 High Priority';
        break;
      case 'low':
        color = Colors.greenAccent;
        label = '🌱 Low Priority';
        break;
      case 'medium':
      default:
        color = Colors.amberAccent;
        label = '⚡ Medium';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, int boardId, VisionItemModel item, AppState appState) {
    if (item.type == 'sticky_note') {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9C4).withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFF59D).withOpacity(0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.push_pin_rounded, color: Colors.amberAccent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  if (item.content != null && item.content!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(item.content!, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: () => appState.deleteVisionItem(item.id),
              child: const Icon(Icons.close_rounded, size: 16, color: Colors.white38),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => appState.toggleVisionItem(item.id),
            child: Icon(
              item.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: item.isCompleted ? AppTheme.primaryRose : Colors.white38,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => appState.toggleVisionItem(item.id),
              child: Text(
                item.title,
                style: TextStyle(
                  color: item.isCompleted ? Colors.white38 : Colors.white,
                  decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => appState.deleteVisionItem(item.id),
            child: const Icon(Icons.close_rounded, size: 16, color: Colors.white24),
          ),
        ],
      ),
    );
  }

  void _showCardActions(BuildContext context, VisionBoardModel board, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1C2B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.playlist_add_rounded, color: AppTheme.primaryRose),
                  title: const Text('Add Milestone Task / Note', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddItemModal(context, board.id);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  title: const Text('Delete Vision Goal', style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(context, board, appState);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, VisionBoardModel board, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C2B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Goal?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${board.title}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              await appState.deleteVisionBoard(board.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vision goal deleted')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddGoalModal(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final targetAmountController = TextEditingController();
    final currentAmountController = TextEditingController();
    String category = 'dream_house';
    String priority = 'medium';
    DateTime? targetDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1C2B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Create Vision Goal ✨',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plan your shared future together as a couple',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                    ),
                    const SizedBox(height: 18),

                    // Goal Title
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Goal Title',
                        hintText: 'e.g. Buy Our Dream Villa in Malibu',
                        hintStyle: const TextStyle(color: Colors.white30),
                        prefixIcon: const Icon(Icons.flag_rounded, color: AppTheme.primaryRose),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      value: category,
                      dropdownColor: const Color(0xFF252336),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Category',
                        prefixIcon: const Icon(Icons.category_rounded, color: AppTheme.accentGold),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                      items: _categories.where((c) => c['id'] != 'all').map((c) {
                        return DropdownMenuItem<String>(
                          value: c['id'] as String,
                          child: Text(c['label'] as String),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => category = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Description
                    TextField(
                      controller: descController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description / Vision Note',
                        hintText: 'Describe what achieving this together feels like...',
                        hintStyle: const TextStyle(color: Colors.white30),
                        prefixIcon: const Icon(Icons.description_rounded, color: Colors.white60),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Target Budget / Savings (Optional)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: targetAmountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Target (\$)',
                              hintText: '100000',
                              hintStyle: const TextStyle(color: Colors.white30),
                              prefixIcon: const Icon(Icons.monetization_on_rounded, color: Colors.greenAccent),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.04),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: currentAmountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Current Saved (\$)',
                              hintText: '45000',
                              hintStyle: const TextStyle(color: Colors.white30),
                              prefixIcon: const Icon(Icons.savings_rounded, color: AppTheme.accentGold),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.04),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Target Date & Priority Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 90)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 3650)),
                              );
                              if (picked != null) {
                                setModalState(() => targetDate = picked);
                              }
                            },
                            icon: const Icon(Icons.calendar_today_rounded, size: 16),
                            label: Text(
                              targetDate == null
                                  ? 'Set Deadline'
                                  : '${targetDate!.year}-${targetDate!.month.toString().padLeft(2, '0')}-${targetDate!.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: priority,
                            dropdownColor: const Color(0xFF252336),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.04),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'high', child: Text('🔥 High')),
                              DropdownMenuItem(value: 'medium', child: Text('⚡ Medium')),
                              DropdownMenuItem(value: 'low', child: Text('🌱 Low')),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => priority = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRose,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty) return;
                          final appState = context.read<AppState>();
                          final success = await appState.createVisionBoard(
                            title: titleController.text.trim(),
                            category: category,
                            description: descController.text.trim().isNotEmpty ? descController.text.trim() : null,
                            targetAmount: double.tryParse(targetAmountController.text.trim()),
                            currentAmount: double.tryParse(currentAmountController.text.trim()),
                            targetDate: targetDate,
                            priority: priority,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Dream Goal added to your shared vision board! 🌟')),
                              );
                            }
                          }
                        },
                        child: const Text('Add to Vision Board', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
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

  void _showAddItemModal(BuildContext context, int boardId) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String itemType = 'checklist';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1C2B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Goal Task or Sticky Note', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ChoiceChip(
                        avatar: const Icon(Icons.check_box_outlined, size: 16),
                        label: const Text('Task / Milestone'),
                        selected: itemType == 'checklist',
                        selectedColor: AppTheme.primaryRose,
                        onSelected: (val) {
                          if (val) setModalState(() => itemType = 'checklist');
                        },
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        avatar: const Icon(Icons.push_pin_outlined, size: 16),
                        label: const Text('Sticky Note'),
                        selected: itemType == 'sticky_note',
                        selectedColor: Colors.amberAccent,
                        labelStyle: TextStyle(color: itemType == 'sticky_note' ? Colors.black87 : Colors.white),
                        onSelected: (val) {
                          if (val) setModalState(() => itemType = 'sticky_note');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: itemType == 'sticky_note' ? 'Note Title' : 'Milestone Task',
                      hintText: itemType == 'sticky_note' ? 'e.g. Design inspiration for the patio' : 'e.g. Get pre-approval letter from bank',
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.04),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  if (itemType == 'sticky_note') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: contentController,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Note Content',
                        hintText: 'Write romantic notes, details or thoughts...',
                        hintStyle: const TextStyle(color: Colors.white30),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRose,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) return;
                        final appState = context.read<AppState>();
                        await appState.addVisionItem(
                          boardId,
                          title: titleController.text.trim(),
                          content: contentController.text.trim().isNotEmpty ? contentController.text.trim() : null,
                          type: itemType,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add to Goal', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<VisionBoardModel> _getDemoBoards() {
    return [
      VisionBoardModel(
        id: 1,
        title: 'Modern Seaside Villa',
        category: 'dream_house',
        description: 'Our forever home near the Mediterranean coast with panoramic glass windows and a flower garden.',
        targetAmount: 350000,
        currentAmount: 145000,
        progressPercentage: 41,
        priority: 'high',
        targetDate: DateTime(2028, 6, 30),
        items: [
          VisionItemModel(id: 101, title: 'Pick top 3 architectural blueprints', type: 'checklist', isCompleted: true),
          VisionItemModel(id: 102, title: 'Reach \$150k down payment mark', type: 'checklist', isCompleted: false),
          VisionItemModel(id: 103, title: 'Dream Patio Idea', content: 'String lights + open fireplace for stargazing together', type: 'sticky_note', isCompleted: false),
        ],
      ),
      VisionBoardModel(
        id: 2,
        title: 'Romantic Tokyo & Kyoto Expedition',
        category: 'travel',
        description: 'Cherry blossom season in Kyoto, exploring Mount Fuji hot springs, and sushi making class.',
        targetAmount: 8500,
        currentAmount: 6200,
        progressPercentage: 73,
        priority: 'high',
        targetDate: DateTime(2027, 4, 15),
        items: [
          VisionItemModel(id: 201, title: 'Book authentic Ryokan in Gion', type: 'checklist', isCompleted: true),
          VisionItemModel(id: 202, title: 'Purchase Japan Rail Pass tickets', type: 'checklist', isCompleted: true),
          VisionItemModel(id: 203, title: 'Teamlabs Borderless tickets', type: 'checklist', isCompleted: false),
        ],
      ),
      VisionBoardModel(
        id: 3,
        title: 'Artisan Coffee & Bakery Venture',
        category: 'business',
        description: 'Our cozy couple coffee lounge serving specialty pour-overs, homemade croissants, and couple book clubs.',
        targetAmount: 75000,
        currentAmount: 22000,
        progressPercentage: 29,
        priority: 'medium',
        targetDate: DateTime(2029, 1, 1),
        items: [
          VisionItemModel(id: 301, title: 'Complete Specialty Coffee Association barista certification', type: 'checklist', isCompleted: true),
          VisionItemModel(id: 302, title: 'Draft joint business plan & branding palette', type: 'checklist', isCompleted: false),
        ],
      ),
      VisionBoardModel(
        id: 4,
        title: 'Sunset Beach Wedding Celebration',
        category: 'wedding',
        description: 'Intimate ceremony with our closest families, acoustic live music, and fairy light reception.',
        targetAmount: 25000,
        currentAmount: 25000,
        progressPercentage: 100,
        priority: 'high',
        targetDate: DateTime(2026, 12, 20),
        status: 'achieved',
        items: [
          VisionItemModel(id: 401, title: 'Book beachfront venue & catering', type: 'checklist', isCompleted: true),
          VisionItemModel(id: 402, title: 'Custom handmade vows written', type: 'checklist', isCompleted: true),
          VisionItemModel(id: 403, title: 'Wedding Playlist Note', content: 'First dance song: "Can\'t Help Falling in Love" acoustic', type: 'sticky_note', isCompleted: true),
        ],
      ),
    ];
  }
}
