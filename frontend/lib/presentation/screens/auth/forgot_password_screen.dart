import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isResetMode = false;
  bool _obscurePassword = true;
  String? _feedbackMessage;
  bool _isSuccess = false;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
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
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                decoration: AppTheme.glassBox(context: context, radius: 28),
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
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
                        child: const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 34),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isResetMode ? 'Reset Password' : 'Forgot Password',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isResetMode
                          ? 'Enter the security token and your new password.'
                          : 'Enter your verified email to receive a password reset link.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 28),

                    if (_feedbackMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isSuccess ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _isSuccess ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          _feedbackMessage!,
                          style: TextStyle(color: _isSuccess ? Colors.greenAccent : Colors.redAccent, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Email Input
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryRose),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_isResetMode) ...[
                      // Token Input
                      TextField(
                        controller: _tokenController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Reset Token / Code',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                          prefixIcon: const Icon(Icons.vpn_key_outlined, color: AppTheme.accentGold),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // New Password Input
                      TextField(
                        controller: _newPasswordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryRose),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white54),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Input
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryRose),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Action Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRose,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: appState.isLoading
                          ? null
                          : () async {
                              final email = _emailController.text.trim();
                              if (email.isEmpty) {
                                setState(() {
                                  _feedbackMessage = 'Please enter your email.';
                                  _isSuccess = false;
                                });
                                return;
                              }

                              if (!_isResetMode) {
                                final sent = await appState.forgotPassword(email);
                                setState(() {
                                  if (sent) {
                                    _feedbackMessage = 'Reset token sent to your email. Enter token below.';
                                    _isSuccess = true;
                                    _isResetMode = true;
                                  } else {
                                    _feedbackMessage = appState.errorMessage ?? 'Unable to send reset token.';
                                    _isSuccess = false;
                                  }
                                });
                              } else {
                                final token = _tokenController.text.trim();
                                final password = _newPasswordController.text;
                                final confirm = _confirmPasswordController.text;

                                if (password != confirm) {
                                  setState(() {
                                    _feedbackMessage = 'Passwords do not match.';
                                    _isSuccess = false;
                                  });
                                  return;
                                }

                                final reset = await appState.resetPassword(
                                  email: email,
                                  token: token,
                                  password: password,
                                );

                                setState(() {
                                  if (reset) {
                                    _feedbackMessage = 'Password reset successfully! You can now log in.';
                                    _isSuccess = true;
                                  } else {
                                    _feedbackMessage = appState.errorMessage ?? 'Invalid or expired token.';
                                    _isSuccess = false;
                                  }
                                });

                                if (reset && mounted) {
                                  Future.delayed(const Duration(seconds: 2), () {
                                    if (mounted) Navigator.pop(context);
                                  });
                                }
                              }
                            },
                      child: appState.isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(
                              _isResetMode ? 'Update Password' : 'Send Reset Link',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 16),

                    if (!_isResetMode)
                      TextButton(
                        onPressed: () => setState(() => _isResetMode = true),
                        child: const Text('Already have a reset token?', style: TextStyle(color: AppTheme.accentGold, fontSize: 13)),
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
}
