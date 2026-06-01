import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

/// Modern toast notification helper with ARS branding
/// Replaces outdated SnackBar with modern top-positioned toasts
class ToastHelper {
  static FToast? _fToast;
  static BuildContext? _context;

  /// Initialize toast helper with context (optional - each method auto-initializes)
  static void init(BuildContext context) {
    _context = context;
    _fToast = FToast();
    _fToast!.init(context);
  }

  /// Success toast (ARS Green)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _initIfNeeded(context);
    _fToast?.showToast(
      child: _buildToast(
        context: context,
        message: message,
        icon: Icons.check_circle,
        color: ArsLightColors.success,
        backgroundColor: ArsLightColors.successBg,
      ),
      gravity: ToastGravity.TOP,
      toastDuration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Error toast (Red)
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _initIfNeeded(context);
    _fToast?.showToast(
      child: _buildToast(
        context: context,
        message: message,
        icon: Icons.error_outline,
        color: ArsLightColors.emergency,
        backgroundColor: ArsLightColors.emergencyBg,
      ),
      gravity: ToastGravity.TOP,
      toastDuration: duration ?? const Duration(seconds: 4),
    );
  }

  /// Info toast (Blue)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _initIfNeeded(context);
    _fToast?.showToast(
      child: _buildToast(
        context: context,
        message: message,
        icon: Icons.info_outline,
        color: ArsLightColors.info,
        backgroundColor: ArsLightColors.infoBg,
      ),
      gravity: ToastGravity.TOP,
      toastDuration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Warning toast (Orange)
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _initIfNeeded(context);
    _fToast?.showToast(
      child: _buildToast(
        context: context,
        message: message,
        icon: Icons.warning_amber_rounded,
        color: ArsLightColors.warning,
        backgroundColor: ArsLightColors.warningBg,
      ),
      gravity: ToastGravity.TOP,
      toastDuration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Loading toast (center, manual dismiss)
  static void showLoading(BuildContext context, String message) {
    _initIfNeeded(context);
    _fToast?.showToast(
      child: _buildLoadingToast(context, message),
      gravity: ToastGravity.CENTER,
      toastDuration: const Duration(seconds: 30),
    );
  }

  /// Dismiss all toasts
  static void dismiss() {
    _fToast?.removeCustomToast();
  }

  /// Initialize if needed (auto-init on first call)
  static void _initIfNeeded(BuildContext context) {
    if (_fToast == null || _context != context) {
      _context = context;
      _fToast = FToast();
      _fToast!.init(context);
    }
  }

  /// Build modern toast widget with ARS styling
  static Widget _buildToast({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 14,
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: color.withAlpha(64), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with colored background
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          // Message text
          Flexible(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading toast widget
  static Widget _buildLoadingToast(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(51), blurRadius: 24),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(ArsLightColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
