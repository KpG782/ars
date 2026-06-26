import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fake_auth_repository.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

/// Wire the contract to an implementation. Override this in `ProviderScope`
/// (or a test) to go Fake → Firebase without touching a screen.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FakeAuthRepository(),
);

/// Session state as `AsyncValue<AppUser?>`:
/// - `AsyncData(null)`  → signed out
/// - `AsyncLoading()`   → a login/signup is in flight (drives button spinners)
/// - `AsyncData(user)`  → signed in (screens navigate on this)
/// - `AsyncError`       → surfaced inline / announced to the user
class AuthController extends Notifier<AsyncValue<AppUser?>> {
  @override
  AsyncValue<AppUser?> build() => const AsyncData<AppUser?>(null);

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> login(String email, String password) async {
    state = const AsyncLoading<AppUser?>();
    state = await AsyncValue.guard<AppUser?>(
      () => _repo.login(email: email, password: password),
    );
  }

  Future<void> signup(String name, String email, String password) async {
    state = const AsyncLoading<AppUser?>();
    state = await AsyncValue.guard<AppUser?>(
      () => _repo.signup(name: name, email: email, password: password),
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncData<AppUser?>(null);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<AppUser?>>(AuthController.new);
