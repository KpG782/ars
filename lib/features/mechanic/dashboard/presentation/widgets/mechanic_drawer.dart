import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:arsapplication/core/utils/toast_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:arsapplication/features/mechanic/earnings/presentation/screens/earnings_screen.dart';
import '../screens/profile_settings_screen.dart';
import 'package:arsapplication/features/mechanic/services/presentation/screens/service_history_screen.dart';

class MechanicDrawer extends StatelessWidget {
  final VoidCallback onLogout;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const MechanicDrawer({
    super.key,
    required this.onLogout,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: AppTheme.primaryColor),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: user?.photoURL != null
                          ? ClipOval(
                              child: Image.network(
                                user!.photoURL!,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              LucideIcons.user,
                              size: 40,
                              color: AppTheme.primaryColor,
                            ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.displayName ?? 'Mechanic',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppTheme.fontSize20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: AppTheme.fontSize14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: LucideIcons.layout_dashboard,
                  title: 'Dashboard',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: LucideIcons.history,
                  title: 'Service History',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ServiceHistoryScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: LucideIcons.wallet,
                  title: 'Earnings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EarningsScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: LucideIcons.settings,
                  title: 'Profile Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileSettingsScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: LucideIcons.life_buoy,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    ToastHelper.showInfo(
                      context,
                      'Help & Support coming soon!',
                    );
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: LucideIcons.log_out,
                  title: 'Logout',
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                  textColor: AppTheme.red,
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(20),
            child: const Text(
              'ARS Mechanic v1.0.0',
              style: TextStyle(
                color: AppTheme.grey,
                fontSize: AppTheme.fontSize12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppTheme.primaryColor),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
              onLogout();
            },
            child: const Text('Logout', style: TextStyle(color: AppTheme.red)),
          ),
        ],
      ),
    );
  }
}
