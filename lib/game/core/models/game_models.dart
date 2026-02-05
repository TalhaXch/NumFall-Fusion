import 'package:flutter/foundation.dart';

/// Immutable tile entity
/// Represents a single number tile in the game
@immutable
class GameTile {
  const GameTile({
    required this.id,
    required this.value,
    required this.columnIndex,
    required this.yPosition,
    required this.isSettled,
    this.velocity = 0.0,
  }) : assert(value > 0, 'Tile value must be positive'),
       assert(columnIndex >= 0, 'Column index must be non-negative'),
       assert(yPosition >= 0, 'Y position must be non-negative');

  final String id;
  final int value;
  final int columnIndex;
  final double yPosition; // In pixels from bottom
  final bool isSettled;
  final double velocity; // Pixels per second (downward positive)

  /// Get tile height (tiles are square)
  double getHeight(double tileSize) => tileSize;

  /// Get tile top Y position
  double getTop(double tileSize) => yPosition + tileSize;

  /// Check if this tile overlaps with another
  bool overlapsWith(GameTile other, double tileSize) {
    if (columnIndex != other.columnIndex) return false;

    final thisTop = yPosition + tileSize;
    final otherTop = other.yPosition + tileSize;

    return !(thisTop <= other.yPosition || yPosition >= otherTop);
  }

  /// Check if this tile can merge with another
  bool canMergeWith(GameTile other) {
    return columnIndex == other.columnIndex &&
        value == other.value &&
        isSettled &&
        other.isSettled;
  }

  GameTile copyWith({
    String? id,
    int? value,
    int? columnIndex,
    double? yPosition,
    bool? isSettled,
    double? velocity,
  }) {
    return GameTile(
      id: id ?? this.id,
      value: value ?? this.value,
      columnIndex: columnIndex ?? this.columnIndex,
      yPosition: yPosition ?? this.yPosition,
      isSettled: isSettled ?? this.isSettled,
      velocity: velocity ?? this.velocity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameTile && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'GameTile(id: $id, value: $value, col: $columnIndex, y: $yPosition, settled: $isSettled)';
}

/// Column entity - maintains tiles in vertical order
@immutable
class GameColumn {
  const GameColumn({required this.index, required this.tiles})
    : assert(index >= 0, 'Column index must be non-negative');

  final int index;
  final List<GameTile> tiles; // Ordered bottom to top

  /// Get total height of settled tiles
  double getTotalHeight(double tileSize) {
    return tiles.where((t) => t.isSettled).length * tileSize;
  }

  /// Get topmost settled tile
  GameTile? getTopSettledTile() {
    final settled = tiles.where((t) => t.isSettled).toList();
    if (settled.isEmpty) return null;
    settled.sort((a, b) => b.yPosition.compareTo(a.yPosition));
    return settled.first;
  }

  /// Validate column integrity
  void validate(double tileSize, double boardHeight) {
    // Check no tiles exceed board height
    for (final tile in tiles) {
      if (tile.yPosition + tileSize > boardHeight) {
        throw StateError(
          'Tile ${tile.id} exceeds board height: ${tile.yPosition + tileSize} > $boardHeight',
        );
      }
    }

    // Check no overlapping tiles
    for (var i = 0; i < tiles.length; i++) {
      for (var j = i + 1; j < tiles.length; j++) {
        if (tiles[i].overlapsWith(tiles[j], tileSize)) {
          throw StateError(
            'Overlapping tiles detected: ${tiles[i].id} and ${tiles[j].id}',
          );
        }
      }
    }

    // Check settled tiles are properly stacked
    final settled = tiles.where((t) => t.isSettled).toList();
    settled.sort((a, b) => a.yPosition.compareTo(b.yPosition));

    double expectedY = 0;
    for (final tile in settled) {
      const epsilon = 0.01;
      if ((tile.yPosition - expectedY).abs() > epsilon) {
        throw StateError(
          'Floating tile detected: ${tile.id} at $tile.yPosition, expected $expectedY',
        );
      }
      expectedY += tileSize;
    }
  }

  @override
  String toString() => 'Column($index, ${tiles.length} tiles)';
}

/// Board state - manages all columns
@immutable
class BoardState {
  const BoardState({
    required this.columns,
    required this.boardHeight,
    required this.tileSize,
  }) : assert(boardHeight > 0, 'Board height must be positive'),
       assert(tileSize > 0, 'Tile size must be positive');

  final List<GameColumn> columns;
  final double boardHeight;
  final double tileSize;

  int get columnCount => columns.length;

  bool get isGameOver {
    // Game over if any column has tiles near the top
    final threshold = boardHeight - (tileSize * 2);
    for (final column in columns) {
      for (final tile in column.tiles) {
        if (tile.isSettled && tile.yPosition >= threshold) {
          return true;
        }
      }
    }
    return false;
  }

  /// Get all tiles across all columns
  List<GameTile> getAllTiles() {
    final allTiles = <GameTile>[];
    for (final column in columns) {
      allTiles.addAll(column.tiles);
    }
    return allTiles;
  }

  /// Get tile by ID
  GameTile? getTileById(String id) {
    for (final column in columns) {
      for (final tile in column.tiles) {
        if (tile.id == id) return tile;
      }
    }
    return null;
  }

  /// Validate entire board state
  void validate() {
    // Validate each column
    for (final column in columns) {
      column.validate(tileSize, boardHeight);
    }

    // Check no duplicate tile IDs
    final ids = <String>{};
    for (final tile in getAllTiles()) {
      if (ids.contains(tile.id)) {
        throw StateError('Duplicate tile ID: ${tile.id}');
      }
      ids.add(tile.id);
    }

    // Check tiles are in correct columns
    for (var i = 0; i < columns.length; i++) {
      for (final tile in columns[i].tiles) {
        if (tile.columnIndex != i) {
          throw StateError(
            'Tile ${tile.id} in wrong column: expected $i, got ${tile.columnIndex}',
          );
        }
      }
    }
  }

  @override
  String toString() =>
      'BoardState($columnCount columns, ${getAllTiles().length} tiles)';
}

/// Complete game state
@immutable
class GameState {
  const GameState({
    required this.board,
    required this.currentScore,
    required this.bestScore,
    required this.difficultyLevel,
    required this.tickCount,
  }) : assert(currentScore >= 0, 'Score must be non-negative'),
       assert(bestScore >= 0, 'Best score must be non-negative'),
       assert(difficultyLevel >= 1, 'Difficulty must be at least 1'),
       assert(tickCount >= 0, 'Tick count must be non-negative');

  final BoardState board;
  final int currentScore;
  final int bestScore;
  final int difficultyLevel;
  final int tickCount;

  bool get isGameOver => board.isGameOver;

  GameState copyWith({
    BoardState? board,
    int? currentScore,
    int? bestScore,
    int? difficultyLevel,
    int? tickCount,
  }) {
    return GameState(
      board: board ?? this.board,
      currentScore: currentScore ?? this.currentScore,
      bestScore: bestScore ?? this.bestScore,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      tickCount: tickCount ?? this.tickCount,
    );
  }

  @override
  String toString() =>
      'GameState(score: $currentScore, tick: $tickCount, gameOver: $isGameOver)';
}
