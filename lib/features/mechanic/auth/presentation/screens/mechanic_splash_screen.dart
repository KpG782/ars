import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:arsapplication/core/routing/app_router.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:arsapplication/core/widgets/custom_button.dart';

class MechanicSplashScreen extends StatefulWidget {
  const MechanicSplashScreen({super.key});

  @override
  State<MechanicSplashScreen> createState() => _MechanicSplashScreenState();
}

class _MechanicSplashScreenState extends State<MechanicSplashScreen> {
  bool _showGetStarted = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    final currentUser = FirebaseAuth.instance.currentUser;
    if (!mounted) return;

    if (currentUser != null) {
      await _checkExistingUserStatus(currentUser);
    } else {
      setState(() {
        _showGetStarted = true;
      });
    }
  }

  Future<void> _checkExistingUserStatus(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('mechanics')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data()!;
        final verificationStatus = data['verification']['status'] ?? 'pending';

        switch (verificationStatus) {
          case 'approved':
            context.go(AppRoutes.mechanicDashboard);
            break;
          case 'pending':
          case 'rejected':
            context.go(AppRoutes.mechanicVerification);
            break;
          default:
            setState(() {
              _showGetStarted = true;
            });
        }
      } else {
        setState(() {
          _showGetStarted = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _showGetStarted = true;
      });
    }
  }

  void _navigateToAuth() {
    context.go(AppRoutes.mechanicAuth);
  }

  void _navigateToUserTypeSelection() {
    context.go(AppRoutes.userType);
  }

  void _skipLogin() {
    context.go(AppRoutes.mechanicDashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(LucideIcons.chevron_left),
                            color: AppTheme.onSurfaceColor,
                            onPressed: _navigateToUserTypeSelection,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ARS Mechanic',
                          style: AppTheme.figtreeExtraBold.copyWith(
                            fontSize: AppTheme.fontSize28,
                            color: AppTheme.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Professional Auto Repair Services',
                          style: AppTheme.figtreeMedium.copyWith(
                            fontSize: AppTheme.fontSize14,
                            color: AppTheme.subtitleColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Join our network of trusted mechanics and grow your business with ARS.',
                            style: AppTheme.figtreeRegular.copyWith(
                              fontSize: AppTheme.fontSize13,
                              color: AppTheme.subtitleColor,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: Image.asset(
                            'assets/onboarding_one.png',
                            width: MediaQuery.of(context).size.width * 0.55,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!_showGetStarted)
                          Column(
                            children: [
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppTheme.primaryColor.withAlpha(120),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Checking account status...',
                                style: AppTheme.figtreeRegular.copyWith(
                                  color: AppTheme.subtitleColor,
                                  fontSize: AppTheme.fontSize13,
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomButton(
                                text: 'Get Started',
                                onPressed: _navigateToAuth,
                                trailingIcon: LucideIcons.arrow_right,
                              ),
                              const SizedBox(height: 12),
                              CustomButton(
                                text: 'Skip for now',
                                onPressed: _skipLogin,
                                isOutlined: true,
                                trailingIcon: LucideIcons.arrow_right,
                              ),
                              const SizedBox(height: 20),
                              const _FeatureItem(
                                icon: LucideIcons.badge_check,
                                text: 'Get verified as a professional mechanic',
                              ),
                              const SizedBox(height: 8),
                              const _FeatureItem(
                                icon: LucideIcons.map_pin,
                                text: 'Receive nearby service requests',
                              ),
                              const SizedBox(height: 8),
                              const _FeatureItem(
                                icon: LucideIcons.wallet,
                                text: 'Secure payments and earnings tracking',
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTheme.figtreeRegular.copyWith(
              color: AppTheme.subtitleColor,
              fontSize: AppTheme.fontSize13,
            ),
          ),
        ),
      ],
    );
  }
}
