import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Repository for persisting game data
class GameRepository {
  GameRepository(this._prefs);

  final SharedPreferences _prefs;

  // Singleton pattern for easy access
  static GameRepository? _instance;

  static Future<GameRepository> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = GameRepository(prefs);
    }
    return _instance!;
  }

  /// Get high score
  int getHighScore() {
    return _prefs.getInt(StorageKeys.highScore) ?? 0;
  }

  /// Save high score
  Future<bool> saveHighScore(int score) async {
    final currentHigh = getHighScore();
    if (score > currentHigh) {
      return await _prefs.setInt(StorageKeys.highScore, score);
    }
    return false;
  }

  /// Get total games played
  int getTotalGamesPlayed() {
    return _prefs.getInt(StorageKeys.totalGamesPlayed) ?? 0;
  }

  /// Increment games played
  Future<void> incrementGamesPlayed() async {
    final current = getTotalGamesPlayed();
    await _prefs.setInt(StorageKeys.totalGamesPlayed, current + 1);
  }

  /// Get theme mode
  ThemeMode getThemeMode() {
    final modeString = _prefs.getString(StorageKeys.themeMode);
    if (modeString == 'dark') return ThemeMode.dark;
    if (modeString == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  /// Save theme mode
  Future<void> saveThemeMode(ThemeMode mode) async {
    String modeString;
    switch (mode) {
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    await _prefs.setString(StorageKeys.themeMode, modeString);
  }

  /// Get sound enabled state
  bool isSoundEnabled() {
    return _prefs.getBool(StorageKeys.soundEnabled) ?? true;
  }

  /// Save sound enabled state
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(StorageKeys.soundEnabled, enabled);
  }

  /// Get haptics enabled state
  bool isHapticsEnabled() {
    return _prefs.getBool(StorageKeys.hapticsEnabled) ?? true;
  }

  /// Save haptics enabled state
  Future<void> setHapticsEnabled(bool enabled) async {
    await _prefs.setBool(StorageKeys.hapticsEnabled, enabled);
  }

  /// Get music enabled state
  bool isMusicEnabled() {
    return _prefs.getBool(StorageKeys.musicEnabled) ?? true;
  }

  /// Save music enabled state
  Future<void> setMusicEnabled(bool enabled) async {
    await _prefs.setBool(StorageKeys.musicEnabled, enabled);
  }

  /// Clear all data (for debugging)
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
