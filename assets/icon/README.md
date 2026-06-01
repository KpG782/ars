# App Icon Assets

## Current Setup

The app uses **"ARS Roadside"** as the display name with a teal/green (#00BFA5) color scheme.

## Icon Requirements

### For automatic icon generation, you need:

1. **app_icon.png** (1024x1024px)

   - Main app icon with transparent or colored background
   - Should contain the "ARS" logo/text clearly visible
   - Use teal (#00BFA5) as primary color

2. **app_icon_foreground.png** (1024x1024px) [Optional for Android Adaptive Icons]
   - Foreground layer for Android adaptive icons
   - Center safe zone: 432x432px from center
   - Should be the main logo only (no background)

## Icon Design Suggestions

### Option 1: Simple Text Badge (Recommended for Quick Setup)

- White background with rounded corners
- Large "ARS" text in teal (#00BFA5)
- Small wrench/car icon below or beside text
- Clean, modern sans-serif font

### Option 2: Gradient Circle

- Circular icon with gradient (light teal to dark teal)
- White "ARS" text in center
- Small wrench or road icon at bottom

### Option 3: Road/Service Theme

- Stylized road going to horizon
- "ARS" overlaid on road
- Wrench/car silhouette integrated

## How to Create Your Icon

### Quick Method (Using Online Tools):

1. Use Canva, Figma, or Adobe Express
2. Create 1024x1024px canvas
3. Design your icon with "ARS" prominently displayed
4. Export as PNG
5. Save as `app_icon.png` in this folder

### Professional Method:

1. Hire a designer on Fiverr/99designs ($20-100)
2. Provide them with:
   - App name: ARS Roadside
   - Color: #00BFA5 (teal)
   - Theme: Automotive roadside assistance
   - Need: 1024x1024px PNG

## After Adding Your Icon

Run these commands in terminal:

```bash
# Install dependencies
flutter pub get

# Generate app icons
flutter pub run flutter_launcher_icons

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Current Placeholder

Until you add your custom icon, the app will use the default Flutter icon.
The teal color (#00BFA5) has been set as the adaptive icon background for Android.

## Colors Used in App

- Primary: #00BFA5 (Teal)
- Accent: #00897B (Dark Teal)
- Error/Emergency: #FF5252 (Red)
