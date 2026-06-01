import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'payment_screen.dart';
import 'package:arsapplication/core/utils/toast_helper.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final String mechanicName;
  final String serviceName;
  final String location;
  final double amount;

  const PaymentDetailsScreen({
    super.key,
    required this.mechanicName,
    required this.serviceName,
    required this.location,
    required this.amount,
  });

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _promoCodeController = TextEditingController();

  double _tipAmount = 0;
  double _discount = 0;
  String? _appliedPromoCode;

  double get _subtotal => widget.amount;
  double get _serviceFee => _subtotal * 0.10;
  double get _totalAmount => _subtotal + _serviceFee + _tipAmount - _discount;

  void _applyPromoCode() {
    final code = _promoCodeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      _showMessage('Please enter a promo code', isError: true);
      return;
    }

    // Validate promo codes
    if (code == 'ARS50') {
      setState(() {
        _discount = 50;
        _appliedPromoCode = code;
      });
      _showMessage('Promo code applied! ₱50 discount', isError: false);
      _promoCodeController.clear();
    } else if (code == 'FIRST20') {
      setState(() {
        _discount = (_subtotal + _serviceFee) * 0.20;
        _appliedPromoCode = code;
      });
      _showMessage('Promo code applied! 20% discount', isError: false);
      _promoCodeController.clear();
    } else {
      _showMessage('Invalid promo code', isError: true);
    }
  }

  void _removePromoCode() {
    setState(() {
      _discount = 0;
      _appliedPromoCode = null;
    });
    _showMessage('Promo code removed', isError: false);
  }

  void _showMessage(String message, {required bool isError}) {
    if (isError) {
      ToastHelper.showError(
        context,
        message,
        duration: const Duration(seconds: 2),
      );
    } else {
      ToastHelper.showSuccess(
        context,
        message,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _continueToPaymentMethod() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          mechanicName: widget.mechanicName,
          serviceName: widget.serviceName,
          location: widget.location,
          amount: _totalAmount,
          notes: _notesController.text.trim(),
          tipAmount: _tipAmount,
          discount: _discount,
          appliedPromoCode: _appliedPromoCode,
          subtotal: _subtotal,
          serviceFee: _serviceFee,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.arrow_left,
            color: AppTheme.onSurfaceColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment Details',
          style: AppTheme.figtreeBold.copyWith(
            color: AppTheme.onSurfaceColor,
            fontSize: AppTheme.fontSize18,
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
              // Service Summary Card
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
                    _SummaryRow(
                      icon: LucideIcons.user,
                      label: 'Mechanic',
                      value: widget.mechanicName,
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      icon: LucideIcons.wrench,
                      label: 'Service',
                      value: widget.serviceName,
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      icon: LucideIcons.map_pin,
                      label: 'Location',
                      value: widget.location,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Price Breakdown Card
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
                      'Price Breakdown',
                      style: TextStyle(
                        fontSize: AppTheme.fontSize18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Base Service Fee:',
                          style: TextStyle(
                            color: AppTheme.grey,
                            fontSize: AppTheme.fontSize15,
                          ),
                        ),
                        Text(
                          '₱${_subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSize16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Platform Fee (10%):',
                          style: TextStyle(
                            color: AppTheme.grey,
                            fontSize: AppTheme.fontSize15,
                          ),
                        ),
                        Text(
                          '₱${_serviceFee.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSize16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    if (_tipAmount > 0) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tip for Mechanic:',
                            style: TextStyle(
                              color: AppTheme.grey,
                              fontSize: AppTheme.fontSize15,
                            ),
                          ),
                          Text(
                            '₱${_tipAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSize16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (_discount > 0) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Discount ($_appliedPromoCode):',
                            style: const TextStyle(
                              color: AppTheme.green,
                              fontSize: AppTheme.fontSize15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '-₱${_discount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSize16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.green,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),
                    const Divider(thickness: 1.5),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontSize: AppTheme.fontSize18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₱${_totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSize22,
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

              // Tip Section
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
                          LucideIcons.heart,
                          color: AppTheme.primaryColor,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Add a Tip (Optional)',
                          style: TextStyle(
                            fontSize: AppTheme.fontSize16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Show appreciation for excellent service',
                      style: TextStyle(
                        fontSize: AppTheme.fontSize13,
                        color: AppTheme.grey600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _TipButton(
                          amount: 20,
                          isSelected: _tipAmount == 20,
                          onTap: () => setState(() => _tipAmount = 20),
                        ),
                        const SizedBox(width: 8),
                        _TipButton(
                          amount: 50,
                          isSelected: _tipAmount == 50,
                          onTap: () => setState(() => _tipAmount = 50),
                        ),
                        const SizedBox(width: 8),
                        _TipButton(
                          amount: 100,
                          isSelected: _tipAmount == 100,
                          onTap: () => setState(() => _tipAmount = 100),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _tipAmount = 0),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: _tipAmount == 0
                                    ? AppTheme.primaryColor
                                    : AppTheme.grey300,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'No Tip',
                              style: TextStyle(
                                fontSize: AppTheme.fontSize13,
                                fontWeight: FontWeight.w600,
                                color: _tipAmount == 0
                                    ? AppTheme.primaryColor
                                    : AppTheme.grey600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Promo Code Section
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
                          LucideIcons.tag,
                          color: AppTheme.primaryColor,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Promo Code',
                          style: TextStyle(
                            fontSize: AppTheme.fontSize16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_appliedPromoCode != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.green),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppTheme.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Code "$_appliedPromoCode" applied',
                                style: const TextStyle(
                                  color: AppTheme.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _removePromoCode,
                              icon: const Icon(Icons.close, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _promoCodeController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: 'Enter code (e.g., ARS50)',
                                hintStyle: const TextStyle(
                                  color: AppTheme.grey400,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppTheme.grey300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppTheme.grey300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppTheme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _applyPromoCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Apply',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Notes Section
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
                          LucideIcons.file_text,
                          color: AppTheme.primaryColor,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Additional Notes (Optional)',
                          style: TextStyle(
                            fontSize: AppTheme.fontSize16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Any special instructions or feedback',
                      style: TextStyle(
                        fontSize: AppTheme.fontSize13,
                        color: AppTheme.grey600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      maxLength: 200,
                      decoration: InputDecoration(
                        hintText:
                            'e.g., Please call when you arrive, Parts needed replaced...',
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

              const SizedBox(height: 32),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continueToPaymentMethod,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue to Payment  •  ₱${_totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: AppTheme.fontSize17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        LucideIcons.arrow_right,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
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
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final int maxLines;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
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

class _TipButton extends StatelessWidget {
  final double amount;
  final bool isSelected;
  final VoidCallback onTap;

  const _TipButton({
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.grey300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            '₱${amount.toInt()}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTheme.fontSize14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
