import 'package:flutter/material.dart';
import '../widgets/page_template.dart';

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