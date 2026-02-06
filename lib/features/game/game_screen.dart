import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/feedback_utils.dart';
import '../../core/utils/responsive_utils.dart';
import '../../data/repositories/game_repository.dart';
import '../../providers/game_providers.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/game_button.dart';
import '../../widgets/game/game_tile_widget.dart';
import '../../widgets/game/game_hud.dart';
import '../../widgets/game/score_popup_widget.dart';
import 'pause_menu.dart';
import 'game_over_screen.dart';

/// Main game screen with real-time board and HUD
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  DateTime? _lastFrameTime;
  Size? _boardSize;
  int _highScore = 0;
  int _lastScore = 0; // Track score for level-up detection

  // Level-up thresholds (every 100 points)
  static const int _levelUpInterval = 100;

  @override
  void initState() {
    super.initState();

    // Load high score
    _loadHighScore();

    // Create ticker for game loop
    _ticker = createTicker(_onTick);

    // Start game after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  Future<void> _loadHighScore() async {
    final repo = await GameRepository.getInstance();
    setState(() {
      _highScore = repo.getHighScore();
    });
  }

  void _initializeGame() {
    final screenSize = MediaQuery.of(context).size;
    final scale = ResponsiveUtils.getBoardScale(screenSize);

    // Calculate board size
    const boardWidth =
        GameConstants.boardColumns * GameConstants.tileSize +
        (GameConstants.boardColumns - 1) * GameConstants.tileSpacing;
    const boardHeight =
        GameConstants.boardRows * GameConstants.tileSize +
        (GameConstants.boardRows - 1) * GameConstants.tileSpacing;

    _boardSize = Size(boardWidth * scale, boardHeight * scale);

    // Initialize game engine
    ref
        .read(gameStateProvider.notifier)
        .initializeEngine(
          _boardSize!,
          (points, position) {
            ref.read(scorePopupsProvider.notifier).addPopup(points, position);
          },
          () {
            // On merge callback
            if (ref.read(settingsProvider).hapticsEnabled) {
              HapticUtils.medium();
            }
            SoundUtils.play(SoundEffect.tileMerge);
          },
        );

    // Start game
    ref.read(gameStateProvider.notifier).startGame();
    _ticker.start();

    // Start background music
    SoundUtils.startMusic();
  }

  void _onTick(Duration elapsed) {
    if (_lastFrameTime == null) {
      _lastFrameTime = DateTime.now();
      return;
    }

    // NOTE: Controller now manages its own tick loop internally
    // No need to call tick() from UI anymore
    // The controller runs at its own configurable tick rate (60 FPS)

    // Check for game state changes
    final gameState = ref.read(gameStateProvider);

    // Check for level up (score crossed a milestone)
    if (gameState.score > _lastScore) {
      final lastLevel = _lastScore ~/ _levelUpInterval;
      final currentLevel = gameState.score ~/ _levelUpInterval;

      if (currentLevel > lastLevel) {
        // Level up achieved!
        if (mounted && ref.read(settingsProvider).hapticsEnabled) {
          HapticUtils.success();
        }
        SoundUtils.play(SoundEffect.levelUp);
      }

      _lastScore = gameState.score;
    }

    if (gameState.isGameOver) {
      _ticker.stop();
      _handleGameOver();
    }
  }

  Future<void> _handleGameOver() async {
    final gameState = ref.read(gameStateProvider);
    final repo = await GameRepository.getInstance();

    // Stop background music
    SoundUtils.stopMusic();

    // Save high score
    final isNewHighScore = await repo.saveHighScore(gameState.score);
    await repo.incrementGamesPlayed();

    if (isNewHighScore && mounted) {
      if (ref.read(settingsProvider).hapticsEnabled) {
        HapticUtils.success();
      }
      SoundUtils.play(SoundEffect.newHighScore);
    } else if (mounted) {
      if (ref.read(settingsProvider).hapticsEnabled) {
        HapticUtils.error();
      }
      SoundUtils.play(SoundEffect.gameOver);
    }

    // Navigate to game over screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) => GameOverScreen(
                score: gameState.score,
                isNewHighScore: isNewHighScore,
                highScore: isNewHighScore ? gameState.score : _highScore,
              ),
        ),
      );
    }
  }

  void _pauseGame() {
    _ticker.stop();
    ref.read(gameStateProvider.notifier).pauseGame();

    // Pause background music
    SoundUtils.pauseMusic();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PauseMenu(
            onResume: () {
              Navigator.of(context).pop();
              ref.read(gameStateProvider.notifier).resumeGame();
              _lastFrameTime = DateTime.now();
              _ticker.start();
              // Resume background music
              SoundUtils.resumeMusic();
            },
            onQuit: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              // Stop music when quitting
              SoundUtils.stopMusic();
            },
          ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    // Stop music when leaving screen
    SoundUtils.stopMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final scorePopups = ref.watch(scorePopupsProvider);
    final screenSize = MediaQuery.of(context).size;
    final scale = ResponsiveUtils.getBoardScale(screenSize);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/bg image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.all(GameConstants.defaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GameIconButton(icon: Icons.pause, onPressed: _pauseGame),
                    GameHUD(
                      score: gameState.score,
                      highScore: _highScore,
                      combo: gameState.combo,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Game Board
              if (_boardSize != null)
                GestureDetector(
                  onTapDown: (details) {
                    // Tap to move tiles to tapped column (smooth movement)
                    final tapX = details.localPosition.dx;
                    final boardWidth = _boardSize!.width;
                    final columnWidth = boardWidth / GameConstants.boardColumns;
                    final targetColumn = (tapX / columnWidth).floor().clamp(
                      0,
                      GameConstants.boardColumns - 1,
                    );

                    // Move tiles to target column with smooth animation
                    ref
                        .read(gameStateProvider.notifier)
                        .moveTilesToColumn(targetColumn);
                  },
                  onHorizontalDragUpdate: (details) {
                    // Swipe to move tiles one column at a time
                    if (details.primaryDelta! > 10) {
                      ref.read(gameStateProvider.notifier).moveTilesRight();
                    } else if (details.primaryDelta! < -10) {
                      ref.read(gameStateProvider.notifier).moveTilesLeft();
                    }
                  },
                  child: SizedBox(
                    width: _boardSize!.width,
                    height: _boardSize!.height,
                    child: Stack(
                      children: [
                        // Board background
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(
                              GameConstants.cardBorderRadius,
                            ),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.1),
                              width: 2,
                            ),
                          ),
                        ),

                        // Tiles
                        ...gameState.tiles.map((tile) {
                          return AnimatedPositioned(
                            key: ValueKey(tile.id),
                            duration: const Duration(milliseconds: 16),
                            curve: Curves.linear,
                            left: tile.position.dx * scale,
                            top: tile.position.dy * scale,
                            child: GameTileWidget(tile: tile, scale: scale),
                          );
                        }),

                        // Score popups
                        ...scorePopups.map((popup) {
                          return Positioned(
                            left: popup.position.dx * scale,
                            top: popup.position.dy * scale,
                            child: ScorePopupWidget(popup: popup, scale: scale),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

              const Spacer(),
              const SizedBox(height: GameConstants.defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}
