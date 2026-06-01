/// Application-wide constants
class AppConstants {
  AppConstants._();

  // File upload
  static const List<String> allowedFileExtensions = [
    'pdf',
    'jpg',
    'jpeg',
    'png',
  ];
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB

  // Mechanic specializations
  static const List<String> mechanicSpecializations = [
    'Auto Electrical',
    'Engine Repair',
    'Brake Systems',
    'Transmission',
    'Air Conditioning',
    'Body Work',
    'Tire Services',
    'General Automotive',
    'Motorcycle Repair',
    'Heavy Equipment',
  ];

  // Experience limits
  static const int minYearsOfExperience = 1;
  static const int maxYearsOfExperience = 50;

  // Firestore collections
  static const String mechanicsCollection = 'mechanics';
  static const String customersCollection = 'customers';

  // Verification
  static const String verificationStatusPending = 'pending';
  static const String verificationStatusApproved = 'approved';
  static const String verificationStatusRejected = 'rejected';

  // Storage paths
  static String mechanicLicensePath(String uid) => 'mechanics/$uid/license';
  static String mechanicCertificationPath(String uid) =>
      'mechanics/$uid/certification';
  static String mechanicGovernmentIdPath(String uid) =>
      'mechanics/$uid/government_id';
}
