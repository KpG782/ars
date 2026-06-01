import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'dart:io';
import '../../domain/models/service_request.dart';

class CompletionSummaryScreen extends StatelessWidget {
  final ServiceRequest serviceRequest;
  final Duration workDuration;
  final List<String> workPhotos;
  final String mechanicNotes;
  final VoidCallback onConfirm;

  const CompletionSummaryScreen({
    super.key,
    required this.serviceRequest,
    required this.workDuration,
    required this.workPhotos,
    required this.mechanicNotes,
    required this.onConfirm,
  });

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '$hours hr $minutes min';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final actualPrice =
        serviceRequest.actualPrice ?? serviceRequest.estimatedPrice;
    final tipAmount = serviceRequest.tipAmount;
    final platformFee = actualPrice * 0.15;
    final mechanicEarnings = actualPrice - platformFee + tipAmount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrow_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Service Completion Summary',
          style: AppTheme.figtreeBold.copyWith(
            color: Colors.white,
            fontSize: AppTheme.fontSize18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.check,
                      color: AppTheme.primaryColor,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Service Completed!',
                    style: TextStyle(
                      fontSize: AppTheme.fontSize24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Great job! You earned ₱${mechanicEarnings.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: AppTheme.fontSize16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Service Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Service Details',
                    style: TextStyle(
                      fontSize: AppTheme.fontSize18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: LucideIcons.user,
                          label: 'Customer',
                          value: serviceRequest.customerName,
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: LucideIcons.wrench,
                          label: 'Service',
                          value: serviceRequest.serviceType,
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: LucideIcons.timer,
                          label: 'Duration',
                          value: _formatDuration(workDuration),
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: LucideIcons.calendar,
                          label: 'Completed',
                          value: _formatDateTime(DateTime.now()),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Work Photos
                  if (workPhotos.isNotEmpty) ...[
                    const Text(
                      'Work Photos',
                      style: TextStyle(
                        fontSize: AppTheme.fontSize18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: workPhotos.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.grey300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(workPhotos[index]),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppTheme.grey200,
                                    child: const Center(
                                      child: Icon(Icons.image_not_supported),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Mechanic Notes
                  if (mechanicNotes.isNotEmpty) ...[
                    const Text(
                      'Work Notes',
                      style: TextStyle(
                        fontSize: AppTheme.fontSize18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.grey300),
                      ),
                      child: Text(
                        mechanicNotes,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSize14,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Earnings Breakdown
                  const Text(
                    'Earnings Breakdown',
                    style: TextStyle(
                      fontSize: AppTheme.fontSize18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _PriceRow(
                          label: 'Service Price',
                          amount: actualPrice,
                          isSubtotal: true,
                        ),
                        const SizedBox(height: 12),
                        _PriceRow(
                          label: 'Platform Fee (15%)',
                          amount: -platformFee,
                          color: AppTheme.red,
                          isSubtotal: true,
                        ),
                        if (tipAmount > 0) ...[
                          const SizedBox(height: 12),
                          _PriceRow(
                            label: 'Tip from Customer',
                            amount: tipAmount,
                            color: AppTheme.green,
                            isSubtotal: true,
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        _PriceRow(
                          label: 'Your Earnings',
                          amount: mechanicEarnings,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Customer Rating (placeholder)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.star, color: Colors.amber, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Waiting for Customer Rating',
                                style: TextStyle(
                                  fontSize: AppTheme.fontSize14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Customer will rate your service soon',
                                style: TextStyle(
                                  fontSize: AppTheme.fontSize12,
                                  color: AppTheme.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              // Pop back to dashboard and trigger reset to available state
              Navigator.of(context).popUntil((route) => route.isFirst);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Back to Dashboard',
              style: TextStyle(
                fontSize: AppTheme.fontSize16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    return '$day/$month/$year at $hour:$minute';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: AppTheme.fontSize12,
                  color: AppTheme.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: AppTheme.fontSize15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color? color;
  final bool isBold;
  final bool isSubtotal;

  const _PriceRow({
    required this.label,
    required this.amount,
    this.color,
    this.isBold = false,
    this.isSubtotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black87,
          ),
        ),
        Text(
          '${amount >= 0 ? '+' : ''}₱${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isBold ? 20 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? (isBold ? AppTheme.primaryColor : Colors.black87),
          ),
        ),
      ],
    );
  }
}
