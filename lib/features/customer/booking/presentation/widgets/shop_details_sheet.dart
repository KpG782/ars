/// Shop Details Sheet - Bottom sheet for shop information
///
/// Displays detailed information about a mechanic shop including
/// services, operating hours, contact info, and selection options.
library;

import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/models/mechanic_shop.dart';

/// Shows a bottom sheet with shop details
class ShopDetailsSheet extends StatelessWidget {
  final MechanicShop shop;
  final LatLng customerLocation;
  final VoidCallback? onSelect;

  const ShopDetailsSheet({
    super.key,
    required this.shop,
    required this.customerLocation,
    this.onSelect,
  });

  /// Show the shop details as a modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    required MechanicShop shop,
    required LatLng customerLocation,
    VoidCallback? onSelect,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ShopDetailsSheet(
          shop: shop,
          customerLocation: customerLocation,
          onSelect: onSelect,
        )._buildScrollableContent(scrollController),
      ),
    );
  }

  Widget _buildScrollableContent(ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHandle(),
            _buildHeader(),
            const SizedBox(height: 16),
            _buildStatusBadge(),
            const SizedBox(height: 20),
            _buildInfoCards(),
            const SizedBox(height: 20),
            if (shop.description != null) _buildDescription(),
            _buildServicesSection(),
            const SizedBox(height: 20),
            _buildContactSection(),
            const SizedBox(height: 24),
            Builder(builder: (context) => _buildActionSection(context)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Use static show method
  }

  /// Build drag handle
  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppTheme.grey300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  /// Build shop header with name and rating
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                shop.shopName,
                style: const TextStyle(
                  fontSize: AppTheme.fontSize22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (shop.isPartner) _buildPartnerBadge(),
          ],
        ),
        const SizedBox(height: 8),
        _buildRatingRow(),
      ],
    );
  }

  /// Build partner badge
  Widget _buildPartnerBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'PARTNER',
        style: TextStyle(
          color: Colors.white,
          fontSize: AppTheme.fontSize10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Build rating row with stars
  Widget _buildRatingRow() {
    return Row(
      children: [
        ...List.generate(
          5,
          (index) => Icon(
            index < shop.rating.floor() ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${shop.rating.toStringAsFixed(1)} (${shop.totalReviews} reviews)',
          style: const TextStyle(
            fontSize: AppTheme.fontSize14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Build open/closed status badge
  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: shop.isOpen ? AppTheme.green50 : AppTheme.red50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: shop.isOpen ? AppTheme.green : AppTheme.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            shop.isOpen ? Icons.check_circle : Icons.cancel,
            color: shop.isOpen ? AppTheme.green : AppTheme.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            shop.isOpen ? 'Open Now' : 'Closed',
            style: TextStyle(
              color: shop.isOpen ? AppTheme.green : AppTheme.red,
              fontWeight: FontWeight.bold,
              fontSize: AppTheme.fontSize14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            shop.getTodayHours(),
            style: TextStyle(
              color: shop.isOpen ? AppTheme.green700 : AppTheme.red700,
              fontSize: AppTheme.fontSize12,
            ),
          ),
        ],
      ),
    );
  }

  /// Build distance and price info cards
  Widget _buildInfoCards() {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            icon: Icons.location_on,
            title: 'Distance',
            value: shop.getDistanceString(customerLocation),
            color: AppTheme.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            icon: Icons.attach_money,
            title: 'Price Range',
            value: shop.priceRange,
            color: AppTheme.green,
          ),
        ),
      ],
    );
  }

  /// Build description section
  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontSize: AppTheme.fontSize16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          shop.description!,
          style: const TextStyle(
            fontSize: AppTheme.fontSize14,
            color: AppTheme.grey700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  /// Build services section
  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services Offered',
          style: TextStyle(
            fontSize: AppTheme.fontSize16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: shop.services.map((service) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                service,
                style: const TextStyle(
                  fontSize: AppTheme.fontSize12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryColor,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build contact section
  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactRow(Icons.location_on, shop.address),
          const SizedBox(height: 8),
          _buildContactRow(Icons.phone, shop.phoneNumber),
          if (shop.owner != null) ...[
            const SizedBox(height: 8),
            _buildContactRow(Icons.person, 'Owner: ${shop.owner}'),
          ],
        ],
      ),
    );
  }

  /// Build contact row
  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: AppTheme.fontSize13),
          ),
        ),
      ],
    );
  }

  /// Build action section (select button or unavailable notice)
  Widget _buildActionSection(BuildContext context) {
    if (shop.isPartner && shop.isOpen) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onSelect?.call();
              },
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text(
                'Request Service from This Shop',
                style: TextStyle(
                  fontSize: AppTheme.fontSize16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.orange50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.orange),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.orange),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  shop.isPartner
                      ? 'This shop is currently closed. Check back during operating hours.'
                      : 'This shop is not yet partnered with us. You can view details but cannot request services.',
                  style: const TextStyle(fontSize: AppTheme.fontSize13),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
      ],
    );
  }
}

/// Helper widget for info cards
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: AppTheme.fontSize11,
              color: AppTheme.grey600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: AppTheme.fontSize14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
