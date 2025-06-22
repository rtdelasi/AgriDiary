import 'package:agridiary/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agridiary/providers/theme_provider.dart';
import 'package:agridiary/providers/user_profile_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Agric Plant',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: Colors.grey[100],
            textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme).apply(bodyColor: Colors.black87),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: const Color(0xFF121212),
            textTheme: GoogleFonts.latoTextTheme(Theme.of(context).primaryTextTheme).apply(bodyColor: Colors.white70),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            cardColor: const Color(0xFF1E1E1E),
            dividerColor: Colors.white24,
            iconTheme: const IconThemeData(color: Colors.white70),
          ),
          home: const HomePage(),
        );
      },
    );
  }
}
