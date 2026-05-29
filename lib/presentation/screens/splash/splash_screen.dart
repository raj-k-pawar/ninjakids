import 'package:flutter/material.dart';

// Splash Screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text('🥷', style: TextStyle(fontSize: 64))));
}
