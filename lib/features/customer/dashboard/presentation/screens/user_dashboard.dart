import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arsapplication/features/onboarding/presentation/screens/loading_screen.dart';
import 'package:arsapplication/main.dart';
import 'package:arsapplication/core/utils/toast_helper.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/firebase_profile_repository.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  // Repository (Dependency Injection)
  late final ProfileRepository _profileRepository;
  final _formKey = GlobalKey<FormState>();

  // Controllers for editing
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    // Initialize repository
    _profileRepository = FirebaseProfileRepository();
    _loadUserData();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() => _isInitialLoading = true);

    try {
      // Reload user data from server
      await _profileRepository.reloadUserData();

      // Get fresh user profile
      final profile = await _profileRepository.getCurrentUserProfile();

      if (profile != null) {
        _userProfile = profile;
        _displayNameController.text = profile.displayName ?? '';
        _phoneController.text = profile.phoneNumber ?? '';
      }

      // Minimum loading time for better UX (prevents flashing)
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(
          context,
          'Error loading profile: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isInitialLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Prevent multiple simultaneous updates
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final newDisplayName = _displayNameController.text.trim();

      // Update display name if changed
      if (newDisplayName != _userProfile?.displayName) {
        await _profileRepository.updateDisplayName(newDisplayName);
      }

      // Reload user data
      await _profileRepository.reloadUserData();
      final updatedProfile = await _profileRepository.getCurrentUserProfile();

      if (mounted && updatedProfile != null) {
        setState(() {
          _userProfile = updatedProfile;
          _isEditing = false;
          _isLoading = false;
        });

        ToastHelper.showSuccess(context, 'Profile updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ToastHelper.showError(
          context,
          'Error updating profile: ${e.toString()}',
        );
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Logout', style: TextStyle(color: AppTheme.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);

    try {
      await _profileRepository.signOut();

      // Clear user type so they can choose again
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_type');

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const UserTypeSelectionScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ToastHelper.showError(context, 'Error logging out: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state while initial data is being fetched
    if (_isInitialLoading || _userProfile == null) {
      return AppLoadingStates.userProfile(message: 'Loading your profile...');
    }

    return LoadingOverlay(
      isLoading: _isLoading,
      loadingMessage: 'Updating profile...',
      child: Scaffold(
        backgroundColor: AppTheme.grey50,
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            if (!_isEditing)
              IconButton(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(LucideIcons.pencil),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Picture Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: AppTheme.primaryColor,
                            backgroundImage: _userProfile?.photoUrl != null
                                ? NetworkImage(_userProfile!.photoUrl!)
                                : null,
                            child: _userProfile?.photoUrl == null
                                ? const Icon(
                                    LucideIcons.user,
                                    size: 60,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    // Implement photo picker functionality
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Photo update feature coming soon!',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    LucideIcons.camera,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!_isEditing)
                        Text(
                          _userProfile?.displayName ?? 'No Name',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSize24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // User Information Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Display Name Field
                      if (_isEditing)
                        TextFormField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        )
                      else
                        _buildInfoTile(
                          icon: Icons.person,
                          title: 'Full Name',
                          value: _userProfile?.displayName ?? 'Not set',
                        ),

                      const SizedBox(height: 16),

                      // Email Field (Read-only)
                      _buildInfoTile(
                        icon: Icons.email,
                        title: 'Email',
                        value: _userProfile?.email ?? 'No email',
                        isReadOnly: true,
                      ),

                      const SizedBox(height: 16),

                      // Phone Number Field
                      if (_isEditing)
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        )
                      else
                        _buildInfoTile(
                          icon: Icons.phone,
                          title: 'Phone Number',
                          value: _userProfile?.phoneNumber ?? 'Not set',
                        ),

                      const SizedBox(height: 16),

                      // Account Created
                      _buildInfoTile(
                        icon: Icons.calendar_today,
                        title: 'Member Since',
                        value: _userProfile?.createdAt != null
                            ? '${_userProfile!.createdAt!.day}/${_userProfile!.createdAt!.month}/${_userProfile!.createdAt!.year}'
                            : 'Unknown',
                        isReadOnly: true,
                      ),

                      const SizedBox(height: 16),

                      // Email Verified Status
                      _buildInfoTile(
                        icon: _userProfile?.emailVerified == true
                            ? Icons.verified
                            : Icons.warning,
                        title: 'Email Status',
                        value: _userProfile?.emailVerified == true
                            ? 'Verified'
                            : 'Not Verified',
                        isReadOnly: true,
                        valueColor: _userProfile?.emailVerified == true
                            ? AppTheme.green
                            : AppTheme.orange,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Action Buttons
                if (_isEditing)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() => _isEditing = false);
                                  _loadUserData(); // Reset form data
                                },
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save Changes'),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showLogoutDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    bool isReadOnly = false,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isReadOnly ? AppTheme.grey50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSize12,
                    color: AppTheme.grey600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: AppTheme.fontSize16,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
