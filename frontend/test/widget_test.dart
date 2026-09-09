import 'package:flutter_test/flutter_test.dart';
import 'package:couple_connect_frontend/main.dart';
import 'package:provider/provider.dart';
import 'package:couple_connect_frontend/presentation/providers/app_state.dart';

void main() {
  testWidgets('Couple Connect smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: const CoupleConnectApp(),
      ),
    );

    expect(find.text('Couple Connect'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
