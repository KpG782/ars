import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:arsapplication/main.dart';
import 'package:arsapplication/features/mechanic/dashboard/presentation/screens/mechanic_dashboard.dart';

class MechanicVerificationStatusScreen extends StatefulWidget {
  const MechanicVerificationStatusScreen({super.key});

  @override
  State<MechanicVerificationStatusScreen> createState() =>
      _MechanicVerificationStatusScreenState();
}

class _MechanicVerificationStatusScreenState
    extends State<MechanicVerificationStatusScreen> {
  late ConfettiController _confettiController;
  String _verificationStatus = 'pending';
  bool _isLoading = true;
  bool _emailVerified = false;
  Timer? _statusCheckTimer;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _loadVerificationStatus();
    _startPeriodicStatusCheck();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicStatusCheck() {
    // Check status every 3 seconds
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _loadVerificationStatus();
      }
    });
  }

  Future<void> _loadVerificationStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Reload user to get latest email verification status
        await user.reload();
        final updatedUser = FirebaseAuth.instance.currentUser;

        final doc = await FirebaseFirestore.instance
            .collection('mechanics')
            .doc(user.uid)
            .get();

        if (doc.exists && mounted) {
          final data = doc.data()!;
          final status = data['verification']?['status'] ?? 'pending';
          final emailVerified = updatedUser?.emailVerified ?? false;

          setState(() {
            _verificationStatus = status;
            _emailVerified = emailVerified;
            _isLoading = false;
          });

          // Check if both conditions are met for approval
          if (status == 'approved' && emailVerified) {
            _confettiController.play();

            // Wait 2 seconds to show confetti, then navigate
            await Future.delayed(const Duration(seconds: 2));

            if (mounted) {
              _statusCheckTimer?.cancel(); // Stop the timer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MechanicDashboard(),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _manualStatusCheck() async {
    setState(() => _isLoading = true);
    await _loadVerificationStatus();
  }

  Future<void> _resendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Verification email sent! Please check your inbox.',
              ),
              backgroundColor: AppTheme.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending email: ${e.toString()}'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      _statusCheckTimer?.cancel(); // Stop the timer before logout
      await FirebaseAuth.instance.signOut();

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _verificationStatus == 'pending') {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking verification status...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: Stack(
        children: [
          if (_verificationStatus == 'approved' && _emailVerified)
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
                ],
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_getStatusIcon(), color: Colors.white, size: 100),
                  const SizedBox(height: 24),
                  Text(
                    _getStatusTitle(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppTheme.fontSize28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getStatusMessage(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppTheme.fontSize16,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Email and Admin Verification Status
                  _buildVerificationStatus(),
                  const SizedBox(height: 32),

                  // Action buttons based on status
                  if (_verificationStatus == 'pending') ...[
                    if (!_emailVerified) ...[
                      ElevatedButton(
                        onPressed: _resendEmailVerification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 32,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Resend Email Verification'),
                      ),
                      const SizedBox(height: 16),
                    ],
                    ElevatedButton(
                      onPressed: _isLoading ? null : _manualStatusCheck,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Check Status Now'),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_verificationStatus == 'approved' && _emailVerified)
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _statusCheckTimer?.cancel();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MechanicDashboard(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 32,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Go to Dashboard'),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Redirecting automatically...',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: AppTheme.fontSize14,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Auto-check indicator
                  if (_verificationStatus == 'pending')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51), // 0.2 * 255 = 51
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, color: Colors.white70, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Auto-checking every 3 seconds',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: AppTheme.fontSize12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _logout,
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25), // 0.1 * 255 = 25
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(76)), // 0.3 * 255 = 76
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _emailVerified ? Icons.check_circle : Icons.email_outlined,
                color: _emailVerified ? AppTheme.green : Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Email Verification',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTheme.fontSize16,
                  ),
                ),
              ),
              Text(
                _emailVerified ? 'Verified' : 'Pending',
                style: TextStyle(
                  color: _emailVerified ? AppTheme.green : AppTheme.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _verificationStatus == 'approved'
                    ? Icons.verified
                    : Icons.pending,
                color: _verificationStatus == 'approved'
                    ? AppTheme.green
                    : Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Admin Verification',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTheme.fontSize16,
                  ),
                ),
              ),
              Text(
                _verificationStatus == 'approved' ? 'Approved' : 'Pending',
                style: TextStyle(
                  color: _verificationStatus == 'approved'
                      ? AppTheme.green
                      : AppTheme.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    if (_verificationStatus == 'approved' && _emailVerified) {
      return AppTheme.primaryColor;
    } else if (_verificationStatus == 'rejected') {
      return AppTheme.red;
    } else {
      return AppTheme.orange;
    }
  }

  IconData _getStatusIcon() {
    if (_verificationStatus == 'approved' && _emailVerified) {
      return Icons.check_circle;
    } else if (_verificationStatus == 'rejected') {
      return Icons.cancel;
    } else {
      return Icons.hourglass_empty;
    }
  }

  String _getStatusTitle() {
    if (_verificationStatus == 'approved' && _emailVerified) {
      return 'WELCOME TO ARS!\nYou\'re Verified!';
    } else if (_verificationStatus == 'rejected') {
      return 'Verification Failed';
    } else {
      return 'Verification Pending';
    }
  }

  String _getStatusMessage() {
    if (_verificationStatus == 'approved' && _emailVerified) {
      return 'Your account has been verified and your email is confirmed. You can now start receiving service requests!';
    } else if (_verificationStatus == 'rejected') {
      return 'Your verification was rejected. Please contact support for assistance.';
    } else if (_verificationStatus == 'approved' && !_emailVerified) {
      return 'Your documents are approved! Please verify your email address to complete the process.';
    } else if (!_emailVerified) {
      return 'Please verify your email address and wait for admin approval. Check your email inbox for the verification link.';
    } else {
      return 'Your email is verified! Your documents are under admin review. This usually takes 1-3 business days.';
    }
  }
}
