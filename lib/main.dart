import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() {
  runApp(const NoorAIApp());
}

class NoorAIApp extends StatelessWidget {
  const NoorAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NOOR AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
    );
  }
}

