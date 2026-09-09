import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';

class VisionBoardScreen extends StatelessWidget {
  const VisionBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final boards = appState.visionBoards;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Vision Board', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded, color: AppTheme.primaryRose, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: boards.isEmpty
          ? Center(
              child: Text('Create your first couple dream goal!', style: TextStyle(color: Colors.white.withOpacity(0.6))),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: boards.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final board = boards[index];
                return Container(
                  decoration: AppTheme.glassBox(context: context, radius: 24),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header & Category Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              board.category.replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(color: AppTheme.accentGold, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text('${board.progressPercentage}% Completed', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title & Description
                      Text(board.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      if (board.description != null) ...[
                        const SizedBox(height: 4),
                        Text(board.description!, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                      ],
                      const SizedBox(height: 16),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: board.progressPercentage / 100,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryRose),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Checklists & Milestones
                      if (board.items.isNotEmpty) ...[
                        const Text('Milestones', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 8),
                        ...board.items.map((item) {
                          return GestureDetector(
                            onTap: () => appState.toggleVisionItem(item.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Icon(
                                    item.isCompleted ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                    color: item.isCompleted ? AppTheme.primaryRose : Colors.white38,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        color: item.isCompleted ? Colors.white38 : Colors.white,
                                        decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
