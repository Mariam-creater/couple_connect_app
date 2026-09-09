import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:couple_connect_frontend/presentation/providers/app_state.dart';
import 'package:couple_connect_frontend/presentation/screens/auth/login_screen.dart';
import 'package:couple_connect_frontend/presentation/screens/auth/register_screen.dart';
import 'package:couple_connect_frontend/presentation/widgets/set_credentials_modal.dart';
import 'package:couple_connect_frontend/data/models/models.dart';

void main() {
  group('Unified Auth Frontend Tests', () {
    testWidgets('LoginScreen renders fields, Google button, and demo account chips', (tester) async {
      final appState = AppState();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppState>.value(
            value: appState,
            child: const LoginScreen(),
          ),
        ),
      );

      // Verify Header & Title
      expect(find.text('Couple Connect'), findsOneWidget);
      expect(find.text('Your intimate, encrypted world for two.'), findsOneWidget);

      // Verify input fields
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Sign In'), findsOneWidget);

      // Verify Google Sign-In button
      expect(find.text('Google Sign-In'), findsOneWidget);

      // Verify Demo Chips
      expect(find.text('👦 Saam (Boyfriend)'), findsOneWidget);
      expect(find.text('👧 Boqran (Girlfriend)'), findsOneWidget);
    });

    testWidgets('RegisterScreen renders full name, username, email, passwords, and Google button', (tester) async {
      final appState = AppState();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppState>.value(
            value: appState,
            child: const RegisterScreen(),
          ),
        ),
      );

      expect(find.text('Create Account'), findsWidgets);
      expect(find.text('Sign up with Google'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Unique Username'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password (min 8 characters)'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('SetCredentialsModal displays username and password inputs', (tester) async {
      final appState = AppState();
      appState.currentUser = UserModel(
        id: 99,
        name: 'Google User',
        username: 'google_user_99',
        email: 'guser@example.com',
        coupleId: 'CP-TEST-99',
        relationshipStatus: 'single',
        hasPassword: false,
        isGoogleLinked: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppState>.value(
            value: appState,
            child: const Scaffold(
              body: SetCredentialsModal(),
            ),
          ),
        ),
      );

      expect(find.text('Set Username & Password'), findsOneWidget);
      expect(find.text('Enable direct login with credentials anytime.'), findsOneWidget);
      expect(find.text('Save Credentials'), findsOneWidget);
    });
  });
}
