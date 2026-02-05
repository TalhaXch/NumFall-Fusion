import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/game_button.dart';

/// Settings screen with theme and preferences
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final settings = ref.watch(settingsProvider);
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
                      'Settings',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(GameConstants.defaultPadding),
                  children: [
                    // Theme Section
                    _SectionHeader(title: 'APPEARANCE'),
                    const SizedBox(height: 8),
                    _SettingsCard(
                      child: Column(
                        children: [
                          _SettingsTile(
                            title: 'Light Mode',
                            subtitle: 'Use light color scheme',
                            trailing: Radio<ThemeMode>(
                              value: ThemeMode.light,
                              groupValue: themeMode,
                              onChanged: (value) {
                                if (value != null) {
                                  ref
                                      .read(themeModeProvider.notifier)
                                      .setThemeMode(value);
                                }
                              },
                            ),
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            title: 'Dark Mode',
                            subtitle: 'Use dark color scheme',
                            trailing: Radio<ThemeMode>(
                              value: ThemeMode.dark,
                              groupValue: themeMode,
                              onChanged: (value) {
                                if (value != null) {
                                  ref
                                      .read(themeModeProvider.notifier)
                                      .setThemeMode(value);
                                }
                              },
                            ),
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            title: 'System Default',
                            subtitle: 'Follow system theme',
                            trailing: Radio<ThemeMode>(
                              value: ThemeMode.system,
                              groupValue: themeMode,
                              onChanged: (value) {
                                if (value != null) {
                                  ref
                                      .read(themeModeProvider.notifier)
                                      .setThemeMode(value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Audio Section
                    _SectionHeader(title: 'AUDIO'),
                    const SizedBox(height: 8),
                    _SettingsCard(
                      child: Column(
                        children: [
                          _SettingsTile(
                            title: 'Sound Effects',
                            subtitle: 'Play sound effects',
                            trailing: Switch(
                              value: settings.soundEnabled,
                              onChanged: (value) {
                                ref
                                    .read(settingsProvider.notifier)
                                    .setSoundEnabled(value);
                              },
                            ),
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            title: 'Music',
                            subtitle: 'Play background music',
                            trailing: Switch(
                              value: settings.musicEnabled,
                              onChanged: (value) {
                                ref
                                    .read(settingsProvider.notifier)
                                    .setMusicEnabled(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Feedback Section
                    _SectionHeader(title: 'FEEDBACK'),
                    const SizedBox(height: 8),
                    _SettingsCard(
                      child: _SettingsTile(
                        title: 'Haptic Feedback',
                        subtitle: 'Vibrate on interactions',
                        trailing: Switch(
                          value: settings.hapticsEnabled,
                          onChanged: (value) {
                            ref
                                .read(settingsProvider.notifier)
                                .setHapticsEnabled(value);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // About
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'NumFall Fusion',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Version 1.0.0',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(
            context,
          ).textTheme.titleMedium?.color?.withOpacity(0.7),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
