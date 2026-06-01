/// Mechanic Details Sheet - Bottom sheet for mechanic information
///
/// Displays detailed information about a mechanic including
/// contact info, rating, ETA, and selection options.
library;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import '../../domain/models/mechanic.dart';

/// Shows a bottom sheet with mechanic details
class MechanicDetailsSheet extends StatelessWidget {
  final Mechanic mechanic;
  final VoidCallback? onSelect;
  final VoidCallback? onCall;

  const MechanicDetailsSheet({
    super.key,
    required this.mechanic,
    this.onSelect,
    this.onCall,
  });

  /// Show the mechanic details as a modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    required Mechanic mechanic,
    VoidCallback? onSelect,
    VoidCallback? onCall,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => MechanicDetailsSheet(
        mechanic: mechanic,
        onSelect: onSelect,
        onCall: onCall,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          _buildHeader(),
          const SizedBox(height: 24),
          if (mechanic.phoneNumber != null) _buildContactInfo(),
          _buildETAInfo(),
          const SizedBox(height: 28),
          _buildSelectButton(context),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  /// Build header with photo and basic info
  Widget _buildHeader() {
    return Row(
      children: [
        // Mechanic photo or placeholder
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.primarySurface,
            shape: BoxShape.circle,
            image: mechanic.photoUrl != null
                ? DecorationImage(
                    image: NetworkImage(mechanic.photoUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: mechanic.photoUrl == null
              ? const Icon(
                  LucideIcons.user,
                  size: 32,
                  color: AppTheme.primaryColor,
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mechanic.name,
                style: AppTheme.figtreeBold.copyWith(
                  fontSize: AppTheme.fontSize20,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
              const SizedBox(height: 6),
              _buildRatingStars(),
            ],
          ),
        ),
      ],
    );
  }

  /// Build rating stars display
  Widget _buildRatingStars() {
    return Row(
      children: [
        ...List.generate(
          5,
          (index) => Icon(
            index < mechanic.rating.floor()
                ? LucideIcons.star
                : LucideIcons.star,
            color: index < mechanic.rating.floor()
                ? AppTheme.accentYellow
                : AppTheme.borderColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          mechanic.rating.toStringAsFixed(1),
          style: AppTheme.figtreeSemiBold.copyWith(
            fontSize: AppTheme.fontSize15,
            color: AppTheme.onSurfaceColor,
          ),
        ),
      ],
    );
  }

  /// Build contact information row
  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.phone, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mechanic.phoneNumber!,
              style: AppTheme.figtreeMedium.copyWith(
                fontSize: AppTheme.fontSize15,
              ),
            ),
          ),
          GestureDetector(
            onTap: onCall,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                LucideIcons.phone_call,
                color: AppTheme.successColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build ETA information row
  Widget _buildETAInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryColor.withAlpha(40)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.clock, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            'ETA: ${mechanic.formattedETA}',
            style: AppTheme.figtreeSemiBold.copyWith(
              fontSize: AppTheme.fontSize15,
              color: AppTheme.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  /// Build select button
  Widget _buildSelectButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          onSelect?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Select This Mechanic',
              style: AppTheme.buttonMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.arrow_right, size: 20),
          ],
        ),
      ),
    );
  }
}
