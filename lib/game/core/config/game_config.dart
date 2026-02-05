/// Game configuration - all gameplay constants
/// Centralized to prevent hardcoding and enable tuning
class GameConfig {
  const GameConfig({
    required this.boardWidth,
    required this.boardHeight,
    required this.columnCount,
    required this.tileSize,
    required this.baseGravity,
    required this.maxGravity,
    required this.gravityScalePerLevel,
    required this.spawnInterval,
    required this.maxActiveTiles,
    required this.initialTileValues,
    this.randomSeed,
  }) : assert(boardWidth > 0, 'Board width must be positive'),
       assert(boardHeight > 0, 'Board height must be positive'),
       assert(columnCount > 0, 'Column count must be positive'),
       assert(tileSize > 0, 'Tile size must be positive'),
       assert(baseGravity > 0, 'Base gravity must be positive'),
       assert(maxGravity >= baseGravity, 'Max gravity must be >= base gravity'),
       assert(spawnInterval > 0, 'Spawn interval must be positive'),
       assert(maxActiveTiles > 0, 'Max active tiles must be positive');

  final double boardWidth;
  final double boardHeight;
  final int columnCount;
  final double tileSize;

  /// Gravity in pixels/second²
  final double baseGravity;
  final double maxGravity;
  final double gravityScalePerLevel;

  /// Spawn timing in seconds
  final double spawnInterval;

  /// Maximum number of unsettled tiles
  final int maxActiveTiles;

  /// Possible values for newly spawned tiles
  final List<int> initialTileValues;

  /// Random seed for deterministic testing (null = random)
  final int? randomSeed;

  /// Get gravity for a given difficulty level
  double getGravity(int level) {
    final scaled = baseGravity + (level - 1) * gravityScalePerLevel;
    return scaled.clamp(baseGravity, maxGravity);
  }

  /// Default production configuration
  static const GameConfig standard = GameConfig(
    boardWidth: 360, // 7 columns × 48px + 6 gaps × 4px = 360px
    boardHeight: 632, // 12 rows × 48px + 11 gaps × 4px = 632px
    columnCount: 7,
    tileSize: 48, // Match UI constant
    baseGravity: 300,
    maxGravity: 1200,
    gravityScalePerLevel: 50,
    spawnInterval: 2.0,
    maxActiveTiles: 5,
    initialTileValues: [2, 4],
  );

  /// Testing configuration with seed
  static GameConfig testing({int? seed}) => GameConfig(
    boardWidth: 360, // 7 columns × 48px + 6 gaps × 4px = 360px
    boardHeight: 632, // 12 rows × 48px + 11 gaps × 4px = 632px
    columnCount: 7,
    tileSize: 48, // Match UI constant
    baseGravity: 300,
    maxGravity: 1200,
    gravityScalePerLevel: 50,
    spawnInterval: 2.0,
    maxActiveTiles: 5,
    initialTileValues: [2, 4],
    randomSeed: seed,
  );
}
