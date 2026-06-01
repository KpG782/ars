/// Domain Model: User
///
/// Represents a customer user in the business domain
library;

enum UserType { customer, mechanic }

enum AccountStatus { active, inactive, suspended }

/// Customer user entity
class User {
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final UserType userType;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final String? profileImageUrl;
  final String? address;
  final AccountStatus accountStatus;
  final DateTime? emailVerifiedAt;

  User({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.userType = UserType.customer,
    this.isEmailVerified = false,
    required this.createdAt,
    required this.lastLoginAt,
    this.profileImageUrl,
    this.address,
    this.accountStatus = AccountStatus.active,
    this.emailVerifiedAt,
  });

  // Business logic: Check if user can access services
  bool get canAccessServices =>
      isEmailVerified && accountStatus == AccountStatus.active;

  // Business logic: Check if profile is complete
  bool get isProfileComplete => fullName.isNotEmpty && phoneNumber.isNotEmpty;

  // Business logic: Check if user needs verification
  bool get needsVerification => !isEmailVerified;

  User copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    UserType? userType,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? profileImageUrl,
    String? address,
    AccountStatus? accountStatus,
    DateTime? emailVerifiedAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      accountStatus: accountStatus ?? this.accountStatus,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
    );
  }
}
