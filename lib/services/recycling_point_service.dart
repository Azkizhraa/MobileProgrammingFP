import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/recycling_point.dart';

class RecyclingPointService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<RecyclingPoint>> getSurabayaRecyclingPoints() async {
    final snapshot = await _firestore
        .collection('recycling_points')
        .where('city', isEqualTo: 'Surabaya')
        .get();

    return snapshot.docs.map((doc) {
      return RecyclingPoint.fromFirestore(doc.id, doc.data());
    }).toList();
  }
}