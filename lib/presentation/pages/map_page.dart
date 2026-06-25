import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/recycling_point.dart';
import '../../services/recycling_point_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final RecyclingPointService _service = RecyclingPointService();
  final MapController _mapController = MapController();
  double _currentZoom = 13;

  static const LatLng _surabayaCenter = LatLng(-7.2575, 112.7521);

  LatLng? _userLocation;
  List<RecyclingPoint> _points = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    LatLng location = _surabayaCenter;
    List<RecyclingPoint> points = [];
    String? message;

    try {
      location = await _getUserLocation().timeout(
        const Duration(seconds: 8),
      );
    } catch (e) {
      message = 'Location unavailable. Showing Surabaya area.';
    }

    try {
      points = await _service.getSurabayaRecyclingPoints().timeout(
        const Duration(seconds: 8),
      );

      debugPrint('Loaded recycling points: ${points.length}');

      if (points.isEmpty) {
        message = 'No recycling points found yet.';
      }
    } catch (e, stackTrace) {
      debugPrint('Firestore recycling points error: $e');
      debugPrint('Firestore stack trace: $stackTrace');

      message = 'Could not load recycling points. Showing map only.';
    }

    points.sort((a, b) {
      final distance = const Distance();

      final distanceA = distance.as(
        LengthUnit.Kilometer,
        location,
        LatLng(a.latitude, a.longitude),
      );

      final distanceB = distance.as(
        LengthUnit.Kilometer,
        location,
        LatLng(b.latitude, b.longitude),
      );

      return distanceA.compareTo(distanceB);
    });

    if (!mounted) return;

    setState(() {
      _userLocation = location;
      _points = points;
      _errorMessage = message;
      _isLoading = false;
    });
  }

  Future<LatLng> _getUserLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location service is disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    ).timeout(const Duration(seconds: 8));

    return LatLng(position.latitude, position.longitude);
  }

  String _getDistanceText(RecyclingPoint point) {
    if (_userLocation == null) {
      return 'Distance unavailable';
    }

    final distanceKm = const Distance().as(
      LengthUnit.Kilometer,
      _userLocation!,
      LatLng(point.latitude, point.longitude),
    );

    return '${distanceKm.toStringAsFixed(1)} km away';
  }

  Future<void> _openGoogleMaps(RecyclingPoint point) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
          '&destination=${point.latitude},${point.longitude}'
          '&travelmode=driving',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not open Google Maps');
    }
  }

  void _showPointDetails(RecyclingPoint point) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.recycling,
                    color: Color(0xFF2E6B4E),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      point.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(point.address),
              const SizedBox(height: 8),
              Text(
                _getDistanceText(point),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E6B4E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                point.acceptedWasteTypes.isEmpty
                    ? 'Accepted waste: Not specified'
                    : 'Accepted waste: ${point.acceptedWasteTypes.join(', ')}',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openGoogleMaps(point),
                  icon: const Icon(Icons.directions),
                  label: const Text('Navigate with Google Maps'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E6B4E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    if (_userLocation != null) {
      markers.add(
        Marker(
          point: _userLocation!,
          width: 44,
          height: 44,
          child: const Icon(
            Icons.my_location,
            color: Colors.blue,
            size: 32,
          ),
        ),
      );
    }

    for (final point in _points) {
      markers.add(
        Marker(
          point: LatLng(point.latitude, point.longitude),
          width: 48,
          height: 48,
          child: GestureDetector(
            onTap: () => _showPointDetails(point),
            child: const Icon(
              Icons.location_on,
              color: Color(0xFF2E6B4E),
              size: 40,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final mapCenter = _userLocation ?? _surabayaCenter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_errorMessage != null)
          Container(
            width: double.infinity,
            color: Colors.orange.shade100,
            padding: const EdgeInsets.all(12),
            child: Text(_errorMessage!),
          ),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 28, 24, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.map,
                size: 40,
                color: Color(0xFF2E6B4E),
              ),
              SizedBox(height: 20),
              Text(
                'Recycling Points',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Find nearby bank sampah and recycling locations.',
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : FlutterMap(
                options: MapOptions(
                  initialCenter: mapCenter,
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.finalproject',
                  ),
                  MarkerLayer(
                    markers: _buildMarkers(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}