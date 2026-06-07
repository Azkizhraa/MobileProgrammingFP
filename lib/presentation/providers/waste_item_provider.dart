import 'package:flutter/material.dart';
import '../../models/waste_item_model.dart';
import '../../services/waste_item_service.dart';

class WasteItemProvider extends ChangeNotifier {
  final WasteItemService _service = WasteItemService();

  final List<WasteItem> _wasteItems = [];
  WasteItem? _selectedItem;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<WasteItem> get wasteItems => _wasteItems;
  WasteItem? get selectedItem => _selectedItem;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Stream getter for real-time updates
  Stream<List<WasteItem>> get wasteItemsStream => _service.getWasteItemsStream();

  /// Create a new waste item
  Future<bool> createWasteItem(WasteItem item) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final id = await _service.createWasteItem(item);
      final success = id != null;

      if (!success) {
        _errorMessage = 'Failed to create waste item';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Update an existing waste item
  Future<bool> updateWasteItem(String id, WasteItem item) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final success = await _service.updateWasteItem(id, item);

      if (!success) {
        _errorMessage = 'Failed to update waste item';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Delete a waste item
  Future<bool> deleteWasteItem(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final success = await _service.deleteWasteItem(id);

      if (!success) {
        _errorMessage = 'Failed to delete waste item';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Get a single waste item by ID
  Future<void> fetchWasteItemById(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _selectedItem = await _service.getWasteItemById(id);

      if (_selectedItem == null) {
        _errorMessage = 'Waste item not found';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Clear selection
  void clearSelection() {
    _selectedItem = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
