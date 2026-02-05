import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/game_state.dart' as ui;
import '../data/models/score.dart';
import '../game/controller/game_controller.dart';

/// Game state provider
final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, ui.GameState>((ref) {
      return GameStateNotifier();
    });

/// Score popups provider
final scorePopupsProvider =
    StateNotifierProvider<ScorePopupsNotifier, List<ScorePopup>>((ref) {
      return ScorePopupsNotifier();
    });

/// Game state notifier - Thin wrapper around GameController
/// This exposes the controller to Riverpod but doesn't contain game logic
class GameStateNotifier extends StateNotifier<ui.GameState> {
  GameStateNotifier() : super(ui.GameState.initial());

  GameController? _controller;

  /// Initialize game controller
  void initializeEngine(
    Size boardSize,
    Function(int, Offset) onScorePopup,
    VoidCallback onMerge,
  ) {
    _controller = GameController(
      boardSize: boardSize,
      onStateChanged: (newState) {
        state = newState;
      },
      onScorePopup: onScorePopup,
      onMerge: onMerge,
      tickRate: 60, // 60 FPS
    );
  }

  /// Start new game - delegates to controller
  void startGame() {
    _controller?.startGame();
  }

  /// Pause game - delegates to controller
  void pauseGame() {
    _controller?.pauseGame();
  }

  /// Resume game - delegates to controller
  void resumeGame() {
    _controller?.resumeGame();
  }

  /// Move falling tiles left - delegates to controller with validation
  void moveTilesLeft() {
    _controller?.moveLeft();
  }

  /// Move falling tiles right - delegates to controller with validation
  void moveTilesRight() {
    _controller?.moveRight();
  }

  /// Move falling tiles to specific column - delegates to controller
  void moveTilesToColumn(int column) {
    _controller?.moveToColumn(column);
  }

  /// Update game tick - NO LONGER NEEDED
  /// The controller manages its own game loop
  @Deprecated('Controller manages its own tick loop')
  void tick(double deltaTime) {
    // This is now handled internally by the controller
    debugPrint('[Provider] tick() is deprecated - controller has own loop');
  }

  /// Reset to initial state - delegates to controller
  void reset() {
    _controller?.reset();
  }

  @override
  void dispose() {
    // Dispose controller resources
    _controller?.dispose();
    super.dispose();
  }
}

/// Score popups notifier
class ScorePopupsNotifier extends StateNotifier<List<ScorePopup>> {
  ScorePopupsNotifier() : super([]);

  int _nextPopupId = 0;

  /// Add a score popup
  void addPopup(int points, Offset position) {
    final popup = ScorePopup(
      id: 'popup_${_nextPopupId++}',
      points: points,
      position: position,
      timestamp: DateTime.now(),
    );

    state = [...state, popup];

    // Auto-remove after duration
    Future.delayed(const Duration(milliseconds: 800), () {
      removePopup(popup.id);
    });
  }

  /// Remove a specific popup
  void removePopup(String id) {
    state = state.where((p) => p.id != id).toList();
  }

  /// Clear all popups
  void clear() {
    state = [];
  }
}
