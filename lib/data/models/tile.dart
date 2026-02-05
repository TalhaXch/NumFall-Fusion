import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents a single tile in the game with physics properties
@immutable
class Tile extends Equatable {
  const Tile({
    required this.id,
    required this.value,
    required this.position,
    required this.velocity,
    required this.column,
    this.targetColumn,
    this.isStatic = false,
    this.isMerging = false,
  });

  /// Unique identifier for this tile
  final String id;

  /// Numerical value (2, 4, 8, 16, etc.)
  final int value;

  /// Current position in pixels (x, y from top-left)
  final Offset position;

  /// Current velocity in pixels per second
  final Offset velocity;

  /// Column index (0 to boardColumns-1) - tiles MUST stay in their column
  final int column;

  /// Target column for smooth movement (null if not moving)
  final int? targetColumn;

  /// Whether this tile is static (cannot move)
  final bool isStatic;

  /// Whether this tile is currently merging
  final bool isMerging;

  /// Create a copy with updated properties
  Tile copyWith({
    String? id,
    int? value,
    Offset? position,
    Offset? velocity,
    int? column,
    int? targetColumn,
    bool? isStatic,
    bool? isMerging,
  }) {
    return Tile(
      id: id ?? this.id,
      value: value ?? this.value,
      position: position ?? this.position,
      velocity: velocity ?? this.velocity,
      column: column ?? this.column,
      targetColumn: targetColumn,
      isStatic: isStatic ?? this.isStatic,
      isMerging: isMerging ?? this.isMerging,
    );
  }

  /// Get tile bounds for collision detection (AABB)
  Rect get bounds {
    return Rect.fromLTWH(
      position.dx,
      position.dy,
      48.0, // tile size from constants
      48.0,
    );
  }

  /// Check if this tile is at rest (not moving)
  bool get isAtRest {
    return velocity.distance < 5.0; // threshold from constants
  }

  @override
  List<Object?> get props => [
    id,
    value,
    position,
    velocity,
    column,
    targetColumn,
    isStatic,
    isMerging,
  ];

  @override
  String toString() =>
      'Tile(id: $id, value: $value, col: $column, pos: $position, vel: $velocity)';
}
