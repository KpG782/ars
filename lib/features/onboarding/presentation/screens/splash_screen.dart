import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:arsapplication/core/routing/app_router.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthenticationState();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  Future<void> _checkAuthenticationState() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      final userType = prefs.getString('user_type') ?? 'user';
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // User is signed in, check email verification
        try {
          await currentUser.reload(); // Refresh user data
        } catch (_) {
          // Offline — proceed with cached Firebase auth state
        }
        if (!mounted) return;

        final updatedUser = FirebaseAuth.instance.currentUser;

        if (updatedUser?.emailVerified == true) {
          if (userType == 'mechanic') {
            context.go(AppRoutes.mechanicDashboard);
          } else {
            context.go(AppRoutes.customerBooking);
          }
        } else {
          context.go(AppRoutes.verifyEmail);
        }
      } else {
        context.go(AppRoutes.userType);
      }
    } catch (e) {
      if (mounted) {
        context.go(AppRoutes.userType);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ARS Logo
                    SvgPicture.asset(
                      'assets/ars_logo.svg',
                      width: 120,
                      height: 120,
                      colorFilter: const ColorFilter.mode(
                        AppTheme.primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App Name
                    Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Column(
                        children: [
                          Text(
                            'ARS',
                            style: AppTheme.figtreeBlack.copyWith(
                              fontSize: AppTheme.fontSize56,
                              color: AppTheme.primaryColor,
                              letterSpacing: -1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rescuing your ride.',
                            style: AppTheme.figtreeRegular.copyWith(
                              fontSize: AppTheme.fontSize16,
                              color: AppTheme.subtitleColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Loading indicator
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppTheme.primaryColor.withAlpha(120),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
