import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String mechanicName;
  final String serviceName;
  final String location;
  final double amount;
  final String notes;
  final double tipAmount;
  final double discount;
  final String? appliedPromoCode;
  final double subtotal;
  final double serviceFee;

  const PaymentScreen({
    super.key,
    required this.mechanicName,
    required this.serviceName,
    required this.location,
    required this.amount,
    required this.notes,
    required this.tipAmount,
    required this.discount,
    this.appliedPromoCode,
    required this.subtotal,
    required this.serviceFee,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'Cash';
  bool _isProcessing = false;

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      name: 'Cash',
      icon: LucideIcons.banknote,
      description: 'Pay with cash on completion',
    ),
    PaymentMethod(
      name: 'GCash',
      icon: LucideIcons.smartphone,
      description: 'Pay via GCash mobile wallet',
    ),
    PaymentMethod(
      name: 'Credit Card',
      icon: LucideIcons.credit_card,
      description: 'Pay with credit/debit card',
    ),
    PaymentMethod(
      name: 'PayMaya',
      icon: LucideIcons.wallet,
      description: 'Pay via PayMaya digital wallet',
    ),
  ];

  void _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            amount: widget.amount,
            paymentMethod: _selectedPaymentMethod,
            mechanicName: widget.mechanicName,
            serviceName: widget.serviceName,
          ),
        ),
      );
    }
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
          'Select Payment Method',
          style: AppTheme.figtreeBold.copyWith(
            color: AppTheme.onSurfaceColor,
            fontSize: AppTheme.fontSize18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Amount Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withAlpha(60),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total Amount to Pay',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: AppTheme.fontSize14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₱${widget.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppTheme.fontSize40,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _PriceRow(
                                label: 'Service Fee',
                                amount: widget.subtotal,
                                isWhite: true,
                              ),
                              const SizedBox(height: 6),
                              _PriceRow(
                                label: 'Platform Fee',
                                amount: widget.serviceFee,
                                isWhite: true,
                              ),
                              if (widget.tipAmount > 0) ...[
                                const SizedBox(height: 6),
                                _PriceRow(
                                  label: 'Tip',
                                  amount: widget.tipAmount,
                                  isWhite: true,
                                ),
                              ],
                              if (widget.discount > 0) ...[
                                const SizedBox(height: 6),
                                _PriceRow(
                                  label:
                                      'Discount (${widget.appliedPromoCode})',
                                  amount: -widget.discount,
                                  isWhite: true,
                                  isDiscount: true,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Payment Methods Section
                  Text(
                    'Choose Payment Method',
                    style: AppTheme.figtreeBold.copyWith(
                      fontSize: AppTheme.fontSize18,
                      color: AppTheme.onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select how you want to pay',
                    style: AppTheme.figtreeRegular.copyWith(
                      fontSize: AppTheme.fontSize14,
                      color: AppTheme.subtitleColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Payment Method Tiles
                  ..._paymentMethods.map(
                    (method) => _PaymentMethodTile(
                      method: method,
                      isSelected: _selectedPaymentMethod == method.name,
                      onTap: () {
                        setState(() {
                          _selectedPaymentMethod = method.name;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Notes Display (if any)
                  if (widget.notes.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.blue50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.blue200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.note_alt_outlined,
                                size: 18,
                                color: AppTheme.blue700,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Your Note:',
                                style: TextStyle(
                                  fontSize: AppTheme.fontSize13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.blue700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.notes,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSize14,
                              color: AppTheme.grey800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Pay Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                onPressed: _isProcessing ? null : _processPayment,
                child: _isProcessing
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
                            'Processing Payment...',
                            style: TextStyle(
                              fontSize: AppTheme.fontSize16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.lock,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pay ₱${widget.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSize18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isWhite;
  final bool isDiscount;

  const _PriceRow({
    required this.label,
    required this.amount,
    this.isWhite = false,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isWhite ? Colors.white70 : AppTheme.grey600,
            fontSize: AppTheme.fontSize13,
          ),
        ),
        Text(
          '${amount < 0 ? '-' : ''}₱${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            color: isWhite
                ? (isDiscount ? AppTheme.green50 : Colors.white)
                : Colors.black87,
            fontSize: AppTheme.fontSize14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.grey300,
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppTheme.primaryColor.withAlpha(40),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withAlpha(30)
                      : AppTheme.grey100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  method.icon,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.grey600,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: TextStyle(
                        fontSize: AppTheme.fontSize17,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.description,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSize13,
                        color: AppTheme.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.grey400,
                    width: 2,
                  ),
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentMethod {
  final String name;
  final IconData icon;
  final String description;

  PaymentMethod({
    required this.name,
    required this.icon,
    required this.description,
  });
}
