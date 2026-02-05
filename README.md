# NumFall Fusion

A production-ready physics-based number-merging puzzle game built with Flutter.

## 🎮 Game Description

NumFall Fusion is a mobile puzzle game where numbered tiles fall with gravity, collide realistically, and merge into higher values. The game features real physics simulation, dynamic difficulty progression, and a combo multiplier system.

## ✨ Features

- **Real Physics Engine** - Gravity, velocity, collision detection (AABB)
- **Premium UI** - Gradient themes, smooth animations, haptic feedback
- **Dark & Light Modes** - Full theming with persistent preferences
- **Score Tracking** - High score persistence with SharedPreferences
- **Combo System** - Chain merges for bonus multipliers
- **Responsive Design** - Adaptive layouts for all screen sizes
- **60 FPS Performance** - Frame-rate independent physics

## 🚀 Quick Start

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Build for production
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 📱 Screenshots

The game includes:
- Animated splash screen
- Home menu with high score
- Real-time game board with physics
- Pause menu
- Game over screen
- Settings (theme, sound, haptics)
- How to play instructions

## 🏗️ Architecture

This project follows **Clean Architecture** principles:

- **Core Layer**: Constants, themes, utilities
- **Data Layer**: Models, repositories (SharedPreferences)
- **Game Engine**: Physics simulation, game loop
- **State Management**: Riverpod providers
- **UI Layer**: Reusable widgets and feature screens

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed documentation.

## 🎯 Production Quality

This is NOT a demo or prototype. It's production-ready code with:

✅ Real physics (not fake animations)  
✅ Clean architecture (separation of concerns)  
✅ State management (Riverpod)  
✅ Persistent data (SharedPreferences)  
✅ Premium UI/UX (animations, theming)  
✅ Performance optimized (60 FPS)  
✅ Scalable & maintainable code  
✅ App store ready  

## 📊 Technical Stack

- **Flutter SDK**: 3.7.2+
- **Dart**: 3.x
- **State Management**: Riverpod 2.6.1
- **Persistence**: SharedPreferences 2.3.3
- **Architecture**: Clean Architecture pattern

## 🎲 Game Mechanics

### Physics
- Gravity: 980 px/s² (realistic acceleration)
- Terminal velocity: 1200 px/s
- Collision damping: 30% restitution
- Delta time for frame-rate independence

### Merging Rules
- Same-value tiles merge on collision
- Both tiles must be at rest (low velocity)
- New tile = sum of values (2+2=4, 4+4=8, etc.)

### Difficulty Progression
- Spawn rate increases with score
- More tiles appear simultaneously
- Data-driven configuration (no magic numbers)

## 🔧 Development

### Project Structure
```
lib/
├── core/         # Constants, themes, utilities
├── data/         # Models, repositories
├── game/         # Physics engine, game loop
├── providers/    # Riverpod state management
├── widgets/      # Reusable UI components
├── features/     # Screens (splash, home, game, etc.)
└── main.dart     # App entry point
```

### Code Quality
- Production-level lints enabled
- No magic numbers
- Comprehensive error handling
- Modular and testable

## 📝 License

Copyright © 2026. All rights reserved.

## 🙏 Acknowledgments

Built following Flutter best practices for commercial game development.

---

**For detailed architecture documentation, see [ARCHITECTURE.md](ARCHITECTURE.md)**

