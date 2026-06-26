import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/design/design.dart';
import 'auth_controller.dart';
import 'auth_widgets.dart';

/// Log in. Minimal fields, visible labels, inline validation, a loading button,
/// and an announced (liveRegion) error with a recovery path.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  String? _emailErr;
  String? _passwordErr;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _email.text.trim();
    final pw = _password.text;
    setState(() {
      _emailErr = validateEmail(email);
      _passwordErr = pw.length < 6 ? 'At least 6 characters.' : null;
    });
    if (_emailErr != null || _passwordErr != null) return;
    ref.read(authControllerProvider.notifier).login(email, pw);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    ref.listen(authControllerProvider, (_, next) {
      if (next.hasValue && next.value != null) context.go(Routes.roleSelect);
    });
    final loading = state.isLoading;
    final errorMsg = state.hasError ? messageFor(state.error) : null;

    return Scaffold(
      appBar: AuthTopBar(onBack: () => context.go(Routes.landing)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: TalyerSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Maligayang balik!', style: context.tt.displaySmall),
              const SizedBox(height: TalyerSpacing.x2),
              Text('Log in to find a verified Talyer.',
                  style: TalyerType.bodyMedium.copyWith(color: context.talyer.text2)),
              const SizedBox(height: TalyerSpacing.x8),
              if (errorMsg != null) ...[
                AuthErrorBanner(message: errorMsg),
                const SizedBox(height: TalyerSpacing.x4),
              ],
              TalyerTextField(
                label: 'Email',
                hint: 'juan@email.com',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_outline_rounded,
                errorText: _emailErr,
              ),
              const SizedBox(height: TalyerSpacing.x4),
              TalyerTextField(
                label: 'Password',
                hint: '••••••••',
                controller: _password,
                obscureText: _obscure,
                prefixIcon: Icons.lock_outline_rounded,
                errorText: _passwordErr,
                suffix: PasswordToggle(
                  obscured: _obscure,
                  onToggle: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: TalyerSpacing.x6),
              TalyerButton(
                label: 'Log in',
                loading: loading,
                onPressed: loading ? null : _submit,
              ),
              const SizedBox(height: TalyerSpacing.x5),
              AuthSwitchLink(
                prompt: 'Wala pang account? ',
                action: 'Sign up',
                onTap: () => context.go(Routes.signup),
              ),
              const SizedBox(height: TalyerSpacing.x6),
            ],
          ),
        ),
      ),
    );
  }
}
