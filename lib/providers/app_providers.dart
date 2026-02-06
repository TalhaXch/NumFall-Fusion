import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/game_repository.dart';
import '../core/services/sound_manager.dart';

/// Provider for SharedPreferences instance (initialized in main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  );
});

/// Provider for GameRepository instance
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  throw UnimplementedError(
    'gameRepositoryProvider must be overridden in main.dart',
  );
});

/// Theme mode state notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._repository) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  final GameRepository _repository;

  Future<void> _loadThemeMode() async {
    state = _repository.getThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _repository.saveThemeMode(mode);
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(newMode);
  }
}

/// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  final repository = ref.watch(gameRepositoryProvider);
  return ThemeModeNotifier(repository);
});

/// Settings state class
@immutable
class SettingsState {
  const SettingsState({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.musicEnabled = true,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool musicEnabled;

  SettingsState copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? musicEnabled,
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
    );
  }
}

/// Settings state notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._repository) : super(const SettingsState()) {
    _loadSettings();
  }

  final GameRepository _repository;

  Future<void> _loadSettings() async {
    state = SettingsState(
      soundEnabled: _repository.isSoundEnabled(),
      hapticsEnabled: _repository.isHapticsEnabled(),
      musicEnabled: _repository.isMusicEnabled(),
    );
  }

  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _repository.setSoundEnabled(enabled);
    // Sync with sound manager
    SoundManager.instance.setSoundEnabled(enabled);
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    state = state.copyWith(hapticsEnabled: enabled);
    await _repository.setHapticsEnabled(enabled);
  }

  Future<void> setMusicEnabled(bool enabled) async {
    state = state.copyWith(musicEnabled: enabled);
    await _repository.setMusicEnabled(enabled);
    // Sync with sound manager
    SoundManager.instance.setMusicEnabled(enabled);
  }
}

/// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    final repository = ref.watch(gameRepositoryProvider);
    return SettingsNotifier(repository);
  },
);

/// High score provider
final highScoreProvider = Provider<int>((ref) {
  final repository = ref.watch(gameRepositoryProvider);
  return repository.getHighScore();
});

/// Total games played provider
final totalGamesPlayedProvider = Provider<int>((ref) {
  final repository = ref.watch(gameRepositoryProvider);
  return repository.getTotalGamesPlayed();
});
