import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:arsapplication/core/routing/app_router.dart';
import 'package:arsapplication/features/mechanic/auth/presentation/screens/mechanic_mobile_number_screen.dart';
import 'package:arsapplication/features/mechanic/auth/presentation/screens/mechanic_professional_details_screen.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:arsapplication/core/widgets/custom_button.dart';
import 'package:arsapplication/core/widgets/custom_text_field.dart';
import 'package:arsapplication/core/utils/toast_helper.dart';

class MechanicAuthScreen extends StatefulWidget {
  const MechanicAuthScreen({super.key});

  @override
  State<MechanicAuthScreen> createState() => _MechanicAuthScreenState();
}

class _MechanicAuthScreenState extends State<MechanicAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      User? user;

      if (_isSignUp) {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
        user = credential.user;

        await user?.updateDisplayName(
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        );

        await user?.sendEmailVerification();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MechanicProfessionalDetailsScreen(
                phoneNumber: '+63${_phoneController.text.trim()}',
                firstName: _firstNameController.text.trim(),
                lastName: _lastNameController.text.trim(),
                username: _usernameController.text.trim(),
                email: _emailController.text.trim(),
              ),
            ),
          );
        }
      } else {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
        user = credential.user;

        if (user != null && mounted) {
          await _checkMechanicStatus(user);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ToastHelper.showError(context, _getErrorMessage(e.code));
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'An error occurred: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkMechanicStatus(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('mechanics')
          .doc(user.uid)
          .get();

      if (mounted) {
        if (doc.exists) {
          final data = doc.data()!;
          final verificationStatus =
              data['verification']?['status'] ?? 'pending';

          switch (verificationStatus) {
            case 'approved':
              context.go(AppRoutes.mechanicDashboard);
              break;
            case 'pending':
            case 'rejected':
              context.go(AppRoutes.mechanicVerification);
              break;
            default:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MechanicMobileNumberScreen(),
                ),
              );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MechanicMobileNumberScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Error checking account status: $e');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MechanicMobileNumberScreen(),
          ),
        );
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many failed attempts. Try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  void _skipLogin() {
    context.go(AppRoutes.mechanicDashboard);
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
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isSignUp
                          ? 'Join ARS as a\nMechanic'
                          : 'Welcome Back,\nMechanic!',
                      style: AppTheme.figtreeExtraBold.copyWith(
                        fontSize: AppTheme.fontSize28,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUp
                          ? 'Create your account to start\naccepting service requests.'
                          : 'Sign in to manage your\nservices and bookings.',
                      style: AppTheme.figtreeRegular.copyWith(
                        fontSize: AppTheme.fontSize14,
                        color: Colors.white.withAlpha(200),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),

                      if (_isSignUp) ...[
                        CustomTextField(
                          hintText: 'Juan',
                          labelText: 'First Name',
                          controller: _firstNameController,
                          prefixIcon: const Icon(
                            LucideIcons.user,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'First name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        CustomTextField(
                          hintText: 'Dela Cruz',
                          labelText: 'Last Name',
                          controller: _lastNameController,
                          prefixIcon: const Icon(
                            LucideIcons.user,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Last name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        CustomTextField(
                          hintText: 'mechanic_juan',
                          labelText: 'Username',
                          controller: _usernameController,
                          prefixIcon: const Icon(
                            LucideIcons.at_sign,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Username is required';
                            }
                            if (value.length < 3) {
                              return 'Username must be at least 3 characters';
                            }
                            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                              return 'Only letters, numbers, and underscores';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        CustomTextField(
                          hintText: '9XX XXX XXXX',
                          labelText: 'Phone Number',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(
                            LucideIcons.phone,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Phone number is required';
                            }
                            if (value.length != 10) {
                              return 'Enter a valid 10-digit phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Email
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
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Password
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
                            return 'Password is required';
                          }
                          if (_isSignUp && value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Confirm Password (sign up only)
                      if (_isSignUp) ...[
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
                        const SizedBox(height: 14),
                      ],

                      const SizedBox(height: 12),

                      // Auth button
                      CustomButton(
                        text: _isSignUp
                            ? 'Create Account & Continue'
                            : 'Sign In',
                        onPressed: _handleAuth,
                        isLoading: _isLoading,
                        trailingIcon: LucideIcons.arrow_right,
                      ),

                      const SizedBox(height: 12),

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

                      const SizedBox(height: 12),

                      // Skip Login
                      CustomButton(
                        text: 'Skip for now',
                        onPressed: _skipLogin,
                        isOutlined: true,
                        trailingIcon: LucideIcons.arrow_right,
                      ),

                      const SizedBox(height: 24),

                      // Toggle sign in / sign up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isSignUp
                                ? 'Already have an account? '
                                : 'Don\'t have an account? ',
                            style: AppTheme.figtreeRegular.copyWith(
                              fontSize: AppTheme.fontSize14,
                              color: AppTheme.subtitleColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSignUp = !_isSignUp;
                                _firstNameController.clear();
                                _lastNameController.clear();
                                _usernameController.clear();
                                _emailController.clear();
                                _phoneController.clear();
                                _passwordController.clear();
                                _confirmPasswordController.clear();
                              });
                            },
                            child: Text(
                              _isSignUp ? 'Sign In' : 'Sign Up',
                              style: AppTheme.figtreeSemiBold.copyWith(
                                fontSize: AppTheme.fontSize14,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (!_isSignUp) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              ToastHelper.showInfo(
                                context,
                                'Forgot password feature coming soon!',
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: AppTheme.figtreeMedium.copyWith(
                                fontSize: AppTheme.fontSize14,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
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
