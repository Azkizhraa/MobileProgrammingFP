import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'app/sortify_app.dart';
import 'presentation/providers/waste_item_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/eco_stats_provider.dart';
import 'presentation/providers/air_quality_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize notification service
  await NotificationService.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WasteItemProvider()),
        ChangeNotifierProvider(create: (_) => EcoStatsProvider()),
        ChangeNotifierProvider(create: (_) => AirQualityProvider()),
      ],
      child: const SortifyApp(),
    ),
  );
}