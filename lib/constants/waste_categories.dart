class WasteCategories {
  static const List<String> categories = [
    'Plastic',
    'Paper/Cardboard',
    'Glass',
    'Metal',
    'E-Waste',
    'Hazardous (B3)',
  ];

  static const Map<String, String> categoryEmojis = {
    'Plastic': '🟡',
    'Paper/Cardboard': '📦',
    'Glass': '🟢',
    'Metal': '⚪',
    'E-Waste': '🔌',
    'Hazardous (B3)': '⚠️',
  };

  static String getEmoji(String category) {
    return categoryEmojis[category] ?? '♻️';
  }
}

enum UnitType { kilogram, unit }

extension UnitTypeExtension on UnitType {
  String get label {
    switch (this) {
      case UnitType.kilogram:
        return 'Per Kilogram (kg)';
      case UnitType.unit:
        return 'Per Unit';
    }
  }

  String get shortLabel {
    switch (this) {
      case UnitType.kilogram:
        return 'kg';
      case UnitType.unit:
        return 'unit';
    }
  }
}
