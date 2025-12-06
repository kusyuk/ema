import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/di/injection_container.dart' as di;
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.init();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: AppConstants.defaultFontSize),
          bodyMedium: TextStyle(fontSize: AppConstants.defaultFontSize),
          bodySmall: TextStyle(fontSize: AppConstants.defaultFontSize),
        ),
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'EMA - Elderly Medical Appointment',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
