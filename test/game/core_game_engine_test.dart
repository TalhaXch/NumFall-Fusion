import 'package:flutter_test/flutter_test.dart';
import 'package:numfallfusion/game/core/models/game_models.dart';
import 'package:numfallfusion/game/core/config/game_config.dart';
import 'package:numfallfusion/game/core/engine/core_game_engine.dart';

void main() {
  group('CoreGameEngine - Deterministic Tests', () {
    late GameConfig config;
    late CoreGameEngine engine;

    setUp(() {
      config = GameConfig.testing(seed: 42);
      engine = CoreGameEngine(config: config);
    });

    test('Initialize creates valid empty board', () {
      final state = engine.initialize();

      expect(state.currentScore, 0);
      expect(state.tickCount, 0);
      expect(state.difficultyLevel, 1);
      expect(state.board.columnCount, config.columnCount);
      expect(state.board.getAllTiles(), isEmpty);
      expect(state.isGameOver, false);

      // Validate integrity
      expect(() => state.board.validate(), returnsNormally);
    });

    test('Tick increments tick count', () {
      var state = engine.initialize();
      state = engine.tick(state, 0.016); // ~60 FPS

      expect(state.tickCount, 1);
    });

    test('Gravity pulls tiles downward', () {
      var state = engine.initialize();

      // Manually add a falling tile at top
      final tile = GameTile(
        id: 'test1',
        value: 2,
        columnIndex: 3,
        yPosition: config.boardHeight - config.tileSize,
        isSettled: false,
        velocity: 0.0,
      );

      final updatedColumn = GameColumn(index: 3, tiles: [tile]);

      final columns = List<GameColumn>.from(state.board.columns);
      columns[3] = updatedColumn;

      state = state.copyWith(
        board: BoardState(
          columns: columns,
          boardHeight: config.boardHeight,
          tileSize: config.tileSize,
        ),
      );

      final initialY = tile.yPosition;

      // Tick several times
      for (var i = 0; i < 10; i++) {
        state = engine.tick(state, 0.016);
      }

      final updatedTile = state.board.getTileById('test1');
      expect(updatedTile, isNotNull);
      expect(updatedTile!.yPosition, lessThan(initialY)); // Fell down
    });

    test('Tile settles on floor', () {
      var state = engine.initialize();

      // Add tile near floor
      final tile = GameTile(
        id: 'test1',
        value: 2,
        columnIndex: 3,
        yPosition: 10,
        isSettled: false,
        velocity: 100.0,
      );

      final columns = List<GameColumn>.from(state.board.columns);
      columns[3] = GameColumn(index: 3, tiles: [tile]);

      state = state.copyWith(
        board: BoardState(
          columns: columns,
          boardHeight: config.boardHeight,
          tileSize: config.tileSize,
        ),
      );

      // Tick until settled
      for (var i = 0; i < 20; i++) {
        state = engine.tick(state, 0.016);
      }

      final settledTile = state.board.getTileById('test1');
      expect(settledTile, isNotNull);
      expect(settledTile!.isSettled, true);
      expect(settledTile.yPosition, 0.0); // On floor
    });

    test('Tiles stack correctly in same column', () {
      var state = engine.initialize();

      // Add two tiles in same column
      final tile1 = GameTile(
        id: 'test1',
        value: 2,
        columnIndex: 3,
        yPosition: 0.0,
        isSettled: true,
      );

      final tile2 = GameTile(
        id: 'test2',
        value: 4,
        columnIndex: 3,
        yPosition: 200,
        isSettled: false,
        velocity: 100.0,
      );

      final columns = List<GameColumn>.from(state.board.columns);
      columns[3] = GameColumn(index: 3, tiles: [tile1, tile2]);

      state = state.copyWith(
        board: BoardState(
          columns: columns,
          boardHeight: config.boardHeight,
          tileSize: config.tileSize,
        ),
      );

      // Tick until second tile settles
      for (var i = 0; i < 30; i++) {
        state = engine.tick(state, 0.016);
      }

      final settledTile2 = state.board.getTileById('test2');
      expect(settledTile2, isNotNull);
      expect(settledTile2!.isSettled, true);
      expect(settledTile2.yPosition, config.tileSize); // On top of tile1

      // Validate no overlap
      expect(() => state.board.validate(), returnsNormally);
    });

    test('Same value tiles merge on contact', () {
      var state = engine.initialize();

      // Add two tiles with same value
      final tile1 = GameTile(
        id: 'test1',
        value: 2,
        columnIndex: 3,
        yPosition: 0.0,
        isSettled: true,
      );

      final tile2 = GameTile(
        id: 'test2',
        value: 2, // Same value
        columnIndex: 3,
        yPosition: 100,
        isSettled: false,
        velocity: 100.0,
      );

      final columns = List<GameColumn>.from(state.board.columns);
      columns[3] = GameColumn(index: 3, tiles: [tile1, tile2]);

      state = state.copyWith(
        board: BoardState(
          columns: columns,
          boardHeight: config.boardHeight,
          tileSize: config.tileSize,
        ),
      );

      final initialScore = state.currentScore;

      // Tick until merge happens
      for (var i = 0; i < 50; i++) {
        state = engine.tick(state, 0.016);
      }

      // Both original tiles should be gone
      expect(state.board.getTileById('test1'), isNull);
      expect(state.board.getTileById('test2'), isNull);

      // Should have a merged tile with value 4
      final column = state.board.columns[3];
      final settledTiles = column.tiles.where((t) => t.isSettled).toList();
      expect(settledTiles.length, 1);
      expect(settledTiles.first.value, 4);

      // Score should increase
      expect(state.currentScore, greaterThan(initialScore));
    });

    test('Different value tiles do not merge', () {
      var state = engine.initialize();

      final tile1 = GameTile(
        id: 'test1',
        value: 2,
        columnIndex: 3,
        yPosition: 0.0,
        isSettled: true,
      );

      final tile2 = GameTile(
        id: 'test2',
        value: 4, // Different value
        columnIndex: 3,
        yPosition: 100,
        isSettled: false,
        velocity: 100.0,
      );

      final columns = List<GameColumn>.from(state.board.columns);
      columns[3] = GameColumn(index: 3, tiles: [tile1, tile2]);

      state = state.copyWith(
        board: BoardState(
          columns: columns,
          boardHeight: config.boardHeight,
          tileSize: config.tileSize,
        ),
      );

      // Tick until settled
      for (var i = 0; i < 50; i++) {
        state = engine.tick(state, 0.016);
      }

      // Both tiles should still exist (no merge)
      expect(state.board.getTileById('test1'), isNotNull);
      expect(state.board.getTileById('test2'), isNotNull);

      final column = state.board.columns[3];
      expect(column.tiles.length, 2);
    });

    test('Stabilization removes gaps', () {
      var state = engine.initialize();

      // Create tiles with gaps
      final tile1 = GameTile(
        id: 'test1',
        value: 2,
        columnIndex: 3,
        yPosition: 0.0,
        isSettled: true,
      );

      final tile2 = GameTile(
        id: 'test2',
        value: 4,
        columnIndex: 3,
        yPosition: config.tileSize * 3, // Gap!
        isSettled: true,
      );

      final columns = List<GameColumn>.from(state.board.columns);
      columns[3] = GameColumn(index: 3, tiles: [tile1, tile2]);

      state = state.copyWith(
        board: BoardState(
          columns: columns,
          boardHeight: config.boardHeight,
          tileSize: config.tileSize,
        ),
      );

      // Tick once (includes stabilization)
      state = engine.tick(state, 0.016);

      // Gap should be removed
      final updatedTile2 = state.board.getTileById('test2');
      expect(updatedTile2, isNotNull);
      expect(updatedTile2!.yPosition, config.tileSize); // Right on top of tile1
    });

    test('Game over when tiles reach top', () {
      var state = engine.initialize();

      // Fill column to near top
      final tiles = <GameTile>[];
      final maxTiles = (config.boardHeight / config.tileSize).floor() - 1;

      for (var i = 0; i < maxTiles; i++) {
        tiles.add(
          GameTile(
            id: 'tile$i',
            value: 2,
            columnIndex: 3,
            yPosition: i * config.tileSize,
            isSettled: true,
          ),
        );
      }

      final columns = List<GameColumn>.from(state.board.columns);
      columns[3] = GameColumn(index: 3, tiles: tiles);

      state = state.copyWith(
        board: BoardState(
          columns: columns,
          boardHeight: config.boardHeight,
          tileSize: config.tileSize,
        ),
      );

      expect(state.isGameOver, true);
    });

    test('Horizontal move succeeds when valid', () {
      var state = engine.initialize();

      final tile = GameTile(
        id: 'test1',
        value: 2,
        columnIndex: 3,
        yPosition: 100,
        isSettled: false,
      );

      final columns = List<GameColumn>.from(state.board.columns);
      columns[3] = GameColumn(index: 3, tiles: [tile]);

      state = state.copyWith(
        board: BoardState(
          columns: columns,
          boardHeight: config.boardHeight,
          tileSize: config.tileSize,
        ),
      );

      // Move to column 4
      state = engine.moveTileHorizontal(state, 'test1', 4);

      final movedTile = state.board.getTileById('test1');
      expect(movedTile, isNotNull);
      expect(movedTile!.columnIndex, 4);

      // Original column should be empty
      expect(state.board.columns[3].tiles, isEmpty);

      // New column should have the tile
      expect(state.board.columns[4].tiles, contains(movedTile));
    });

    test('Horizontal move blocked when settled', () {
      var state = engine.initialize();

      final tile = GameTile(
        id: 'test1',
        value: 2,
        columnIndex: 3,
        yPosition: 0,
        isSettled: true, // Settled
      );

      final columns = List<GameColumn>.from(state.board.columns);
      columns[3] = GameColumn(index: 3, tiles: [tile]);

      state = state.copyWith(
        board: BoardState(
          columns: columns,
          boardHeight: config.boardHeight,
          tileSize: config.tileSize,
        ),
      );

      final stateBefore = state;

      // Try to move
      state = engine.moveTileHorizontal(state, 'test1', 4);

      // Should be unchanged
      expect(state, stateBefore);
      final unmoved = state.board.getTileById('test1');
      expect(unmoved!.columnIndex, 3); // Still in original column
    });

    test('Engine is deterministic with same seed', () {
      final engine1 = CoreGameEngine(config: GameConfig.testing(seed: 123));
      final engine2 = CoreGameEngine(config: GameConfig.testing(seed: 123));

      var state1 = engine1.initialize();
      var state2 = engine2.initialize();

      // Run same number of ticks
      for (var i = 0; i < 100; i++) {
        state1 = engine1.tick(state1, 0.016);
        state2 = engine2.tick(state2, 0.016);
      }

      // States should be identical
      expect(state1.currentScore, state2.currentScore);
      expect(
        state1.board.getAllTiles().length,
        state2.board.getAllTiles().length,
      );
    });

    test('Board validation catches overlapping tiles', () {
      final tile1 = GameTile(
        id: 'test1',
        value: 2,
        columnIndex: 3,
        yPosition: 0.0,
        isSettled: true,
      );

      final tile2 = GameTile(
        id: 'test2',
        value: 4,
        columnIndex: 3,
        yPosition: 10.0, // Overlaps with tile1
        isSettled: true,
      );

      final columns = List.generate(
        config.columnCount,
        (i) =>
            i == 3
                ? GameColumn(index: i, tiles: [tile1, tile2])
                : GameColumn(index: i, tiles: const []),
      );

      final board = BoardState(
        columns: columns,
        boardHeight: config.boardHeight,
        tileSize: config.tileSize,
      );

      expect(() => board.validate(), throwsStateError);
    });

    test('Board validation catches floating tiles', () {
      final tile1 = GameTile(
        id: 'test1',
        value: 2,
        columnIndex: 3,
        yPosition: config.tileSize * 2, // Gap below
        isSettled: true,
      );

      final columns = List.generate(
        config.columnCount,
        (i) =>
            i == 3
                ? GameColumn(index: i, tiles: [tile1])
                : GameColumn(index: i, tiles: const []),
      );

      final board = BoardState(
        columns: columns,
        boardHeight: config.boardHeight,
        tileSize: config.tileSize,
      );

      expect(() => board.validate(), throwsStateError);
    });
  });
}
