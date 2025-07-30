import 'package:finger_on_the_app/screens/simulator_screen.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const FingerOnTheApp());
}

class FingerOnTheApp extends StatelessWidget {
  const FingerOnTheApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finger on the App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Regular',
      ),
      home: SplashScreen(), // SplashScreen will navigate to LoginScreen
      debugShowCheckedModeBanner: false,
    );
  }
}
