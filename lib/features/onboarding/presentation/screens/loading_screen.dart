import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

class LoadingScreen extends StatefulWidget {
  final String? message;
  final bool showLogo;
  final Color? backgroundColor;
  final Color? primaryColor;

  const LoadingScreen({
    super.key,
    this.message,
    this.showLogo = true,
    this.backgroundColor,
    this.primaryColor,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _rotationController.repeat();
    _fadeController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.primaryColor ?? AppTheme.primaryColor;
    final bgColor = widget.backgroundColor ?? Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.showLogo) ...[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.build_circle, size: 44, color: color),
              ),
              const SizedBox(height: 32),
            ],

            // Loading spinner
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 3, color: color),
            ),

            const SizedBox(height: 24),

            // Message
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Text(
                    widget.message ?? 'Loading...',
                    style: GoogleFonts.figtree(
                      fontSize: AppTheme.fontSize15,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.subtitleColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Utility class for different loading states
class AppLoadingStates {
  static Widget userProfile({String? message}) {
    return LoadingScreen(
      message: message ?? 'Loading profile...',
      showLogo: false,
    );
  }

  static Widget booking({String? message}) {
    return LoadingScreen(message: message ?? 'Loading map...', showLogo: false);
  }

  static Widget vehicles({String? message}) {
    return LoadingScreen(
      message: message ?? 'Loading vehicles...',
      showLogo: false,
    );
  }

  static Widget authentication({String? message}) {
    return LoadingScreen(
      message: message ?? 'Authenticating...',
      showLogo: true,
    );
  }

  static Widget general({String? message}) {
    return LoadingScreen(message: message ?? 'Please wait...', showLogo: false);
  }
}

// Loading overlay widget for use within existing pages
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingMessage;
  final Color? overlayColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingMessage,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: (overlayColor ?? Colors.black).withAlpha(77),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                        strokeWidth: 3,
                      ),
                    ),
                    if (loadingMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        loadingMessage!,
                        style: GoogleFonts.figtree(
                          fontSize: AppTheme.fontSize14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.onSurfaceColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
