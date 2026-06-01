import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:arsapplication/core/constants/app_constants.dart';
import 'package:arsapplication/core/constants/app_strings.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:arsapplication/features/mechanic/auth/presentation/screens/mechanic_verification_status_screen.dart';

class MechanicProfessionalDetailsScreen extends StatefulWidget {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String username;
  final String email;

  const MechanicProfessionalDetailsScreen({
    super.key,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
  });

  @override
  State<MechanicProfessionalDetailsScreen> createState() =>
      _MechanicProfessionalDetailsScreenState();
}

class _MechanicProfessionalDetailsScreenState
    extends State<MechanicProfessionalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedSpecialization = '';
  int _yearsOfExperience = AppConstants.minYearsOfExperience;
  bool _isLoading = false;

  // File upload variables
  File? _licenseFile;
  File? _certificationFile;
  File? _governmentIdFile;

  String? _licenseFileName;
  String? _certificationFileName;
  String? _governmentIdFileName;

  @override
  void dispose() {
    _businessNameController.dispose();
    _licenseNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String fileType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.allowedFileExtensions,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final fileName = result.files.first.name;

        setState(() {
          switch (fileType) {
            case 'license':
              _licenseFile = file;
              _licenseFileName = fileName;
              break;
            case 'certification':
              _certificationFile = file;
              _certificationFileName = fileName;
              break;
            case 'governmentId':
              _governmentIdFile = file;
              _governmentIdFileName = fileName;
              break;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(AppStrings.errorPickingFile(e.toString()));
      }
    }
  }

  Future<String?> _uploadFile(File file, String fileName, String folder) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final storagePath = 'mechanics/${user.uid}/$folder/$fileName';
      final ref = FirebaseStorage.instance.ref().child(storagePath);

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  bool _validateRequiredFields() {
    if (_selectedSpecialization.isEmpty) {
      _showErrorSnackBar(AppStrings.selectSpecializationError);
      return false;
    }

    if (_licenseFile == null || _governmentIdFile == null) {
      _showErrorSnackBar(AppStrings.requiredDocumentsError);
      return false;
    }

    return true;
  }

  Future<void> _saveProfessionalDetails() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateRequiredFields()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception(AppStrings.noAuthenticatedUserError);

      // Upload files
      String? licenseUrl;
      String? certificationUrl;
      String? governmentIdUrl;

      if (_licenseFile != null) {
        licenseUrl = await _uploadFile(
          _licenseFile!,
          _licenseFileName!,
          'license',
        );
      }

      if (_certificationFile != null) {
        certificationUrl = await _uploadFile(
          _certificationFile!,
          _certificationFileName!,
          'certification',
        );
      }

      if (_governmentIdFile != null) {
        governmentIdUrl = await _uploadFile(
          _governmentIdFile!,
          _governmentIdFileName!,
          'government_id',
        );
      }

      // Save to Firestore
      await _saveMechanicToFirestore(
        user.uid,
        licenseUrl,
        certificationUrl,
        governmentIdUrl,
      );

      if (mounted) {
        _navigateToVerificationStatus();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(AppStrings.errorSavingDetails(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveMechanicToFirestore(
    String uid,
    String? licenseUrl,
    String? certificationUrl,
    String? governmentIdUrl,
  ) async {
    await FirebaseFirestore.instance
        .collection(AppConstants.mechanicsCollection)
        .doc(uid)
        .set({
          'basicInfo': {
            'firstName': widget.firstName,
            'lastName': widget.lastName,
            'username': widget.username,
            'email': widget.email,
            'phoneNumber': widget.phoneNumber,
            'fullName': '${widget.firstName} ${widget.lastName}',
          },
          'professionalDetails': {
            'businessName': _businessNameController.text.trim(),
            'specialization': _selectedSpecialization,
            'yearsOfExperience': _yearsOfExperience,
            'licenseNumber': _licenseNumberController.text.trim(),
            'serviceLocation': _addressController.text.trim(),
          },
          'documents': {
            'licenseUrl': licenseUrl,
            'certificationUrl': certificationUrl,
            'governmentIdUrl': governmentIdUrl,
          },
          'verification': {
            'status': AppConstants.verificationStatusPending,
            'emailVerified':
                FirebaseAuth.instance.currentUser?.emailVerified ?? false,
            'submittedAt': FieldValue.serverTimestamp(),
            'reviewedAt': null,
            'reviewedBy': null,
            'rejectionReason': null,
          },
          'accountType': 'mechanic',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': false,
          'rating': 0.0,
          'totalReviews': 0,
          'completedJobs': 0,
        });
  }

  void _navigateToVerificationStatus() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MechanicVerificationStatusScreen(),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildFileUploadCard({
    required String title,
    required String subtitle,
    required bool isRequired,
    required String fileType,
    String? fileName,
  }) {
    final hasFile = fileName != null;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _pickFile(fileType),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasFile
                      ? AppTheme.primaryColor.withValues(alpha: 0.1)
                      : AppTheme.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  hasFile ? Icons.check_circle : Icons.upload_file,
                  color: hasFile ? AppTheme.primaryColor : AppTheme.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title + (isRequired ? ' *' : ''),
                      style: const TextStyle(
                        fontSize: AppTheme.fontSize16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasFile ? fileName : subtitle,
                      style: AppTheme.bodySmall.copyWith(
                        color: hasFile ? AppTheme.primaryColor : AppTheme.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                hasFile ? Icons.edit : Icons.arrow_forward_ios,
                color: AppTheme.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.professionalDetailsTitle,
          style: AppTheme.appBarTitle,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      AppStrings.completeProfileHeader,
                      style: AppTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.welcomeMessage(widget.firstName),
                      style: AppTheme.bodyLarge.copyWith(color: AppTheme.grey),
                    ),
                    const SizedBox(height: 32),

                    // Business Name
                    TextFormField(
                      controller: _businessNameController,
                      decoration: const InputDecoration(
                        labelText: AppStrings.businessNameLabel,
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                        helperText: AppStrings.businessNameHelper,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Specialization
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: AppStrings.specializationLabel,
                        prefixIcon: Icon(Icons.build),
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _selectedSpecialization.isEmpty
                          ? null
                          : _selectedSpecialization,
                      items: AppConstants.mechanicSpecializations.map((spec) {
                        return DropdownMenuItem(value: spec, child: Text(spec));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedSpecialization = value);
                        }
                      },
                      validator: (value) => value == null
                          ? AppStrings.selectSpecializationError
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Years of Experience
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.work_outline,
                              color: AppTheme.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                AppStrings.yearsOfExperienceLabel,
                                style: AppTheme.bodyMedium,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed:
                                        _yearsOfExperience >
                                            AppConstants.minYearsOfExperience
                                        ? () => setState(
                                            () => _yearsOfExperience--,
                                          )
                                        : null,
                                    icon: const Icon(Icons.remove),
                                  ),
                                  Text(
                                    '$_yearsOfExperience',
                                    style: AppTheme.bodyMedium,
                                  ),
                                  IconButton(
                                    onPressed:
                                        _yearsOfExperience <
                                            AppConstants.maxYearsOfExperience
                                        ? () => setState(
                                            () => _yearsOfExperience++,
                                          )
                                        : null,
                                    icon: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // License Number
                    TextFormField(
                      controller: _licenseNumberController,
                      decoration: const InputDecoration(
                        labelText: AppStrings.licenseNumberLabel,
                        prefixIcon: Icon(Icons.assignment),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.licenseNumberRequiredError;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Document Uploads Section
                    Text(
                      AppStrings.requiredDocumentsTitle,
                      style: AppTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    _buildFileUploadCard(
                      title: AppStrings.licenseDocumentTitle,
                      subtitle: AppStrings.licenseDocumentSubtitle,
                      isRequired: true,
                      fileType: 'license',
                      fileName: _licenseFileName,
                    ),
                    const SizedBox(height: 12),

                    _buildFileUploadCard(
                      title: AppStrings.certificationsTitle,
                      subtitle: AppStrings.certificationsSubtitle,
                      isRequired: false,
                      fileType: 'certification',
                      fileName: _certificationFileName,
                    ),
                    const SizedBox(height: 12),

                    _buildFileUploadCard(
                      title: AppStrings.governmentIdTitle,
                      subtitle: AppStrings.governmentIdSubtitle,
                      isRequired: true,
                      fileType: 'governmentId',
                      fileName: _governmentIdFileName,
                    ),
                    const SizedBox(height: 24),

                    // Service Location
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: AppStrings.serviceLocationLabel,
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                        helperText: AppStrings.serviceLocationHelper,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.serviceLocationRequiredError;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfessionalDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                AppStrings.submitButtonText,
                                style: AppTheme.buttonLarge,
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      AppStrings.verificationNote,
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
