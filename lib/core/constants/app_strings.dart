/// Application-wide string constants
class AppStrings {
  AppStrings._();

  // Professional Details Screen
  static const String professionalDetailsTitle = 'Professional Details';
  static const String completeProfileHeader =
      'Complete Your Professional Profile';
  static String welcomeMessage(String firstName) =>
      'Hi $firstName! Please provide your professional details for verification.';

  // Form labels
  static const String businessNameLabel = 'Shop/Business Name (Optional)';
  static const String businessNameHelper =
      'Leave blank if you work independently';
  static const String specializationLabel = 'Specialization *';
  static const String yearsOfExperienceLabel = 'Years of Experience';
  static const String licenseNumberLabel = 'License Number *';
  static const String serviceLocationLabel = 'Service Location/Address *';
  static const String serviceLocationHelper =
      'Where do you provide your services?';

  // Document section
  static const String requiredDocumentsTitle = 'Required Documents';
  static const String licenseDocumentTitle = 'License Document';
  static const String licenseDocumentSubtitle =
      'Upload your mechanic license (PDF, JPG, PNG)';
  static const String certificationsTitle = 'Certifications';
  static const String certificationsSubtitle =
      'NC II in Automotive Servicing, Electrical, etc.';
  static const String governmentIdTitle = 'Government-issued ID';
  static const String governmentIdSubtitle =
      "Valid ID for verification (Driver's License, National ID, etc.)";

  // Buttons
  static const String submitButtonText = 'Submit for Verification';

  // Messages
  static const String verificationNote =
      'Note: Your account will be reviewed within 1-3 business days. You will receive an email once verification is complete.';
  static const String selectSpecializationError =
      'Please select a specialization';
  static const String requiredDocumentsError =
      'License and Government ID are required';
  static const String licenseNumberRequiredError = 'License number is required';
  static const String serviceLocationRequiredError =
      'Service location is required';
  static const String noAuthenticatedUserError = 'No authenticated user';

  // Error messages
  static String errorPickingFile(String error) => 'Error picking file: $error';
  static String errorSavingDetails(String error) =>
      'Error saving details: $error';
}
