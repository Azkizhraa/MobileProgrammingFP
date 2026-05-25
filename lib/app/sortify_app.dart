import 'package:flutter/material.dart';
import '../presentation/navigation/main_navigation_page.dart';

class SortifyApp extends StatelessWidget {
  const SortifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sortify Indonesia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E6B4E),
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationPage(),
    );
  }
}