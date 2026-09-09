import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:couple_connect_frontend/presentation/providers/app_state.dart';
import 'package:couple_connect_frontend/presentation/screens/chat/chat_screen.dart';
import 'package:couple_connect_frontend/presentation/screens/games/games_screen.dart';
import 'package:couple_connect_frontend/data/models/models.dart';

void main() {
  testWidgets('ChatScreen renders correctly with empty and populated messages', (WidgetTester tester) async {
    final appState = AppState();
    appState.currentUser = UserModel(
      id: 1,
      name: 'Alex Johnson',
      username: 'alex_j',
      email: 'alex@coupleconnect.app',
      coupleId: 'CP-9942',
      relationshipStatus: 'connected',
    );
    appState.partner = UserModel(
      id: 2,
      name: 'Sophia Rose',
      username: 'sophia_r',
      email: 'sophia@coupleconnect.app',
      coupleId: 'CP-9942',
      relationshipStatus: 'connected',
    );
    appState.coupleSpace = CoupleSpaceModel(
      id: 1,
      uuid: 'space-uuid-1234',
      spaceName: 'Alex & Sophia Space',
      themePreset: 'rose_gold',
      connectedAt: DateTime.now(),
    );

    // Populate a text message, voice note, and document
    appState.messages = [
      MessageModel(
        id: 101,
        messageUuid: 'msg-uuid-1',
        senderId: 1,
        type: 'text',
        encryptedPayload: 'payload1',
        iv: 'iv1',
        createdAt: DateTime.now(),
        decryptedText: 'I love you so much sweetheart! ❤️',
        status: 'read',
      ),
      MessageModel(
        id: 102,
        messageUuid: 'msg-uuid-2',
        senderId: 2,
        type: 'voice',
        encryptedPayload: 'payload2',
        iv: 'iv2',
        createdAt: DateTime.now(),
        decryptedText: '🎙️ Voice Note (0:18)',
        metadata: {'duration': '0:18', 'seconds': 18},
        status: 'read',
      ),
      MessageModel(
        id: 103,
        messageUuid: 'msg-uuid-3',
        senderId: 1,
        type: 'document',
        encryptedPayload: 'payload3',
        iv: 'iv3',
        createdAt: DateTime.now(),
        decryptedText: 'Kyoto_Trip_Plan.pdf',
        metadata: {'file_name': 'Kyoto_Trip_Plan.pdf', 'file_size': '2.4 MB'},
        status: 'read',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const ChatScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    // Verify partner name and online encryption status header
    expect(find.text('Sophia Rose'), findsOneWidget);
    expect(find.textContaining('E2EE AES-256'), findsOneWidget);

    // Verify messages appear
    expect(find.text('I love you so much sweetheart! ❤️'), findsOneWidget);
    expect(find.text('Kyoto_Trip_Plan.pdf'), findsOneWidget);
    expect(find.textContaining('0:18'), findsOneWidget);

    // Verify input and voice mic buttons exist
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline_rounded), findsOneWidget);
  });

  testWidgets('GamesScreen renders 1v1 and multiplayer tabs with chess & ludo buttons', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = AppState();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const GamesScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    // Verify Tabs
    expect(find.text('🎮 Intimate (1v1)'), findsOneWidget);
    expect(find.text('⚔️ 2v2 Multiplayer'), findsOneWidget);
    expect(find.text('🏆 Rank & Rewards'), findsOneWidget);

    // Verify Game Cards
    expect(find.text('♟️ Speed Chess Engine'), findsOneWidget);
    expect(find.text('🎲 Real Couple Ludo'), findsOneWidget);
    expect(find.text('🧩 Sliding Tile Image Puzzle'), findsOneWidget);

    // Tap Multiplayer Tab
    await tester.tap(find.text('⚔️ 2v2 Multiplayer'));
    await tester.pumpAndSettle();

    expect(find.text('Team: The Stargazers'), findsOneWidget);
    expect(find.text('Global 2v2 Season Leaderboard'), findsOneWidget);
  });
}
