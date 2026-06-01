// location_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextField(
            style: AppTheme.figtreeRegular.copyWith(
              fontSize: AppTheme.fontSize14,
            ),
            decoration: InputDecoration(
              hintText: 'Search repair location...',
              hintStyle: AppTheme.figtreeRegular.copyWith(
                color: AppTheme.subtitleColor.withAlpha(150),
                fontSize: AppTheme.fontSize14,
              ),
              prefixIcon: const Icon(
                LucideIcons.search,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14.0,
                horizontal: 10.0,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildCurrentLocationTile(),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved Locations',
                      style: AppTheme.figtreeBold.copyWith(
                        fontSize: AppTheme.fontSize18,
                        color: AppTheme.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start saving locations so you can book a mechanic faster!',
                      style: AppTheme.figtreeRegular.copyWith(
                        fontSize: AppTheme.fontSize14,
                        color: AppTheme.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildLocationOption(
                icon: LucideIcons.house,
                label: 'Add Home',
                onTap: () {},
              ),
              _buildLocationOption(
                icon: LucideIcons.briefcase,
                label: 'Add Work',
                onTap: () {},
              ),
              _buildLocationOption(
                icon: LucideIcons.graduation_cap,
                label: 'Add School',
                onTap: () {},
              ),
              _buildLocationOption(
                icon: LucideIcons.plus,
                label: 'Add Another Place',
                onTap: () {},
              ),
              const SizedBox(height: 80), // Space for the bottom button
            ],
          ),
          _buildChooseFromMapButton(),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationTile() {
    return GestureDetector(
      onTap: () {
        // TODO: Implement logic to use current location
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.primarySurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primaryColor.withAlpha(40)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.locate,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Use My Current Location',
                style: AppTheme.figtreeSemiBold.copyWith(
                  fontSize: AppTheme.fontSize16,
                  color: AppTheme.primaryDark,
                ),
              ),
            ),
            const Icon(
              LucideIcons.chevron_right,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.subtitleColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTheme.figtreeMedium.copyWith(
                  fontSize: AppTheme.fontSize15,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
            ),
            const Icon(
              LucideIcons.plus,
              color: AppTheme.subtitleColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChooseFromMapButton() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement map selection logic
            },
            icon: const Icon(LucideIcons.map, size: 20),
            label: Text(
              'Choose from map',
              style: AppTheme.figtreeSemiBold.copyWith(
                fontSize: AppTheme.fontSize15,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
