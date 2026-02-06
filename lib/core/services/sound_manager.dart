import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Professional sound manager with audio pooling and resource management
/// Handles both sound effects and background music
class SoundManager {
  SoundManager._();

  static final SoundManager instance = SoundManager._();

  // Audio players for sound effects (pool for simultaneous sounds)
  final List<AudioPlayer> _sfxPool = [];
  final int _poolSize = 5; // Allow up to 5 simultaneous sounds

  // Dedicated player for background music
  AudioPlayer? _musicPlayer;

  // State management
  bool _initialized = false;
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _sfxVolume = 0.7;
  double _musicVolume = 0.4;

  // Sound asset paths
  static const String _soundsPath = 'sounds/';
  static const Map<String, String> _soundFiles = {
    'tileMerge': 'levelup.mp3',
    'gameOver': 'game over.mp3',
    'levelUp': 'levelup.mp3',
    'music': 'music.mp3',
  };

  // Track if music is currently playing
  bool _isMusicPlaying = false;

  /// Initialize the sound system
  /// Call this once at app startup
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('[SoundManager] Already initialized');
      return;
    }

    try {
      debugPrint('[SoundManager] Initializing sound system...');

      // Create audio player pool for sound effects
      for (int i = 0; i < _poolSize; i++) {
        final player = AudioPlayer();
        await player.setVolume(_sfxVolume);
        await player.setPlayerMode(
          PlayerMode.lowLatency,
        ); // For fast SFX playback
        await player.setAudioContext(
          AudioContext(
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.playback,
              options: {
                AVAudioSessionOptions.mixWithOthers,
                AVAudioSessionOptions.duckOthers,
              },
            ),
            android: AudioContextAndroid(
              isSpeakerphoneOn: false,
              stayAwake: false,
              contentType: AndroidContentType.music,
              usageType: AndroidUsageType.game,
              audioFocus: AndroidAudioFocus.gain,
            ),
          ),
        );
        _sfxPool.add(player);
      }

      // Create music player
      _musicPlayer = AudioPlayer();
      await _musicPlayer!.setVolume(_musicVolume);
      await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer!.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gain,
          ),
        ),
      );

      // Preload common sounds for instant playback
      await _preloadSounds();

      _initialized = true;
      debugPrint('[SoundManager] Initialized successfully');
    } catch (e) {
      debugPrint('[SoundManager] Error during initialization: $e');
    }
  }

  /// Preload frequently used sounds
  Future<void> _preloadSounds() async {
    try {
      // Preload the most common sounds
      final commonSounds = ['tileMerge', 'gameOver', 'levelUp'];

      for (final soundKey in commonSounds) {
        final fileName = _soundFiles[soundKey];
        if (fileName != null && _sfxPool.isNotEmpty) {
          // Use first player to preload
          final source = AssetSource('$_soundsPath$fileName');
          // Just set the source without playing
          await _sfxPool[0].setSource(source);
        }
      }

      debugPrint('[SoundManager] Preloaded common sounds');
    } catch (e) {
      debugPrint('[SoundManager] Error preloading sounds: $e');
    }
  }

  /// Play a sound effect
  void playSoundEffect(String soundKey) {
    if (!_initialized) {
      debugPrint('[SoundManager] Not initialized, skipping sound: $soundKey');
      return;
    }

    if (!_soundEnabled) {
      debugPrint('[SoundManager] Sound disabled, skipping: $soundKey');
      return;
    }

    final fileName = _soundFiles[soundKey];
    if (fileName == null) {
      debugPrint('[SoundManager] Sound not found: $soundKey');
      return;
    }

    // Play asynchronously without blocking
    _playSound(soundKey, fileName);
  }

  /// Internal async sound playback
  Future<void> _playSound(String soundKey, String fileName) async {
    try {
      // Find an available player from the pool
      AudioPlayer? availablePlayer;

      for (final player in _sfxPool) {
        final state = player.state;
        if (state == PlayerState.completed || state == PlayerState.stopped) {
          availablePlayer = player;
          break;
        }
      }

      // If no player is available, use the first one (interrupt oldest sound)
      availablePlayer ??= _sfxPool.first;

      // Play the sound
      await availablePlayer.stop(); // Stop any current playback
      final source = AssetSource('$_soundsPath$fileName');
      await availablePlayer.play(source);

      debugPrint('[SoundManager] Playing sound: $soundKey ($fileName)');
    } catch (e) {
      debugPrint('[SoundManager] Error playing sound $soundKey: $e');
    }
  }

  /// Start background music
  Future<void> startMusic() async {
    if (!_initialized || !_musicEnabled || _isMusicPlaying) return;

    final fileName = _soundFiles['music'];
    if (fileName == null || _musicPlayer == null) return;

    try {
      await _musicPlayer!.play(AssetSource('$_soundsPath$fileName'));
      _isMusicPlaying = true;
      debugPrint('[SoundManager] Background music started');
    } catch (e) {
      debugPrint('[SoundManager] Error starting music: $e');
    }
  }

  /// Stop background music
  Future<void> stopMusic() async {
    if (!_initialized || _musicPlayer == null) return;

    try {
      await _musicPlayer!.stop();
      _isMusicPlaying = false;
      debugPrint('[SoundManager] Background music stopped');
    } catch (e) {
      debugPrint('[SoundManager] Error stopping music: $e');
    }
  }

  /// Pause background music
  Future<void> pauseMusic() async {
    if (!_initialized || _musicPlayer == null) return;

    try {
      await _musicPlayer!.pause();
      debugPrint('[SoundManager] Background music paused');
    } catch (e) {
      debugPrint('[SoundManager] Error pausing music: $e');
    }
  }

  /// Resume background music
  Future<void> resumeMusic() async {
    if (!_initialized || !_musicEnabled || _musicPlayer == null) return;

    try {
      await _musicPlayer!.resume();
      debugPrint('[SoundManager] Background music resumed');
    } catch (e) {
      debugPrint('[SoundManager] Error resuming music: $e');
    }
  }

  /// Enable/disable sound effects
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (!enabled) {
      // Stop all currently playing sounds
      for (final player in _sfxPool) {
        player.stop();
      }
    }
    debugPrint(
      '[SoundManager] Sound effects ${enabled ? 'enabled' : 'disabled'}',
    );
  }

  /// Enable/disable background music
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (enabled && !_isMusicPlaying) {
      startMusic();
    } else if (!enabled && _isMusicPlaying) {
      stopMusic();
    }
    debugPrint('[SoundManager] Music ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Set sound effects volume (0.0 to 1.0)
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    for (final player in _sfxPool) {
      await player.setVolume(_sfxVolume);
    }
    debugPrint('[SoundManager] SFX volume set to $_sfxVolume');
  }

  /// Set music volume (0.0 to 1.0)
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _musicPlayer?.setVolume(_musicVolume);
    debugPrint('[SoundManager] Music volume set to $_musicVolume');
  }

  /// Stop all sounds (useful for game over/pause)
  Future<void> stopAll() async {
    for (final player in _sfxPool) {
      await player.stop();
    }
    debugPrint('[SoundManager] All sounds stopped');
  }

  /// Dispose all resources
  Future<void> dispose() async {
    if (!_initialized) return;

    debugPrint('[SoundManager] Disposing sound system...');

    // Dispose all players in the pool
    for (final player in _sfxPool) {
      await player.dispose();
    }
    _sfxPool.clear();

    // Dispose music player
    await _musicPlayer?.dispose();
    _musicPlayer = null;

    _initialized = false;
    _isMusicPlaying = false;
    debugPrint('[SoundManager] Disposed successfully');
  }
}
