# 💳 PayMongo Payment Integration for ARS

Excellent choice! PayMongo is **perfect for Philippines market** (GCash, GrabPay, Maya, QR Ph, Cards). Let me design the complete payment flow for your ARS application.

---

## 🎯 PAYMENT FLOW STRATEGY

### **Understanding Payment Types in ARS:**

**1. Upfront Payment (BEFORE service)**

- Customer pays when booking
- Mechanic gets job after payment confirmed
- Risk: Customer pays but mechanic doesn't come

**2. Pay After Service (TRADITIONAL)**

- Mechanic completes job
- Customer pays cash on-site
- Risk: Customer doesn't pay

**3. Hold-Then-Capture (BEST for ARS)** ⭐ **RECOMMENDED**

- Customer authorizes payment when booking
- Money is HELD (not charged yet)
- Mechanic completes service
- Money is CAPTURED (charged) after completion
- If cancelled: money is RELEASED back to customer

---

## 🏆 RECOMMENDED PAYMENT FLOW: "Hold-Then-Capture"

### **Why This is BEST for Emergency Services:**

```
1. Customer requests emergency help
   ↓
2. ARS shows estimated cost: ₱500-800
   ↓
3. Customer authorizes payment (Hold ₱800)
   💰 Money is RESERVED but NOT charged
   ↓
4. Mechanic accepts & provides service
   ↓
5. Mechanic completes, actual cost: ₱650
   💰 Charge ₱650, Release ₱150 back
   ↓
6. Customer rates mechanic
   ✅ Payment complete
```

**Benefits:**

- ✅ **Customer trust:** Not charged until service done
- ✅ **Mechanic security:** Payment guaranteed
- ✅ **Flexible pricing:** Actual cost may differ from estimate
- ✅ **No-show protection:** Hold prevents fake bookings

---

## 💰 PayMongo Payment Methods Recommendation

### **For Philippines Market:**

| Method      | Use Case              | Customer Experience   | Fees             |
| ----------- | --------------------- | --------------------- | ---------------- |
| **GCash**   | Most popular e-wallet | Scan QR or enter PIN  | 2.5%             |
| **Maya**    | Second most popular   | Scan QR or enter PIN  | 2.5%             |
| **GrabPay** | For Grab users        | One-tap payment       | 2.5%             |
| **QR Ph**   | Universal QR          | Any bank app          | 0.5% (cheapest!) |
| **Cards**   | For tourists/expats   | Visa/Mastercard       | 3.5%             |
| **Cash**    | Traditional           | Pay mechanic directly | 0% (free)        |

**Recommendation:**

- ✅ **GCash** (must-have - 60% market share)
- ✅ **Maya** (must-have - 25% market share)
- ✅ **QR Ph** (cheapest fees!)
- ✅ **Cards** (for expats/tourists)
- ⚠️ **GrabPay** (optional - small market)
- ✅ **Cash** (always offer as fallback)

---

## 🏗️ COMPLETE PAYMENT ARCHITECTURE

### **Firebase + PayMongo Integration**

```
Firebase Firestore = Store payment records
     +
PayMongo API = Process payments
     +
Firebase Functions = Secure backend (handle webhooks)
```

---

## 📱 IMPLEMENTATION: Complete Payment System

### **Step 1: PayMongo Account Setup** (10 minutes)

1. Go to https://dashboard.paymongo.com/signup
2. Create account (free, no credit card needed for testing)
3. Get your API keys:
   - **Test Public Key:** `pk_test_...`
   - **Test Secret Key:** `sk_test_...`

**Where to find keys:**

- Dashboard → Developers → API Keys

---

### **Step 2: Payment Models in Firebase**

```javascript
// Firestore Collections

// 1. PAYMENT INTENTS (PayMongo payment sessions)
paymentIntents /
  {
    pi_xxx123: {
      bookingId: "booking_123",
      customerId: "user_456",
      mechanicId: "mechanic_789",

      // Amount details
      estimatedAmount: 800, // Pesos
      actualAmount: null, // Set after service completion
      holdAmount: 800, // Amount reserved

      // PayMongo details
      paymongoIntentId: "pi_xxx123",
      clientKey: "pi_xxx123_client_xxx",

      // Payment method
      paymentMethod: "gcash", // gcash, maya, card, qr_ph, cash
      paymentStatus: "requires_payment_method",
      // Statuses: requires_payment_method, requires_action,
      //           processing, succeeded, cancelled

      // Timestamps
      createdAt: Timestamp,
      authorizedAt: null,
      capturedAt: null,

      // Metadata
      description: "Emergency tire repair",
      serviceFee: 800,
      platformFee: 80, // 10% commission
      mechanicPayout: 720,
    },
  };

// 2. PAYMENT HISTORY (for customer/mechanic records)
payments /
  {
    payment_001: {
      bookingId: "booking_123",
      customerId: "user_456",
      mechanicId: "mechanic_789",
      amount: 650,
      method: "gcash",
      status: "completed",
      paymongoId: "pi_xxx123",
      createdAt: Timestamp,
      completedAt: Timestamp,
    },
  };

// 3. MECHANIC PAYOUTS (for tracking earnings)
payouts /
  {
    payout_001: {
      mechanicId: "mechanic_789",
      amount: 720,
      bookingId: "booking_123",
      status: "pending", // pending, processing, paid
      payoutDate: Timestamp,
    },
  };
```

---

### **Step 3: Add PayMongo Dependencies**

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter

  # Existing
  firebase_core: ^2.24.2
  cloud_firestore: ^4.14.0

  # Add for PayMongo
  http: ^1.1.0 # For API calls
  crypto: ^3.0.3 # For encoding API keys
  url_launcher: ^6.2.2 # For opening external payment pages
```

---

### **Step 4: Create PayMongo Service**

```dart
// lib/core/services/paymongo_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class PayMongoService {
  // 🔥 REPLACE WITH YOUR KEYS
  static const String _secretKey = 'sk_test_YOUR_SECRET_KEY';
  static const String _publicKey = 'pk_test_YOUR_PUBLIC_KEY';

  static const String _baseUrl = 'https://api.paymongo.com/v1';

  /// Get authorization header
  String get _authHeader {
    final credentials = base64Encode(utf8.encode('$_secretKey:'));
    return 'Basic $credentials';
  }

  /// Create Payment Intent (Hold-Then-Capture)
  Future<PaymentIntentResponse> createPaymentIntent({
    required double amount,
    required String description,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/payment_intents');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _authHeader,
        },
        body: json.encode({
          'data': {
            'attributes': {
              'amount': (amount * 100).toInt(), // Convert to centavos
              'currency': 'PHP',
              'description': description,
              'statement_descriptor': 'ARS Service',
              'capture_type': 'manual', // ⭐ HOLD, don't capture yet
              'payment_method_allowed': [
                'gcash',
                'paymaya',
                'card',
                'qrph',
                'grab_pay',
              ],
              'metadata': metadata,
            },
          },
        }),
      );

      print('PayMongo Response: ${response.statusCode}');
      print('PayMongo Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return PaymentIntentResponse.fromJson(data['data']);
      } else {
        throw Exception('PayMongo error: ${response.body}');
      }
    } catch (e) {
      print('❌ PayMongo error: $e');
      rethrow;
    }
  }

  /// Attach Payment Method (Customer chooses GCash/Card/etc)
  Future<PaymentIntentResponse> attachPaymentMethod({
    required String paymentIntentId,
    required String paymentMethodId,
  }) async {
    final url = Uri.parse('$_baseUrl/payment_intents/$paymentIntentId/attach');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': _authHeader,
      },
      body: json.encode({
        'data': {
          'attributes': {
            'payment_method': paymentMethodId,
            'client_key': '', // Will be provided by payment intent
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PaymentIntentResponse.fromJson(data['data']);
    } else {
      throw Exception('Failed to attach payment method');
    }
  }

  /// Capture Payment (After service completed)
  Future<PaymentIntentResponse> capturePayment({
    required String paymentIntentId,
    required double actualAmount,
  }) async {
    final url = Uri.parse('$_baseUrl/payment_intents/$paymentIntentId/capture');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': _authHeader,
      },
      body: json.encode({
        'data': {
          'attributes': {
            'amount_to_capture': (actualAmount * 100).toInt(),
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PaymentIntentResponse.fromJson(data['data']);
    } else {
      throw Exception('Failed to capture payment: ${response.body}');
    }
  }

  /// Cancel Payment (If booking cancelled)
  Future<PaymentIntentResponse> cancelPayment(String paymentIntentId) async {
    final url = Uri.parse('$_baseUrl/payment_intents/$paymentIntentId/cancel');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': _authHeader,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PaymentIntentResponse.fromJson(data['data']);
    } else {
      throw Exception('Failed to cancel payment');
    }
  }

  /// Create Payment Method (for Card payments)
  Future<String> createPaymentMethod({
    required String type, // card, gcash, paymaya
    required Map<String, dynamic> details,
  }) async {
    final url = Uri.parse('$_baseUrl/payment_methods');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': _authHeader,
      },
      body: json.encode({
        'data': {
          'attributes': {
            'type': type,
            'details': details,
          },
        },
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['data']['id'];
    } else {
      throw Exception('Failed to create payment method: ${response.body}');
    }
  }

  /// Retrieve Payment Intent (Check status)
  Future<PaymentIntentResponse> getPaymentIntent(String paymentIntentId) async {
    final url = Uri.parse('$_baseUrl/payment_intents/$paymentIntentId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': _authHeader,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PaymentIntentResponse.fromJson(data['data']);
    } else {
      throw Exception('Failed to retrieve payment intent');
    }
  }
}

// Models
class PaymentIntentResponse {
  final String id;
  final String status;
  final double amount;
  final String currency;
  final String? clientKey;
  final String? nextAction;
  final Map<String, dynamic>? nextActionData;

  PaymentIntentResponse({
    required this.id,
    required this.status,
    required this.amount,
    required this.currency,
    this.clientKey,
    this.nextAction,
    this.nextActionData,
  });

  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>;

    return PaymentIntentResponse(
      id: json['id'],
      status: attributes['status'],
      amount: (attributes['amount'] as int) / 100, // Convert from centavos
      currency: attributes['currency'],
      clientKey: attributes['client_key'],
      nextAction: attributes['next_action']?['type'],
      nextActionData: attributes['next_action'],
    );
  }
}
```

---

### **Step 5: Payment Flow Screen**

```dart
// lib/features/customer/booking/presentation/screens/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/paymongo_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final double estimatedCost;
  final String serviceDescription;

  const PaymentScreen({
    required this.bookingId,
    required this.estimatedCost,
    required this.serviceDescription,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PayMongoService _paymongo = PayMongoService();

  String? _selectedMethod;
  bool _processing = false;

  final List<PaymentMethodOption> _paymentMethods = [
    PaymentMethodOption(
      id: 'gcash',
      name: 'GCash',
      icon: Icons.account_balance_wallet,
      color: Colors.blue,
      description: 'Pay with GCash e-wallet',
      fee: 2.5,
    ),
    PaymentMethodOption(
      id: 'paymaya',
      name: 'Maya',
      icon: Icons.account_balance_wallet,
      color: Colors.green,
      description: 'Pay with Maya e-wallet',
      fee: 2.5,
    ),
    PaymentMethodOption(
      id: 'qrph',
      name: 'QR Ph',
      icon: Icons.qr_code_2,
      color: Colors.purple,
      description: 'Scan QR with any bank app',
      fee: 0.5,
      recommended: true,
    ),
    PaymentMethodOption(
      id: 'card',
      name: 'Credit/Debit Card',
      icon: Icons.credit_card,
      color: Colors.orange,
      description: 'Visa, Mastercard',
      fee: 3.5,
    ),
    PaymentMethodOption(
      id: 'cash',
      name: 'Cash',
      icon: Icons.money,
      color: Colors.grey,
      description: 'Pay mechanic directly',
      fee: 0,
    ),
  ];

  double get _totalAmount {
    if (_selectedMethod == null) return widget.estimatedCost;

    final method = _paymentMethods.firstWhere((m) => m.id == _selectedMethod);
    final fee = widget.estimatedCost * (method.fee / 100);
    return widget.estimatedCost + fee;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Amount Summary
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Service Cost',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '₱${widget.estimatedCost.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedMethod != null && _selectedMethod != 'cash') ...[
                  SizedBox(height: 8),
                  Text(
                    '+ ₱${(_totalAmount - widget.estimatedCost).toStringAsFixed(2)} processing fee',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Divider(color: Colors.white30, height: 24),
                  Text(
                    'Total: ₱${_totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Payment Methods
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                final isSelected = _selectedMethod == method.id;

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? Colors.blue : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => setState(() => _selectedMethod = method.id),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: method.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              method.icon,
                              color: method.color,
                              size: 28,
                            ),
                          ),

                          SizedBox(width: 16),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      method.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (method.recommended) ...[
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'LOWEST FEE',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  method.description,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                                if (method.fee > 0) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    '${method.fee}% processing fee',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Radio
                          Radio<String>(
                            value: method.id,
                            groupValue: _selectedMethod,
                            onChanged: (value) {
                              setState(() => _selectedMethod = value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Continue Button
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedMethod == null || _processing
                      ? null
                      : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _processing
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Continue to Payment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_selectedMethod == 'cash') {
      // Save cash payment preference
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
        'paymentMethod': 'cash',
        'paymentStatus': 'pay_on_completion',
      });

      Navigator.pop(context, true);
      return;
    }

    setState(() => _processing = true);

    try {
      // Create Payment Intent
      final paymentIntent = await _paymongo.createPaymentIntent(
        amount: _totalAmount,
        description: widget.serviceDescription,
        metadata: {
          'booking_id': widget.bookingId,
          'service_type': 'emergency_repair',
        },
      );

      print('✅ Payment Intent created: ${paymentIntent.id}');

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('paymentIntents')
          .doc(paymentIntent.id)
          .set({
        'bookingId': widget.bookingId,
        'paymongoIntentId': paymentIntent.id,
        'amount': _totalAmount,
        'status': paymentIntent.status,
        'paymentMethod': _selectedMethod,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Open payment page based on method
      if (_selectedMethod == 'gcash' || _selectedMethod == 'paymaya' || _selectedMethod == 'qrph') {
        // These methods redirect to external page
        if (paymentIntent.nextActionData != null) {
          final redirectUrl = paymentIntent.nextActionData!['redirect']?['url'];
          if (redirectUrl != null) {
            await _launchPaymentUrl(redirectUrl);
          }
        }
      } else if (_selectedMethod == 'card') {
        // Show card input dialog
        // (implement card form here)
      }

      setState(() => _processing = false);
      Navigator.pop(context, true);

    } catch (e) {
      setState(() => _processing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _launchPaymentUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class PaymentMethodOption {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final double fee;
  final bool recommended;

  PaymentMethodOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.fee,
    this.recommended = false,
  });
}
```

---

## 🔄 COMPLETE PAYMENT FLOW

### **Customer Journey:**

```
1. Request emergency service
   ↓
2. See estimated cost: ₱800
   ↓
3. Choose payment method (GCash/Maya/QR/Card/Cash)
   ↓
4. If digital: Authorize payment (money HELD)
   💰 Customer balance: -₱800 (reserved)
   ✅ Shows "Payment authorized" in app
   ↓
5. Mechanic arrives & fixes car
   ↓
6. Mechanic marks "Service complete"
   Actual cost: ₱650
   ↓
7. System captures ₱650 from held amount
   💰 Charge: ₱650
   💰 Refund: ₱150 back to customer
   ↓
8. Customer rates mechanic
   ✅ Transaction complete
```

### **Mechanic Journey:**

```
1. Receives job request
   ✅ Payment authorized (guaranteed)
   ↓
2. Accepts job
   ↓
3. Provides service
   ↓
4. Marks "Service complete" with actual cost
   ↓
5. System captures payment
   ↓
6. Earnings added to mechanic wallet
   💰 ₱585 (₱650 - 10% platform fee)
   ↓
7. Request payout weekly/monthly
```

---

## 💡 BEST PRACTICES

### **1. Always Offer Cash Option**

```dart
// Many Filipinos still prefer cash
// Don't force digital payments
```

### **2. Show Fees Transparently**

```dart
Service Cost: ₱800
Processing Fee: ₱20 (2.5%)
─────────────────
Total: ₱820
```

### **3. Use Hold-Then-Capture**

```dart
// Don't charge immediately
// Hold → Complete service → Capture
```

### **4. Handle Cancellations**

```dart
if (bookingCancelled) {
  await _paymongo.cancelPayment(paymentIntentId);
  // Money released back to customer automatically
}
```

---

## 🎯 TESTING

PayMongo provides test cards:

```
GCash Test: Use test number in GCash sandbox
Card Test: 4343 4343 4343 4343
CVC: any 3 digits
Expiry: any future date
```

---

## ✅ IMPLEMENTATION CHECKLIST

- [ ] Sign up for PayMongo account
- [ ] Get test API keys
- [ ] Add dependencies
- [ ] Create PayMongoService
- [ ] Create payment screen UI
- [ ] Integrate with booking flow
- [ ] Test GCash payment
- [ ] Test card payment
- [ ] Test cash option
- [ ] Setup webhooks (for production)

---

Use this checklist as the source of truth before building production payment flows.
