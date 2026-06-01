import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../../../../core/routing/app_router.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/utils/toast_helper.dart';
import '../../../../../core/theme/app_theme.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Repository (Dependency Injection)
  late final AuthRepository _authRepository;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authRepository = FirebaseAuthRepository();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        // Check if email is verified
        if (user.isEmailVerified) {
          // Save user type to shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_type', user.userType.name);

          // Navigate based on user type
          if (user.userType.name == 'mechanic') {
            if (!mounted) return;
            context.go(AppRoutes.mechanicDashboard);
          } else {
            if (!mounted) return;
            context.go(AppRoutes.customerBooking);
          }
        } else {
          if (!mounted) return;
          context.go(AppRoutes.verifyEmail);
        }
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Login failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _skipLogin() {
    context.go(AppRoutes.customerBooking);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero section with brand color background
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(
                        LucideIcons.chevron_left,
                        color: Colors.white,
                      ),
                      onPressed: () => context.go(AppRoutes.userType),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 24),

                    // Headline
                    Text(
                      'Get Back on\nthe Road',
                      style: AppTheme.figtreeExtraBold.copyWith(
                        fontSize: AppTheme.fontSize32,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your email to request\na repair instantly.',
                      style: AppTheme.figtreeRegular.copyWith(
                        fontSize: AppTheme.fontSize15,
                        color: Colors.white.withAlpha(200),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Form section
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),

                      CustomTextField(
                        hintText: 'your.email@example.com',
                        labelText: 'Email Address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          LucideIcons.mail,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      CustomTextField(
                        hintText: 'Your password',
                        labelText: 'Password',
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: const Icon(
                          LucideIcons.lock,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Continue button
                      CustomButton(
                        text: 'Continue',
                        onPressed: _login,
                        isLoading: _isLoading,
                        trailingIcon: LucideIcons.arrow_right,
                      ),

                      const SizedBox(height: 16),

                      // Divider with "or"
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: AppTheme.borderColor),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or',
                              style: AppTheme.figtreeRegular.copyWith(
                                fontSize: AppTheme.fontSize13,
                                color: AppTheme.subtitleColor,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: AppTheme.borderColor),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Skip Login button
                      CustomButton(
                        text: 'Skip for now',
                        onPressed: _skipLogin,
                        isOutlined: true,
                        trailingIcon: LucideIcons.arrow_right,
                      ),

                      const SizedBox(height: 32),

                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTheme.figtreeRegular.copyWith(
                              fontSize: AppTheme.fontSize14,
                              color: AppTheme.subtitleColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.signup),
                            child: Text(
                              'Sign up',
                              style: AppTheme.figtreeSemiBold.copyWith(
                                fontSize: AppTheme.fontSize14,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
