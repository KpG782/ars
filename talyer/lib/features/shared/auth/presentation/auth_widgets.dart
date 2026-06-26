import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';
import '../domain/app_user.dart';

/// Shared bits for the auth screens — keeps login & signup consistent.

/// Email format check. Returns a user-facing message or null when valid.
String? validateEmail(String value) {
  if (value.isEmpty) return 'Kailangan ang email.';
  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  return ok ? null : 'Mukhang mali ang email.';
}

/// Maps an auth error to a user-facing message (domain errors carry their own).
String messageFor(Object? error) =>
    error is AuthException ? error.message : 'May problema. Subukan ulit.';

class AuthTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AuthTopBar({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: onBack,
          tooltip: 'Back',
        ),
      );
}

/// Announced error banner (role=alert equivalent via [Semantics.liveRegion]).
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(TalyerSpacing.x3),
        decoration: BoxDecoration(
          color: t.emergencyBg,
          borderRadius: TalyerRadii.all(TalyerRadii.sm),
          border: Border.all(color: t.emergency.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, size: 18, color: t.emergencyTx),
            const SizedBox(width: TalyerSpacing.x2),
            Expanded(
              child: Text(message,
                  style: TalyerType.bodyMedium.copyWith(color: t.emergencyTx)),
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordToggle extends StatelessWidget {
  const PasswordToggle({super.key, required this.obscured, required this.onToggle});
  final bool obscured;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
        color: context.talyer.text3,
      ),
      onPressed: onToggle,
      tooltip: obscured ? 'Show password' : 'Hide password',
    );
  }
}

class AuthSwitchLink extends StatelessWidget {
  const AuthSwitchLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });
  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prompt, style: TalyerType.bodyMedium.copyWith(color: t.text2)),
        GestureDetector(
          onTap: onTap,
          child: Text(action,
              style: TalyerType.label.copyWith(color: t.primary)),
        ),
      ],
    );
  }
}
