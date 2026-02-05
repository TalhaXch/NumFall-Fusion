import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'tile.dart';

/// Game state status enumeration
enum GameStatus { idle, playing, paused, gameOver }

/// Immutable game state representation
@immutable
class GameState extends Equatable {
  const GameState({
    required this.tiles,
    required this.score,
    required this.status,
    required this.combo,
    required this.comboTimer,
    required this.timeElapsed,
    required this.nextSpawnTime,
  });

  /// All active tiles on the board
  final List<Tile> tiles;

  /// Current score
  final int score;

  /// Current game status
  final GameStatus status;

  /// Current combo count
  final int combo;

  /// Time remaining for combo (seconds)
  final double comboTimer;

  /// Total time elapsed in game (seconds)
  final double timeElapsed;

  /// Time until next tile spawn (seconds)
  final double nextSpawnTime;

  /// Initial game state
  factory GameState.initial() {
    return const GameState(
      tiles: [],
      score: 0,
      status: GameStatus.idle,
      combo: 0,
      comboTimer: 0,
      timeElapsed: 0,
      nextSpawnTime: 2.5,
    );
  }

  /// Create a copy with updated properties
  GameState copyWith({
    List<Tile>? tiles,
    int? score,
    GameStatus? status,
    int? combo,
    double? comboTimer,
    double? timeElapsed,
    double? nextSpawnTime,
  }) {
    return GameState(
      tiles: tiles ?? this.tiles,
      score: score ?? this.score,
      status: status ?? this.status,
      combo: combo ?? this.combo,
      comboTimer: comboTimer ?? this.comboTimer,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      nextSpawnTime: nextSpawnTime ?? this.nextSpawnTime,
    );
  }

  /// Check if game is active
  bool get isActive => status == GameStatus.playing;

  /// Check if game is over
  bool get isGameOver => status == GameStatus.gameOver;

  /// Check if game is paused
  bool get isPaused => status == GameStatus.paused;

  /// Get number of active (moving) tiles
  int get activeTileCount =>
      tiles.where((t) => !t.isStatic && !t.isAtRest).length;

  @override
  List<Object?> get props => [
    tiles,
    score,
    status,
    combo,
    comboTimer,
    timeElapsed,
    nextSpawnTime,
  ];

  @override
  String toString() =>
      'GameState(score: $score, status: $status, tiles: ${tiles.length})';
}
