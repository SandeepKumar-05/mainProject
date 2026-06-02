import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './presentation/providers/robot_provider.dart';
import './presentation/screens/home_screen.dart';
import './theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => RobotProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coconut Bot Control',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
