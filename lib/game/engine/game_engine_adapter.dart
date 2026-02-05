import 'package:flutter/material.dart';
import '../core/models/game_models.dart' as core;
import '../core/engine/core_game_engine.dart';
import '../core/config/game_config.dart';
import '../../data/models/tile.dart' as ui;
import '../../data/models/game_state.dart' as ui;

/// Adapter between core game engine and UI layer
/// Converts between core models and UI models
class GameEngineAdapter {
  GameEngineAdapter({
    required Size boardSize,
    required this.onStateChanged,
    required this.onScorePopup,
    required this.onMerge,
  }) : _coreEngine = CoreGameEngine(
         config: GameConfig(
           boardWidth: boardSize.width,
           boardHeight: boardSize.height,
           columnCount: 7,
           tileSize: 48, // Match UI GameConstants.tileSize
           baseGravity: 300,
           maxGravity: 1200,
           gravityScalePerLevel: 50,
           spawnInterval: 2.0,
           maxActiveTiles: 5,
           initialTileValues: [2, 4],
         ),
       ) {
    _coreState = _coreEngine.initialize();
  }

  final CoreGameEngine _coreEngine;
  final ValueChanged<ui.GameState> onStateChanged;
  final Function(int points, Offset position) onScorePopup;
  final VoidCallback onMerge;

  late core.GameState _coreState;
  final Map<String, ui.Tile> _tileCache = {};

  core.GameState get coreState => _coreState;

  /// Start a new game
  void startGame() {
    _coreState = _coreEngine.initialize();
    _tileCache.clear();
    _notifyUI();
  }

  /// Pause the game
  void pauseGame() {
    // Core engine doesn't need pause logic - just stop calling tick
    _notifyUI(status: ui.GameStatus.paused);
  }

  /// Resume the game
  void resumeGame() {
    _notifyUI(status: ui.GameStatus.playing);
  }

  /// Get current UI state without notifying
  /// Used by controller to poll state
  ui.GameState getCurrentState({ui.GameStatus? overrideStatus}) {
    return _convertToUIState(overrideStatus);
  }

  /// Game tick - call every frame
  void tick(double deltaTime) {
    if (_coreState.isGameOver) {
      _notifyUI(status: ui.GameStatus.gameOver);
      return;
    }

    final previousScore = _coreState.currentScore;
    _coreState = _coreEngine.tick(_coreState, deltaTime);

    // Check for score changes (merges happened)
    if (_coreState.currentScore > previousScore) {
      final scoreGained = _coreState.currentScore - previousScore;
      try {
        onMerge();
        // Find approximate position of merge (use first settled tile in any column)
        Offset mergePos = const Offset(200, 400);
        for (final column in _coreState.board.columns) {
          if (column.tiles.isNotEmpty) {
            final tile = column.tiles.first;
            mergePos = Offset(
              tile.columnIndex * _coreEngine.config.tileSize +
                  _coreEngine.config.tileSize / 2,
              _coreEngine.config.boardHeight -
                  tile.yPosition -
                  _coreEngine.config.tileSize / 2,
            );
            break;
          }
        }
        onScorePopup(scoreGained, mergePos);
      } catch (_) {
        // Ignore callback errors
      }
    }

    _notifyUI();
  }

  /// Move active tile to target column
  void moveTile(int targetColumn) {
    // Find first unsettled tile
    for (final tile in _coreState.board.getAllTiles()) {
      if (!tile.isSettled) {
        _coreState = _coreEngine.moveTileHorizontal(
          _coreState,
          tile.id,
          targetColumn,
        );
        _notifyUI();
        return;
      }
    }
  }

  /// Convert core state to UI state and notify
  void _notifyUI({ui.GameStatus? status}) {
    final uiState = _convertToUIState(status);
    try {
      onStateChanged(uiState);
    } catch (_) {
      // Ignore callback errors during disposal
    }
  }

  /// Convert core GameState to UI GameState
  ui.GameState _convertToUIState(ui.GameStatus? overrideStatus) {
    final uiTiles = <ui.Tile>[];
    final currentTileIds = <String>{};

    for (final column in _coreState.board.columns) {
      for (final coreTile in column.tiles) {
        currentTileIds.add(coreTile.id);

        // Check if tile exists in cache
        final cachedTile = _tileCache[coreTile.id];
        final newTileData = _convertToUITile(coreTile);

        if (cachedTile != null) {
          // Update existing tile only if something changed
          if (cachedTile.position != newTileData.position ||
              cachedTile.isStatic != newTileData.isStatic ||
              cachedTile.value != newTileData.value ||
              cachedTile.velocity != newTileData.velocity) {
            final updatedTile = cachedTile.copyWith(
              position: newTileData.position,
              velocity: newTileData.velocity,
              isStatic: newTileData.isStatic,
              value: newTileData.value,
            );
            _tileCache[coreTile.id] = updatedTile;
            uiTiles.add(updatedTile);
          } else {
            // No changes, use cached tile
            uiTiles.add(cachedTile);
          }
        } else {
          // New tile, add to cache
          _tileCache[coreTile.id] = newTileData;
          uiTiles.add(newTileData);
        }
      }
    }

    // Remove tiles that no longer exist from cache
    _tileCache.removeWhere((id, _) => !currentTileIds.contains(id));

    // Determine status
    final status =
        overrideStatus ??
        (_coreState.isGameOver
            ? ui.GameStatus.gameOver
            : ui.GameStatus.playing);

    return ui.GameState(
      tiles: uiTiles,
      score: _coreState.currentScore,
      status: status,
      combo: 0, // Core engine doesn't track combo yet
      comboTimer: 0,
      timeElapsed: _coreState.tickCount * 0.016, // Approximate
      nextSpawnTime: 0,
    );
  }

  /// Convert core GameTile to UI Tile
  ui.Tile _convertToUITile(core.GameTile coreTile) {
    // Convert Y position: core uses bottom-up, UI uses top-down
    final uiY =
        _coreEngine.config.boardHeight -
        coreTile.yPosition -
        _coreEngine.config.tileSize;

    return ui.Tile(
      id: coreTile.id,
      value: coreTile.value,
      position: Offset(coreTile.columnIndex * _coreEngine.config.tileSize, uiY),
      velocity: Offset(0, coreTile.velocity),
      column: coreTile.columnIndex,
      isStatic: coreTile.isSettled,
      isMerging: false, // Core engine doesn't track merge animation
    );
  }

  /// Dispose resources
  void dispose() {
    // Nothing to dispose in core engine
  }
}
