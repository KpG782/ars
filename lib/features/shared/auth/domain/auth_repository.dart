import 'app_user.dart';

/// Auth contract. Presentation depends on THIS, not on Firebase — so the Fake
/// (today) and a `FirebaseAuthRepository` (Phase 1) are interchangeable.
///
/// `deleteAccount` is part of the contract from day one: it's a P0 store
/// requirement (Apple 5.1.1(v) / Google Play) that ARS was missing on the
/// customer side — Talyer makes it impossible to forget.
abstract interface class AuthRepository {
  /// Emits the current user (or null when signed out) on every auth change.
  Stream<AppUser?> authChanges();

  AppUser? get currentUser;

  Future<AppUser> login({required String email, required String password});

  Future<AppUser> signup({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();

  /// Reauthenticates if needed, then deletes the account and cascades a
  /// server-side wipe of the user's data (bookings, chat, storage).
  Future<void> deleteAccount();
}
