library;

import 'package:flutter/material.dart';

/// Application-wide constants
/// This file contains all configuration values used throughout the game
/// to ensure maintainability and avoid magic numbers

/// Game configuration constants
class GameConstants {
  const GameConstants._();

  // Board dimensions
  static const int boardColumns = 7;
  static const int boardRows = 12;
  static const double tileSize = 48.0;
  static const double tileSpacing = 4.0;

  // Physics constants (tuned for natural feel)
  static const double baseGravity = 300.0; // Starting gravity (slow fall)
  static const double maxGravity = 1200.0; // Maximum gravity at high scores
  static const double gravityIncreasePerScore = 0.5; // Gravity increase rate
  static const double gravity = 980.0; // Default (kept for compatibility)
  static const double terminalVelocity = 1200.0; // max fall speed
  static const double collisionDamping = 0.3; // bounce reduction
  static const double minVelocityThreshold =
      5.0; // velocity considered "stopped"
  static const double horizontalMoveSpeed =
      3500.0; // pixels per second for smooth column movement (fast)

  // Game loop
  static const int targetFps = 60;
  static const double maxDeltaTime = 1.0 / 30.0; // prevent spiral of death

  // Tile values
  static const List<int> initialTileValues = [2, 4, 8];
  static const int maxTileValue = 2048;
  static const int minMergeValue = 2;

  // Scoring
  static const int baseScore = 10;
  static const double comboMultiplier = 1.5;
  static const double comboTimeWindow = 1.0; // seconds to maintain combo

  // Difficulty progression (data-driven)
  static const Map<int, DifficultyConfig> difficultyLevels = {
    0: DifficultyConfig(spawnInterval: 2.5, maxActiveTiles: 5),
    100: DifficultyConfig(spawnInterval: 2.0, maxActiveTiles: 6),
    500: DifficultyConfig(spawnInterval: 1.5, maxActiveTiles: 7),
    1000: DifficultyConfig(spawnInterval: 1.2, maxActiveTiles: 8),
    2000: DifficultyConfig(spawnInterval: 1.0, maxActiveTiles: 10),
  };

  // Animation durations (milliseconds)
  static const int mergeDuration = 300;
  static const int spawnDuration = 250;
  static const int scorePopupDuration = 800;
  static const int screenTransitionDuration = 350;

  // UI spacing
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double smallPadding = 8.0;

  // Border radius
  static const double tileBorderRadius = 12.0;
  static const double buttonBorderRadius = 16.0;
  static const double cardBorderRadius = 20.0;
}

/// Difficulty configuration data class
class DifficultyConfig {
  const DifficultyConfig({
    required this.spawnInterval,
    required this.maxActiveTiles,
  });

  final double spawnInterval; // seconds between spawns
  final int maxActiveTiles; // max tiles on board

  /// Get difficulty config for current score
  static DifficultyConfig forScore(int score) {
    DifficultyConfig? config;
    for (final entry in GameConstants.difficultyLevels.entries) {
      if (score >= entry.key) {
        config = entry.value;
      } else {
        break;
      }
    }
    return config ?? GameConstants.difficultyLevels[0]!;
  }
}

/// Storage keys for persistence
class StorageKeys {
  const StorageKeys._();

  static const String highScore = 'high_score';
  static const String totalGamesPlayed = 'total_games_played';
  static const String themeMode = 'theme_mode';
  static const String soundEnabled = 'sound_enabled';
  static const String hapticsEnabled = 'haptics_enabled';
  static const String musicEnabled = 'music_enabled';
}

/// Animation curve definitions
class AppCurves {
  const AppCurves._();

  static final merge = Curves.easeOutBack;
  static final spawn = Curves.elasticOut;
  static final scorePopup = Curves.easeOut;
  static final screenTransition = Curves.easeInOutCubic;
}
