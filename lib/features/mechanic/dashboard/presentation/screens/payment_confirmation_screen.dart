import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:arsapplication/core/theme/app_theme.dart';
import '../../domain/models/service_request.dart';
import 'completion_summary_screen.dart';
import 'package:arsapplication/core/utils/toast_helper.dart';

class MechanicPaymentConfirmationScreen extends StatefulWidget {
  final ServiceRequest serviceRequest;
  final VoidCallback onConfirm;

  const MechanicPaymentConfirmationScreen({
    super.key,
    required this.serviceRequest,
    required this.onConfirm,
  });

  @override
  State<MechanicPaymentConfirmationScreen> createState() =>
      _MechanicPaymentConfirmationScreenState();
}

class _MechanicPaymentConfirmationScreenState
    extends State<MechanicPaymentConfirmationScreen> {
  late TextEditingController _notesController;
  bool _isConfirming = false;
  final List<String> _workPhotos = [];
  final ImagePicker _imagePicker = ImagePicker();
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text: widget.serviceRequest.mechanicNotes ?? '',
    );
    _startTime = DateTime.now().subtract(
      const Duration(minutes: 30),
    ); // Simulated start time
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _workPhotos.add(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Failed to pick image: $e');
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _workPhotos.removeAt(index);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _confirmCompletion() async {
    setState(() => _isConfirming = true);

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isConfirming = false);

      // Navigate to completion summary
      final workDuration = DateTime.now().difference(_startTime!);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CompletionSummaryScreen(
            serviceRequest: widget.serviceRequest,
            workDuration: workDuration,
            workPhotos: _workPhotos,
            mechanicNotes: _notesController.text.trim(),
            onConfirm: () {
              widget.onConfirm();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.serviceRequest;
    final basePrice = service.actualPrice ?? service.estimatedPrice;
    final platformFee = service.platformFee;
    final tipAmount = service.tipAmount;
    final totalEarnings = service.mechanicEarnings;

    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrow_left, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Service Complete',
          style: TextStyle(
            color: Colors.black87,
            fontSize: AppTheme.fontSize18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Success Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.circle_check_big,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Service Completed!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTheme.fontSize24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Great work! Review your earnings below.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: AppTheme.fontSize14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Customer & Service Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Service Summary',
                      style: TextStyle(
                        fontSize: AppTheme.fontSize18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      label: 'Customer',
                      value: service.customerName,
                      icon: LucideIcons.user,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Service Type',
                      value: service.serviceType,
                      icon: LucideIcons.wrench,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Duration',
                      value: _calculateDuration(service),
                      icon: LucideIcons.timer,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Earnings Breakdown
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Earnings Breakdown',
                      style: TextStyle(
                        fontSize: AppTheme.fontSize18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _EarningsRow(
                      label: 'Service Price',
                      amount: basePrice,
                      isBase: true,
                    ),
                    const SizedBox(height: 12),
                    _EarningsRow(
                      label: 'Platform Fee (15%)',
                      amount: -platformFee,
                      isDeduction: true,
                    ),
                    if (tipAmount > 0) ...[
                      const SizedBox(height: 12),
                      _EarningsRow(
                        label: 'Customer Tip 💚',
                        amount: tipAmount,
                        isBonus: true,
                      ),
                    ],
                    if (service.discountApplied > 0) ...[
                      const SizedBox(height: 12),
                      _EarningsRow(
                        label: 'Your Share of Discount',
                        amount: -(service.discountApplied * 0.5),
                        isDeduction: true,
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Divider(thickness: 1.5),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'You Earn:',
                          style: TextStyle(
                            fontSize: AppTheme.fontSize18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₱${totalEarnings.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSize24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Work Notes
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          LucideIcons.notebook_pen,
                          color: AppTheme.primaryColor,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Work Notes (Optional)',
                          style: TextStyle(
                            fontSize: AppTheme.fontSize16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Describe what you did and any observations',
                      style: TextStyle(
                        fontSize: AppTheme.fontSize13,
                        color: AppTheme.grey600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      maxLength: 300,
                      decoration: InputDecoration(
                        hintText:
                            'e.g., Replaced spark plugs, checked battery...',
                        hintStyle: const TextStyle(
                          color: AppTheme.grey400,
                          fontSize: AppTheme.fontSize14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.grey300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.grey300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Work Photos
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          LucideIcons.camera,
                          color: AppTheme.primaryColor,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Work Photos (Optional)',
                          style: TextStyle(
                            fontSize: AppTheme.fontSize16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Add photos of completed work',
                      style: TextStyle(
                        fontSize: AppTheme.fontSize13,
                        color: AppTheme.grey600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Photos Grid
                    if (_workPhotos.isNotEmpty)
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ..._workPhotos.asMap().entries.map((entry) {
                            final index = entry.key;
                            final photoPath = entry.value;
                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.grey300),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(photoPath),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removePhoto(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),

                          // Add Photo Button
                          if (_workPhotos.length < 6)
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => SafeArea(
                                    child: Wrap(
                                      children: [
                                        ListTile(
                                          leading: const Icon(
                                            LucideIcons.camera,
                                          ),
                                          title: const Text('Take Photo'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _pickImage(ImageSource.camera);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(
                                            LucideIcons.image,
                                          ),
                                          title: const Text(
                                            'Choose from Gallery',
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _pickImage(ImageSource.gallery);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primaryColor,
                                    width: 2,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.image_plus,
                                      color: AppTheme.primaryColor,
                                      size: 32,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Add Photo',
                                      style: TextStyle(
                                        fontSize: AppTheme.fontSize11,
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      )
                    else
                      // Empty state
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => SafeArea(
                              child: Wrap(
                                children: [
                                  ListTile(
                                    leading: const Icon(LucideIcons.camera),
                                    title: const Text('Take Photo'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImage(ImageSource.camera);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(LucideIcons.image),
                                    title: const Text('Choose from Gallery'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImage(ImageSource.gallery);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          decoration: BoxDecoration(
                            color: AppTheme.grey50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.grey300,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                LucideIcons.image_plus,
                                color: AppTheme.grey400,
                                size: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to add photos',
                                style: TextStyle(
                                  fontSize: AppTheme.fontSize14,
                                  color: AppTheme.grey600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Customer Rating (if available)
              if (service.customerRating != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(LucideIcons.star, color: Colors.amber, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Customer Rating',
                            style: TextStyle(
                              fontSize: AppTheme.fontSize16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) => Icon(
                              index < (service.customerRating ?? 0).floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${service.customerRating?.toStringAsFixed(1) ?? 'N/A'} / 5.0',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSize16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (service.customerReview != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          service.customerReview!,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSize14,
                            color: AppTheme.grey700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isConfirming ? null : _confirmCompletion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isConfirming
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Processing...',
                              style: TextStyle(
                                fontSize: AppTheme.fontSize16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Confirm & Receive ₱${totalEarnings.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSize16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateDuration(ServiceRequest service) {
    if (service.completionTime == null) return 'In progress';
    final minutes = service.completionTime!
        .difference(service.requestTime)
        .inMinutes;
    if (minutes < 60) return '$minutes minutes';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours hr ${mins}m';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.grey600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: AppTheme.fontSize13,
                  color: AppTheme.grey600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: AppTheme.fontSize15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EarningsRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isBase;
  final bool isDeduction;
  final bool isBonus;

  const _EarningsRow({
    required this.label,
    required this.amount,
    this.isBase = false,
    this.isDeduction = false,
    this.isBonus = false,
  });

  @override
  Widget build(BuildContext context) {
    Color amountColor = Colors.black87;
    if (isBonus) amountColor = AppTheme.green;
    if (isDeduction) amountColor = AppTheme.red;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppTheme.fontSize15,
            fontWeight: isBase ? FontWeight.w600 : FontWeight.w500,
            color: AppTheme.grey700,
          ),
        ),
        Text(
          '${amount < 0 ? '-' : '+'}₱${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: AppTheme.fontSize15,
            fontWeight: FontWeight.w600,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}
