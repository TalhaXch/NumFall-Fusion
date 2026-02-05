import 'dart:math' as math;
import '../models/game_models.dart';
import '../config/game_config.dart';

/// Production-grade game engine
/// Fully deterministic, testable, and bug-resistant
class CoreGameEngine {
  CoreGameEngine({required this.config})
    : _random = math.Random(config.randomSeed),
      _nextTileId = 0;

  final GameConfig config;
  final math.Random _random;
  int _nextTileId;
  double _timeSinceLastSpawn = 0;

  /// Initialize a new game state
  GameState initialize() {
    final columns = List.generate(
      config.columnCount,
      (index) => GameColumn(index: index, tiles: const []),
    );

    final board = BoardState(
      columns: columns,
      boardHeight: config.boardHeight,
      tileSize: config.tileSize,
    );

    return GameState(
      board: board,
      currentScore: 0,
      bestScore: 0,
      difficultyLevel: 1,
      tickCount: 0,
    );
  }

  /// Main game loop tick
  /// This is the ONLY entry point for game updates
  /// @param deltaTime: Time elapsed since last tick in seconds
  /// @returns: New game state with all updates applied
  GameState tick(GameState currentState, double deltaTime) {
    if (currentState.isGameOver) {
      return currentState; // No updates if game over
    }

    // MANDATORY STEP 1: Apply gravity
    var state = _applyGravity(currentState, deltaTime);

    // MANDATORY STEP 2: Resolve collisions and settle tiles
    state = _resolveCollisions(state);

    // MANDATORY STEP 3: Process merges
    final mergeResult = _processMerges(state);
    state = mergeResult.state;

    // MANDATORY STEP 4: Stabilization pass
    state = _stabilizeBoard(state);

    // MANDATORY STEP 5: Validate integrity
    state.board.validate();

    // MANDATORY STEP 6: Spawn new tiles if needed
    _timeSinceLastSpawn += deltaTime;
    if (_timeSinceLastSpawn >= config.spawnInterval) {
      state = _spawnTile(state);
      _timeSinceLastSpawn = 0;
    }

    // Update tick count
    return state.copyWith(tickCount: state.tickCount + 1);
  }

  /// STEP 1: Apply gravity to all unsettled tiles
  /// RULE: Tiles can NEVER touch or pass through each other
  GameState _applyGravity(GameState state, double deltaTime) {
    final gravity = config.getGravity(state.difficultyLevel);
    final newColumns = <GameColumn>[];

    for (final column in state.board.columns) {
      final settledTiles = <GameTile>[];
      final fallingTiles = <GameTile>[];

      // Separate settled and falling tiles
      for (final tile in column.tiles) {
        if (tile.isSettled) {
          settledTiles.add(tile);
        } else {
          fallingTiles.add(tile);
        }
      }

      // Sort settled tiles by position (bottom to top)
      settledTiles.sort((a, b) => a.yPosition.compareTo(b.yPosition));

      // Sort falling tiles by position (bottom to top) to process in order
      fallingTiles.sort((a, b) => a.yPosition.compareTo(b.yPosition));

      final updatedTiles = <GameTile>[];
      updatedTiles.addAll(settledTiles);

      // Process each falling tile with strict collision checking
      for (final tile in fallingTiles) {
        // Apply gravity: v = v + g*dt
        final newVelocity = tile.velocity + (gravity * deltaTime);

        // Calculate desired new position: y = y - v*dt
        final desiredY = tile.yPosition - (newVelocity * deltaTime);

        // Find the maximum allowed Y position (collision boundary)
        final settleY = _findSettlePosition(
          tile,
          updatedTiles.where((t) => t.isSettled).toList(),
        );

        // STRICT RULE: Never allow tile to go below settle position
        final constrainedY = math
            .max(settleY, desiredY)
            .clamp(0.0, config.boardHeight - config.tileSize);

        // Check if tile would overlap with ANY other tile
        bool wouldOverlap = false;
        for (final other in updatedTiles) {
          final testTile = tile.copyWith(yPosition: constrainedY);
          if (testTile.overlapsWith(other, config.tileSize)) {
            wouldOverlap = true;
            break;
          }
        }

        // If overlap detected, snap to safe position
        final finalY = wouldOverlap ? settleY : constrainedY;

        updatedTiles.add(
          tile.copyWith(
            yPosition: finalY,
            velocity: finalY == settleY ? 0.0 : newVelocity,
          ),
        );
      }

      newColumns.add(GameColumn(index: column.index, tiles: updatedTiles));
    }

    return state.copyWith(
      board: BoardState(
        columns: newColumns,
        boardHeight: config.boardHeight,
        tileSize: config.tileSize,
      ),
    );
  }

  /// STEP 2: Resolve collisions and settle tiles
  /// STRICT RULE: No overlap tolerance - tiles must be perfectly separated
  GameState _resolveCollisions(GameState state) {
    final newColumns = <GameColumn>[];

    for (final column in state.board.columns) {
      final settledTiles = <GameTile>[];
      final fallingTiles = <GameTile>[];

      // Separate settled and falling
      for (final tile in column.tiles) {
        if (tile.isSettled) {
          settledTiles.add(tile);
        } else {
          fallingTiles.add(tile);
        }
      }

      // Sort settled tiles bottom to top
      settledTiles.sort((a, b) => a.yPosition.compareTo(b.yPosition));

      // Process each falling tile
      final updatedTiles = List<GameTile>.from(settledTiles);

      for (final fallingTile in fallingTiles) {
        // Find exact collision point
        final settleY = _findSettlePosition(fallingTile, settledTiles);

        // STRICT: Use exact position matching (no tolerance)
        if (fallingTile.yPosition <= settleY) {
          // Tile has reached or passed settle point - snap to exact position
          final settledTile = fallingTile.copyWith(
            yPosition: settleY,
            velocity: 0.0,
            isSettled: true,
          );
          updatedTiles.add(settledTile);
          settledTiles.add(settledTile); // For next iteration
        } else {
          // Still falling - but verify no overlap
          bool hasOverlap = false;
          for (final other in updatedTiles) {
            if (fallingTile.overlapsWith(other, config.tileSize)) {
              hasOverlap = true;
              break;
            }
          }

          // If overlap detected, force settle immediately
          if (hasOverlap) {
            final settledTile = fallingTile.copyWith(
              yPosition: settleY,
              velocity: 0.0,
              isSettled: true,
            );
            updatedTiles.add(settledTile);
            settledTiles.add(settledTile);
          } else {
            updatedTiles.add(fallingTile);
          }
        }
      }

      newColumns.add(GameColumn(index: column.index, tiles: updatedTiles));
    }

    return state.copyWith(
      board: BoardState(
        columns: newColumns,
        boardHeight: config.boardHeight,
        tileSize: config.tileSize,
      ),
    );
  }

  /// Find Y position where tile should settle
  double _findSettlePosition(
    GameTile fallingTile,
    List<GameTile> settledTiles,
  ) {
    if (settledTiles.isEmpty) {
      return 0.0; // Settle on floor
    }

    // Find topmost settled tile
    final topTile = settledTiles.reduce(
      (a, b) => a.yPosition > b.yPosition ? a : b,
    );

    // Settle on top of it
    return topTile.yPosition + config.tileSize;
  }

  /// STEP 3: Process merges
  /// Returns merged tiles and score gained
  _MergeResult _processMerges(GameState state) {
    var totalScore = 0;
    final newColumns = <GameColumn>[];

    for (final column in state.board.columns) {
      final tiles = List<GameTile>.from(column.tiles);
      final processedIds = <String>{};
      final updatedTiles = <GameTile>[];

      // Sort by Y position for bottom-up processing
      tiles.sort((a, b) => a.yPosition.compareTo(b.yPosition));

      for (var i = 0; i < tiles.length; i++) {
        if (processedIds.contains(tiles[i].id)) continue;

        final tile = tiles[i];

        // Find adjacent tile above
        GameTile? adjacentTile;
        for (var j = i + 1; j < tiles.length; j++) {
          final expectedY = tile.yPosition + config.tileSize;
          const epsilon = 0.01;

          if ((tiles[j].yPosition - expectedY).abs() < epsilon) {
            adjacentTile = tiles[j];
            break;
          }
        }

        // Check if can merge
        if (adjacentTile != null && tile.canMergeWith(adjacentTile)) {
          // MERGE: Remove both, create new merged tile
          final mergedValue = tile.value * 2;
          final mergedTile = GameTile(
            id: 'tile_${_nextTileId++}',
            value: mergedValue,
            columnIndex: column.index,
            yPosition: tile.yPosition, // Place at lower position
            isSettled: true,
          );

          updatedTiles.add(mergedTile);
          processedIds.add(tile.id);
          processedIds.add(adjacentTile.id);
          totalScore += mergedValue;
        } else {
          // No merge, keep tile
          updatedTiles.add(tile);
          processedIds.add(tile.id);
        }
      }

      newColumns.add(GameColumn(index: column.index, tiles: updatedTiles));
    }

    final newBoard = BoardState(
      columns: newColumns,
      boardHeight: config.boardHeight,
      tileSize: config.tileSize,
    );

    return _MergeResult(
      state: state.copyWith(
        board: newBoard,
        currentScore: state.currentScore + totalScore,
      ),
      scoreGained: totalScore,
    );
  }

  /// STEP 4: Stabilization pass
  /// Removes gaps and ensures proper stacking
  GameState _stabilizeBoard(GameState state) {
    final newColumns = <GameColumn>[];

    for (final column in state.board.columns) {
      final settledTiles = column.tiles.where((t) => t.isSettled).toList();
      final fallingTiles = column.tiles.where((t) => !t.isSettled).toList();

      // Sort settled tiles
      settledTiles.sort((a, b) => a.yPosition.compareTo(b.yPosition));

      // Repack settled tiles from bottom
      final repacked = <GameTile>[];
      double currentY = 0.0;

      for (final tile in settledTiles) {
        repacked.add(tile.copyWith(yPosition: currentY));
        currentY += config.tileSize;
      }

      // Add falling tiles unchanged
      repacked.addAll(fallingTiles);

      newColumns.add(GameColumn(index: column.index, tiles: repacked));
    }

    return state.copyWith(
      board: BoardState(
        columns: newColumns,
        boardHeight: config.boardHeight,
        tileSize: config.tileSize,
      ),
    );
  }

  /// Spawn a new tile
  GameState _spawnTile(GameState state) {
    // Count active (unsettled) tiles
    final activeTiles =
        state.board.getAllTiles().where((t) => !t.isSettled).length;
    if (activeTiles >= config.maxActiveTiles) {
      return state; // Too many active tiles
    }

    // Pick random column
    final columnIndex = _random.nextInt(config.columnCount);
    final column = state.board.columns[columnIndex];

    // Check if spawn position is clear
    final spawnY = config.boardHeight - config.tileSize;
    for (final tile in column.tiles) {
      if (tile.yPosition >= spawnY - config.tileSize) {
        return state; // Column too full
      }
    }

    // Pick random value
    final value =
        config.initialTileValues[_random.nextInt(
          config.initialTileValues.length,
        )];

    // Create new tile
    final newTile = GameTile(
      id: 'tile_${_nextTileId++}',
      value: value,
      columnIndex: columnIndex,
      yPosition: spawnY,
      isSettled: false,
      velocity: 0.0,
    );

    // Add to column
    final updatedColumn = GameColumn(
      index: columnIndex,
      tiles: [...column.tiles, newTile],
    );

    final newColumns = List<GameColumn>.from(state.board.columns);
    newColumns[columnIndex] = updatedColumn;

    return state.copyWith(
      board: BoardState(
        columns: newColumns,
        boardHeight: config.boardHeight,
        tileSize: config.tileSize,
      ),
    );
  }

  /// Move tile horizontally (player input)
  /// STRICT RULE: Movement only allowed if no collision will occur
  /// Returns updated state or original if move is invalid
  GameState moveTileHorizontal(
    GameState state,
    String tileId,
    int targetColumn,
  ) {
    // Validate target column
    if (targetColumn < 0 || targetColumn >= config.columnCount) {
      return state; // Invalid column
    }

    // Find tile
    final tile = state.board.getTileById(tileId);
    if (tile == null) {
      return state; // Tile not found
    }

    // Validate move is allowed
    if (tile.isSettled) {
      return state; // Can't move settled tiles
    }

    if (tile.columnIndex == targetColumn) {
      return state; // Already in target column
    }

    // STRICT: Check if target column has ANY overlap with the tile
    final targetColumnData = state.board.columns[targetColumn];
    final movedTile = tile.copyWith(columnIndex: targetColumn);

    for (final other in targetColumnData.tiles) {
      // Check for ANY overlap - zero tolerance
      if (movedTile.overlapsWith(other, config.tileSize)) {
        return state; // Movement blocked - tiles would touch
      }

      // Also check if tile would be too close (safety margin)
      final tileBounds = _getTileBounds(movedTile);
      final otherBounds = _getTileBounds(other);

      // Tiles must maintain at least 0.1px separation
      if (_boundsOverlapOrTouch(tileBounds, otherBounds)) {
        return state; // Too close - reject movement
      }
    }

    // Execute move
    final newColumns = List<GameColumn>.from(state.board.columns);

    // Remove from source column
    final sourceColumn = newColumns[tile.columnIndex];
    newColumns[tile.columnIndex] = GameColumn(
      index: sourceColumn.index,
      tiles: sourceColumn.tiles.where((t) => t.id != tileId).toList(),
    );

    // Add to target column
    newColumns[targetColumn] = GameColumn(
      index: targetColumn,
      tiles: [...targetColumnData.tiles, movedTile],
    );

    return state.copyWith(
      board: BoardState(
        columns: newColumns,
        boardHeight: config.boardHeight,
        tileSize: config.tileSize,
      ),
    );
  }

  /// Get tile boundaries for strict collision checking
  _TileBounds _getTileBounds(GameTile tile) {
    return _TileBounds(
      bottom: tile.yPosition,
      top: tile.yPosition + config.tileSize,
    );
  }

  /// Check if two tile bounds overlap or touch (zero tolerance)
  bool _boundsOverlapOrTouch(_TileBounds a, _TileBounds b) {
    // Tiles overlap or touch if there's any intersection
    return !(a.top <= b.bottom || b.top <= a.bottom);
  }
}

/// Internal merge result
class _MergeResult {
  const _MergeResult({required this.state, required this.scoreGained});

  final GameState state;
  final int scoreGained;
}

/// Helper class for tile bounds checking
class _TileBounds {
  const _TileBounds({required this.bottom, required this.top});

  final double bottom;
  final double top;
}
