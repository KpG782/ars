# 🚗 ARS Complete Booking Flow - From Emergency SOS to Payment

**Last Updated**: February 8, 2026  
**Purpose**: Complete documentation of the customer booking journey from emergency request initiation to payment completion

---

## 📋 Table of Contents

1. [Flow Overview](#flow-overview)
2. [Detailed Step-by-Step Flow](#detailed-step-by-step-flow)
3. [State Management](#state-management)
4. [UI Screens & Panels](#ui-screens--panels)
5. [Data Flow](#data-flow)
6. [Error Handling](#error-handling)
7. [Technical Implementation](#technical-implementation)

---

## 🎯 Flow Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        CUSTOMER BOOKING JOURNEY                          │
└─────────────────────────────────────────────────────────────────────────┘

1. EMERGENCY TRIGGER         Customer taps "Emergency SOS" button
         ↓
2. EMERGENCY PANEL          Selects emergency service type
         ↓
3. SEARCHING STATUS         System searches for nearby mechanics
         ↓
4. MECHANIC FOUND           Mechanic accepts request
         ↓
5. CONFIRMED STATUS         Real-time tracking begins
         ↓
6. IN-TRANSIT               Live ETA updates & Chat available
         ↓
7. SERVICE DELIVERY         Mechanic arrives & performs service
         ↓
8. SERVICE COMPLETION       Mechanic marks service as complete
         ↓
9. PAYMENT DETAILS          Customer reviews & adds tip/promo
         ↓
10. PAYMENT METHOD          Select payment option (Cash/GCash/Card)
         ↓
11. PAYMENT PROCESSING      Process payment via selected method
         ↓
12. PAYMENT SUCCESS         Show confirmation & receipt
         ↓
13. RATING & REVIEW         Rate mechanic & service quality
```

---

## 📱 Detailed Step-by-Step Flow

### **PHASE 1: Emergency Request Initiation**

#### **Step 1: Initial Screen (BookingStatus.initial)**

**Location**: [booking_screen.dart](../lib/features/customer/booking/presentation/screens/booking_screen.dart)  
**Panel**: [initial_panel.dart](../lib/features/customer/booking/presentation/widgets/panels/initial_panel.dart)

**User View**:
```
┌─────────────────────────────────┐
│       MAP VIEW                  │
│   (Shows user location)         │
│                                 │
│   📍 Current Location           │
│   🔵 User marker                │
│                                 │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│  [Choose Service]               │ ← Big button
│                                 │
│  ⚠️ Emergency SOS               │ ← Red outlined button
└─────────────────────────────────┘
```

**Actions Available**:
- ✅ Tap "Choose Service" → Regular booking flow
- ✅ Tap "Emergency SOS" → Emergency booking flow (our focus)
- ✅ View nearby mechanics on map
- ✅ Access menu drawer

**Code Reference**:
```dart
// State transition when Emergency SOS tapped
onBookingStatusChanged(BookingStatus.emergency)
```

---

#### **Step 2: Emergency Service Selection (BookingStatus.emergency)**

**Location**: [emergency_panel.dart](../lib/features/customer/booking/presentation/widgets/panels/emergency_panel.dart)  
**Documentation**: [EMERGENCY_REQUEST_IMPLEMENTATION.md](EMERGENCY_REQUEST_IMPLEMENTATION.md)

**User View**:
```
┌──────────────────────────────────────┐
│  🚨 EMERGENCY SERVICE                │
│                                      │
│  Choose your emergency:              │
│                                      │
│  🔧 Dead Battery        [SELECT]     │
│  🛞 Flat Tire          [SELECT]     │
│  🔥 Overheating        [SELECT]     │
│  🚫 Won't Start        [SELECT]     │
│  ⚙️ Engine Problem      [SELECT]     │
│  🛠️ Other Emergency     [SELECT]     │
│                                      │
│  ⏰ Priority Response                │
│  💰 Estimated: ₱500-800              │
│                                      │
│  [Cancel]                            │
└──────────────────────────────────────┘
```

**User Actions**:
- ✅ Select emergency service type
- ✅ See estimated price range
- ✅ Understand priority response
- ✅ Cancel to go back

**Backend Action**:
```dart
// Creates service request with emergency flag
ServiceRequest(
  id: generatedId,
  customerName: userData.name,
  location: customerLocation,
  serviceType: selectedService,
  isEmergency: true,  // 🔴 Critical flag
  status: 'pending',
  requestTime: DateTime.now(),
  estimatedPrice: estimatedPrice,
)
```

**State Transition**:
```dart
onEmergencyServiceSelected(service) → BookingStatus.searching
```

---

### **PHASE 2: Mechanic Search & Assignment**

#### **Step 3: Searching for Mechanic (BookingStatus.searching)**

**Location**: [searching_panel.dart](../lib/features/customer/booking/presentation/widgets/panels/searching_panel.dart)

**User View**:
```
┌──────────────────────────────────────┐
│  🔍 Finding mechanic for you...      │
│                                      │
│  ⚡ Emergency priority search        │
│                                      │
│     [Animated loading spinner]       │
│                                      │
│  🛞 Flat Tire                        │
│  📍 Your location: Quezon City       │
│                                      │
│  ⏱️ Average wait: 3-5 minutes        │
│                                      │
│  [Cancel Search]                     │
└──────────────────────────────────────┘
```

**Backend Process**:
1. **Query nearby mechanics** (within 5km radius)
   ```dart
   final mechanics = await _mechanicRepository.getNearbyMechanics(
     userLocation: customerLocation,
     radius: 5000, // meters
     services: [selectedService],
     onlineOnly: true,
   );
   ```

2. **Priority sorting for emergency**
   ```dart
   mechanics.sort((a, b) {
     // Emergency requests get highest priority
     if (isEmergency) {
       return a.distance.compareTo(b.distance); // Closest first
     }
     return a.rating.compareTo(b.rating); // Highest rated first
   });
   ```

3. **Send notifications to mechanics**
   ```dart
   // Broadcast to top 5 nearest mechanics
   for (var mechanic in mechanics.take(5)) {
     await _notificationService.sendEmergencyRequest(
       mechanicId: mechanic.id,
       requestData: serviceRequest,
       priority: NotificationPriority.max, // Red alert
     );
   }
   ```

4. **Real-time listener for acceptance**
   ```dart
   FirebaseFirestore.instance
     .collection('service_requests')
     .doc(requestId)
     .snapshots()
     .listen((snapshot) {
       if (snapshot.data()?['status'] == 'accepted') {
         // Mechanic accepted!
         onBookingStatusChanged(BookingStatus.confirmed);
       }
     });
   ```

**What Mechanic Sees** (on their dashboard):
```
┌──────────────────────────────────────────┐
│ 🚨 EMERGENCY REQUEST    [HIGH PRIORITY]  │ ← Red card with animation
├──────────────────────────────────────────┤
│ 👤 Maria Santos              💰 ₱650     │
│ 🛞 Flat Tire                 [URGENT]    │
│ 📍 2.3 km away • Quezon City             │
│ ⏰ Requested 30 seconds ago              │
│                                          │
│ "Flat tire on EDSA, please hurry!"      │
│                                          │
│ [View Details]    [Accept Emergency] ←   │
└──────────────────────────────────────────┘
```

**State Transitions**:
- ✅ Mechanic accepts → `BookingStatus.confirmed`
- ❌ User cancels → `BookingStatus.initial`
- ⏱️ Timeout (5 min) → Expand search radius + retry

---

#### **Step 4: Mechanic Accepted (BookingStatus.confirmed)**

**Location**: [mechanic_confirmed_panel.dart](../lib/features/customer/booking/presentation/widgets/panels/mechanic_confirmed_panel.dart)  
**Models**: [mechanic.dart](../lib/features/customer/booking/domain/models/mechanic.dart)

**User View**:
```
┌──────────────────────────────────────────┐
│ ✅ Mechanic on the way!                  │
│ 🛞 Flat Tire                             │
├──────────────────────────────────────────┤
│                                          │
│  ⏱️ Estimated Arrival                    │
│     13 minutes                           │
│     via OSRM Philippines routing         │
│                                          │
├──────────────────────────────────────────┤
│  👨‍🔧 Jose Garcia        ⭐ 4.8 (156)      │
│  🚗 Honda XRM 125 • Red                  │
│  📱 +63 912 345 6789                     │
│  ✅ Verified Mechanic                    │
│                                          │
│  📍 Currently 2.3 km away                │
│                                          │
├──────────────────────────────────────────┤
│  [💬 Chat]  [📍 Share Location]  [📞 Call] │
│                                          │
│  [Cancel Service]                        │
└──────────────────────────────────────────┘
```

**Features Active**:

1. **Real-time ETA Calculation** (OSRM Service)
   ```dart
   // Auto-refreshes every 30 seconds
   CompactETADisplay(
     mechanic: mechanic,
     customerLocation: customerLocation,
     refreshInterval: Duration(seconds: 30),
   )
   ```
   - Uses self-hosted OSRM server for Philippine roads
   - Calculates route with traffic consideration
   - Updates automatically as mechanic moves
   - [Full documentation](OSRM_IMPLEMENTATION_REPORT.md)

2. **Live Location Tracking**
   ```dart
   // Mechanic location updates via Firebase
   FirebaseFirestore.instance
     .collection('mechanics')
     .doc(mechanicId)
     .snapshots()
     .listen((doc) {
       final location = doc.data()?['currentLocation'];
       _updateMechanicMarker(location);
       _recalculateETA();
     });
   ```

3. **Chat System** (Tap "Chat" button)
   - Opens [chat_screen.dart](../lib/features/customer/booking/presentation/screens/chat/chat_screen.dart)
   - Real-time messaging via Firebase
   - Image sharing capability
   - [Full chat documentation](chat-feature.md)

4. **Share Location** (Tap "Share Location" button)
   - Opens [share_location_sheet.dart](../lib/features/customer/booking/presentation/widgets/share_location_sheet.dart)
   - Send location via SMS
   - Share with emergency contacts
   - Copy Google Maps link

5. **Direct Call** (Tap "Call" button)
   ```dart
   final Uri phoneUri = Uri(scheme: 'tel', path: mechanic.phoneNumber);
   await launchUrl(phoneUri);
   ```

**Notifications Sent**:
- ✅ To Customer: "Jose Garcia accepted your request"
- ✅ To Mechanic: "On the way to Maria Santos"
- ✅ Auto-updates every location change

---

### **PHASE 3: Service Delivery**

#### **Step 5: In-Transit Monitoring**

**Map View Updates**:
```
┌─────────────────────────────────────────┐
│          MAP VIEW                        │
│                                         │
│   🔵 Customer Location (You)            │
│        ↑                                │
│   ═════════ Route Line ═════════        │
│        ↓                                │
│   🚗 Mechanic Moving (Real-time)        │
│                                         │
│   📍 "Jose is 1.2 km away"              │
│   ⏱️ "Arriving in 8 minutes"            │
└─────────────────────────────────────────┘
```

**Auto-notifications**:
- 📲 When mechanic is 5 min away → "Jose is nearby!"
- 📲 When mechanic is 1 min away → "Jose is arriving!"
- 📲 When mechanic arrives → "Jose has arrived"

**Customer Actions Available**:
- 💬 Send messages via chat
- 📸 Share photos of the problem
- 📍 Update location if moved
- ❌ Cancel service (with penalty warning)

---

#### **Step 6: Service Completion**

**Mechanic Side Action**:
1. Mechanic completes repair work
2. Mechanic taps "Complete Service" in their app
3. Adds work notes and photos (optional)
4. Confirms actual service cost

```dart
// Mechanic marks service complete
ServiceRequest.update({
  status: 'completed',
  completionTime: DateTime.now(),
  actualPrice: 650.0, // Can be different from estimate
  mechanicNotes: "Replaced tire, checked spare tire pressure",
  workPhotos: ['photo1.jpg', 'photo2.jpg'],
});
```

**Customer Receives Notification**:
```
┌──────────────────────────────────────┐
│  ✅ Service Completed!                │
│                                      │
│  Jose Garcia has finished working    │
│  on your vehicle.                    │
│                                      │
│  💰 Final Amount: ₱650               │
│                                      │
│  [View Details & Pay]                │
└──────────────────────────────────────┘
```

**State Transition**:
```dart
// Auto-navigate to payment
Navigator.push(context, 
  PaymentDetailsScreen(
    mechanicName: mechanic.name,
    serviceName: serviceType,
    location: customerLocation,
    amount: actualPrice,
  )
);
```

---

### **PHASE 4: Payment Processing**

#### **Step 7: Payment Details Screen**

**Location**: [payment_details_screen.dart](../lib/features/customer/booking/presentation/screens/payment/payment_details_screen.dart)

**User View**:
```
┌──────────────────────────────────────────┐
│  💰 Payment Details                      │
├──────────────────────────────────────────┤
│  SERVICE SUMMARY                         │
│                                          │
│  👨‍🔧 Jose Garcia                          │
│  🛞 Flat Tire Service                    │
│  📍 Quezon City                          │
│  ⏱️ Duration: 35 minutes                 │
│                                          │
├──────────────────────────────────────────┤
│  PRICE BREAKDOWN                         │
│                                          │
│  Service Fee          ₱ 650.00          │
│  Platform Fee (10%)   ₱  65.00          │
│  ─────────────────────────────          │
│  Subtotal            ₱ 715.00          │
│                                          │
│  💝 Add Tip (Optional)                   │
│  [₱ 0] [₱ 20] [₱ 50] [₱ 100] [Custom]  │
│  Selected: ₱ 50                          │
│                                          │
│  🎟️ Promo Code                           │
│  [Enter code___________] [Apply]        │
│  ✅ FIRST20 applied (-₱143.00)           │
│                                          │
│  ─────────────────────────────          │
│  TOTAL AMOUNT         ₱ 622.00     │
│  ─────────────────────────────          │
│                                          │
│  📝 Additional Notes (Optional)          │
│  [Great service, very fast!_____]       │
│                                          │
│  [Continue to Payment]                   │
└──────────────────────────────────────────┘
```

**Features**:

1. **Service Review**
   - Mechanic details with rating
   - Service type and duration
   - Location where service was performed

2. **Price Breakdown**
   ```dart
   double subtotal = serviceAmount;
   double platformFee = subtotal * 0.10;
   double tipAmount = selectedTip;
   double discount = promoDiscount;
   
   double total = subtotal + platformFee + tipAmount - discount;
   ```

3. **Tip Options**
   - Preset values: ₱20, ₱50, ₱100
   - Custom amount input
   - Optional (can skip)

4. **Promo Codes**
   ```dart
   // Valid promo codes
   'ARS50'    → ₱50 flat discount
   'FIRST20'  → 20% discount on subtotal
   'WELCOME'  → ₱100 off first booking
   ```

5. **Notes Field**
   - Customer feedback
   - Special requests
   - Saved for service history

**State Data**:
```dart
PaymentDetailsState {
  mechanicName: "Jose Garcia",
  serviceName: "Flat Tire",
  location: "Quezon City",
  baseAmount: 650.0,
  tipAmount: 50.0,
  discount: 143.0,
  appliedPromoCode: "FIRST20",
  subtotal: 715.0,
  serviceFee: 65.0,
  totalAmount: 622.0,
  notes: "Great service!",
}
```

**Actions**:
- ✅ Add/remove tip
- ✅ Apply promo code
- ✅ Add notes
- ✅ Continue to payment method

---

#### **Step 8: Payment Method Selection**

**Location**: [payment_screen.dart](../lib/features/customer/booking/presentation/screens/payment/payment_screen.dart)  
**Integration**: [payment.md](payment.md) (PayMongo integration guide)

**User View**:
```
┌──────────────────────────────────────────┐
│  💳 Select Payment Method                │
├──────────────────────────────────────────┤
│                                          │
│  💰 Total Amount: ₱ 622.00               │
│                                          │
├──────────────────────────────────────────┤
│  PAYMENT OPTIONS                         │
│                                          │
│  ◉ 💵 Cash                               │
│     Pay the mechanic directly            │
│     No processing fee                    │
│                                          │
│  ○ 📱 GCash                              │
│     Pay via GCash mobile wallet          │
│     + ₱15.55 processing fee (2.5%)       │
│                                          │
│  ○ 💳 Credit/Debit Card                  │
│     Visa, Mastercard accepted            │
│     + ₱21.77 processing fee (3.5%)       │
│                                          │
│  ○ 📲 Maya (PayMaya)                     │
│     Pay via Maya digital wallet          │
│     + ₱15.55 processing fee (2.5%)       │
│                                          │
│  ○ 📷 QR Ph  ⭐ RECOMMENDED              │
│     Scan with any bank app               │
│     + ₱3.11 processing fee (0.5%)        │
│                                          │
├──────────────────────────────────────────┤
│  🔒 Secured by PayMongo                  │
│                                          │
│  [Continue to Payment]                   │
└──────────────────────────────────────────┘
```

**Payment Methods**:

| Method | Provider | Fee | Processing Time |
|--------|----------|-----|-----------------|
| Cash | Direct | 0% | Immediate |
| GCash | PayMongo | 2.5% | 5 seconds |
| Maya | PayMongo | 2.5% | 5 seconds |
| QR Ph | PayMongo | 0.5% | 10 seconds |
| Card | PayMongo | 3.5% | 15 seconds |

**Payment Flow Strategies**:

1. **Cash Payment** (Traditional)
   ```dart
   // Save preference, no processing needed
   ServiceRequest.update({
     paymentMethod: 'cash',
     paymentStatus: 'pay_on_completion',
     paidAt: DateTime.now(),
   });
   
   // Navigate to success screen
   Navigator.pushReplacement(context, PaymentSuccessScreen(...));
   ```

2. **Digital Payment** (Hold-Then-Capture via PayMongo)
   ```dart
   // Step 1: Create Payment Intent (Hold funds)
   final paymentIntent = await PayMongoService.createPaymentIntent(
     amount: totalAmount,
     currency: 'PHP',
     description: 'Flat Tire Service - Jose Garcia',
     metadata: {
       'bookingId': bookingId,
       'serviceType': serviceType,
     },
   );
   
   // Step 2: Attach Payment Method
   await PayMongoService.attachPaymentMethod(
     paymentIntentId: paymentIntent.id,
     paymentMethodId: selectedMethod, // gcash, card, maya
   );
   
   // Step 3a: For GCash/Maya - Redirect to payment page
   if (selectedMethod == 'gcash' || selectedMethod == 'maya') {
     final redirectUrl = paymentIntent.nextAction.redirectUrl;
     await launchUrl(redirectUrl); // Opens GCash/Maya app
     
     // Wait for payment confirmation via webhook
   }
   
   // Step 3b: For Card - Show card input form
   if (selectedMethod == 'card') {
     await showCardInputDialog(
       paymentIntent: paymentIntent,
       onComplete: (result) {
         // Process card payment
       },
     );
   }
   
   // Step 4: Capture Payment (Charge the held funds)
   final captured = await PayMongoService.capturePayment(
     paymentIntentId: paymentIntent.id,
     actualAmount: totalAmount,
   );
   
   // Step 5: Update booking status
   ServiceRequest.update({
     paymentMethod: selectedMethod,
     paymentStatus: 'completed',
     paymentIntentId: paymentIntent.id,
     paidAt: DateTime.now(),
   });
   ```

**Error Handling**:
```dart
try {
  await processPayment();
} catch (e) {
  if (e is PaymentFailedException) {
    showError("Payment failed: ${e.message}");
  } else if (e is NetworkException) {
    showError("Network error. Please try again.");
  } else {
    showError("Something went wrong. Contact support.");
  }
}
```

---

#### **Step 9: Payment Processing & Confirmation**

**Processing Screen**:
```
┌──────────────────────────────────────────┐
│                                          │
│         [Animated loading spinner]       │
│                                          │
│     ⏳ Processing your payment...        │
│                                          │
│     Please wait, do not close this       │
│     screen or press back.                │
│                                          │
│     💳 GCash                              │
│     Amount: ₱ 622.00                     │
│                                          │
└──────────────────────────────────────────┘
```

**Backend Process**:
1. Validate payment with PayMongo
2. Update Firestore
3. Distribute funds:
   ```
   Total Payment: ₱622.00
   ├─ Platform Fee (15%): ₱93.30 → ARS
   ├─ Processing Fee (2.5%): ₱15.55 → PayMongo
   └─ Mechanic Earnings (82.5%): ₱513.15 → Jose Garcia
   ```
4. Send confirmation notifications
5. Update mechanic wallet

---

#### **Step 10: Payment Success**

**Location**: [payment_success_screen.dart](../lib/features/customer/booking/presentation/screens/payment/payment_success_screen.dart)

**User View**:
```
┌──────────────────────────────────────────┐
│                                          │
│           🎉 [Confetti animation]        │
│                                          │
│         ✅ Payment Successful!           │
│                                          │
│         [Checkmark animation]            │
│                                          │
│  ──────────────────────────────────      │
│                                          │
│  TRANSACTION DETAILS                     │
│                                          │
│  Transaction ID                          │
│  ARS-2026-02-08-12345                    │
│                                          │
│  Mechanic: Jose Garcia                   │
│  Service: Flat Tire                      │
│                                          │
│  Amount Paid: ₱ 622.00                   │
│  Payment Method: GCash                   │
│  Date: Feb 8, 2026 2:45 PM               │
│                                          │
│  ──────────────────────────────────      │
│                                          │
│  📧 Receipt sent to your email           │
│  📱 SMS confirmation sent                 │
│                                          │
│  [Download Receipt]  [Share]             │
│                                          │
│  [Done - Return to Home]                 │
│                                          │
└──────────────────────────────────────────┘
```

**Animations**:
```dart
// Confetti celebration
_confettiController.forward();

// Checkmark pop animation
_checkmarkController.forward();

// Haptic feedback
HapticFeedback.heavyImpact();
```

**Notifications Sent**:
- 📧 Email receipt to customer
- 📱 SMS confirmation to customer
- 💰 Earnings notification to mechanic
- 📊 Transaction log to admin

**Auto-actions**:
1. Save receipt to user's transaction history
2. Update mechanic's earnings wallet
3. Trigger rating prompt after 2 seconds

---

### **PHASE 5: Post-Service**

#### **Step 11: Rating & Review**

**User View** (Auto-prompts after 2 seconds):
```
┌──────────────────────────────────────────┐
│  ⭐ Rate Your Experience                  │
├──────────────────────────────────────────┤
│                                          │
│  How was your service with               │
│  Jose Garcia?                            │
│                                          │
│  ⭐ ⭐ ⭐ ⭐ ⭐                              │
│  (Tap to rate 1-5 stars)                 │
│                                          │
│  ──────────────────────────────────      │
│                                          │
│  QUICK FEEDBACK                          │
│  [Professional] [Fast] [Friendly]        │
│  [Great Price] [Skilled] [Clean Work]    │
│                                          │
│  DETAILED REVIEW (Optional)              │
│  [Write your review here..._______]      │
│                                          │
│  [Skip]              [Submit Review]     │
│                                          │
└──────────────────────────────────────────┘
```

**Rating Saved**:
```dart
Rating {
  bookingId: "booking_123",
  customerId: "customer_456",
  mechanicId: "mechanic_789",
  rating: 5.0,
  tags: ["Professional", "Fast", "Friendly"],
  review: "Very quick response and fixed my tire perfectly!",
  createdAt: DateTime.now(),
}

// Update mechanic's average rating
Mechanic.update({
  totalRatings: totalRatings + 1,
  averageRating: (averageRating * totalRatings + 5.0) / (totalRatings + 1),
});
```

**Customer Rewards** (if high rating):
```
Thank you for your feedback! 🎉

You earned:
🎟️ ₱50 voucher for your next booking
⭐ 10 loyalty points
```

---

## 🔄 State Management

### **Booking Status Enum**

**Location**: [booking_status.dart](../lib/features/customer/booking/domain/models/booking_status.dart)

```dart
enum BookingStatus {
  initial,              // Home screen, ready to book
  emergency,            // Emergency service selection
  serviceSelection,     // Regular service selection
  subServiceSelection,  // Detailed service selection
  details,              // Booking details form
  searching,            // Looking for mechanic
  confirmed,            // Mechanic accepted & on the way
}
```

### **State Transitions**

```dart
// State Flow for Emergency Booking
initial → emergency → searching → confirmed

// State Flow for Regular Booking
initial → serviceSelection → subServiceSelection → searching → confirmed

// Cancel Flows
any_state → initial (with confirmation dialog)
```

### **Status Checks**

```dart
extension BookingStatusExtension on BookingStatus {
  // Display names
  String get displayName;
  
  // Can user go back?
  bool get canGoBack => this != BookingStatus.initial && 
                        this != BookingStatus.searching &&
                        this != BookingStatus.confirmed;
  
  // Is booking in progress?
  bool get isInProgress => this == BookingStatus.searching ||
                           this == BookingStatus.confirmed;
}
```

---

## 🗂️ UI Screens & Panels

### **Screen Hierarchy**

```
BookingScreen (Main container)
├── BookingMapWidget (Map display)
├── BookingSearchBar (Top search/actions)
├── BookingDrawer (Side menu)
└── BookingBottomPanels (Dynamic panels based on status)
    ├── InitialPanel
    ├── EmergencyPanel ⚡
    ├── ServiceSelectionPanel
    ├── SubServiceSelectionPanel
    ├── SearchingPanel
    └── MechanicConfirmedPanel
        ├── CompactETADisplay
        ├── ShareLocationSheet
        └── Action Buttons (Chat, Call, Cancel)
```

### **Payment Screens**

```
PaymentDetailsScreen
├── Service Summary
├── Price Breakdown
├── Tip Selection
├── Promo Code Input
└── Continue Button → PaymentScreen
    ├── Payment Method List
    ├── Fee Information
    └── Process Button → PaymentSuccessScreen
        ├── Success Animation
        ├── Receipt Details
        └── Rating Prompt
```

### **Key Files**

| Screen/Widget | File Path | Purpose |
|---------------|-----------|---------|
| Main Booking | [booking_screen.dart](../lib/features/customer/booking/presentation/screens/booking_screen.dart) | Container for all booking UI |
| Emergency Panel | [emergency_panel.dart](../lib/features/customer/booking/presentation/widgets/panels/emergency_panel.dart) | Emergency service selection |
| Searching Panel | [searching_panel.dart](../lib/features/customer/booking/presentation/widgets/panels/searching_panel.dart) | Loading state during search |
| Confirmed Panel | [mechanic_confirmed_panel.dart](../lib/features/customer/booking/presentation/widgets/panels/mechanic_confirmed_panel.dart) | Mechanic details & tracking |
| Payment Details | [payment_details_screen.dart](../lib/features/customer/booking/presentation/screens/payment/payment_details_screen.dart) | Price, tip, promo |
| Payment Method | [payment_screen.dart](../lib/features/customer/booking/presentation/screens/payment/payment_screen.dart) | Method selection & processing |
| Payment Success | [payment_success_screen.dart](../lib/features/customer/booking/presentation/screens/payment/payment_success_screen.dart) | Confirmation & receipt |
| Chat | [chat_screen.dart](../lib/features/customer/booking/presentation/screens/chat/chat_screen.dart) | Real-time messaging |

---

## 📊 Data Flow

### **Firestore Collections**

```javascript
// Service Requests (Main booking data)
service_requests/
  {
    request_123: {
      // Basic Info
      id: "request_123",
      customerId: "customer_456",
      mechanicId: "mechanic_789", // null until accepted
      
      // Service Details
      serviceType: "Flat Tire",
      isEmergency: true,
      location: GeoPoint(14.5995, 120.9842),
      locationName: "Quezon City",
      
      // Pricing
      estimatedPrice: 800.0,
      actualPrice: 650.0, // Set on completion
      tipAmount: 50.0,
      discount: 143.0,
      appliedPromoCode: "FIRST20",
      totalAmount: 622.0,
      
      // Status & Timeline
      status: "completed", // pending, accepted, working, completed, cancelled
      requestTime: Timestamp,
      acceptedTime: Timestamp,
      startTime: Timestamp,
      completionTime: Timestamp,
      
      // Notes & Media
      customerNotes: "Flat tire on EDSA",
      mechanicNotes: "Replaced tire, checked spare",
      workPhotos: ["photo1.jpg", "photo2.jpg"],
      
      // Payment
      paymentMethod: "gcash",
      paymentStatus: "completed",
      paymentIntentId: "pi_xxx123",
      paidAt: Timestamp,
      
      // Rating
      rating: 5.0,
      reviewTags: ["Professional", "Fast"],
      review: "Great service!",
    }
  }

// Users (Customer data)
users/
  {
    customer_456: {
      name: "Maria Santos",
      email: "maria@example.com",
      phoneNumber: "+63 912 345 6789",
      photoUrl: "https://...",
      location: GeoPoint(14.5995, 120.9842),
      
      // Stats
      totalBookings: 15,
      completedBookings: 14,
      cancelledBookings: 1,
      
      // Payment
      savedPaymentMethods: ["gcash_method_id"],
      walletBalance: 0,
      
      // Loyalty
      loyaltyPoints: 150,
      availableVouchers: ["voucher_001"],
    }
  }

// Mechanics (Mechanic data)
mechanics/
  {
    mechanic_789: {
      name: "Jose Garcia",
      phoneNumber: "+63 917 123 4567",
      photoUrl: "https://...",
      
      // Location (real-time updates)
      currentLocation: GeoPoint(14.5898, 120.9787),
      isOnline: true,
      
      // Vehicle Info
      vehicleType: "Motorcycle",
      vehicleModel: "Honda XRM 125",
      vehicleColor: "Red",
      licensePlate: "ABC 1234",
      
      // Rating & Stats
      rating: 4.8,
      totalRatings: 156,
      totalJobs: 189,
      completedJobs: 180,
      
      // Services
      services: ["Tire Problem", "Dead Battery", "Engine Problems"],
      
      // Verification
      isVerified: true,
      verificationDate: Timestamp,
      
      // Earnings
      totalEarnings: 45_650.00,
      pendingEarnings: 2_140.00,
      walletBalance: 43_510.00,
    }
  }

// Payment Intents (PayMongo integration)
payment_intents/
  {
    pi_xxx123: {
      bookingId: "request_123",
      customerId: "customer_456",
      mechanicId: "mechanic_789",
      
      // PayMongo details
      paymongoIntentId: "pi_xxx123",
      clientKey: "pi_xxx123_client_xxx",
      
      // Amount
      estimatedAmount: 800.0,
      actualAmount: 622.0,
      holdAmount: 800.0,
      
      // Status
      paymentMethod: "gcash",
      paymentStatus: "succeeded",
      
      // Timestamps
      createdAt: Timestamp,
      completedAt: Timestamp,
    }
  }

// Chats (Real-time messaging)
chats/
  {
    chat_booking_123: {
      bookingId: "request_123",
      participants: {
        customer_456: { name: "Maria", lastSeen: Timestamp },
        mechanic_789: { name: "Jose", lastSeen: Timestamp }
      },
      lastMessage: {
        text: "I'm 5 minutes away",
        senderId: "mechanic_789",
        timestamp: Timestamp
      },
      
      // Subcollection: messages
      messages/
        {
          msg_001: {
            senderId: "customer_456",
            text: "Where are you?",
            type: "text",
            timestamp: Timestamp,
            read: true
          },
          msg_002: {
            senderId: "mechanic_789",
            text: "5 minutes away!",
            type: "text",
            timestamp: Timestamp,
            read: true
          }
        }
    }
  }

// Ratings (Service ratings)
ratings/
  {
    rating_123: {
      bookingId: "request_123",
      customerId: "customer_456",
      mechanicId: "mechanic_789",
      rating: 5.0,
      tags: ["Professional", "Fast", "Friendly"],
      review: "Very quick response!",
      createdAt: Timestamp
    }
  }
```

### **Real-time Listeners**

```dart
// 1. Listen for mechanic acceptance
FirebaseFirestore.instance
  .collection('service_requests')
  .doc(requestId)
  .snapshots()
  .listen((snapshot) {
    final status = snapshot.data()?['status'];
    if (status == 'accepted') {
      setState(() => bookingStatus = BookingStatus.confirmed);
    }
  });

// 2. Listen for mechanic location updates
FirebaseFirestore.instance
  .collection('mechanics')
  .doc(mechanicId)
  .snapshots()
  .listen((doc) {
    final location = doc.data()?['currentLocation'];
    _updateMechanicMarker(location);
    _recalculateETA();
  });

// 3. Listen for payment status
FirebaseFirestore.instance
  .collection('payment_intents')
  .doc(paymentIntentId)
  .snapshots()
  .listen((doc) {
    final status = doc.data()?['paymentStatus'];
    if (status == 'succeeded') {
      _showPaymentSuccess();
    }
  });

// 4. Listen for new chat messages
FirebaseFirestore.instance
  .collection('chats')
  .doc(chatId)
  .collection('messages')
  .orderBy('timestamp')
  .snapshots()
  .listen((snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        _addMessage(change.doc.data());
      }
    }
  });
```

---

## ⚠️ Error Handling

### **Common Errors & Solutions**

| Error | Cause | Solution | User Message |
|-------|-------|----------|--------------|
| **LocationPermissionDenied** | User denied location access | Show permission dialog | "Location access is required to find nearby mechanics" |
| **NoMechanicsAvailable** | No mechanics in range | Expand search radius | "No mechanics available nearby. Expanding search..." |
| **SearchTimeout** | No acceptance in 5 min | Cancel & retry | "Taking longer than usual. Try again?" |
| **PaymentFailed** | Payment gateway error | Retry or use different method | "Payment failed. Please try another payment method" |
| **NetworkError** | No internet connection | Queue for retry | "No internet. Will retry when connected" |
| **InvalidPromoCode** | Wrong promo code entered | Clear field | "Invalid promo code" |
| **SessionExpired** | Booking took too long | Restart booking | "Session expired. Please start a new booking" |

### **Error Handling Implementation**

```dart
try {
  await searchForMechanic();
} on LocationPermissionDeniedException {
  showDialog(
    title: "Location Required",
    message: "We need your location to find nearby mechanics",
    actions: [
      TextButton(
        onPressed: () => Geolocator.openLocationSettings(),
        child: Text("Open Settings"),
      ),
    ],
  );
} on NoMechanicsAvailableException {
  ToastHelper.showWarning(
    context,
    "No mechanics available nearby. Expanding search area...",
  );
  // Retry with larger radius
  await searchForMechanic(radiusKm: 10);
} on TimeoutException {
  final retry = await showRetryDialog();
  if (retry) {
    await searchForMechanic();
  }
} catch (e) {
  ToastHelper.showError(
    context,
    "Something went wrong. Please try again.",
  );
  analytics.logError(e);
}
```

---

## 🛠️ Technical Implementation

### **Services Used**

| Service | Purpose | Documentation |
|---------|---------|---------------|
| **Firebase Auth** | User authentication | Built-in |
| **Cloud Firestore** | Database & real-time sync | Built-in |
| **Firebase Storage** | Photo uploads (work photos) | Built-in |
| **Firebase Cloud Messaging** | Push notifications | [NOTIFICATION_IMPLEMENTATION.md](NOTIFICATION_IMPLEMENTATION.md) |
| **OSRM** | Route calculation & ETA | [OSRM_IMPLEMENTATION_REPORT.md](OSRM_IMPLEMENTATION_REPORT.md) |
| **PayMongo** | Payment processing | [payment.md](payment.md) |
| **Geolocator** | Location services | pub.dev package |
| **Flutter Map** | Map display | pub.dev package |

### **Key Controllers**

**BookingController**  
[booking_controller.dart](../lib/features/customer/booking/presentation/controllers/booking_controller.dart)

```dart
class BookingController extends ChangeNotifier {
  // State
  BookingStatus _bookingStatus = BookingStatus.initial;
  List<Mechanic> _nearbyMechanics = [];
  Mechanic? _selectedMechanic;
  ServiceRequest? _currentRequest;
  
  // Location
  LatLng? _currentLocation;
  
  // Methods
  Future<void> searchNearbyMechanics();
  Future<void> createEmergencyRequest();
  Future<void> acceptMechanic(Mechanic mechanic);
  Future<void> cancelBooking();
  
  // Real-time updates
  void startLocationTracking();
  void listenToRequestStatus();
}
```

### **Payment Integration**

**PayMongoService**  
```dart
class PayMongoService {
  // Create payment intent (hold funds)
  Future<PaymentIntent> createPaymentIntent({
    required double amount,
    required String currency,
    required String description,
    Map<String, dynamic>? metadata,
  });
  
  // Attach payment method
  Future<PaymentIntent> attachPaymentMethod({
    required String paymentIntentId,
    required String paymentMethodId,
  });
  
  // Capture payment (charge held funds)
  Future<PaymentIntent> capturePayment({
    required String paymentIntentId,
    required double actualAmount,
  });
  
  // Cancel payment (refund)
  Future<PaymentIntent> cancelPayment(String paymentIntentId);
}
```

### **Notification System**

**NotificationService**  
[notification_service.dart](../lib/core/services/notification_service.dart)

```dart
class NotificationService {
  // Send to mechanic
  Future<void> sendEmergencyRequest({
    required String mechanicId,
    required ServiceRequest request,
  });
  
  // Send to customer
  Future<void> notifyMechanicAccepted({
    required String customerId,
    required Mechanic mechanic,
  });
  
  Future<void> notifyMechanicArriving({
    required String customerId,
    required int minutesAway,
  });
  
  Future<void> notifyServiceCompleted({
    required String customerId,
    required double amount,
  });
  
  Future<void> notifyPaymentConfirmed({
    required String mechanicId,
    required double earnings,
  });
}
```

---

## 📈 Performance Optimizations

### **Map Performance**
- Limit markers to 20 nearest mechanics
- Use clustering for dense areas
- Lazy load mechanic details

### **Real-time Updates**
- Throttle location updates to 30 seconds
- Batch Firestore reads
- Cache mechanic data locally

### **Payment**
- Pre-validate promo codes client-side
- Show loading states immediately
- Cache payment methods

---

## 🔐 Security Considerations

### **Firebase Rules**
```javascript
// Service Requests - Only customer & assigned mechanic can read
match /service_requests/{requestId} {
  allow read: if request.auth != null && 
    (resource.data.customerId == request.auth.uid ||
     resource.data.mechanicId == request.auth.uid);
  
  allow create: if request.auth != null;
  
  allow update: if request.auth != null &&
    (resource.data.customerId == request.auth.uid ||
     resource.data.mechanicId == request.auth.uid);
}

// Payment Intents - Owner only
match /payment_intents/{intentId} {
  allow read, write: if request.auth != null &&
    resource.data.customerId == request.auth.uid;
}
```

### **Input Validation**
- Validate promo codes server-side
- Sanitize user inputs
- Verify payment amounts match server records
- Rate limit emergency requests (max 3 per day)

---

## 📚 Related Documentation

- [Emergency Request Implementation](EMERGENCY_REQUEST_IMPLEMENTATION.md)
- [OSRM ETA Integration](OSRM_IMPLEMENTATION_REPORT.md)
- [Notification System](NOTIFICATION_IMPLEMENTATION.md)
- [Chat Feature](chat-feature.md)
- [Payment Integration (PayMongo)](payment.md)
- [Mechanic Payment Confirmation](MECHANIC_PHASE1_COMPLETION.md)
- [Project Architecture](../ARCHITECTURE.md)

---

## ✅ Testing Checklist

### **Emergency Flow**
- [ ] Emergency button displays correctly
- [ ] Emergency service selection works
- [ ] Priority notifications sent to mechanics
- [ ] Emergency requests sorted first in mechanic dashboard
- [ ] Can cancel emergency request
- [ ] Emergency badge shows on cards

### **Search & Assignment**
- [ ] Location permission requested
- [ ] Nearby mechanics loaded correctly
- [ ] Searching animation displays
- [ ] Mechanic acceptance triggers state change
- [ ] Timeout handled gracefully
- [ ] Can retry search

### **Tracking**
- [ ] Mechanic location updates in real-time
- [ ] ETA calculates correctly
- [ ] ETA auto-refreshes every 30 seconds
- [ ] Route line displays on map
- [ ] Notifications sent at milestones (5 min, 1 min, arrived)

### **Chat**
- [ ] Chat screen opens
- [ ] Messages send successfully
- [ ] Messages display in real-time
- [ ] Images can be shared
- [ ] Call buttons work

### **Payment**
- [ ] Price breakdown correct
- [ ] Tip selection works
- [ ] Promo codes validate
- [ ] Payment methods display
- [ ] Processing fee calculated
- [ ] Cash payment records correctly
- [ ] Digital payment redirects to PayMongo
- [ ] Payment success shows
- [ ] Receipt generated
- [ ] Notification sent to mechanic

### **Rating**
- [ ] Rating prompt appears
- [ ] Stars can be selected
- [ ] Tags can be selected
- [ ] Review text can be entered
- [ ] Rating saves correctly
- [ ] Mechanic average updates

---

## 🎓 Best Practices

### **For Developers**

1. **Always handle loading states**
   ```dart
   if (_isLoading) {
     return LoadingWidget();
   }
   ```

2. **Show user feedback**
   ```dart
   ToastHelper.showSuccess(context, "Booking confirmed!");
   ```

3. **Validate before API calls**
   ```dart
   if (!isValidPromoCode(code)) {
     showError("Invalid code");
     return;
   }
   ```

4. **Clean up listeners**
   ```dart
   @override
   void dispose() {
     _subscription?.cancel();
     super.dispose();
   }
   ```

5. **Log important events**
   ```dart
   FirebaseAnalytics.instance.logEvent(
     name: 'emergency_request_created',
     parameters: {'service_type': serviceType},
   );
   ```

---

## 🚀 Future Enhancements

### **Phase 2 Features**
- [ ] Live voice call in-app (Agora integration)
- [ ] Multiple mechanics bidding on request
- [ ] Scheduled bookings (book for later)
- [ ] Recurring services subscription
- [ ] In-app navigation to mechanic

### **Phase 3 Features**
- [ ] AI price estimation
- [ ] Video call for diagnosis
- [ ] Parts ordering integration
- [ ] Insurance claim integration
- [ ] Loyalty tier system with benefits

---

**Document Version**: 1.0  
**Last Updated**: February 8, 2026  
**Maintained By**: ARS Development Team  
**Questions?** Contact: dev@arsphilippines.com

---

## 📞 Support

If you encounter any issues or need clarification on the booking flow:

1. Check this documentation first
2. Review related documentation files
3. Check code comments in implementation files
4. Contact the development team

**Emergency Contact**: dev-support@arsphilippines.com  
**Documentation Feedback**: docs@arsphilippines.com
