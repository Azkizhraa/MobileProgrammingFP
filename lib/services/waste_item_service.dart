import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/waste_item_model.dart';

class WasteItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'waste_items';

  /// Get all waste items as a stream
  Stream<List<WasteItem>> getWasteItemsStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WasteItem.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get waste items filtered by category
  Stream<List<WasteItem>> getWasteItemsByCategory(String category) {
    return _firestore
        .collection(_collectionName)
        .where('category', isEqualTo: category)
        .orderBy('itemName')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WasteItem.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get a single waste item by ID
  Future<WasteItem?> getWasteItemById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        return WasteItem.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching waste item: $e');
      return null;
    }
  }

  /// Create a new waste item
  Future<String?> createWasteItem(WasteItem item) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(item.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating waste item: $e');
      return null;
    }
  }

  /// Update an existing waste item
  Future<bool> updateWasteItem(String id, WasteItem item) async {
    try {
      final updatedItem = item.copyWith(
        updatedAt: DateTime.now(),
      );
      await _firestore
          .collection(_collectionName)
          .doc(id)
          .update(updatedItem.toMap());
      return true;
    } catch (e) {
      print('Error updating waste item: $e');
      return false;
    }
  }

  /// Delete a waste item
  Future<bool> deleteWasteItem(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting waste item: $e');
      return false;
    }
  }

  /// Search waste items by name
  Stream<List<WasteItem>> searchWasteItems(String query) {
    return _firestore
        .collection(_collectionName)
        .orderBy('itemName')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WasteItem.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get total count of waste items
  Future<int> getWasteItemsCount() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting waste items count: $e');
      return 0;
    }
  }
}
