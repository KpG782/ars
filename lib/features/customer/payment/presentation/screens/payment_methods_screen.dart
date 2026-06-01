import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:arsapplication/core/utils/toast_helper.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'type': 'Cash',
      'icon': LucideIcons.banknote,
      'color': AppTheme.green,
      'default': true,
    },
    {
      'type': 'GCash',
      'number': '0917-XXX-4567',
      'icon': LucideIcons.wallet,
      'color': AppTheme.blue,
      'default': false,
    },
    {
      'type': 'Credit Card',
      'number': '•••• •••• •••• 1234',
      'expiry': '12/25',
      'icon': LucideIcons.credit_card,
      'color': Colors.purple,
      'default': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Payment Methods',
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
          ..._paymentMethods.map((method) => _buildPaymentCard(method)),
          const SizedBox(height: 16),
          _buildAddPaymentButton(),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> method) {
    final isDefault = method['default'] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDefault
            ? const BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: (method['color'] as Color).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            method['icon'] as IconData,
            color: method['color'] as Color,
            size: 28,
          ),
        ),
        title: Row(
          children: [
            Text(
              method['type'] as String,
              style: const TextStyle(
                fontSize: AppTheme.fontSize16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTheme.fontSize10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: method['number'] != null
            ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['number'] as String,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSize14,
                        color: AppTheme.grey600,
                      ),
                    ),
                    if (method['expiry'] != null)
                      Text(
                        'Expires: ${method['expiry']}',
                        style: const TextStyle(
                          fontSize: AppTheme.fontSize12,
                          color: AppTheme.grey500,
                        ),
                      ),
                  ],
                ),
              )
            : null,
        trailing: PopupMenuButton<String>(
          icon: const Icon(LucideIcons.ellipsis_vertical),
          onSelected: (value) {
            if (value == 'default' && !isDefault) {
              _setAsDefault(method);
            } else if (value == 'delete' && method['type'] != 'Cash') {
              _showDeleteConfirmation(method);
            }
          },
          itemBuilder: (context) => [
            if (!isDefault)
              const PopupMenuItem(
                value: 'default',
                child: Row(
                  children: [
                    Icon(LucideIcons.circle_check, size: 20),
                    SizedBox(width: 12),
                    Text('Set as Default'),
                  ],
                ),
              ),
            if (method['type'] != 'Cash')
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(LucideIcons.trash_2, size: 20, color: AppTheme.red),
                    SizedBox(width: 12),
                    Text('Remove', style: TextStyle(color: AppTheme.red)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPaymentButton() {
    return InkWell(
      onTap: () => _showAddPaymentDialog(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.circle_plus,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              'Add Payment Method',
              style: TextStyle(
                fontSize: AppTheme.fontSize16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Payment Method',
              style: TextStyle(
                fontSize: AppTheme.fontSize20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(LucideIcons.wallet, color: AppTheme.blue),
              title: const Text('GCash'),
              trailing: const Icon(LucideIcons.chevron_right, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showGCashForm();
              },
            ),
            ListTile(
              leading: const Icon(
                LucideIcons.credit_card,
                color: Colors.purple,
              ),
              title: const Text('Credit/Debit Card'),
              trailing: const Icon(LucideIcons.chevron_right, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showCardForm();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showGCashForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link GCash Account'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                hintText: '09XX XXX XXXX',
                border: OutlineInputBorder(),
                prefixIcon: Icon(LucideIcons.phone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ToastHelper.showSuccess(
                context,
                'GCash account linked successfully!',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Link Account'),
          ),
        ],
      ),
    );
  }

  void _showCardForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Card'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(LucideIcons.credit_card),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Cardholder Name',
                  hintText: 'JUAN DELA CRUZ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(LucideIcons.user),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Expiry',
                        hintText: 'MM/YY',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ToastHelper.showSuccess(context, 'Card added successfully!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Add Card'),
          ),
        ],
      ),
    );
  }

  void _setAsDefault(Map<String, dynamic> method) {
    setState(() {
      for (var m in _paymentMethods) {
        m['default'] = false;
      }
      method['default'] = true;
    });
    ToastHelper.showSuccess(
      context,
      '${method['type']} set as default payment method',
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Payment Method'),
        content: Text('Are you sure you want to remove ${method['type']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _paymentMethods.remove(method);
              });
              Navigator.pop(context);
              ToastHelper.showError(context, 'Payment method removed');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
