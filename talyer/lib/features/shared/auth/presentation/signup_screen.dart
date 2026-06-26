import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/design/design.dart';
import 'auth_controller.dart';
import 'auth_widgets.dart';

/// Sign up. Three fields (the conversion sweet spot), visible labels, inline
/// validation, loading button, announced error + recovery.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  String? _nameErr;
  String? _emailErr;
  String? _passwordErr;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final pw = _password.text;
    setState(() {
      _nameErr = name.isEmpty ? 'Kailangan ang pangalan.' : null;
      _emailErr = validateEmail(email);
      _passwordErr = pw.length < 6 ? 'At least 6 characters.' : null;
    });
    if (_nameErr != null || _emailErr != null || _passwordErr != null) return;
    ref.read(authControllerProvider.notifier).signup(name, email, pw);
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
              Text('Gumawa ng account', style: context.tt.displaySmall),
              const SizedBox(height: TalyerSpacing.x2),
              Text('Mabilis lang — para makahanap ka agad ng Talyer.',
                  style: TalyerType.bodyMedium.copyWith(color: context.talyer.text2)),
              const SizedBox(height: TalyerSpacing.x8),
              if (errorMsg != null) ...[
                AuthErrorBanner(message: errorMsg),
                const SizedBox(height: TalyerSpacing.x4),
              ],
              TalyerTextField(
                label: 'Full name',
                hint: 'Juan Dela Cruz',
                controller: _name,
                prefixIcon: Icons.person_outline_rounded,
                errorText: _nameErr,
              ),
              const SizedBox(height: TalyerSpacing.x4),
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
                hint: 'At least 6 characters',
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
                label: 'Create account',
                loading: loading,
                onPressed: loading ? null : _submit,
              ),
              const SizedBox(height: TalyerSpacing.x5),
              AuthSwitchLink(
                prompt: 'May account ka na? ',
                action: 'Log in',
                onTap: () => context.go(Routes.login),
              ),
              const SizedBox(height: TalyerSpacing.x6),
            ],
          ),
        ),
      ),
    );
  }
}
