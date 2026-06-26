import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talyer/core/design/design.dart';
import 'package:talyer/features/shared/auth/data/fake_auth_repository.dart';
import 'package:talyer/features/shared/auth/domain/app_user.dart';
import 'package:talyer/features/shared/auth/presentation/auth_controller.dart';
import 'package:talyer/features/shared/auth/presentation/landing_screen.dart';

void main() {
  group('FakeAuthRepository', () {
    test('signup returns a user with the given name', () async {
      final user = await FakeAuthRepository()
          .signup(name: 'Juan', email: 'juan@email.com', password: 'secret1');
      expect(user.name, 'Juan');
      expect(user.email, 'juan@email.com');
    });

    test('login throws on the known-bad email', () {
      expect(
        () => FakeAuthRepository().login(email: 'wrong@talyer.ph', password: 'secret1'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('AuthController', () {
    test('login moves session from null → signed-in', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(authControllerProvider).value, isNull);

      await container
          .read(authControllerProvider.notifier)
          .login('a@b.com', 'secret1');

      expect(container.read(authControllerProvider).value, isNotNull);
      expect(container.read(authControllerProvider).value!.email, 'a@b.com');
    });

    test('login surfaces an error for bad credentials', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(authControllerProvider.notifier)
          .login('wrong@talyer.ph', 'secret1');

      expect(container.read(authControllerProvider).hasError, isTrue);
    });
  });

  testWidgets('LandingScreen shows both CTAs', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LandingScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}
