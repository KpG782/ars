import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:confetti/confetti.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:arsapplication/core/auth/auth_service.dart';
import 'package:arsapplication/features/customer/auth/presentation/screens/user_login_screen.dart';
import 'package:arsapplication/features/mechanic/auth/presentation/screens/mechanic_professional_details_screen.dart'; // Keep the mechanics navigation
import 'package:arsapplication/features/customer/booking/presentation/screens/booking.dart';

class MechanicMobileNumberScreen extends StatefulWidget {
  const MechanicMobileNumberScreen({super.key});

  @override
  State<MechanicMobileNumberScreen> createState() =>
      _MechanicMobileNumberScreenState();
}

class _MechanicMobileNumberScreenState
    extends State<MechanicMobileNumberScreen> {
  final AuthService _authService = AuthService();
  final _phoneController = TextEditingController();
  bool _isValidNumber = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validateNumber(String value) {
    setState(() {
      _isValidNumber = value.length >= 10;
    });
  }

  Future<void> _switchToUserAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_type', 'user');

    if (mounted) {
      // Show a confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Switch Account'),
          content: const Text(
            'Switched to user account. You will be redirected to the user experience.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to the user experience
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookingScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: const Text('Logout', style: TextStyle(color: AppTheme.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    try {
      await _authService.signOut();
      // Clear user type preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_type');

      if (!mounted) return;
      // Navigate to login screen and clear all previous routes
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const UserLoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final errorColor = Theme.of(context).colorScheme.error;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevron_left, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(LucideIcons.menu, color: primaryColor),
            onSelected: (String result) {
              switch (result) {
                case 'switch':
                  _switchToUserAccount();
                  break;
                case 'logout':
                  _showLogoutDialog();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'switch',
                child: Text('Switch to User Account'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48.0,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Ilagay ang iyong mobile number',
                        style: AppTheme.headlineSmall.copyWith(
                          color: onSurfaceColor,
                          fontSize: AppTheme.fontSize20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gagamitin namin ito para sa verification at communication',
                        style: AppTheme.bodyMedium.copyWith(
                          color: onSurfaceColor.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    '🇵🇭',
                                    style: TextStyle(
                                      fontSize: AppTheme.fontSize24,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '+63',
                                    style: AppTheme.bodyLarge.copyWith(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                onChanged: _validateNumber,
                                decoration: InputDecoration(
                                  labelText: 'Mobile Number',
                                  labelStyle: TextStyle(
                                    color: primaryColor,
                                    fontSize: AppTheme.fontSize14,
                                  ),
                                  border: InputBorder.none,
                                  hintText: '9XX XXX XXXX',
                                  hintStyle: AppTheme.bodySmall.copyWith(
                                    color: onSurfaceColor.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                keyboardType: TextInputType.phone,
                                style: AppTheme.bodyMedium,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!_isValidNumber && _phoneController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(
                            'Please enter a valid mobile number.',
                            style: AppTheme.bodySmall.copyWith(
                              color: errorColor,
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      const Spacer(),
                      Text(
                        'Paalala: Makokontak ka ng ARS APP at ng iyong customer sa mobile number na ito.',
                        style: AppTheme.bodySmall.copyWith(
                          color: onSurfaceColor.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isValidNumber
                              ? () {
                                  // Navigate to professional details for mechanics flow
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MechanicProfessionalDetailsScreen(
                                            phoneNumber:
                                                '+63${_phoneController.text}',
                                            firstName:
                                                '', // Will get from auth screen
                                            lastName:
                                                '', // Will get from auth screen
                                            username:
                                                '', // Will get from auth screen
                                            email:
                                                '', // Will get from auth screen
                                          ),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: surfaceColor,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                            disabledBackgroundColor: primaryColor.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Next',
                                style: AppTheme.buttonMedium.copyWith(
                                  color: surfaceColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: surfaceColor,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Keep the additional screens from main branch for completeness
class PhotoTranslateScreen extends StatefulWidget {
  const PhotoTranslateScreen({super.key});

  @override
  State<PhotoTranslateScreen> createState() => _PhotoTranslateScreenState();
}

class _PhotoTranslateScreenState extends State<PhotoTranslateScreen> {
  final AuthService _authService = AuthService();

  Future<void> _switchToUserAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_type', 'user');

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Switch Account'),
          content: const Text(
            'Switched to user account. You will be redirected to the user experience.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookingScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: const Text('Logout', style: TextStyle(color: AppTheme.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    try {
      await _authService.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_type');

      if (mounted) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const UserLoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(LucideIcons.menu, color: primaryColor),
            onSelected: (String result) {
              switch (result) {
                case 'switch':
                  _switchToUserAccount();
                  break;
                case 'logout':
                  _showLogoutDialog();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'switch',
                child: Text('Switch to User Account'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/003.jpg', width: 250),
            const SizedBox(height: 32),
            Text(
              "ARS APPLICATION \nTerms and Privacy Policy.",
              textAlign: TextAlign.center,
              style: AppTheme.headlineSmall.copyWith(color: primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              'To keep using our app, please review the updated Terms of Use and Privacy Policy. Tap \'I Agree\' to accept the changes and continue.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyLarge.copyWith(color: primaryColor),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WelcomeScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: surfaceColor,
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'I Agree',
                  style: AppTheme.buttonLarge.copyWith(color: surfaceColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late ConfettiController _confettiController;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _switchToUserAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_type', 'user');

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Switch Account'),
          content: const Text(
            'Switched to user account. You will be redirected to the user experience.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookingScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: const Text('Logout', style: TextStyle(color: AppTheme.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    try {
      await _authService.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_type');

      if (mounted) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const UserLoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: primaryColor.withValues(alpha: 0.9),
      appBar: AppBar(
        backgroundColor: primaryColor.withValues(alpha: 0.9),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (String result) {
              switch (result) {
                case 'switch':
                  _switchToUserAccount();
                  break;
                case 'logout':
                  _showLogoutDialog();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'switch',
                child: Text('Switch to User Account'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 20,
              minBlastForce: 8,
              numberOfParticles: 50,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                AppTheme.green,
                Colors.yellow,
                AppTheme.blue,
                Colors.pink,
                AppTheme.orange,
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 100),
                const SizedBox(height: 24),
                Text(
                  'WELCOME TO ARS APPLICATION',
                  textAlign: TextAlign.center,
                  style: AppTheme.headlineSmall.copyWith(color: surfaceColor),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: surfaceColor,
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'OK',
                      style: AppTheme.buttonLarge.copyWith(color: primaryColor),
                    ),
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final AuthService _authService = AuthService();

  final CollectionReference mechanics = FirebaseFirestore.instance.collection(
    'mechanics',
  );

  Future<void> _addData() async {
    String name = _nameController.text.trim();
    String service = _serviceController.text.trim();

    if (name.isEmpty || service.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    try {
      await mechanics.add({
        'name': name,
        'service': service,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Data added successfully")));
      _nameController.clear();
      _serviceController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _switchToUserAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_type', 'user');

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Switch Account'),
          content: const Text(
            'Switched to user account. You will be redirected to the user experience.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookingScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: const Text('Logout', style: TextStyle(color: AppTheme.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    try {
      await _authService.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_type');

      if (mounted) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const UserLoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen', style: AppTheme.appBarTitle),
        backgroundColor: primaryColor,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(LucideIcons.menu, color: surfaceColor),
            onSelected: (String result) {
              switch (result) {
                case 'switch':
                  _switchToUserAccount();
                  break;
                case 'logout':
                  _showLogoutDialog();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'switch',
                child: Text('Switch to User Account'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'ARS HOMESCREEN',
              style: AppTheme.titleMedium.copyWith(color: primaryColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Mechanic Name",
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: primaryColor),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _serviceController,
              decoration: InputDecoration(
                labelText: "Service Offered",
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: primaryColor),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addData,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: surfaceColor,
              ),
              child: Text(
                "Add to Firestore",
                style: AppTheme.buttonMedium.copyWith(color: surfaceColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
