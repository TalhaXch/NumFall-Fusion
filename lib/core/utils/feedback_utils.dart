import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../services/sound_manager.dart';

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

/// Sound effect types
enum SoundEffect {
  tileDrop,
  tileMerge,
  buttonClick,
  gameOver,
  levelUp,
  newHighScore,
  comboAchieved,
}

/// Sound utilities - Production-ready implementation
class SoundUtils {
  const SoundUtils._();

  /// Play sound effect
  static void play(SoundEffect effect) {
    final soundManager = SoundManager.instance;

    switch (effect) {
      case SoundEffect.tileMerge:
      case SoundEffect.levelUp:
      case SoundEffect.comboAchieved:
        debugPrint('[SoundUtils] Playing tileMerge for $effect');
        soundManager.playSoundEffect('tileMerge');
        break;
      case SoundEffect.gameOver:
      case SoundEffect.newHighScore:
        debugPrint('[SoundUtils] Playing gameOver for $effect');
        soundManager.playSoundEffect('gameOver');
        break;
      case SoundEffect.tileDrop:
      case SoundEffect.buttonClick:
        debugPrint('[SoundUtils] Skipping $effect - no audio file');
        // These sounds don't have audio files yet, skip silently
        break;
    }
  }

  /// Stop all sounds
  static void stopAll() {
    SoundManager.instance.stopAll();
  }

  /// Start background music
  static void startMusic() {
    SoundManager.instance.startMusic();
  }

  /// Stop background music
  static void stopMusic() {
    SoundManager.instance.stopMusic();
  }

  /// Pause background music
  static void pauseMusic() {
    SoundManager.instance.pauseMusic();
  }

  /// Resume background music
  static void resumeMusic() {
    SoundManager.instance.resumeMusic();
  }
}
