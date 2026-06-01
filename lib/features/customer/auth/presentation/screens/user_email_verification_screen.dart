import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'dart:async';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../../../../core/routing/app_router.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/utils/toast_helper.dart';
import '../../../../../core/theme/app_theme.dart';

class UserEmailVerificationScreen extends StatefulWidget {
  const UserEmailVerificationScreen({super.key});

  @override
  State<UserEmailVerificationScreen> createState() =>
      _UserEmailVerificationScreenState();
}

class _UserEmailVerificationScreenState
    extends State<UserEmailVerificationScreen> {
  // Repository (Dependency Injection)
  late final AuthRepository _authRepository;
  Timer? _timer;
  bool _isEmailVerified = false;
  bool _isResending = false;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _authRepository = FirebaseAuthRepository();
    _isEmailVerified = _authRepository.currentUser?.isEmailVerified ?? false;

    if (!_isEmailVerified) {
      _sendEmailVerification();
      _startEmailVerificationTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendEmailVerification() async {
    try {
      await _authRepository.sendEmailVerification();

      if (mounted) {
        ToastHelper.showSuccess(
          context,
          'Verification email sent! Please check your inbox.',
        );
      }

      // Start cooldown
      setState(() {
        _resendCooldown = 60;
        _isResending = false;
      });

      // Cooldown timer
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_resendCooldown > 0) {
          if (mounted) setState(() => _resendCooldown--);
        } else {
          timer.cancel();
        }
      });
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Error sending verification email: $e');
      }
    }
  }

  void _startEmailVerificationTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _checkEmailVerification();
    });
  }

  Future<void> _checkEmailVerification() async {
    try {
      final isVerified = await _authRepository.checkEmailVerified();

      if (isVerified) {
        setState(() => _isEmailVerified = true);
        _timer?.cancel();

        final currentUser = _authRepository.currentUser;
        if (currentUser != null) {
          // Update email verification status in Firestore
          await _authRepository.updateEmailVerificationStatus(currentUser.uid);

          // Get updated user data
          final userData = await _authRepository.getUserData(currentUser.uid);

          if (userData != null) {
            // Save user type to shared preferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_type', userData.userType.name);

            // Navigate based on user type
            if (mounted) {
              if (userData.userType.name == 'mechanic') {
                context.go(AppRoutes.mechanicDashboard);
              } else {
                context.go(AppRoutes.customerBooking);
              }
            }
          }
        }
      }
    } catch (e) {
      // Silently handle errors during background check
    }
  }

  void _resendVerificationEmail() {
    if (_resendCooldown > 0) return;
    setState(() => _isResending = true);
    _sendEmailVerification();
  }

  void _manualCheckVerification() {
    _checkEmailVerification();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authRepository.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Verify Email',
          style: AppTheme.figtreeBold.copyWith(
            fontSize: AppTheme.fontSize18,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight -
                  48,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),

                  // Email icon
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: AppTheme.primarySurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.mail_check,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'Check Your Email',
                    style: AppTheme.figtreeExtraBold.copyWith(
                      fontSize: AppTheme.fontSize26,
                      color: AppTheme.onSurfaceColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'We sent a verification link to:',
                    style: AppTheme.figtreeRegular.copyWith(
                      fontSize: AppTheme.fontSize15,
                      color: AppTheme.subtitleColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    user?.email ?? '',
                    style: AppTheme.figtreeSemiBold.copyWith(
                      fontSize: AppTheme.fontSize15,
                      color: AppTheme.onSurfaceColor,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 28),

                  // Instructions card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primarySurface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.info,
                              color: AppTheme.primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Next Steps:',
                              style: AppTheme.figtreeSemiBold.copyWith(
                                fontSize: AppTheme.fontSize14,
                                color: AppTheme.onSurfaceColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '1. Check your email inbox\n2. Click the verification link\n3. You\'ll be automatically redirected',
                          style: AppTheme.figtreeRegular.copyWith(
                            fontSize: AppTheme.fontSize13,
                            color: AppTheme.subtitleColor,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Resend button
                  CustomButton(
                    text: _resendCooldown > 0
                        ? 'Resend in ${_resendCooldown}s'
                        : 'Resend Verification Email',
                    onPressed: _resendCooldown > 0
                        ? () {}
                        : _resendVerificationEmail,
                    isLoading: _isResending,
                    backgroundColor: _resendCooldown > 0
                        ? AppTheme.subtitleColor.withAlpha(100)
                        : AppTheme.primaryColor,
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: _manualCheckVerification,
                    child: Text(
                      'I\'ve verified my email',
                      style: AppTheme.figtreeSemiBold.copyWith(
                        fontSize: AppTheme.fontSize14,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Spam folder note
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.primaryLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.triangle_alert,
                          color: AppTheme.warningColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Can\'t find the email? Check your spam folder.',
                            style: AppTheme.figtreeRegular.copyWith(
                              fontSize: AppTheme.fontSize12,
                              color: AppTheme.warningTx,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
