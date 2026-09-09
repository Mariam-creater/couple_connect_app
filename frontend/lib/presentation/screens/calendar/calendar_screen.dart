import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../providers/app_state.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  String _selectedCategory = 'all';
  String _viewMode = 'month'; // 'month', 'week', 'daily'
  DateTime _selectedDate = DateTime.now();

  final Map<String, String> _categoryLabels = {
    'all': 'All Events',
    'anniversary': '💍 Anniversary',
    'birthday': '🎂 Birthday',
    'date_night': '🍷 Date Night',
    'movie_night': '🍿 Movie Night',
    'travel': '✈️ Travel',
    'wedding_planning': '💒 Wedding Planning',
    'bills': '💳 Bills & Finances',
    'other': '✨ Custom Event',
  };

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final allEvents = appState.calendarEvents;

    final filteredEvents = _selectedCategory == 'all'
        ? allEvents
        : allEvents.where((e) => e.category == _selectedCategory).toList();

    final countdownEvent = allEvents.where((e) => e.isCountdown && e.startTime.isAfter(DateTime.now())).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final activeCountdown = countdownEvent.isNotEmpty ? countdownEvent.first : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Love Calendar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          // View Mode Selector Segment
          PopupMenuButton<String>(
            icon: const Icon(Icons.view_agenda_outlined, color: Colors.white70),
            color: const Color(0xFF1E1C2B),
            onSelected: (mode) => setState(() => _viewMode = mode),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'month', child: Text('Monthly Grid View', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'week', child: Text('Weekly Timeline View', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'daily', child: Text('Daily Agenda View', style: TextStyle(color: Colors.white))),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryRose, size: 28),
            onPressed: () => _showEventModal(context, appState),
          ),
        ],
      ),
      body: Column(
        children: [
          // Active Countdown Banner (if any upcoming countdown)
          if (activeCountdown != null) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B1135), Color(0xFF3F134A)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryRose.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.timer_rounded, color: AppTheme.accentGold, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('COUNTDOWN TO SPECIAL MOMENT', style: TextStyle(color: AppTheme.accentGold.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const SizedBox(height: 2),
                        Text(activeCountdown.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(DateFormat('EEEE, MMMM d, y').format(activeCountdown.startTime), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${activeCountdown.startTime.difference(DateTime.now()).inDays + 1}',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Text('DAYS LEFT', style: TextStyle(color: AppTheme.accentGold, fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: _categoryLabels.entries.map((e) => _buildCategoryChip(e.key, e.value)).toList(),
            ),
          ),

          // Calendar View Mode
          if (_viewMode == 'month')
            _buildMonthCalendarView(filteredEvents)
          else if (_viewMode == 'week')
            _buildWeekCalendarView(filteredEvents)
          else
            _buildDailyAgendaHeader(),

          const SizedBox(height: 8),

          // Events List View
          Expanded(
            child: filteredEvents.isEmpty
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
                    itemCount: filteredEvents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      final daysRemaining = event.startTime.difference(DateTime.now()).inDays;

                      return GestureDetector(
                        onTap: () => _showEventDetailSheet(context, event, appState),
                        child: Container(
                          decoration: AppTheme.glassBox(context: context, radius: 20),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Date Box
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryRose.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.primaryRose.withOpacity(0.25)),
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

                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(_getCategoryEmoji(event.category), style: const TextStyle(fontSize: 14)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            event.title,
                                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      event.isAllDay ? 'All Day' : DateFormat('h:mm a').format(event.startTime),
                                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                                    ),
                                    if (event.location != null) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined, size: 12, color: AppTheme.accentGold),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              event.location!,
                                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Days Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  daysRemaining == 0
                                      ? 'Today'
                                      : daysRemaining > 0
                                          ? 'In $daysRemaining d'
                                          : '${daysRemaining.abs()} d ago',
                                  style: TextStyle(
                                    color: daysRemaining == 0
                                        ? Colors.greenAccent
                                        : daysRemaining > 0
                                            ? AppTheme.accentGold
                                            : Colors.white54,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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

  Widget _buildMonthCalendarView(List<CalendarEventModel> events) {
    final now = _selectedDate;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161522),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, color: Colors.white70),
                onPressed: () => setState(() => _selectedDate = DateTime(now.year, now.month - 1, 1)),
              ),
              Text(
                DateFormat('MMMM yyyy').format(now),
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: Colors.white70),
                onPressed: () => setState(() => _selectedDate = DateTime(now.year, now.month + 1, 1)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              return Text(day, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold));
            }).toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: (startingWeekday - 1) + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, index) {
              if (index < startingWeekday - 1) {
                return const SizedBox.shrink();
              }
              final dayNum = index - (startingWeekday - 1) + 1;
              final cellDate = DateTime(now.year, now.month, dayNum);
              final isToday = cellDate.year == DateTime.now().year &&
                  cellDate.month == DateTime.now().month &&
                  cellDate.day == DateTime.now().day;
              final hasEvent = events.any((e) =>
                  e.startTime.year == cellDate.year &&
                  e.startTime.month == cellDate.month &&
                  e.startTime.day == cellDate.day);

              return Center(
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isToday ? AppTheme.primaryRose : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          color: isToday ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (hasEvent && !isToday)
                        Positioned(
                          bottom: 2,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(color: AppTheme.accentGold, shape: BoxShape.circle),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendarView(List<CalendarEventModel> events) {
    final now = DateTime.now();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(7, (i) {
          final day = now.add(Duration(days: i));
          final hasEvent = events.any((e) => e.startTime.day == day.day && e.startTime.month == day.month);
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: i == 0 ? AppTheme.primaryRose.withOpacity(0.2) : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: i == 0 ? AppTheme.primaryRose : Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                Text(DateFormat('E').format(day).toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('${day.day}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                if (hasEvent)
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.accentGold, shape: BoxShape.circle))
                else
                  const SizedBox(height: 6),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDailyAgendaHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Today’s Agenda', style: TextStyle(color: AppTheme.accentGold, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(DateFormat('EEEE, MMM d').format(DateTime.now()), style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String key, String label) {
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

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'anniversary':
        return '💍';
      case 'birthday':
        return '🎂';
      case 'date_night':
        return '🍷';
      case 'movie_night':
        return '🍿';
      case 'travel':
        return '✈️';
      case 'wedding_planning':
        return '💒';
      case 'bills':
        return '💳';
      default:
        return '✨';
    }
  }

  void _showEventModal(BuildContext context, AppState appState, {CalendarEventModel? existing}) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final descController = TextEditingController(text: existing?.description ?? '');
    final locController = TextEditingController(text: existing?.location ?? '');
    String category = existing?.category ?? 'date_night';
    DateTime selectedDate = existing?.startTime ?? DateTime.now().add(const Duration(days: 1));
    bool isCountdown = existing?.isCountdown ?? false;
    bool isAllDay = existing?.isAllDay ?? false;
    String recurrence = existing?.recurrence ?? 'none';
    int reminder = existing?.reminderMinutesBefore ?? 60;

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
                    Text(
                      existing == null ? 'Create Love Event' : 'Edit Event',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Title
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Event Title',
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
                          items: _categoryLabels.entries.where((e) => e.key != 'all').map((e) {
                            return DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(color: Colors.white)));
                          }).toList(),
                          onChanged: (val) => setModalState(() => category = val!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Date & Time Picker Row
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (pickedDate != null) {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedDate),
                          );
                          setModalState(() {
                            selectedDate = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime?.hour ?? 18,
                              pickedTime?.minute ?? 0,
                            );
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: AppTheme.accentGold),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                DateFormat('EEEE, MMM d, y • h:mm a').format(selectedDate),
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Location
                    TextField(
                      controller: locController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Location / Venue',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        prefixIcon: const Icon(Icons.place_outlined, color: AppTheme.primaryRose),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Countdown & Recurrence Switches
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Featured Countdown Banner', style: TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: Text('Pin on top of calendar with live days countdown', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                      value: isCountdown,
                      activeColor: AppTheme.primaryRose,
                      onChanged: (val) => setModalState(() => isCountdown = val),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('All Day Event', style: TextStyle(color: Colors.white, fontSize: 14)),
                      value: isAllDay,
                      activeColor: AppTheme.primaryRose,
                      onChanged: (val) => setModalState(() => isAllDay = val),
                    ),

                    const SizedBox(height: 20),

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

                        if (existing == null) {
                          await appState.addCalendarEvent(
                            title: title,
                            category: category,
                            startTime: selectedDate,
                            description: descController.text.trim(),
                            location: locController.text.trim(),
                            isCountdown: isCountdown,
                            isAllDay: isAllDay,
                            recurrence: recurrence,
                            reminderMinutesBefore: reminder,
                          );
                        } else {
                          await appState.updateCalendarEvent(
                            existing.id,
                            title: title,
                            category: category,
                            startTime: selectedDate,
                            description: descController.text.trim(),
                            location: locController.text.trim(),
                            isCountdown: isCountdown,
                            isAllDay: isAllDay,
                            recurrence: recurrence,
                            reminderMinutesBefore: reminder,
                          );
                        }
                        if (mounted) Navigator.pop(ctx);
                      },
                      child: Text(existing == null ? 'Save to Shared Calendar' : 'Update Event', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  void _showEventDetailSheet(BuildContext context, CalendarEventModel event, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1C2B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_getCategoryEmoji(event.category), style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(_categoryLabels[event.category] ?? 'Event', style: const TextStyle(color: AppTheme.accentGold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time_rounded, color: AppTheme.primaryRose),
                  title: Text(DateFormat('EEEE, MMMM d, y • h:mm a').format(event.startTime), style: const TextStyle(color: Colors.white, fontSize: 14)),
                ),
                if (event.location != null) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.place_rounded, color: AppTheme.primaryRose),
                    title: Text(event.location!, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ],
                const Divider(color: Colors.white12, height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withOpacity(0.2)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showEventModal(context, appState, existing: event);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.2),
                          foregroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          await appState.deleteCalendarEvent(event.id);
                          if (mounted) Navigator.pop(ctx);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
