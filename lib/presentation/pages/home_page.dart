import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/notification_service.dart';
import '../providers/weather_provider.dart';
import '../providers/eco_stats_provider.dart';
import '../widgets/air_quality_banner.dart';
import '../widgets/eco_stats_dashboard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Initialize providers on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final airQualityProvider = Provider.of<AirQualityProvider>(
        context,
        listen: false,
      );
      final ecoStatsProvider = Provider.of<EcoStatsProvider>(
        context,
        listen: false,
      );

      airQualityProvider.fetchAirQuality();
      if (!ecoStatsProvider.isInitialized) {
        ecoStatsProvider.init();
      }
      NotificationService.requestNotificationPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<AirQualityProvider>(
            context,
            listen: false,
          ).refreshAirQuality();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Sortify Indonesia',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start sorting and recycling smarter.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),
                Consumer<AirQualityProvider>(
                  builder: (context, airQualityProvider, _) {
                    return AirQualityBanner(
                      city:
                          airQualityProvider.airQualityData?.city ??
                          'Loading...',
                      aqi: airQualityProvider.airQualityData?.aqi ?? 0,
                      aqiLevel:
                          airQualityProvider.airQualityData?.aqiLevel ??
                          'Loading',
                      pollutant:
                          airQualityProvider.airQualityData?.pollutant ?? 'N/A',
                      recommendation: airQualityProvider
                          .getAirQualityRecommendation(),
                      backgroundColor: airQualityProvider.getBannerColor(),
                      isLoading: airQualityProvider.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Consumer<EcoStatsProvider>(
                  builder: (context, ecoStatsProvider, _) {
                    return EcoStatsDashboard(
                      dayStreak: ecoStatsProvider.dayStreak,
                      totalItemsLogged: ecoStatsProvider.totalItemsLogged,
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
