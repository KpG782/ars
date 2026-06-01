// Domain Models for Mechanic User
//
// Following Domain-Driven Design principles with value objects and entities

import 'package:cloud_firestore/cloud_firestore.dart';

/// Mechanic User Aggregate Root
///
/// Main entity representing a mechanic in the system.
/// Contains all mechanic-related information.
class MechanicUser {
  final String uid;
  final BasicInfo basicInfo;
  final ProfessionalInfo professionalInfo;
  final DocumentUrls documentUrls;
  final VerificationStatus verificationStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MechanicUser({
    required this.uid,
    required this.basicInfo,
    required this.professionalInfo,
    required this.documentUrls,
    required this.verificationStatus,
    required this.createdAt,
    this.updatedAt,
  });

  // Factory constructor from Firestore data
  factory MechanicUser.fromMap(Map<String, dynamic> map) {
    return MechanicUser(
      uid: map['uid'] as String,
      basicInfo: BasicInfo.fromMap(map['basicInfo'] as Map<String, dynamic>),
      professionalInfo: ProfessionalInfo.fromMap(
        map['professionalInfo'] as Map<String, dynamic>,
      ),
      documentUrls: DocumentUrls.fromMap(
        map['documentUrls'] as Map<String, dynamic>,
      ),
      verificationStatus: VerificationStatus.fromMap(
        map['verificationStatus'] as Map<String, dynamic>,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'basicInfo': basicInfo.toMap(),
      'professionalInfo': professionalInfo.toMap(),
      'documentUrls': documentUrls.toMap(),
      'verificationStatus': verificationStatus.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create a copy with updated fields
  MechanicUser copyWith({
    String? uid,
    BasicInfo? basicInfo,
    ProfessionalInfo? professionalInfo,
    DocumentUrls? documentUrls,
    VerificationStatus? verificationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MechanicUser(
      uid: uid ?? this.uid,
      basicInfo: basicInfo ?? this.basicInfo,
      professionalInfo: professionalInfo ?? this.professionalInfo,
      documentUrls: documentUrls ?? this.documentUrls,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Basic Information Value Object
///
/// Represents basic personal information of a mechanic
class BasicInfo {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? username;

  const BasicInfo({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.username,
  });

  factory BasicInfo.fromMap(Map<String, dynamic> map) {
    return BasicInfo(
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      phoneNumber: map['phoneNumber'] as String,
      username: map['username'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'username': username,
    };
  }

  BasicInfo copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? username,
  }) {
    return BasicInfo(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
    );
  }
}

/// Professional Information Value Object
///
/// Represents professional credentials and business info
class ProfessionalInfo {
  final String businessName;
  final String licenseNumber;
  final List<String> specializations;
  final String address;
  final double? latitude;
  final double? longitude;

  const ProfessionalInfo({
    required this.businessName,
    required this.licenseNumber,
    required this.specializations,
    required this.address,
    this.latitude,
    this.longitude,
  });

  factory ProfessionalInfo.fromMap(Map<String, dynamic> map) {
    return ProfessionalInfo(
      businessName: map['businessName'] as String,
      licenseNumber: map['licenseNumber'] as String,
      specializations: List<String>.from(map['specializations'] as List),
      address: map['address'] as String,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'licenseNumber': licenseNumber,
      'specializations': specializations,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  ProfessionalInfo copyWith({
    String? businessName,
    String? licenseNumber,
    List<String>? specializations,
    String? address,
    double? latitude,
    double? longitude,
  }) {
    return ProfessionalInfo(
      businessName: businessName ?? this.businessName,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      specializations: specializations ?? this.specializations,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

/// Document URLs Value Object
///
/// Stores URLs to uploaded documents
class DocumentUrls {
  final String? profilePhotoUrl;
  final String? licensePhotoUrl;
  final String? certificatePhotoUrl;

  const DocumentUrls({
    this.profilePhotoUrl,
    this.licensePhotoUrl,
    this.certificatePhotoUrl,
  });

  factory DocumentUrls.fromMap(Map<String, dynamic> map) {
    return DocumentUrls(
      profilePhotoUrl: map['profilePhotoUrl'] as String?,
      licensePhotoUrl: map['licensePhotoUrl'] as String?,
      certificatePhotoUrl: map['certificatePhotoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profilePhotoUrl': profilePhotoUrl,
      'licensePhotoUrl': licensePhotoUrl,
      'certificatePhotoUrl': certificatePhotoUrl,
    };
  }

  DocumentUrls copyWith({
    String? profilePhotoUrl,
    String? licensePhotoUrl,
    String? certificatePhotoUrl,
  }) {
    return DocumentUrls(
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      licensePhotoUrl: licensePhotoUrl ?? this.licensePhotoUrl,
      certificatePhotoUrl: certificatePhotoUrl ?? this.certificatePhotoUrl,
    );
  }
}

/// Verification Status Value Object
///
/// Tracks the verification state of a mechanic
class VerificationStatus {
  final VerificationState state;
  final String? rejectionReason;
  final DateTime? verifiedAt;

  const VerificationStatus({
    required this.state,
    this.rejectionReason,
    this.verifiedAt,
  });

  factory VerificationStatus.fromMap(Map<String, dynamic> map) {
    return VerificationStatus(
      state: VerificationState.values.firstWhere(
        (e) => e.toString() == 'VerificationState.${map['state']}',
      ),
      rejectionReason: map['rejectionReason'] as String?,
      verifiedAt: map['verifiedAt'] != null
          ? (map['verifiedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'state': state.toString().split('.').last,
      'rejectionReason': rejectionReason,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
    };
  }

  VerificationStatus copyWith({
    VerificationState? state,
    String? rejectionReason,
    DateTime? verifiedAt,
  }) {
    return VerificationStatus(
      state: state ?? this.state,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}

/// Verification State Enum
///
/// Possible states of mechanic verification
enum VerificationState { pending, verified, rejected }
