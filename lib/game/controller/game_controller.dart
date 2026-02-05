import 'dart:async';
import 'package:flutter/material.dart';
import '../engine/game_engine_adapter.dart';
import '../../data/models/game_state.dart' as ui;
import '../../data/models/tile.dart' as ui;

/// GAME CONTROLLER - The Single Source of Truth for Game Flow
///
/// RESPONSIBILITIES:
/// - Receives and validates user input
/// - Manages game lifecycle (start/pause/resume/reset)
/// - Controls tick timing via game loop
/// - Coordinates engine updates
/// - Emits immutable state to UI
/// - Handles difficulty progression
/// - Prevents invalid state transitions
///
/// WHAT IT MUST NEVER DO:
/// - Calculate physics (that's the engine's job)
/// - Modify tiles directly (immutable state only)
/// - Contain UI logic (UI reads state, doesn't write)
///
/// ARCHITECTURE:
/// Input → Controller → Engine → New State → UI
/// The UI can NEVER bypass the controller to mutate state.
///
/// FUTURE PROOF:
/// This design supports:
/// - Replays (record input stream)
/// - AI players (AI generates input)
/// - Online multiplayer (sync input over network)
class GameController {
  GameController({
    required Size boardSize,
    required this.onStateChanged,
    required this.onScorePopup,
    required this.onMerge,
    this.tickRate = 60, // 60 FPS default
  }) : _adapter = GameEngineAdapter(
         boardSize: boardSize,
         onStateChanged: (state) {}, // We'll handle state emission
         onScorePopup: onScorePopup,
         onMerge: onMerge,
       ) {
    _currentState = ui.GameState.initial();
  }

  // === DEPENDENCIES ===
  final GameEngineAdapter _adapter;
  final ValueChanged<ui.GameState> onStateChanged;
  final Function(int points, Offset position) onScorePopup;
  final VoidCallback onMerge;
  final int tickRate; // Ticks per second

  // === STATE ===
  late ui.GameState _currentState;
  GameStatus _status = GameStatus.idle;
  Timer? _gameLoopTimer;
  DateTime? _lastTickTime;
  int _tickCount = 0;
  double _difficultyTimer = 0.0;

  // === READ-ONLY STATE EXPOSURE ===
  /// Current game state - IMMUTABLE, UI must not modify
  ui.GameState get currentState => _currentState;

  /// Current game status - for input validation
  GameStatus get status => _status;

  /// Whether game is actively running
  bool get isPlaying => _status == GameStatus.playing;

  /// Whether input is allowed right now
  bool get canAcceptInput => _status == GameStatus.playing && !_isInTransition;

  /// Get column count from adapter config
  int get _columnCount => _adapter.coreState.board.columnCount;

  // === TRANSITION GUARDS ===
  bool _isInTransition = false; // Prevents input during merge/settle
  bool _inputThrottled = false; // Prevents double input

  // === LIFECYCLE METHODS ===

  /// Start a new game
  /// Resets all state and begins the game loop
  void startGame() {
    // Prevent starting if already playing
    if (_status == GameStatus.playing) {
      debugPrint('[Controller] Game already running, ignoring start');
      return;
    }

    debugPrint('[Controller] Starting new game');

    // Reset everything
    _adapter.startGame();
    _status = GameStatus.playing;
    _tickCount = 0;
    _difficultyTimer = 0.0;
    _isInTransition = false;
    _inputThrottled = false;

    // Start the game loop
    _startGameLoop();

    // Emit initial state
    _emitState();
  }

  /// Pause the game
  /// Stops the game loop but preserves state
  void pauseGame() {
    if (_status != GameStatus.playing) {
      debugPrint('[Controller] Cannot pause, not playing');
      return;
    }

    debugPrint('[Controller] Pausing game');

    _status = GameStatus.paused;
    _stopGameLoop();
    _adapter.pauseGame();
    _emitState();
  }

  /// Resume the game
  /// Continues from paused state
  void resumeGame() {
    if (_status != GameStatus.paused) {
      debugPrint('[Controller] Cannot resume, not paused');
      return;
    }

    debugPrint('[Controller] Resuming game');

    _status = GameStatus.playing;
    _adapter.resumeGame();
    _lastTickTime = DateTime.now(); // Reset timing
    _startGameLoop();
    _emitState();
  }

  /// Reset game to initial state
  /// Clears everything and prepares for new game
  void reset() {
    debugPrint('[Controller] Resetting game');

    _stopGameLoop();
    _status = GameStatus.idle;
    _tickCount = 0;
    _difficultyTimer = 0.0;
    _isInTransition = false;
    _inputThrottled = false;
    _currentState = ui.GameState.initial();
    _emitState();
  }

  /// Dispose resources
  /// Must be called when controller is no longer needed
  void dispose() {
    debugPrint('[Controller] Disposing');
    _stopGameLoop();
  }

  // === GAME LOOP CONTROL ===

  /// Start the tick-based game loop
  /// STRICT: Must run at configured tick rate
  void _startGameLoop() {
    // Prevent multiple loops
    if (_gameLoopTimer != null && _gameLoopTimer!.isActive) {
      debugPrint('[Controller] Game loop already running');
      return;
    }

    final tickDuration = Duration(milliseconds: (1000 / tickRate).round());
    _lastTickTime = DateTime.now();

    _gameLoopTimer = Timer.periodic(tickDuration, (_) {
      if (_status == GameStatus.playing) {
        _tick();
      }
    });

    debugPrint('[Controller] Game loop started at $tickRate FPS');
  }

  /// Stop the game loop
  void _stopGameLoop() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = null;
    _lastTickTime = null;
    debugPrint('[Controller] Game loop stopped');
  }

  /// Execute one game tick
  /// MANDATORY ORDER (NON-NEGOTIABLE):
  /// 1. Calculate deltaTime
  /// 2. Engine update (gravity, collision, merge, stabilize, validate, spawn)
  /// 3. Update difficulty
  /// 4. Check game over
  /// 5. Emit state
  void _tick() {
    final now = DateTime.now();
    final deltaTime =
        _lastTickTime != null
            ? now.difference(_lastTickTime!).inMilliseconds / 1000.0
            : 1 / tickRate;
    _lastTickTime = now;

    // Guard: Prevent ticks during transitions
    if (_isInTransition) {
      return;
    }

    _tickCount++;

    // STEP 1: Engine update (contains all physics logic)
    // The engine handles: gravity → collision → merge → stabilize → validate → spawn
    _adapter.tick(deltaTime);

    // STEP 2: Update difficulty over time
    _updateDifficulty(deltaTime);

    // STEP 3: Check game over condition
    _checkGameOver();

    // STEP 4: Emit new state to UI
    _emitState();
  }

  /// Update difficulty based on time/score
  /// RULES:
  /// - Gradual changes only
  /// - Data-driven (no magic numbers)
  /// - Deterministic (same input = same output)
  void _updateDifficulty(double deltaTime) {
    _difficultyTimer += deltaTime;

    // Increase difficulty every 30 seconds
    const difficultyInterval = 30.0;
    if (_difficultyTimer >= difficultyInterval) {
      _difficultyTimer -= difficultyInterval;
      // Difficulty increases are handled in the engine's config
      debugPrint('[Controller] Difficulty increased at tick $_tickCount');
    }
  }

  /// Check if game is over
  void _checkGameOver() {
    if (_adapter.coreState.isGameOver && _status != GameStatus.gameOver) {
      debugPrint('[Controller] Game over detected');
      _status = GameStatus.gameOver;
      _stopGameLoop();
    }
  }

  // === INPUT HANDLING ===

  /// Move active tile left
  /// INPUT VALIDATION:
  /// - Only during active play
  /// - Not during transitions
  /// - Not when throttled
  void moveLeft() {
    if (!_validateInput('moveLeft')) return;

    _throttleInput(() {
      // Find active (falling) tile
      final activeTile = _findActiveTile();
      if (activeTile == null) {
        debugPrint('[Controller] No active tile to move');
        return;
      }

      // Bounds check
      if (activeTile.column <= 0) {
        debugPrint('[Controller] Already at left edge');
        return;
      }

      // Execute move via adapter
      final targetColumn = activeTile.column - 1;
      _adapter.moveTile(targetColumn);
      _emitState();
    });
  }

  /// Move active tile right
  void moveRight() {
    if (!_validateInput('moveRight')) return;

    _throttleInput(() {
      final activeTile = _findActiveTile();
      if (activeTile == null) {
        debugPrint('[Controller] No active tile to move');
        return;
      }

      // Bounds check - use dynamic column count
      final maxColumn = _columnCount - 1;
      if (activeTile.column >= maxColumn) {
        debugPrint(
          '[Controller] Already at right edge (column ${activeTile.column}/$maxColumn)',
        );
        return;
      }

      final targetColumn = activeTile.column + 1;
      _adapter.moveTile(targetColumn);
      _emitState();
    });
  }

  /// Move active tile to specific column
  /// Useful for tap/click input on specific columns
  void moveToColumn(int targetColumn) {
    if (!_validateInput('moveToColumn($targetColumn)')) return;

    // Bounds check - use dynamic column count
    final maxColumn = _columnCount - 1;
    if (targetColumn < 0 || targetColumn > maxColumn) {
      debugPrint('[Controller] Invalid column $targetColumn (max: $maxColumn)');
      return;
    }

    _throttleInput(() {
      final activeTile = _findActiveTile();
      if (activeTile == null) {
        debugPrint('[Controller] No active tile to move');
        return;
      }

      if (activeTile.column == targetColumn) {
        debugPrint('[Controller] Already in target column');
        return;
      }

      _adapter.moveTile(targetColumn);
      _emitState();
    });
  }

  // === INPUT VALIDATION & THROTTLING ===

  /// Validate that input is allowed right now
  /// MANDATORY CHECKS:
  /// - Game must be playing
  /// - Not during transitions
  /// - Not when game is over
  bool _validateInput(String action) {
    if (_status == GameStatus.idle) {
      debugPrint('[Controller] Input "$action" ignored - game not started');
      return false;
    }

    if (_status == GameStatus.paused) {
      debugPrint('[Controller] Input "$action" ignored - game paused');
      return false;
    }

    if (_status == GameStatus.gameOver) {
      debugPrint('[Controller] Input "$action" ignored - game over');
      return false;
    }

    if (_isInTransition) {
      debugPrint('[Controller] Input "$action" ignored - in transition');
      return false;
    }

    if (_inputThrottled) {
      debugPrint('[Controller] Input "$action" throttled');
      return false;
    }

    return true;
  }

  /// Throttle input to prevent double-tap issues
  /// Executes action and briefly blocks further input
  void _throttleInput(VoidCallback action) {
    _inputThrottled = true;
    action();

    // Unthrottle after brief delay (prevent rapid fire)
    Future.delayed(const Duration(milliseconds: 50), () {
      _inputThrottled = false;
    });
  }

  /// Find the currently active (falling) tile
  ui.Tile? _findActiveTile() {
    try {
      return _currentState.tiles.firstWhere((tile) => !tile.isStatic);
    } catch (_) {
      return null; // No active tile
    }
  }

  // === STATE EMISSION ===

  /// Emit current state to listeners
  /// CRITICAL: State is immutable - UI cannot modify it
  void _emitState() {
    // Get latest state from adapter
    _currentState = _adapter.getCurrentState(
      overrideStatus: _mapStatusToUIStatus(_status),
    );

    onStateChanged(_currentState);
  }

  /// Map controller status to UI status
  ui.GameStatus _mapStatusToUIStatus(GameStatus status) {
    switch (status) {
      case GameStatus.idle:
        return ui.GameStatus.idle;
      case GameStatus.playing:
        return ui.GameStatus.playing;
      case GameStatus.paused:
        return ui.GameStatus.paused;
      case GameStatus.gameOver:
        return ui.GameStatus.gameOver;
    }
  }
}

/// Game status enumeration
enum GameStatus {
  idle, // Not started yet
  playing, // Active gameplay
  paused, // Temporarily stopped
  gameOver, // Game ended
}
