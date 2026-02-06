import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/services/sound_manager.dart';
import 'providers/app_providers.dart';
import 'features/splash/splash_screen.dart';
import 'data/repositories/game_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences before app starts
  final prefs = await SharedPreferences.getInstance();
  final repository = GameRepository(prefs);

  // Initialize sound system
  await SoundManager.instance.initialize();

  // Configure sound system based on user preferences
  SoundManager.instance.setSoundEnabled(repository.isSoundEnabled());
  SoundManager.instance.setMusicEnabled(repository.isMusicEnabled());

  // Set preferred orientations (portrait only for mobile game)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        gameRepositoryProvider.overrideWithValue(repository),
      ],
      child: const NumFallFusionApp(),
    ),
  );
}

/// Main application widget
class NumFallFusionApp extends ConsumerWidget {
  const NumFallFusionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'NumFall Fusion',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
