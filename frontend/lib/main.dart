import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const FarmExpenseApp());
}

class FarmExpenseApp extends StatelessWidget {
  const FarmExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Farmer Expense Tracker',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 39, 101, 85),
        ),

        scaffoldBackgroundColor: Colors.white,
      ),

      home: const LoginPage(),
    );
  }
}
