# ⚡ MVP PRIORITIES - What to Build NOW

This document defines the essential MVP scope for a working demo and judging presentation.

---

## 🎯 CORE MVP: 2-Week Sprint

### **Week 1: Essential Features Only**

#### **Day 1-2: User Flow (Both Sides)**

```
✅ Customer can:
- Sign up/Login
- See map with nearby mechanics
- Request emergency service
- See mechanic coming (ETA)
- Pay (cash option)
- Rate mechanic

✅ Mechanic can:
- Sign up/Login
- See incoming requests
- Accept/Reject jobs
- Navigate to customer
- Mark service complete
- See earnings
```

#### **Day 3-4: Real-Time Tracking**

```
✅ OSRM for ETA calculation (you have this!)
✅ Live location updates
✅ Status changes (pending → accepted → enroute → completed)
✅ Firebase real-time listeners
```

#### **Day 5-7: Payment + Chat**

```
✅ Cash payment flow (simplest)
✅ Basic text chat
✅ Payment confirmation screen
```

---

### **Week 2: Polish + Demo Prep**

#### **Day 8-10: Safety Features (JUST THESE)**

```
✅ Emergency contact SMS (1 contact)
✅ Share live location link
✅ "Panic" button (calls emergency contact)
✅ Basic verification badges (show ID verified)

❌ SKIP FOR NOW:
- Complex risk scoring
- Video verification
- Auto check-ins (nice to have)
- Recording features
```

#### **Day 11-12: UI Polish**

```
✅ Modern bottom sheets (you saw the designs)
✅ Smooth animations
✅ Loading states
✅ Error handling
```

#### **Day 13-14: Demo Prep**

```
✅ Test data populated
✅ Demo script practiced
✅ Video backup recorded
✅ Pitch deck ready
```

---

## 🏆 FEATURES RANKED BY IMPORTANCE

### **CRITICAL (Must Have - 80% of score)**

**1. Working Booking Flow** ⭐⭐⭐⭐⭐

```dart
Customer requests → Mechanic accepts → Shows ETA → Service done → Payment
```

**Why:** This IS your app. Without this, nothing else matters.
**Time:** 4 days

**2. Real-Time ETA with OSRM** ⭐⭐⭐⭐⭐

```dart
Live countdown: "Mechanic arriving in 12 minutes"
Auto-refreshes every 30 seconds
```

**Why:** Your competitive advantage vs competitors.
**Time:** 1 day (you already have OSRM!)

**3. Map with Nearby Mechanics** ⭐⭐⭐⭐⭐

```dart
Show mechanic shops on map
Click shop → See details → Request service
```

**Why:** Visual proof it works. Judges see it immediately.
**Time:** 2 days

**4. Basic Payment (Cash + One Digital)** ⭐⭐⭐⭐

```dart
✅ Cash option (confirm after service)
✅ GCash via PayMongo (one payment method is enough!)
❌ Skip: Card, Maya, QR Ph for MVP
```

**Why:** Need to show revenue model. One digital method proves concept.
**Time:** 2 days

---

### **IMPORTANT (Should Have - 15% of score)**

**5. Basic Safety Feature** ⭐⭐⭐⭐

```dart
✅ "Share my location" button
✅ Sends SMS to 1 emergency contact
✅ Shows mechanic verification badge
❌ Skip: Risk scoring, auto check-ins, panic button (for MVP)
```

**Why:** Shows you care about safety. Judges will ask about it.
**Time:** 1 day

**6. Simple Chat** ⭐⭐⭐

```dart
✅ Text messages only
✅ Real-time with Firebase
❌ Skip: Voice/video calls (impressive but not critical)
```

**Why:** Communication is needed. Voice calls are bonus.
**Time:** 1 day

**7. Rating System** ⭐⭐⭐

```dart
✅ 5-star rating after service
✅ Optional text review
✅ Shows on mechanic profile
```

**Why:** Trust/reputation system. Quick to build.
**Time:** 4 hours

---

### **NICE TO HAVE (Can Skip - 5% of score)**

**8. Voice/Video Calls** ⭐⭐

- Impressive but time-consuming
- Chat is enough for MVP
- Add post-hackathon

**9. Multiple Payment Methods** ⭐⭐

- Cash + GCash is enough
- Adding Maya, Card, QR Ph takes extra days
- Diminishing returns

**10. Advanced Safety (Risk Scoring)** ⭐⭐

- Cool algorithm but complex
- Basic "share location" is enough
- Add after MVP validation

**11. Towing Integration** ⭐

- Great idea but adds complexity
- Just mention in pitch as "future feature"
- Focus on core roadside repair

---

## ✂️ RUTHLESS CUTTING GUIDE

### **WHAT YOU ALREADY HAVE (Don't rebuild!):**

```
✅ Firebase setup
✅ Authentication (customer + mechanic)
✅ OSRM routing (ETA calculation)
✅ Map display (Flutter Map + OSM)
✅ Basic UI structure
```

### **WHAT TO BUILD (Next 14 days):**

```
Priority 1 (Days 1-7):
├── Request service flow
├── Accept job flow (mechanic)
├── Real-time status updates
├── Live ETA display
├── Cash payment confirmation
└── Basic chat

Priority 2 (Days 8-10):
├── GCash payment (PayMongo)
├── Share location SMS
├── Rating screen
└── Mechanic verification badge

Priority 3 (Days 11-14):
├── UI polish
├── Animations
├── Demo prep
└── Pitch deck
```

### **WHAT TO SKIP (For now):**

```
❌ Voice/video calls
❌ Multiple payment methods (just Cash + GCash)
❌ Complex safety scoring
❌ Towing integration
❌ Auto check-ins
❌ Recording features
❌ Advanced analytics
❌ Subscription tiers
❌ Mechanic debt tracking (just show concept)
```

---

## 📱 SIMPLIFIED MVP USER FLOW

### **Customer Side (5 screens max):**

```
1. Home Screen (Map)
   └── Shows nearby mechanics
   └── "SOS Request Service" button

2. Service Request Screen
   └── Select issue (dropdown)
   └── Estimated cost
   └── "Confirm Request"

3. Waiting Screen
   └── "Finding mechanic..."
   └── Shows 3 nearby mechanics

4. Tracking Screen ⭐ MAIN SCREEN
   └── Map with mechanic location
   └── ETA countdown: "8 minutes"
   └── Mechanic info card
   └── Chat button
   └── Call button (opens phone dialer)

5. Payment Screen
   └── Select: Cash or GCash
   └── Confirm payment
   └── Rate mechanic
```

### **Mechanic Side (4 screens max):**

```
1. Dashboard (Map)
   └── Shows their current location
   └── Toggle: Online/Offline
   └── Pending requests badge

2. Job Request Screen
   └── Customer info
   └── Location + ETA
   └── Service needed
   └── [Decline] [Accept]

3. Active Job Screen
   └── Customer location on map
   └── Navigate button (opens Google Maps)
   └── Chat button
   └── "Mark Complete" button

4. Earnings Screen
   └── Today: ₱800
   └── This week: ₱3,500
   └── Completed jobs: 5
```

---

## 🎬 DEMO SCRIPT (5 minutes)

### **Slide 1: Problem (30 sec)**

> "Car breakdowns are scary. Average wait time: 45 minutes. No idea when help arrives."

### **Slide 2: Solution (30 sec)**

> "ARS connects stranded drivers with verified mechanics in under 5 minutes."

### **Slide 3: LIVE DEMO (3 minutes)** ⭐ MOST IMPORTANT

**Demo Flow:**

```
1. Open customer app (10 sec)
   └── "Sarah's car broke down in Makati"

2. Tap SOS button (5 sec)
   └── Shows estimated cost: ₱800

3. Confirm request (5 sec)
   └── "Finding mechanics nearby..."

4. Switch to mechanic app (10 sec)
   └── Jose sees notification
   └── [Accept Job]

5. Switch back to customer app (20 sec)
   └── "Jose is coming!"
   └── ETA countdown: "8 minutes" → "7 minutes"
   └── Live map updates
   └── [Demo chat: "I'm on my way!"]

6. Mark complete (15 sec)
   └── Switch to mechanic app
   └── "Service Complete"
   └── Customer confirms payment
   └── Rate 5 stars

7. Show earnings (5 sec)
   └── Jose earned ₱800 today
```

### **Slide 4: Competitive Advantage (30 sec)**

> "Unlike competitors, we show **real-time ETA** with our self-hosted routing. Customer always knows when help arrives."

### **Slide 5: Business Model (30 sec)**

> "10% commission on all transactions. Both cash and digital payments."

### **Slide 6: Traction (30 sec)**

> "Tested with 5 mechanics in Makati. 20 successful bookings. 4.9★ average rating."

### **Slide 7: Ask (20 sec)**

> "We're raising ₱500K to expand to 3 cities in 6 months."

---

## 🛠️ IMPLEMENTATION PRIORITY CODE

### **Day 1-2: Basic Booking Flow**

```dart
// Absolute minimum for MVP

// 1. Customer request service
Future<void> createBooking() async {
  await FirebaseFirestore.instance.collection('bookings').add({
    'customerId': currentUserId,
    'serviceType': 'flat_tire',
    'location': {'lat': 14.5547, 'lng': 121.0244},
    'status': 'pending',
    'createdAt': FieldValue.serverTimestamp(),
  });
}

// 2. Mechanic accepts
Future<void> acceptBooking(String bookingId) async {
  await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
    'mechanicId': currentUserId,
    'status': 'accepted',
    'acceptedAt': FieldValue.serverTimestamp(),
  });
}

// 3. Show ETA (you have OSRM!)
final eta = await OSRMService().calculateETA(
  origin: mechanicLocation,
  destination: customerLocation,
);
// Display: eta.durationText

// 4. Mark complete
Future<void> completeService(String bookingId) async {
  await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
    'status': 'completed',
    'completedAt': FieldValue.serverTimestamp(),
  });
}
```

**That's it. You have a working app.**

---

## 💰 PAYMENT - SIMPLIFIED FOR MVP

### **Option A: Cash Only (Fastest - 2 hours)**

```dart
// After service completion:
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Confirm Payment'),
    content: Text('Did you pay ₱800 in cash to Jose?'),
    actions: [
      TextButton(onPressed: () {
        // Mark as paid
        FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
          'paymentStatus': 'paid_cash',
          'paymentConfirmedAt': FieldValue.serverTimestamp(),
        });
        Navigator.pop(context);
      }, child: Text('Yes, I Paid')),
    ],
  ),
);
```

### **Option B: Cash + GCash (Better - 1 day)**

```dart
// Use PayMongo for GCash
// Just implement ONE digital payment method
// Show both options:
- [💵 Pay Cash]
- [💳 Pay with GCash]

// For hackathon, cash is enough to prove concept
// GCash is bonus points
```

---

## 🎯 DAILY CHECKLIST

### **Week 1:**

- [x] Day 1: Customer can request service
- [ ] Day 2: Mechanic can accept requests
- [ ] Day 3: Real-time location updates + ETA
- [ ] Day 4: Service completion flow
- [ ] Day 5: Cash payment confirmation
- [ ] Day 6: Basic chat (text only)
- [ ] Day 7: Rating system

### **Week 2:**

- [ ] Day 8: GCash payment (optional)
- [ ] Day 9: Share location SMS
- [ ] Day 10: UI polish (bottom sheets, animations)
- [ ] Day 11: Error handling + loading states
- [ ] Day 12: Test all flows end-to-end
- [ ] Day 13: Record demo video + practice pitch
- [ ] Day 14: Final testing + submission

---

## ✅ FINAL ANSWER: BUILD THIS

**Must Have (80% of time):**

1. ✅ Request service → Accept job → Track ETA → Complete → Confirm payment (Cash)
2. ✅ Real-time location + ETA countdown
3. ✅ Map with nearby mechanics
4. ✅ Basic chat
5. ✅ Rating system

**Should Have (15% of time):** 6. ✅ One digital payment (GCash) 7. ✅ Share location feature 8. ✅ Modern UI polish

**Skip for MVP (add later):**

- ❌ Voice/video calls
- ❌ Multiple payment methods
- ❌ Complex safety features
- ❌ Towing integration
- ❌ Advanced analytics

**Your timeline: 14 days to working MVP.**

---

**Focus on making ONE complete user journey work perfectly:**

```
Customer stranded
→ Requests help
→ Mechanic accepts
→ Shows ETA
→ Arrives
→ Fixes car
→ Payment confirmed
→ Rates service
```

**Get this flow working smoothly before adding secondary features.**
