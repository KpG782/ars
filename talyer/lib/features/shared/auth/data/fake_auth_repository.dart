import 'dart:async';

import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

/// In-memory auth so the flow runs end-to-end with no backend. Phase 1 swaps
/// this for `FirebaseAuthRepository` behind the same interface — screens don't
/// change. Use `wrong@talyer.ph` to exercise the error path.
class FakeAuthRepository implements AuthRepository {
  AppUser? _current;
  final _controller = StreamController<AppUser?>.broadcast();

  @override
  Stream<AppUser?> authChanges() => _controller.stream;

  @override
  AppUser? get currentUser => _current;

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (email.toLowerCase() == 'wrong@talyer.ph') {
      throw const AuthException('Mali ang email o password. Subukan ulit.');
    }
    final user = AppUser(
      id: 'u_${email.hashCode}',
      name: email.split('@').first,
      email: email,
      emailVerified: true,
    );
    _emit(user);
    return user;
  }

  @override
  Future<AppUser> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (email.toLowerCase() == 'taken@talyer.ph') {
      throw const AuthException('Naka-rehistro na ang email na ito.');
    }
    final user = AppUser(id: 'u_${email.hashCode}', name: name, email: email);
    _emit(user);
    return user;
  }

  @override
  Future<void> logout() async => _emit(null);

  @override
  Future<void> deleteAccount() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _emit(null);
  }

  void _emit(AppUser? user) {
    _current = user;
    _controller.add(user);
  }
}
