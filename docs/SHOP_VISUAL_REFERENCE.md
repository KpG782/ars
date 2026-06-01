# Shop Implementation - Quick Visual Reference

## Map Display

```
┌─────────────────────────────────────────┐
│  🔍 [Search Bar]          ☰ [Menu]     │
├─────────────────────────────────────────┤
│                                         │
│     🟢 AutoFix       🟠 SpeedTech      │
│                                         │
│   ⚫ City Motors    🟢 Elite Auto      │
│                                         │
│            📍 You                       │
│                                         │
│     ⚫ Quick Fix     🟢 Premium        │
│                                         │
│   ⚫ Metro Garage   🔵 Roadside        │
│                                         │
└─────────────────────────────────────────┘

Legend:
🟢 = Partner + Open
🟠 = Partner + Closed  
⚫ = Non-Partner
🔵 = 24/7 Shop
📍 = Your Location
```

## Shop Marker Details

```
   ┌────────┐
   │   🏪   │  ← Icon (Store for partners)
   └────────┘
       │
   ┌────────┐
   │AutoFix │  ← Shop name label
   └────────┘
```

## Shop Details Bottom Sheet Layout

```
╔═══════════════════════════════════════════╗
║  ━━━━  (Drag Handle)                      ║
╠═══════════════════════════════════════════╣
║                                           ║
║  🏪 AutoFix Pro Garage         [PARTNER] ║
║  ⭐⭐⭐⭐⭐ 4.8 (234 reviews)            ║
║                                           ║
║  ┌──────────────────────────────────────┐║
║  │ ✅ Open Now  8:00 AM - 6:00 PM      │║
║  └──────────────────────────────────────┘║
║                                           ║
║  ┌──────────┐    ┌──────────┐           ║
║  │📍 2.3 km │    │💰 ₱500-  │           ║
║  │ Distance │    │  3000    │           ║
║  └──────────┘    └──────────┘           ║
║                                           ║
║  About                                    ║
║  Expert auto repair with 10+ years...    ║
║                                           ║
║  Services Offered                         ║
║  [Engine] [Brake] [Oil] [Tire] [AC]     ║
║  [Battery] [Electrical]                   ║
║                                           ║
║  ┌──────────────────────────────────────┐║
║  │ 📍 123 Ayala Ave, Makati City        │║
║  │ ☎️ +63 917 123 4567                  │║
║  │ 👤 Owner: Juan dela Cruz             │║
║  └──────────────────────────────────────┘║
║                                           ║
║  ┌──────────────────────────────────────┐║
║  │ ✅ Request Service from This Shop    │║
║  └──────────────────────────────────────┘║
║                                           ║
╚═══════════════════════════════════════════╝
```

## Color Coding System

### Marker Colors
| Status | Color | Meaning |
|--------|-------|---------|
| 🟢 Green | `Colors.green` | Partner shop, currently open |
| 🟠 Orange | `Colors.orange` | Partner shop, currently closed |
| ⚫ Grey | `Colors.grey` | Non-partner (listed only) |
| 🔵 Teal | `Color(0xFF00BFA5)` | Currently selected shop |

### Status Indicators
```dart
// Open Status
┌──────────────────────────────┐
│ ✅ Open Now  8:00 AM - 6:00 PM │  ← Green background
└──────────────────────────────┘

// Closed Status  
┌──────────────────────────────┐
│ ❌ Closed  8:00 AM - 6:00 PM  │  ← Red background
└──────────────────────────────┘
```

## Mock Shop Data Overview

```
Metro Manila Shops Distribution:

North Area:
├── North Star Auto Repair (Caloocan) ⚫
└── Premium Auto Works (San Juan) 🟢

Central Area:
├── SpeedTech Auto Care (QC, Cubao) 🟢
├── City Motors Workshop (Mandaluyong) ⚫
└── Elite Auto Repair (Pasig, Ortigas) 🟢

Makati/BGC:
└── AutoFix Pro Garage (Makati) 🟢

South Area:
├── Quick Fix Auto Shop (Taguig) ⚫
├── Metro Garage Services (Manila) ⚫
├── Roadside Auto Clinic (Pasay) 🔵 24/7
└── South Auto Experts (Paranaque) 🟢
```

## Rating Distribution

```
4.9 ⭐⭐⭐⭐⭐  SpeedTech, Premium Auto (2 shops)
4.8 ⭐⭐⭐⭐⭐  AutoFix Pro (1 shop)
4.7 ⭐⭐⭐⭐    Elite Auto, South Auto (2 shops)
4.6 ⭐⭐⭐⭐    City Motors, North Star (2 shops)
4.5 ⭐⭐⭐⭐    Quick Fix (1 shop)
4.4 ⭐⭐⭐⭐    Metro Garage (1 shop)
4.3 ⭐⭐⭐⭐    Roadside Auto (1 shop)
```

## Service Coverage

```
Most Common Services:
├── Oil Change (10/10) ████████████████████
├── Brake Service (9/10) ██████████████████
├── Tire Service (9/10) ██████████████████
├── Engine Repair (8/10) ████████████████
├── AC Repair (7/10) ██████████████
├── Battery Service (6/10) ████████████
├── Electrical (6/10) ████████████
├── Transmission (3/10) ██████
└── Suspension (3/10) ██████
```

## Operating Hours

```
24/7:
└── Roadside Auto Clinic (Pasay)

Extended Hours (7AM-7PM+):
├── SpeedTech Auto Care (7AM-7PM)
├── Quick Fix Auto Shop (7AM-8PM)
└── Premium Auto Works (8AM-7PM)

Standard Hours (8AM-6PM):
├── AutoFix Pro Garage
├── City Motors Workshop
├── Elite Auto Repair
├── Metro Garage Services
├── South Auto Experts
└── North Star Auto Repair
```

## Price Ranges

```
Budget-Friendly:
├── Quick Fix: ₱300-2000
├── City Motors: ₱400-2500
└── North Star: ₱450-2800

Mid-Range:
├── AutoFix Pro: ₱500-3000
├── Metro Garage: ₱500-3200
├── SpeedTech: ₱600-3500
└── South Auto: ₱550-3300

Premium:
├── Elite Auto: ₱700-4000
└── Premium Auto: ₱800-5000
```

## User Interaction Flow

```
┌─────────────────────────────────────┐
│ 1. User opens app                   │
│    └─> Location detected            │
│         └─> 10 shops load on map    │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 2. User sees color-coded markers    │
│    ├─> Green = Open & Partner       │
│    ├─> Orange = Closed Partner      │
│    └─> Grey = Non-partner           │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 3. User taps a shop marker          │
│    └─> Bottom sheet appears         │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 4. User views shop details          │
│    ├─> Rating & reviews             │
│    ├─> Distance from user           │
│    ├─> Services offered             │
│    ├─> Price range                  │
│    └─> Contact info                 │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 5. User action                      │
│    ├─> Request service (if partner) │
│    └─> View info only (if closed)   │
└─────────────────────────────────────┘
```

## Technical Implementation

### File Structure
```
lib/features/customer/booking/
├── data/
│   ├── models/
│   │   ├── mechanic.dart (existing)
│   │   └── mechanic_shop.dart ✨ NEW
│   └── services/
│       └── shop_service.dart ✨ NEW
└── presentation/
    └── screens/
        └── booking.dart (updated) ✨
```

### Key Methods Added

```dart
// Load shops near user
void _loadNearbyShops() {
  _nearbyShops = ShopService.getShopsNearby(
    _currentPosition!,
    radiusKm: 20.0,
  );
}

// Show shop details
void _showShopDetails(MechanicShop shop) {
  // Displays comprehensive bottom sheet
}

// Calculate distance
shop.distanceFrom(userLocation)  // Returns km
shop.getDistanceString(userLocation)  // Returns "2.3 km"

// Check if open
shop.isOpen  // Auto-calculated based on time
shop.getTodayHours()  // Returns "8:00 AM - 6:00 PM"
```

## Demo Highlights

### What Makes This Implementation Special:

1. **Real-time Status** ✅
   - Automatically detects if shop is open based on current time
   - Updates marker color accordingly

2. **Smart Distance Calculation** 📍
   - Shows distance in km or meters
   - Helps users find nearest shops

3. **Partner Distinction** 🏪
   - Clear visual indicators
   - Different interaction flows

4. **Rich Information** 📋
   - Ratings, reviews, services
   - Contact details, operating hours
   - Price ranges

5. **Professional UI** 🎨
   - Color-coded markers
   - Smooth bottom sheets
   - Clean information cards

6. **Ready for Production** 🚀
   - Easy to swap mock data with Firebase
   - Scalable architecture
   - Clean separation of concerns

This implementation is perfect for demos, pitches, and hackathons! 🎉
