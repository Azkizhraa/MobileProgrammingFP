import 'package:flutter/material.dart';
import 'home_page.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageTemplate(
      title: 'Recycling Points',
      subtitle: 'Find nearby bank sampah and recycling locations.',
      icon: Icons.map,
    );
  }
}