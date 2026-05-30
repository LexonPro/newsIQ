import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';

// Global ValueNotifier to listen to theme changes across screens
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load saved theme preference, defaulting to dark mode
  ThemeMode initialTheme = ThemeMode.dark;
  try {
    final prefs = await SharedPreferences.getInstance();
    final isLight = prefs.getBool("theme_light") ?? false;
    initialTheme = isLight ? ThemeMode.light : ThemeMode.dark;
  } catch (_) {}
  
  themeNotifier.value = initialTheme;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'newsIQ',
          themeMode: currentMode,
          // Premium Light Theme Design
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            primaryColor: Colors.red,
            scaffoldBackgroundColor: const Color(0xFFF7F8FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF7F8FA),
              foregroundColor: Color(0xFF1E293B),
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF1E293B)),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Color(0xFF1E293B)),
              bodyMedium: TextStyle(color: Color(0xFF64748B)),
            ),
            cardTheme: const CardThemeData(
              color: Colors.white,
              elevation: 1,
            ),
            dividerTheme: const DividerThemeData(
              color: Colors.black12,
            ),
          ),
          // Premium Dark Theme Design (Default)
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: Colors.red,
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
            ),
            cardTheme: CardThemeData(
              color: Colors.grey[900],
              elevation: 0,
            ),
            dividerTheme: const DividerThemeData(
              color: Colors.white10,
            ),
          ),
          home: const MainScreen(),
        );
      },
    );
  }
}