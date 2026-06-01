import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:arsapplication/features/customer/vehicles/presentation/screens/my_vehicles_screen.dart';
import 'package:arsapplication/features/customer/dashboard/presentation/screens/user_dashboard.dart';
import 'package:arsapplication/features/customer/history/presentation/screens/booking_history_screen.dart';
import 'package:arsapplication/features/customer/saved_places/presentation/screens/saved_places_screen.dart';
import 'package:arsapplication/features/customer/payment/presentation/screens/payment_methods_screen.dart';
import 'package:arsapplication/features/customer/support/presentation/screens/support_screen.dart';
import 'package:arsapplication/features/customer/feedback/presentation/screens/feedback_screen.dart';

class BookingDrawer extends StatelessWidget {
  final VoidCallback onLogout;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const BookingDrawer({
    super.key,
    required this.onLogout,
    required this.scaffoldKey,
  });

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: AppTheme.figtreeBold.copyWith(fontSize: AppTheme.fontSize18),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTheme.figtreeRegular.copyWith(
            fontSize: AppTheme.fontSize15,
            color: AppTheme.subtitleColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTheme.figtreeMedium.copyWith(
                color: AppTheme.subtitleColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onLogout();
            },
            child: Text(
              'Logout',
              style: AppTheme.figtreeSemiBold.copyWith(
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            color: AppTheme.primarySurface,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserDashboard(),
                  ),
                );
              },
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(
                      LucideIcons.user,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'User',
                          style: AppTheme.figtreeSemiBold.copyWith(
                            fontSize: AppTheme.fontSize18,
                            color: AppTheme.onSurfaceColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user?.email ?? '',
                          style: AppTheme.figtreeRegular.copyWith(
                            fontSize: AppTheme.fontSize12,
                            color: AppTheme.subtitleColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    LucideIcons.chevron_right,
                    size: 16,
                    color: AppTheme.subtitleColor,
                  ),
                ],
              ),
            ),
          ),
          ..._buildDrawerItems(context),
          const Divider(color: AppTheme.borderColor),
          ListTile(
            leading: const Icon(
              LucideIcons.log_out,
              color: AppTheme.errorColor,
            ),
            title: Text(
              'Logout',
              style: AppTheme.figtreeMedium.copyWith(
                fontSize: AppTheme.fontSize16,
                color: AppTheme.errorColor,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDrawerItems(BuildContext context) {
    final items = [
      {
        'icon': LucideIcons.car,
        'title': 'My Vehicles',
        'screen': const MyVehiclesScreen(),
      },
      {
        'icon': LucideIcons.history,
        'title': 'History',
        'screen': const BookingHistoryScreen(),
      },
      {
        'icon': LucideIcons.bookmark,
        'title': 'Saved Places',
        'screen': const SavedPlacesScreen(),
      },
      {
        'icon': LucideIcons.credit_card,
        'title': 'Payment Methods',
        'screen': const PaymentMethodsScreen(),
      },
      {
        'icon': LucideIcons.headset,
        'title': 'Support',
        'screen': const SupportScreen(),
      },
      {
        'icon': LucideIcons.thumbs_up,
        'title': 'Feedback',
        'screen': const FeedbackScreen(),
      },
    ];

    return items
        .map(
          (item) => ListTile(
            leading: Icon(
              item['icon'] as IconData,
              color: AppTheme.onSurfaceColor,
              size: 22,
            ),
            title: Text(
              item['title'] as String,
              style: AppTheme.figtreeMedium.copyWith(
                fontSize: AppTheme.fontSize15,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => item['screen'] as Widget,
                ),
              );
            },
          ),
        )
        .toList();
  }
}
