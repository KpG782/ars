/// Authenticated user (domain entity — pure Dart). The data layer maps a
/// Firebase user into this; the UI only ever sees this type.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.emailVerified = false,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final bool emailVerified;
}

/// Domain-level auth error carrying a user-facing message (already localised).
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
