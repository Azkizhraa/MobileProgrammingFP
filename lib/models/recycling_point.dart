import 'package:cloud_firestore/cloud_firestore.dart';

class RecyclingPoint {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String city;
  final String type;
  final List<String> acceptedWasteTypes;
  final bool verified;

  RecyclingPoint({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.type,
    required this.acceptedWasteTypes,
    required this.verified,
  });

  factory RecyclingPoint.fromFirestore(String id, Map<String, dynamic> data) {
    final GeoPoint geoPoint = data['geopoint'] as GeoPoint;

    return RecyclingPoint(
      id: id,
      name: data['name'] ?? '',
      address: data['address'] ?? data['adress'] ?? '',
      latitude: geoPoint.latitude,
      longitude: geoPoint.longitude,
      city: data['city'] ?? '',
      type: data['type'] ?? '',
      acceptedWasteTypes: List<String>.from(data['acceptedWasteTypes'] ?? []),
      verified: data['verified'] ?? false,
    );
  }
}