import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/game_button.dart';

/// How to Play screen with game instructions
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final gradientColors = AppTheme.getBackgroundGradient(brightness);

    return Scaffold(
      body: GradientBackground(
        colors: gradientColors,
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(GameConstants.defaultPadding),
                child: Row(
                  children: [
                    GameIconButton(
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'How to Play',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(GameConstants.defaultPadding),
                  children: [
                    _InstructionCard(
                      icon: Icons.emoji_events,
                      title: 'Objective',
                      description:
                          'Merge falling numbered tiles to create higher values and score points. The game ends when tiles stack to the top.',
                    ),
                    const SizedBox(height: 16),
                    _InstructionCard(
                      icon: Icons.touch_app,
                      title: 'Controls',
                      description:
                          'Tap on a column to move falling tiles there, or swipe left/right to move tiles one column at a time.',
                    ),
                    const SizedBox(height: 16),
                    _InstructionCard(
                      icon: Icons.apps,
                      title: 'Tiles Fall & Merge',
                      description:
                          'Tiles fall with gravity. When two tiles with the same number collide, they merge into a tile with double the value (2+2=4, 4+4=8, etc.).',
                    ),
                    const SizedBox(height: 16),
                    _InstructionCard(
                      icon: Icons.trending_up,
                      title: 'Scoring',
                      description:
                          'Each merge earns points equal to the new tile value. Chain multiple merges quickly to build combos for bonus multipliers!',
                    ),
                    const SizedBox(height: 16),
                    _InstructionCard(
                      icon: Icons.speed,
                      title: 'Difficulty',
                      description:
                          'As your score increases, tiles spawn faster and the game becomes more challenging. Stay focused!',
                    ),
                    const SizedBox(height: 16),
                    _InstructionCard(
                      icon: Icons.lightbulb_outline,
                      title: 'Strategy Tips',
                      description:
                          '• Plan ahead - think about where tiles will land\n'
                          '• Build combos for higher scores\n'
                          '• Manage board space carefully\n'
                          '• Higher tiles = more points',
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            GameConstants.cardBorderRadius,
                          ),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Can you reach 2048?',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(GameConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(description, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
