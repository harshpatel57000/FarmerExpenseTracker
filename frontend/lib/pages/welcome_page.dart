
import 'dart:async';

import 'package:flutter/material.dart';

import 'Login_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  Timer? _welcomeTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // Automatically open the login page after 5 seconds.
    _welcomeTimer = Timer(const Duration(seconds: 5), () {
      _openLoginPage();
    });
  }

  void _openLoginPage() {
    // Prevent the timer and button from navigating twice.
    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;
    _welcomeTimer?.cancel();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  @override
  void dispose() {
    // Cancel the timer if this page is removed.
    _welcomeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Welcome background image.
          Image.asset(
            'assets/images/welcome_page_image.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFE8F3E8),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Welcome image could not load.\n\n$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              );
            },
          ),

          // Dark gradient for button visibility.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.10),
                  Colors.black.withValues(alpha: 0.60),
                ],
                stops: const [0.35, 0.65, 1.0],
              ),
            ),
          ),

          
          
        ],
      ),
    );
  }
}
