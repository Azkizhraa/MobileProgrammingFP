import 'package:flutter/material.dart';
import 'home_page.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageTemplate(
      title: 'Sorting Guide',
      subtitle: 'Learn how to sort plastic, paper, battery, and e-waste.',
      icon: Icons.menu_book,
    );
  }
}