import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const UrbanNestApp());
}

class UrbanNestApp extends StatelessWidget {
  const UrbanNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UrbanNest',
      theme: ThemeData(useMaterial3: true),
      home: const LoginScreen(),
    );
  }
}
