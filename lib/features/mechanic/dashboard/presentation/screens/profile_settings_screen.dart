import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:arsapplication/core/utils/toast_helper.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _experienceController = TextEditingController();

  // Settings
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _availableForEmergency = true;
  String _serviceRadius = '10km';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _auth.currentUser;
    // Pre-fill with Auth data immediately so screen isn't blank
    _nameController.text = user?.displayName ?? '';
    // Then load richer data from Firestore
    if (user != null) {
      _firestore
          .collection('mechanics')
          .doc(user.uid)
          .get()
          .then((doc) {
            if (doc.exists && mounted) {
              final data = doc.data()!;
              final basicInfo = data['basicInfo'] as Map<String, dynamic>?;
              final profInfo =
                  data['professionalInfo'] as Map<String, dynamic>?;
              setState(() {
                _nameController.text =
                    basicInfo?['fullName'] as String? ?? user.displayName ?? '';
                _phoneController.text =
                    basicInfo?['phoneNumber'] as String? ?? '';
                _vehicleTypeController.text =
                    profInfo?['vehicleType'] as String? ??
                    profInfo?['businessName'] as String? ??
                    '';
                _experienceController.text =
                    (profInfo?['yearsExperience'] ?? profInfo?['experience'])
                        ?.toString() ??
                    '';
              });
            }
          })
          .catchError((_) {
            // Firestore read failed — Auth data already loaded, continue
          });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleTypeController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile Settings',
          style: AppTheme.figtreeBold.copyWith(
            color: AppTheme.onSurfaceColor,
            fontSize: AppTheme.fontSize18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.onSurfaceColor,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppTheme.fontSize16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: 16),
            _buildPersonalInfoSection(),
            const SizedBox(height: 16),
            _buildWorkInfoSection(),
            const SizedBox(height: 16),
            _buildNotificationSettings(),
            const SizedBox(height: 16),
            _buildAvailabilitySettings(),
            const SizedBox(height: 16),
            _buildAccountActions(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primaryColor,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? 'Mechanic Name',
            style: const TextStyle(
              fontSize: AppTheme.fontSize22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'mechanic@example.com',
            style: const TextStyle(
              fontSize: AppTheme.fontSize14,
              color: AppTheme.grey600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('4.8', 'Rating', LucideIcons.star, Colors.amber),
              _buildStatCard(
                '127',
                'Services',
                LucideIcons.wrench,
                AppTheme.primaryColor,
              ),
              _buildStatCard(
                '98%',
                'Success',
                LucideIcons.circle_check,
                AppTheme.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: AppTheme.fontSize18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTheme.fontSize12,
            color: AppTheme.grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
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
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: LucideIcons.user,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Name is required';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: LucideIcons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Phone is required';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkInfoSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Work Information',
            style: TextStyle(
              fontSize: AppTheme.fontSize18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _vehicleTypeController,
            label: 'Vehicle Type',
            icon: LucideIcons.bike,
            readOnly: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _experienceController,
            label: 'Years of Experience',
            icon: LucideIcons.briefcase,
            readOnly: true,
          ),
          const SizedBox(height: 16),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              LucideIcons.badge_check,
              color: AppTheme.primaryColor,
            ),
            title: Text(
              'Verification Status',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text('Verified Mechanic'),
            trailing: Icon(LucideIcons.circle_check, color: AppTheme.green),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: AppTheme.fontSize18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive service requests'),
            value: _pushNotifications,
            activeThumbColor: AppTheme.primaryColor,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Email Notifications'),
            subtitle: const Text('Weekly summary reports'),
            value: _emailNotifications,
            activeThumbColor: AppTheme.primaryColor,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySettings() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Availability Settings',
            style: TextStyle(
              fontSize: AppTheme.fontSize18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Emergency Services'),
            subtitle: const Text('Accept urgent requests'),
            value: _availableForEmergency,
            activeThumbColor: AppTheme.primaryColor,
            onChanged: (value) {
              setState(() {
                _availableForEmergency = value;
              });
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Service Radius'),
            subtitle: Text(_serviceRadius),
            trailing: const Icon(LucideIcons.chevron_right),
            onTap: _showServiceRadiusDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account',
            style: TextStyle(
              fontSize: AppTheme.fontSize18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(LucideIcons.lock, color: AppTheme.grey),
            title: const Text('Change Password'),
            trailing: const Icon(LucideIcons.chevron_right),
            onTap: _changePassword,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(LucideIcons.trash_2, color: AppTheme.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: AppTheme.red),
            ),
            trailing: const Icon(
              LucideIcons.chevron_right,
              color: AppTheme.red,
            ),
            onTap: _deleteAccount,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
    );
  }

  void _saveProfile() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      ToastHelper.showError(context, 'Not logged in');
      return;
    }
    _firestore
        .collection('mechanics')
        .doc(uid)
        .set({
          'basicInfo': {
            'fullName': _nameController.text.trim(),
            'phoneNumber': _phoneController.text.trim(),
            'email': _auth.currentUser?.email ?? '',
          },
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        .then((_) {
          // Also update Auth display name
          _auth.currentUser?.updateDisplayName(_nameController.text.trim());
          if (mounted) {
            ToastHelper.showSuccess(context, 'Profile updated successfully!');
          }
        })
        .catchError((e) {
          if (mounted) {
            ToastHelper.showError(context, 'Failed to save profile: $e');
          }
        });
  }

  void _showServiceRadiusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Service Radius'),
        content: RadioGroup<String>(
          groupValue: _serviceRadius,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _serviceRadius = value);
            Navigator.pop(context);
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('5 km'),
                value: '5km',
                activeColor: AppTheme.primaryColor,
              ),
              RadioListTile<String>(
                title: Text('10 km'),
                value: '10km',
                activeColor: AppTheme.primaryColor,
              ),
              RadioListTile<String>(
                title: Text('20 km'),
                value: '20km',
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
          'A password reset link will be sent to your email.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _auth.sendPasswordResetEmail(
                  email: _auth.currentUser!.email!,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                ToastHelper.showSuccess(context, 'Password reset email sent!');
              } catch (e) {
                if (!context.mounted) return;
                ToastHelper.showError(context, 'Error: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.pop(context);
              ToastHelper.showInfo(
                context,
                'Account deletion is currently unavailable',
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
