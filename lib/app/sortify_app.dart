import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/navigation/main_navigation_page.dart';
import '../presentation/pages/login_page.dart';
import '../presentation/providers/auth_provider.dart';

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
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoggedIn) {
            return const MainNavigationPage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}