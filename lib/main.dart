import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const SegundaManoApp());
}

class SegundaManoApp extends StatelessWidget {
  const SegundaManoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SegundaMano',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1F6F5C),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
