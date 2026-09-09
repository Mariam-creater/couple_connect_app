import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:couple_connect_frontend/presentation/providers/app_state.dart';
import 'package:couple_connect_frontend/presentation/screens/vision/vision_board_screen.dart';
import 'package:couple_connect_frontend/presentation/screens/streak/streak_screen.dart';

void main() {
  testWidgets('VisionBoardScreen renders category chips and demo boards', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MaterialApp(
          home: VisionBoardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Shared Vision Board'), findsOneWidget);
    expect(find.text('All Goals'), findsOneWidget);
    expect(find.text('Dream House'), findsOneWidget);
    expect(find.text('Modern Seaside Villa'), findsOneWidget);
  });

  testWidgets('StreakScreen renders flame card, level and statistics', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MaterialApp(
          home: StreakScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Couple Streak & Milestones'), findsOneWidget);
    expect(find.textContaining('Days On Fire'), findsOneWidget);
    expect(find.text('Relationship Statistics'), findsOneWidget);
    expect(find.text('30-Day Activity Heatmap'), findsOneWidget);
  });
}
