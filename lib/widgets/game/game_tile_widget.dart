import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/tile.dart';

/// Premium tile widget with gradients, shadows, and animations
class GameTileWidget extends StatefulWidget {
  const GameTileWidget({super.key, required this.tile, required this.scale});

  final Tile tile;
  final double scale;

  @override
  State<GameTileWidget> createState() => _GameTileWidgetState();
}

class _GameTileWidgetState extends State<GameTileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.tile.isMerging ? 400 : 250),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.tile.isMerging ? 1.3 : 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.tile.isMerging ? Curves.elasticOut : AppCurves.spawn,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(GameTileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger satisfying animation on merge
    if (widget.tile.isMerging && !oldWidget.tile.isMerging) {
      _controller.duration = const Duration(milliseconds: 400);
      _scaleAnimation = Tween<double>(
        begin: 1.3,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
      _controller.reset();
      _controller.forward();
    }
    // Trigger animation on value change
    else if (oldWidget.tile.value != widget.tile.value) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final tileColor = AppTheme.getTileColor(widget.tile.value, brightness);
    final isDark = brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * widget.scale,
          child: child,
        );
      },
      child: Container(
        width: GameConstants.tileSize,
        height: GameConstants.tileSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GameConstants.tileBorderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [tileColor, tileColor.withOpacity(0.7)],
          ),
          boxShadow: [
            BoxShadow(
              color: tileColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: isDark ? Colors.black38 : Colors.white24,
              blurRadius: 4,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${widget.tile.value}',
            style: TextStyle(
              color: Colors.white,
              fontSize: _getFontSize(widget.tile.value),
              fontWeight: FontWeight.w700,
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getFontSize(int value) {
    if (value >= 1000) return 16.0;
    if (value >= 100) return 20.0;
    return 24.0;
  }
}
