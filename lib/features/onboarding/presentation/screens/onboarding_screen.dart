import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arsapplication/core/routing/app_router.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> onboardingData = [
    {
      "title": "Book Repairs Instantly",
      "subtitle":
          "Get your car fixed by trusted mechanics\nin your area with just a few taps.",
      "icon": LucideIcons.calendar_check,
    },
    {
      "title": "Find Local Experts",
      "subtitle":
          "Discover skilled mechanics nearby\nand get back on the road quickly.",
      "icon": LucideIcons.map_pin,
    },
    {
      "title": "Track Everything",
      "subtitle":
          "Real-time updates, transparent pricing,\nand expert service at your fingertips.",
      "icon": LucideIcons.clock,
    },
  ];

  void _nextPage() async {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
      final userType = prefs.getString('user_type') ?? 'user';

      if (mounted) {
        if (userType == 'mechanic') {
          context.go(AppRoutes.mechanicSplash);
        } else {
          context.go(AppRoutes.signup);
        }
      }
    }
  }

  void _skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    final userType = prefs.getString('user_type') ?? 'user';

    if (mounted) {
      if (userType == 'mechanic') {
        context.go(AppRoutes.mechanicSplash);
      } else {
        context.go(AppRoutes.signup);
      }
    }
  }

  void _goBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          _goBack();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Top bar: back + skip
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.chevron_left, size: 22),
                      color: AppTheme.onSurfaceColor,
                      onPressed: _goBack,
                    ),
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Skip',
                        style: AppTheme.figtreeMedium.copyWith(
                          fontSize: AppTheme.fontSize14,
                          color: AppTheme.subtitleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (value) =>
                      setState(() => _currentPage = value),
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon with circle background
                          Container(
                            width: 160,
                            height: 160,
                            decoration: const BoxDecoration(
                              color: AppTheme.primarySurface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              onboardingData[index]["icon"],
                              size: 72,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Title
                          Text(
                            onboardingData[index]["title"]!,
                            style: AppTheme.figtreeExtraBold.copyWith(
                              fontSize: AppTheme.fontSize28,
                              color: AppTheme.onSurfaceColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          // Subtitle
                          Text(
                            onboardingData[index]["subtitle"]!,
                            style: AppTheme.figtreeRegular.copyWith(
                              fontSize: AppTheme.fontSize15,
                              color: AppTheme.subtitleColor,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppTheme.primaryColor
                          : AppTheme.borderColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Next / Get Started button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == onboardingData.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: AppTheme.buttonMedium,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage == onboardingData.length - 1
                              ? LucideIcons.check
                              : LucideIcons.arrow_right,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
