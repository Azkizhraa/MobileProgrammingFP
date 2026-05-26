import 'package:flutter/material.dart';
import 'home_page.dart';

class PickupPage extends StatelessWidget {
  const PickupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageTemplate(
      title: 'Pickup Request',
      subtitle: 'Request waste pickup from a community or bank sampah.',
      icon: Icons.local_shipping,
    );
  }
}