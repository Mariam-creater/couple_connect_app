import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthResult {
  final bool success;
  final String? googleId;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? idToken;
  final String? errorMessage;

  GoogleAuthResult({
    required this.success,
    this.googleId,
    this.email,
    this.displayName,
    this.photoUrl,
    this.idToken,
    this.errorMessage,
  });
}

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<GoogleAuthResult> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        return GoogleAuthResult(
          success: false,
          errorMessage: 'Google sign in was cancelled.',
        );
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      return GoogleAuthResult(
        success: true,
        googleId: account.id,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
        idToken: auth.idToken,
      );
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      return GoogleAuthResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google Sign Out Error: $e');
    }
  }
}
