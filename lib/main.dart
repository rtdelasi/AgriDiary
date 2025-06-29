import 'pages/home_page.dart';
import 'pages/permission_request_page.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/permission_provider.dart';
import 'services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserProfileProvider()),
        ChangeNotifierProvider(create: (context) => TaskProvider()),
        ChangeNotifierProvider(create: (context) => PermissionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final permissionService = PermissionService();
    final allGranted = await permissionService.areAllPermissionsGranted();
    
    setState(() {
      _permissionsGranted = allGranted;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'AgriDiary',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.grey[900],
            cardColor: Colors.grey[800],
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[850],
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.grey[850],
              selectedItemColor: Colors.green,
              unselectedItemColor: Colors.grey[400],
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            dialogTheme: DialogTheme(
              backgroundColor: Colors.grey[800],
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              contentTextStyle: const TextStyle(color: Colors.white),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey[700],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              labelStyle: const TextStyle(color: Colors.grey),
              hintStyle: const TextStyle(color: Colors.grey),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
              titleLarge: TextStyle(color: Colors.white),
              titleMedium: TextStyle(color: Colors.white),
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: _isLoading
              ? _buildLoadingScreen()
              : _permissionsGranted
                  ? const HomePage()
                  : const PermissionRequestPage(),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              'AgriDiary',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 16),
            Text(
              'Initializing...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
