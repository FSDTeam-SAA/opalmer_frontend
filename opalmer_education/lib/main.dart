import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Splash_Screen/splash_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // transparent status bar
      statusBarIconBrightness: Brightness.light, 
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Class Pulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter', // Default to standard if available.
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF871DAD)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
