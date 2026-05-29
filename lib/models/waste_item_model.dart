import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/waste_categories.dart';

class WasteItem {
  final String? id;
  final String itemName;
  final String category;
  final num amount;
  final UnitType unitType;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  WasteItem({
    this.id,
    required this.itemName,
    required this.category,
    required this.amount,
    required this.unitType,
    required this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'category': category,
      'amount': amount,
      'unitType': unitType.name,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Map/Firebase
  factory WasteItem.fromMap(Map<String, dynamic> map, String id) {
    return WasteItem(
      id: id,
      itemName: map['itemName'] ?? '',
      category: map['category'] ?? '',
      amount: map['amount'] ?? 0,
      unitType: _parseUnitType(map['unitType']),
      notes: map['notes'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static UnitType _parseUnitType(dynamic value) {
    if (value is String) {
      return value == 'unit' ? UnitType.unit : UnitType.kilogram;
    }
    return UnitType.kilogram;
  }

  // Copy with for updates
  WasteItem copyWith({
    String? id,
    String? itemName,
    String? category,
    num? amount,
    UnitType? unitType,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WasteItem(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      unitType: unitType ?? this.unitType,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
