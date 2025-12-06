import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/di/injection_container.dart' as di;
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/root_page.dart';
import 'presentation/pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize dependency injection
    await di.init();
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    final box = di.sl<Box<dynamic>>();
    final showOnboarding = !(box.get('onboarding_seen') as bool? ?? false);

    runApp(MainApp(showOnboarding: showOnboarding));
  } catch (e, stackTrace) {
    // Log error and show error screen
    debugPrint('Error during initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  final bool showOnboarding;

  const MainApp({super.key, required this.showOnboarding});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _box = di.sl<Box<dynamic>>();

  ThemeMode _resolveThemeMode(Box<dynamic> box) {
    final mode = (box.get('theme_mode') as String?) ?? 'system';
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _box.listenable(keys: ['theme_mode']),
      builder: (context, Box<dynamic> box, _) {
        final themeMode = _resolveThemeMode(box);
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            // Allow user accessibility scaling, but never go below 1.0
            final clampedScaler = mediaQuery.textScaler.clamp(
              minScaleFactor: 1.0,
              maxScaleFactor: 1.6,
            );
            return MediaQuery(
              data: mediaQuery.copyWith(textScaler: clampedScaler),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: widget.showOnboarding ? const OnboardingPage() : const RootPage(),
        );
      },
    );
  }
}
