import 'package:flutter/material.dart';

import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

enum CustomButtonVariant { primary, emergency, trust, info, danger, neutral }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final bool isOutlined;
  final IconData? icon;
  final IconData? trailingIcon;
  final CustomButtonVariant variant;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 54,
    this.isOutlined = false,
    this.icon,
    this.trailingIcon,
    this.variant = CustomButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _buttonColors(theme.colorScheme);
    final bgColor = backgroundColor ?? colors.background;
    final fgColor = textColor ?? (isOutlined ? bgColor : colors.foreground);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: fgColor,
                side: BorderSide(color: bgColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                elevation: 0,
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              ),
              child: _buildChild(context, fgColor),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: fgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                elevation: 0,
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              ),
              child: _buildChild(context, fgColor),
            ),
    );
  }

  _ButtonColors _buttonColors(ColorScheme scheme) {
    return switch (variant) {
      CustomButtonVariant.primary => _ButtonColors(
        scheme.primary,
        scheme.onPrimary,
      ),
      CustomButtonVariant.emergency ||
      CustomButtonVariant.danger => _ButtonColors(scheme.error, scheme.onError),
      CustomButtonVariant.trust => _ButtonColors(
        scheme.secondary,
        scheme.onSecondary,
      ),
      CustomButtonVariant.info => _ButtonColors(
        scheme.tertiary,
        scheme.onTertiary,
      ),
      CustomButtonVariant.neutral => _ButtonColors(
        scheme.surfaceContainerHighest,
        scheme.onSurface,
      ),
    };
  }

  Widget _buildChild(BuildContext context, Color fgColor) {
    final textStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: fgColor);

    if (isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
        Text(text, style: textStyle),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: 20),
        ],
      ],
    );
  }
}

class _ButtonColors {
  final Color background;
  final Color foreground;

  const _ButtonColors(this.background, this.foreground);
}
