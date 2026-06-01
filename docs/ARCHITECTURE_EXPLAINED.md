# Architecture Explained - Simple Guide

## What is This Project's Structure?

This project uses **Clean Architecture** with **Feature-Based Organization**. Think of it like organizing a house - instead of throwing everything in one room, we organize things by purpose and keep related items together.

---

## 🏗️ The Big Picture

### Clean Architecture (In Simple Terms)

Imagine building with LEGO blocks. Clean Architecture means:
- **Separation**: Different types of blocks go in different boxes
- **Independence**: You can change one box without messing up others
- **Testability**: Easy to check if each piece works correctly
- **Reusability**: Use the same pieces in different projects

### Feature-Based Organization

Instead of organizing by type (all screens together, all data together), we organize by **what the feature does**:
- Customer booking? Everything related to booking lives in one place
- Mechanic dashboard? All dashboard code stays together
- Chat feature? All chat-related code in its folder

---

## 📁 Folder Structure Breakdown

### `/lib` - The Main Code Folder

This is where ALL your application code lives. Everything that makes your app work is here.

---

## 🎯 `/core` - The Foundation

**Think of this as**: The toolbox that EVERYONE uses. Shared tools, services, and utilities.

### `core/auth/`
**Purpose**: Handles login, logout, and user authentication  
**Simple Explanation**: This is your security guard. It checks who you are and lets you in or out.  
**Contains**: 
- `auth_service.dart` - Manages Firebase login/logout

### `core/constants/`
**Purpose**: Stores values that never change  
**Simple Explanation**: Like a dictionary of fixed answers. Colors, text, numbers that stay the same throughout the app.  
**Contains**:
- `app_constants.dart` - Fixed numbers and settings
- `app_strings.dart` - Text that appears in the app

### `core/models/`
**Purpose**: Shared data structures  
**Simple Explanation**: Templates for common information used everywhere in the app.  
**Contains**:
- `notification_model.dart` - Structure for notification data

### `core/providers/`
**Purpose**: Riverpod state management setup  
**Simple Explanation**: The "control center" that manages and shares data across the entire app. Like a power grid distributing electricity to every house.  
**Contains**:
- `core_providers.dart` - Firebase, notification, location providers
- `providers.dart` - Exports all providers (easy access)

### `core/services/`
**Purpose**: Shared business logic and external integrations  
**Simple Explanation**: Workers that do specific jobs for the whole app.  
**Contains**:
- `location_sharing_service.dart` - Tracks and shares location
- `notification_service.dart` - Sends notifications to users
- `osrm_service.dart` - Calculates routes and directions

### `core/theme/`
**Purpose**: App-wide styling and appearance  
**Simple Explanation**: Your app's "fashion designer" - defines colors, fonts, and how things look.  
**Contains**:
- `app_theme.dart` - Colors, fonts, button styles

### `core/utils/`
**Purpose**: Helper functions and utilities  
**Simple Explanation**: Small tools that make common tasks easier.  
**Contains**:
- `toast_helper.dart` - Shows quick messages to users

### `core/widgets/`
**Purpose**: Reusable UI components  
**Simple Explanation**: Pre-built pieces you can use anywhere. Like having ready-made furniture instead of building from scratch each time.  
**Contains**:
- `custom_button.dart` - Styled button widget
- `custom_text_field.dart` - Styled input field widget

---

## 🎪 `/features` - The Main Actors

**Think of this as**: Different departments in a company. Each department handles its own business.

---

## 👤 `/features/customer` - Customer Side Features

Everything customers (people needing help) can do.

### `customer/auth/`
**Purpose**: Customer login and signup  
**Simple Explanation**: The entrance door for customers. Sign up, log in, verify account.  
**Structure**:
```
data/repositories/     → Talks to Firebase (gets/saves data)
domain/models/         → User information structure
domain/repositories/   → Rules for what data operations are allowed
presentation/screens/  → What customers see (login screen, signup screen)
```

### `customer/booking/`
**Purpose**: Booking mechanics or shops  
**Simple Explanation**: The heart of the customer app. Find mechanics, request help, track progress.  
**Structure**:
```
data/repositories/           → Saves booking info to database
domain/models/               → Booking information structure
domain/repositories/         → Rules for booking operations
presentation/controllers/    → Brain that controls booking logic
presentation/providers/      → Riverpod state management for booking
presentation/screens/        → Booking map and UI
presentation/widgets/        → Reusable booking components (search bar, panels)
  ├── panels/                → Bottom sheets (service selection, emergency)
  ├── booking_map_widget.dart
  ├── mechanic_details_sheet.dart
  └── shop_details_sheet.dart
```

### `customer/dashboard/`
**Purpose**: Customer home screen  
**Simple Explanation**: First thing customers see after logging in. Overview of everything.

### `customer/data/models/`
**Purpose**: Shared customer data structures  
**Contains**:
- `mechanic.dart` - Information about mechanics

### `customer/feedback/`
**Purpose**: Rate and review mechanics  
**Simple Explanation**: Leave stars and comments after service.

### `customer/history/`
**Purpose**: View past bookings  
**Simple Explanation**: Your service history - like a receipt book.

### `customer/payment/`
**Purpose**: Handle payments  
**Simple Explanation**: Pay for services, view invoices.

### `customer/saved_places/`
**Purpose**: Save favorite locations  
**Simple Explanation**: Like bookmarks for addresses (home, work, etc.).

### `customer/support/`
**Purpose**: Get help or contact support  
**Simple Explanation**: Customer service desk.

### `customer/vehicles/`
**Purpose**: Manage customer vehicles  
**Simple Explanation**: Add and manage your cars/bikes.

---

## 🔧 `/features/mechanic` - Mechanic Side Features

Everything mechanics (service providers) can do.

### `mechanic/auth/`
**Purpose**: Mechanic login and registration  
**Simple Explanation**: The entrance door for mechanics. Sign up with skills, log in.  
**Structure**: Same as customer/auth (data → domain → presentation)

### `mechanic/chat/`
**Purpose**: Real-time messaging with customers  
**Simple Explanation**: Talk to customers directly in the app.  
**Structure**:
```
data/models/           → Message structure
data/repositories/     → Send/receive messages from database
domain/models/         → Chat data rules
domain/repositories/   → Chat operation rules
presentation/screens/  → Chat interface
presentation/widgets/  → Message bubbles, input field
```

### `mechanic/dashboard/`
**Purpose**: Mechanic home screen  
**Simple Explanation**: Command center for mechanics. See nearby requests, accept jobs, navigate to customers.  
**Structure**:
```
data/models/               → Service request structure
data/repositories/         → Get requests from database
domain/models/             → Dashboard data rules
domain/repositories/       → Dashboard operation rules
presentation/controllers/  → Brain controlling dashboard logic
presentation/providers/    → Riverpod state management for dashboard
presentation/screens/      → Main dashboard UI
presentation/widgets/      → Dashboard components
  ├── mechanic_map_widget.dart
  ├── nearby_requests_panel.dart
  ├── active_job_panel.dart
  ├── online_status_button.dart
  └── service_request_details_sheet.dart
```

### `mechanic/earnings/`
**Purpose**: Track income and payments  
**Simple Explanation**: Your wallet - see how much you've earned.

### `mechanic/services/`
**Purpose**: Manage services offered  
**Simple Explanation**: List what repairs you can do, set prices.

---

## 🎓 `/features/onboarding`

**Purpose**: First-time user experience  
**Simple Explanation**: The welcome tour when you first open the app. Shows how to use it.

---

## 📊 Clean Architecture Layers (Inside Each Feature)

Every feature follows the same pattern with 3 layers:

### 1. **Data Layer** (`data/`)
**What it does**: Talks to the outside world (Firebase, APIs, databases)  
**Simple explanation**: The messenger. Gets information from servers, saves information to databases.  
**Contains**:
- `repositories/` - Actual code that fetches/saves data
- `models/` - Data structures specific to external sources

### 2. **Domain Layer** (`domain/`)
**What it does**: Business rules and logic  
**Simple explanation**: The brain. Decides what's allowed and what isn't. Pure logic, no UI, no database code.  
**Contains**:
- `models/` - Clean data structures (what information looks like)
- `repositories/` - Interfaces (contracts) - "This is what we CAN do with data"

### 3. **Presentation Layer** (`presentation/`)
**What it does**: What users see and interact with  
**Simple explanation**: The face. Everything visual - screens, buttons, colors.  
**Contains**:
- `screens/` - Full screen pages
- `widgets/` - Reusable UI pieces
- `controllers/` - Logic that controls what screens do (old pattern)
- `providers/` - Riverpod state management (new pattern)

---

## 🔄 How It All Works Together

### Example: Customer Books a Mechanic

1. **User Action**: Customer taps "Find Mechanic" button
   - Happens in: `presentation/screens/booking_screen.dart`

2. **Controller/Provider**: Processes the request
   - Happens in: `presentation/providers/booking_providers.dart`

3. **Domain**: Checks business rules
   - "Is the customer logged in?"
   - "Is location available?"
   - Happens in: `domain/repositories/`

4. **Data**: Gets nearby mechanics from Firebase
   - Happens in: `data/repositories/mechanic_repository.dart`

5. **Data Returns**: List of mechanics comes back

6. **Provider Updates**: New data is stored in state
   - Happens in: `presentation/providers/`

7. **UI Updates**: Screen shows mechanics on map
   - Happens in: `presentation/screens/booking_screen.dart`

---

## 🎯 Why This Structure?

### ✅ Benefits

1. **Easy to Find Things**: Everything related to booking is in the `booking/` folder
2. **Easy to Test**: Each layer can be tested separately
3. **Easy to Change**: Change UI without touching database code
4. **Easy to Add Features**: Just create a new folder in `/features`
5. **Easy for Teams**: Different developers can work on different features without conflicts
6. **Easy to Understand**: New developers can find things logically

### 📦 Real-World Analogy

Think of it like a restaurant:

- **Core**: The kitchen equipment everyone uses (ovens, knives, plates)
- **Features**: Different food stations
  - `customer/booking/` = Ordering counter (take orders)
  - `mechanic/dashboard/` = Chef station (prepare orders)
  - `customer/payment/` = Cash register
- **Data Layer**: The suppliers (bring ingredients from outside)
- **Domain Layer**: The recipes (rules for making food)
- **Presentation Layer**: The dining area (what customers see)

---

## 🚀 Quick Reference

### Where to Find...

| I want to... | Look in... |
|-------------|-----------|
| Change app colors | `core/theme/app_theme.dart` |
| Add a new feature | Create new folder in `features/` |
| Add a shared service | `core/services/` |
| Create a reusable button | `core/widgets/` |
| Work on booking | `features/customer/booking/` |
| Work on mechanic dashboard | `features/mechanic/dashboard/` |
| Handle authentication | `core/auth/` or `features/*/auth/` |
| Manage app-wide state | `core/providers/` |
| Show notifications | `core/services/notification_service.dart` |
| Calculate routes | `core/services/osrm_service.dart` |

---

## 📝 Summary

**Clean Architecture** = Organized code in layers (data, business logic, UI)  
**Feature-Based** = Organized by what features do (booking, dashboard, chat)  
**Core** = Shared tools everyone uses  
**Features** = Individual app capabilities  

This structure makes your app:
- **Maintainable** - Easy to fix and update
- **Scalable** - Easy to add new features
- **Testable** - Easy to verify everything works
- **Understandable** - Easy for new developers to learn

---

## 🎓 Learning Path

If you're new to this structure:

1. Start with **one feature** (like `customer/booking/`)
2. Follow the **data → domain → presentation** flow
3. See how **providers** connect everything
4. Notice how **core/** services are used everywhere
5. Understand that each feature is **self-contained**

The more you explore, the more you'll see the pattern repeat everywhere!
