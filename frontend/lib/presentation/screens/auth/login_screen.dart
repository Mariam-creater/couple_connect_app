import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../home/home_screen.dart';
import '../couple/couple_connect_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController(text: 'saam');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillAccount(String login, String password) {
    setState(() {
      _loginController.text = login;
      _passwordController.text = password;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F0E17),
              const Color(0xFF1E1C2B),
              AppTheme.primaryRose.withOpacity(0.15),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 460),
                decoration: AppTheme.glassBox(context: context, radius: 28),
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Icon & Header
                    Center(
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryRose, AppTheme.accentGold],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryRose.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 36),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Couple Connect',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your intimate, encrypted world for two.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white60),
                    ),
                    const SizedBox(height: 20),

                    // Quick Demo Login Selector Chips
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: const [
                              Text('⚡ 1-Click Demo Accounts:', style: TextStyle(color: AppTheme.accentGold, fontSize: 12, fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Text('Pass: password123', style: TextStyle(color: Colors.white38, fontSize: 10)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildDemoChip('👦 Saam (Boyfriend)', 'saam', 'password123', AppTheme.primaryRose),
                              _buildDemoChip('👧 Boqran (Girlfriend)', 'boqran', 'password123', Colors.pinkAccent),
                              _buildDemoChip('👤 Alex', 'alex', 'password123', Colors.blueAccent),
                              _buildDemoChip('👩 Sophia', 'sophia', 'password123', Colors.purpleAccent),
                              _buildDemoChip('🛡️ Admin', 'admin', 'password123', Colors.amberAccent),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    if (appState.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          appState.errorMessage!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Input: Email / Username / Couple ID
                    TextField(
                      controller: _loginController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email, Username or Couple ID',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.primaryRose),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryRose)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Input: Password
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryRose),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryRose)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Forgot Password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: AppTheme.accentGold.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Login Action Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRose,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      onPressed: appState.isLoading
                          ? null
                          : () async {
                              final loginInput = _loginController.text.trim();
                              final passwordInput = _passwordController.text.trim();

                              if (loginInput.isEmpty || passwordInput.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Fadlan geli username/email iyo password-ka'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                return;
                              }

                              final success = await appState.login(loginInput, passwordInput);
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Ku soo dhawoow ${appState.currentUser?.name ?? "Partner"}! ❤️'),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                if (appState.isConnectedWithPartner) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                                  );
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const CoupleConnectScreen()),
                                  );
                                }
                              } else if (!success && mounted && appState.errorMessage != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(appState.errorMessage!),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                      child: appState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 18),

                    // Social Login Providers (Google & Apple)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.g_mobiledata_rounded, color: Colors.redAccent, size: 20),
                            ),
                            label: const Text('Google Sign-In', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.white.withOpacity(0.2)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              backgroundColor: Colors.white.withOpacity(0.04),
                            ),
                            onPressed: appState.isLoading
                                ? null
                                : () async {
                                    final ok = await appState.signInWithGoogle();
                                    if (ok && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Ku soo dhawoow ${appState.currentUser?.name ?? "Partner"}! (Google) ❤️'),
                                          backgroundColor: Colors.green,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                      if (appState.isConnectedWithPartner) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                                        );
                                      } else {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (_) => const CoupleConnectScreen()),
                                        );
                                      }
                                    } else if (!ok && mounted && appState.errorMessage != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(appState.errorMessage!),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),

                    const Divider(color: Colors.white12, height: 28),

                    // Register Link
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('Single & starting out? ', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: const Text(
                            'Create Account',
                            style: TextStyle(color: AppTheme.primaryRose, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoChip(String label, String username, String password, Color color) {
    return InkWell(
      onTap: () => _fillAccount(username, password),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
