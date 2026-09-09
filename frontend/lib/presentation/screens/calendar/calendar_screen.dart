import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final events = _selectedCategory == 'all'
        ? appState.calendarEvents
        : appState.calendarEvents.where((e) => e.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Love Calendar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryRose, size: 28),
            onPressed: () => _showAddEventModal(context, appState),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildCategoryChip('all', 'All Events'),
                _buildCategoryChip('anniversary', '💍 Anniversary'),
                _buildCategoryChip('date_night', '🍷 Date Night'),
                _buildCategoryChip('travel', '✈️ Travel'),
                _buildCategoryChip('movie_night', '🍿 Movie Night'),
                _buildCategoryChip('birthday', '🎂 Birthday'),
              ],
            ),
          ),

          // Events List View
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_available_rounded, size: 56, color: Colors.white24),
                        const SizedBox(height: 12),
                        Text('No events in this category yet.', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final daysRemaining = event.startTime.difference(DateTime.now()).inDays;

                      return Container(
                        decoration: AppTheme.glassBox(context: context, radius: 20),
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            // Date Box
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryRose.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('MMM').format(event.startTime).toUpperCase(),
                                    style: const TextStyle(color: AppTheme.primaryRose, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    DateFormat('d').format(event.startTime),
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    event.description ?? event.location ?? DateFormat('EEEE @ h:mm a').format(event.startTime),
                                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            // Countdown Badge
                            if (event.isCountdown)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.accentGold.withOpacity(0.4)),
                                ),
                                child: Text(
                                  daysRemaining <= 0 ? 'Today!' : 'in $daysRemaining d',
                                  style: const TextStyle(color: AppTheme.accentGold, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String key, String label) {
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

  void _showAddEventModal(BuildContext context, AppState appState) {
    final titleController = TextEditingController();
    String category = 'date_night';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    bool isCountdown = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1C2B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Special Event', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Event Title (e.g. Stargazing Picnic)',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                dropdownColor: const Color(0xFF1E1C2B),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                items: const [
                  DropdownMenuItem(value: 'date_night', child: Text('🍷 Date Night')),
                  DropdownMenuItem(value: 'anniversary', child: Text('💍 Anniversary')),
                  DropdownMenuItem(value: 'travel', child: Text('✈️ Travel & Vacation')),
                  DropdownMenuItem(value: 'movie_night', child: Text('🍿 Movie Night')),
                  DropdownMenuItem(value: 'birthday', child: Text('🎂 Birthday')),
                ],
                onChanged: (val) => category = val!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRose,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  if (titleController.text.trim().isEmpty) return;
                  await appState.addCalendarEvent(
                    titleController.text.trim(),
                    category,
                    selectedDate,
                    isCountdown: isCountdown,
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Save Event', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }
}
