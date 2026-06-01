import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

/// Reusable Custom Text Field Widget
///
/// Follows DRY principle by centralizing text field styling and behavior.
/// Follows Open/Closed Principle - open for extension, closed for modification.
///
/// Features:
/// - Consistent ARS branding
/// - Built-in validation support
/// - Password visibility toggle
/// - Customizable icons and hints
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool showPasswordToggle;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.showPasswordToggle = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final arsGreen = AppTheme.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: AppTheme.fontSize14,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey800,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText && !_isPasswordVisible,
          validator: widget.validator,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          textCapitalization: widget.textCapitalization,
          style: const TextStyle(fontSize: AppTheme.fontSize15),
          decoration: InputDecoration(
            hintText: widget.hint ?? widget.label,
            hintStyle: const TextStyle(color: AppTheme.grey400),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: arsGreen)
                : null,
            suffixIcon: widget.showPasswordToggle && widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppTheme.grey600,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                : widget.suffixIcon != null
                ? Icon(widget.suffixIcon, color: AppTheme.grey600)
                : null,
            filled: true,
            fillColor: widget.enabled ? AppTheme.grey50 : AppTheme.grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: arsGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.red, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.grey200),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable Primary Button Widget
///
/// Consistent branded button across all auth screens.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final arsGreen = color ?? AppTheme.primaryColor;

    return SizedBox(
      width: width ?? double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: arsGreen,
          disabledBackgroundColor: AppTheme.grey300,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSize16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Reusable Secondary Button Widget (Outlined)
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final arsGreen = color ?? AppTheme.primaryColor;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: arsGreen,
          side: BorderSide(color: arsGreen, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.fontSize16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable File Upload Card Widget
///
/// Consistent UI for document uploads across auth flow.
class FileUploadCard extends StatelessWidget {
  final String title;
  final String? fileName;
  final bool isRequired;
  final VoidCallback onTap;
  final IconData icon;

  const FileUploadCard({
    super.key,
    required this.title,
    this.fileName,
    this.isRequired = false,
    required this.onTap,
    this.icon = Icons.upload_file,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;
    final arsGreen = AppTheme.primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasFile ? arsGreen.withValues(alpha: 0.05) : AppTheme.grey50,
          border: Border.all(
            color: hasFile ? arsGreen : AppTheme.grey300,
            width: hasFile ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasFile ? arsGreen : AppTheme.grey300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                hasFile ? Icons.check_circle : icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSize15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.grey800,
                        ),
                      ),
                      if (isRequired) ...[
                        const SizedBox(width: 4),
                        const Text(
                          '*',
                          style: TextStyle(
                            color: AppTheme.red,
                            fontSize: AppTheme.fontSize15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasFile ? fileName! : 'Tap to upload',
                    style: TextStyle(
                      fontSize: AppTheme.fontSize13,
                      color: hasFile ? arsGreen : AppTheme.grey600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.grey400),
          ],
        ),
      ),
    );
  }
}

/// Loading Overlay Widget
///
/// Shows a full-screen loading indicator with message.
class LoadingOverlay extends StatelessWidget {
  final String message;

  const LoadingOverlay({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSize16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Error Message Widget
///
/// Displays error messages consistently.
class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorMessage({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.red50,
        border: Border.all(color: AppTheme.red300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.red900,
                fontSize: AppTheme.fontSize14,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

/// Info Card Widget
///
/// Displays informational messages.
class InfoCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? color;

  const InfoCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppTheme.primaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.1),
        border: Border.all(color: cardColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cardColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTheme.fontSize15,
                    fontWeight: FontWeight.w600,
                    color: cardColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSize14,
                    color: AppTheme.grey800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
