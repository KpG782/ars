# Mechanic Shop Implementation

## Overview
This implementation adds 10 random mechanic shop locations to the user dashboard map for demonstration/mockup purposes. Users can now see, interact with, and get details about nearby mechanic shops.

## What Was Added

### 1. **MechanicShop Model** 
`lib/features/customer/booking/data/models/mechanic_shop.dart`

A comprehensive model representing a mechanic shop with:
- Basic info (id, name, location, address, phone)
- Services offered (list of available services)
- Rating and reviews
- Operating hours (with auto-detection of open/closed status)
- Price range
- Partner status (distinguishes partner shops from listed shops)
- Owner information
- Real-time availability (number of available mechanics)
- Distance calculation from user location

**Key Features:**
- Automatic open/closed status checking based on current time
- Distance calculation and formatting
- Today's hours display
- JSON serialization support

### 2. **ShopService** 
`lib/features/customer/booking/data/services/shop_service.dart`

Mock data service providing 10 realistic mechanic shops across Metro Manila:

**Shop Locations:**
1. **AutoFix Pro Garage** - Makati, BGC Area (Partner, Open 8AM-6PM)
2. **SpeedTech Auto Care** - Quezon City, Cubao (Partner, Open 7AM-7PM)
3. **City Motors Workshop** - Mandaluyong (Non-partner)
4. **Elite Auto Repair Center** - Pasig, Ortigas (Partner)
5. **Quick Fix Auto Shop** - Taguig (Non-partner, 7AM-8PM)
6. **Metro Garage Services** - Manila, Ermita (Non-partner)
7. **Premium Auto Works** - San Juan (Partner, Premium service)
8. **Roadside Auto Clinic** - Pasay (24/7 shop, Non-partner)
9. **South Auto Experts** - Paranaque (Partner)
10. **North Star Auto Repair** - Caloocan (Non-partner)

**Service Methods:**
- `getMockShops()` - Get all 10 shops
- `getShopsNearby()` - Filter by distance and partner status
- `getOpenShops()` - Get only currently open shops
- `getPartnerShops()` - Get only partner shops

### 3. **Updated Booking Screen**
`lib/features/customer/booking/presentation/screens/booking.dart`

**New State Variables:**
- `_nearbyShops` - List of shops to display
- `_selectedShop` - Currently selected shop
- `_showShopsOnMap` - Toggle for showing/hiding shop markers

**New Methods:**
- `_loadNearbyShops()` - Loads shops near user location (20km radius)
- `_showShopDetails()` - Displays detailed shop information in a bottom sheet
- `_buildInfoCard()` - Helper widget for info cards

**Map Updates:**
Shop markers now appear with:
- **Green circle**: Partner shop, currently open
- **Orange circle**: Partner shop, currently closed  
- **Grey circle**: Non-partner shop
- **Teal circle**: Selected shop
- Store icon for partners, outlined store for non-partners
- Shop name label below marker

### 4. **Shop Details Bottom Sheet**

When a user taps on a shop marker, they see:

**Header Section:**
- Shop name
- Partner badge (if applicable)
- Rating with stars and review count
- Open/Closed status with today's hours

**Information Cards:**
- Distance from user
- Price range

**About Section:**
- Shop description

**Services Section:**
- All available services in chip format

**Contact Information:**
- Full address
- Phone number
- Owner name

**Action Button:**
- "Request Service" (only for partner shops that are open)
- Info message for closed or non-partner shops

## User Experience

### Visual Indicators

1. **Shop Status Colors:**
   - 🟢 Green = Partner + Open
   - 🟠 Orange = Partner + Closed
   - ⚫ Grey = Not a partner
   - 🔵 Teal = Currently selected

2. **Partner Badge:**
   - Visible "PARTNER" badge on shop details
   - Different icon styles (filled vs outlined)

3. **Interactive Elements:**
   - Tap any shop marker to see details
   - Scroll through services
   - See distance from your location
   - View operating hours

### Key Features for Demo

1. **Real-time Open/Closed Detection:**
   - Automatically checks current time against operating hours
   - Shows appropriate status indicator

2. **Distance Calculation:**
   - Shows distance in kilometers or meters
   - Helps users find nearest shops

3. **Partner vs Non-Partner:**
   - Clear visual distinction
   - Only partners can receive service requests
   - Others are "listed" for future onboarding

4. **Service Categories:**
   - Engine Repair
   - Brake Service
   - Oil Change
   - Tire Service
   - AC Repair
   - Electrical Work
   - Battery Service
   - Transmission
   - Suspension
   - Detailing

## Demo Flow

1. User opens the app and sees their location
2. Map automatically loads with 10 shop markers
3. User can see shops in different colors based on status
4. Tap any shop marker to view full details
5. See distance, rating, services, and contact info
6. Request service from partner shops (if open)
7. Get helpful messages for closed/non-partner shops

## Technical Details

### Location Spread
Shops are distributed across Metro Manila:
- Makati (BGC area)
- Quezon City (Cubao)
- Mandaluyong
- Pasig (Ortigas)
- Taguig
- Manila (Ermita)
- San Juan
- Pasay
- Paranaque
- Caloocan

### Data Structure
Each shop includes:
- Realistic ratings (4.3 - 4.9)
- Review counts (89 - 312)
- Price ranges (₱300 - ₱5000)
- Operating hours (various schedules)
- Multiple services (4-8 per shop)
- Contact information
- Owner names

### Partner Distribution
- 5 Partner shops (50%)
- 5 Non-partner shops (50%)
- 1 24/7 shop (Roadside Auto Clinic)

## Future Enhancements

1. **Firebase Integration:**
   - Replace mock data with real Firebase collection
   - Real-time updates
   - Add/edit shops through admin panel

2. **Advanced Filtering:**
   - Filter by services offered
   - Filter by price range
   - Sort by rating or distance

3. **Navigation:**
   - Get directions to shop
   - Call shop directly from app

4. **Booking Flow:**
   - Schedule appointments
   - See real-time mechanic availability
   - Track service status

5. **Reviews:**
   - View customer reviews
   - Add photos
   - Rate services after completion

## Testing Checklist

- [x] Shops load when user location is determined
- [x] Shop markers appear on map
- [x] Different colors for different statuses
- [x] Tap markers to open details
- [x] Details bottom sheet scrolls properly
- [x] Open/closed status is accurate
- [x] Distance calculation works
- [x] Services display correctly
- [x] Partner badge shows for partners only
- [x] Action button only for open partner shops

## Files Modified/Created

### Created:
1. `lib/features/customer/booking/data/models/mechanic_shop.dart`
2. `lib/features/customer/booking/data/services/shop_service.dart`
3. `docs/SHOP_IMPLEMENTATION.md` (this file)

### Modified:
1. `lib/features/customer/booking/presentation/screens/booking.dart`
   - Added shop imports
   - Added shop state variables
   - Added `_loadNearbyShops()` method
   - Added `_showShopDetails()` method
   - Added `_buildInfoCard()` helper
   - Updated map markers to include shops
   - Updated `_initializeScreen()` to load shops

## Summary

This implementation provides a fully functional shop discovery feature with:
- ✅ 10 realistic mock shops with complete data
- ✅ Interactive map markers with color-coded status
- ✅ Detailed shop information in bottom sheet
- ✅ Real-time open/closed detection
- ✅ Distance calculation from user
- ✅ Partner/non-partner distinction
- ✅ Service listings
- ✅ Contact information
- ✅ Professional UI/UX

The feature is ready for demonstration and can easily be extended with Firebase integration for production use.
