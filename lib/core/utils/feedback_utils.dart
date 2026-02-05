import 'package:flutter/services.dart';

/// Haptic feedback utilities
class HapticUtils {
  const HapticUtils._();

  /// Light haptic feedback for UI interactions
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback for important actions
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback for significant events
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection haptic for toggles
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Success vibration pattern
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// Error vibration pattern
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }
}

/// Sound effect types (hooks for future audio implementation)
enum SoundEffect {
  tileDrop,
  tileMerge,
  buttonClick,
  gameOver,
  newHighScore,
  comboAchieved,
}

/// Sound utilities (hooks for future implementation)
class SoundUtils {
  const SoundUtils._();

  /// Play sound effect (hook for future implementation)
  static void play(SoundEffect effect) {
    // TODO: Implement sound playback when audio assets are added
    // Example: AudioPlayer.play('assets/sounds/${effect.name}.mp3');
  }

  /// Stop all sounds
  static void stopAll() {
    // TODO: Implement when audio is added
  }
}
