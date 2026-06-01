/// Domain Layer: User Profile Entity
///
/// Represents a customer's profile information with business logic
library;

class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    required this.emailVerified,
    this.createdAt,
    this.lastLoginAt,
  });

  // Business logic: Check if profile is complete
  bool get isProfileComplete {
    return displayName != null &&
        displayName!.isNotEmpty &&
        phoneNumber != null &&
        phoneNumber!.isNotEmpty;
  }

  // Business logic: Check if profile needs attention
  bool get needsProfileUpdate {
    return !isProfileComplete || !emailVerified;
  }

  // Business logic: Get display name or fallback
  String get displayNameOrEmail {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    return email.split('@')[0]; // Use email prefix as fallback
  }

  // Business logic: Get initials for avatar
  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName!.substring(0, 1).toUpperCase();
    }
    return email.substring(0, 1).toUpperCase();
  }

  // Business logic: Format phone number
  String get formattedPhoneNumber {
    if (phoneNumber == null || phoneNumber!.isEmpty) {
      return 'Not provided';
    }
    // Simple Philippine format
    if (phoneNumber!.startsWith('+63')) {
      return phoneNumber!;
    }
    return phoneNumber!;
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  String toString() {
    return 'UserProfile(uid: $uid, email: $email, displayName: $displayName, emailVerified: $emailVerified)';
  }
}
