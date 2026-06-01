/// Booking Search Bar - Top search and navigation bar
///
/// Provides search functionality and quick actions for the booking screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

/// Search bar widget for booking screen
class BookingSearchBar extends StatelessWidget {
  final VoidCallback onMenuPressed;
  final VoidCallback onMyLocationPressed;
  final ValueChanged<String>? onSearchChanged;

  const BookingSearchBar({
    super.key,
    required this.onMenuPressed,
    required this.onMyLocationPressed,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildMenuButton(),
        const SizedBox(width: 12),
        Expanded(child: _buildSearchField()),
      ],
    );
  }

  /// Build circular menu button
  Widget _buildMenuButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onMenuPressed,
        icon: const Icon(
          LucideIcons.menu,
          color: AppTheme.onSurfaceColor,
          size: 22,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Build search text field with location button
  Widget _buildSearchField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Icon(
              LucideIcons.search,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              style: AppTheme.figtreeRegular.copyWith(
                fontSize: AppTheme.fontSize14,
                color: AppTheme.onSurfaceColor,
              ),
              decoration: InputDecoration(
                hintText: 'Search location...',
                hintStyle: AppTheme.figtreeRegular.copyWith(
                  color: AppTheme.subtitleColor.withAlpha(150),
                  fontSize: AppTheme.fontSize14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: const Icon(
                LucideIcons.locate,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              onPressed: onMyLocationPressed,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shop filter toggle button
class ShopFilterButton extends StatelessWidget {
  final bool showShops;
  final int shopCount;
  final VoidCallback onToggle;

  const ShopFilterButton({
    super.key,
    required this.showShops,
    required this.shopCount,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: showShops ? AppTheme.primaryColor : AppTheme.borderColor,
              width: showShops ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  LucideIcons.store,
                  color: showShops
                      ? AppTheme.primaryColor
                      : AppTheme.subtitleColor,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        // Badge showing shop count
        if (shopCount > 0 && showShops)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Center(
                child: Text(
                  '$shopCount',
                  style: AppTheme.figtreeBold.copyWith(
                    color: Colors.white,
                    fontSize: AppTheme.fontSize10,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Toggle button for showing/hiding online mechanics on the map
class MechanicFilterButton extends StatelessWidget {
  final bool showMechanics;
  final int mechanicCount;
  final VoidCallback onToggle;

  const MechanicFilterButton({
    super.key,
    required this.showMechanics,
    required this.mechanicCount,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppTheme.primaryDark;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: showMechanics ? activeColor : AppTheme.borderColor,
              width: showMechanics ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  LucideIcons.wrench,
                  color: showMechanics ? activeColor : AppTheme.subtitleColor,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        if (mechanicCount > 0 && showMechanics)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Center(
                child: Text(
                  '$mechanicCount',
                  style: AppTheme.figtreeBold.copyWith(
                    color: Colors.white,
                    fontSize: AppTheme.fontSize10,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Launcher button for local AI booking assistant
class ChatbotLauncherButton extends StatelessWidget {
  final VoidCallback onTap;

  const ChatbotLauncherButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.accentYellow, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(
              LucideIcons.bot,
              color: AppTheme.accentYellow,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
