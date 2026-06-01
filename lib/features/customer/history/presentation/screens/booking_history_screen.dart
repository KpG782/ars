import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Booking History',
          style: AppTheme.figtreeBold.copyWith(
            color: AppTheme.onSurfaceColor,
            fontSize: AppTheme.fontSize18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.onSurfaceColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHistoryCard(
            context,
            serviceType: 'Tire Problem',
            subService: 'Flat Tire Repair',
            mechanicName: 'Juan Dela Cruz',
            date: DateTime.now().subtract(const Duration(days: 2)),
            status: 'Completed',
            amount: '₱500.00',
            rating: 4.8,
          ),
          _buildHistoryCard(
            context,
            serviceType: 'Engine Problems',
            subService: 'Engine Overheating',
            mechanicName: 'Pedro Santos',
            date: DateTime.now().subtract(const Duration(days: 7)),
            status: 'Completed',
            amount: '₱1,200.00',
            rating: 4.9,
          ),
          _buildHistoryCard(
            context,
            serviceType: 'Brake Problem',
            subService: 'Brake Pads Replacement',
            mechanicName: 'Maria Lopez',
            date: DateTime.now().subtract(const Duration(days: 14)),
            status: 'Completed',
            amount: '₱800.00',
            rating: 4.7,
          ),
          _buildHistoryCard(
            context,
            serviceType: 'Tire Problem',
            subService: 'Tire Rotation',
            mechanicName: 'Jose Garcia',
            date: DateTime.now().subtract(const Duration(days: 21)),
            status: 'Cancelled',
            amount: '₱300.00',
            rating: null,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context, {
    required String serviceType,
    required String subService,
    required String mechanicName,
    required DateTime date,
    required String status,
    required String amount,
    double? rating,
  }) {
    final statusColor = status == 'Completed'
        ? AppTheme.green
        : status == 'Cancelled'
        ? AppTheme.red
        : AppTheme.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _showBookingDetails(
            context,
            serviceType,
            subService,
            mechanicName,
            date,
            status,
            amount,
            rating,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceType,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSize18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurfaceColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subService,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSize14,
                            color: AppTheme.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: AppTheme.fontSize12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(LucideIcons.user, size: 18, color: AppTheme.grey),
                  const SizedBox(width: 8),
                  Text(
                    mechanicName,
                    style: const TextStyle(fontSize: AppTheme.fontSize14),
                  ),
                  if (rating != null) ...[
                    const Spacer(),
                    const Icon(LucideIcons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: AppTheme.fontSize14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    LucideIcons.calendar,
                    size: 18,
                    color: AppTheme.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy - hh:mm a').format(date),
                    style: const TextStyle(
                      fontSize: AppTheme.fontSize14,
                      color: AppTheme.grey600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    LucideIcons.wallet,
                    size: 18,
                    color: AppTheme.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSize16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDetails(
    BuildContext context,
    String serviceType,
    String subService,
    String mechanicName,
    DateTime date,
    String status,
    String amount,
    double? rating,
  ) {
    showModalBottomSheet(
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
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Booking Details',
                style: TextStyle(
                  fontSize: AppTheme.fontSize24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Service', serviceType),
              _buildDetailRow('Sub-Service', subService),
              _buildDetailRow('Mechanic', mechanicName),
              _buildDetailRow(
                'Date & Time',
                DateFormat('MMM dd, yyyy - hh:mm a').format(date),
              ),
              _buildDetailRow('Status', status),
              _buildDetailRow('Amount', amount),
              if (rating != null)
                _buildDetailRow('Rating', '⭐ ${rating.toStringAsFixed(1)}'),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: AppTheme.fontSize16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Quezon City, Metro Manila',
                style: TextStyle(
                  fontSize: AppTheme.fontSize14,
                  color: AppTheme.grey600,
                ),
              ),
              const SizedBox(height: 20),
              if (status == 'Completed' && rating == null)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rate mechanic feature coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.star),
                  label: const Text('Rate This Service'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.fontSize14,
                color: AppTheme.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: AppTheme.fontSize14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
