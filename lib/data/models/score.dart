import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Score record for leaderboard/history
@immutable
class ScoreRecord extends Equatable {
  const ScoreRecord({
    required this.score,
    required this.timestamp,
    this.maxCombo = 0,
    this.maxTileValue = 0,
  });

  final int score;
  final DateTime timestamp;
  final int maxCombo;
  final int maxTileValue;

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'timestamp': timestamp.toIso8601String(),
      'maxCombo': maxCombo,
      'maxTileValue': maxTileValue,
    };
  }

  /// Create from JSON
  factory ScoreRecord.fromJson(Map<String, dynamic> json) {
    return ScoreRecord(
      score: json['score'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      maxCombo: json['maxCombo'] as int? ?? 0,
      maxTileValue: json['maxTileValue'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [score, timestamp, maxCombo, maxTileValue];
}

/// Floating score popup data
@immutable
class ScorePopup extends Equatable {
  const ScorePopup({
    required this.id,
    required this.points,
    required this.position,
    required this.timestamp,
  });

  final String id;
  final int points;
  final Offset position;
  final DateTime timestamp;

  @override
  List<Object?> get props => [id, points, position, timestamp];
}
