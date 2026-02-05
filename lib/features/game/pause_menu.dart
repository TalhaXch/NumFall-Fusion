import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/common/game_button.dart';

/// Pause menu overlay
class PauseMenu extends StatelessWidget {
  const PauseMenu({super.key, required this.onResume, required this.onQuit});

  final VoidCallback onResume;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(GameConstants.largePadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(GameConstants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PAUSED',
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 32),
            GameButton(
              onPressed: onResume,
              width: 200,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 24),
                  SizedBox(width: 8),
                  Text('RESUME'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GameButton(
              onPressed: onQuit,
              width: 200,
              backgroundColor: Theme.of(context).colorScheme.error,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home, size: 24),
                  SizedBox(width: 8),
                  Text('QUIT'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
