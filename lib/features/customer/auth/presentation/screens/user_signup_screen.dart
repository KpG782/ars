import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../../../../core/routing/app_router.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/utils/toast_helper.dart';
import '../../../../../core/theme/app_theme.dart';

class UserSignUpScreen extends StatefulWidget {
  const UserSignUpScreen({super.key});

  @override
  State<UserSignUpScreen> createState() => _UserSignUpScreenState();
}

class _UserSignUpScreenState extends State<UserSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authRepository.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      if (mounted) {
        context.go(AppRoutes.verifyEmail);
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Sign up failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              // Hero section
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
                    IconButton(
                      icon: const Icon(
                        LucideIcons.chevron_left,
                        color: Colors.white,
                      ),
                      onPressed: () => context.pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Create Your\nAccount',
                      style: AppTheme.figtreeExtraBold.copyWith(
                        fontSize: AppTheme.fontSize32,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join us to get started with\nrepair services.',
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
                        hintText: 'John Doe',
                        labelText: 'Full Name',
                        controller: _fullNameController,
                        keyboardType: TextInputType.name,
                        prefixIcon: const Icon(
                          LucideIcons.user,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          if (value.length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

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
                      const SizedBox(height: 16),

                      CustomTextField(
                        hintText: '+63 9XX XXX XXXX',
                        labelText: 'Phone Number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(
                          LucideIcons.phone,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.length < 10) {
                            return 'Phone number must be at least 10 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        hintText: 'Create a password',
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
                      const SizedBox(height: 16),

                      CustomTextField(
                        hintText: 'Confirm your password',
                        labelText: 'Confirm Password',
                        controller: _confirmPasswordController,
                        obscureText: true,
                        prefixIcon: const Icon(
                          LucideIcons.lock,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      CustomButton(
                        text: 'Create Account',
                        onPressed: _signUp,
                        isLoading: _isLoading,
                        trailingIcon: LucideIcons.arrow_right,
                      ),

                      const SizedBox(height: 24),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTheme.figtreeRegular.copyWith(
                              fontSize: AppTheme.fontSize14,
                              color: AppTheme.subtitleColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go(AppRoutes.login),
                            child: Text(
                              'Log in',
                              style: AppTheme.figtreeSemiBold.copyWith(
                                fontSize: AppTheme.fontSize14,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
