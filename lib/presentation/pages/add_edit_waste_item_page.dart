import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/waste_categories.dart';
import '../../models/waste_item_model.dart';
import '../providers/eco_stats_provider.dart';
import '../providers/waste_item_provider.dart';

class AddEditWasteItemPage extends StatefulWidget {
  final WasteItem? existingItem;
  final bool isEditing;

  const AddEditWasteItemPage({
    super.key,
    this.existingItem,
    this.isEditing = false,
  });

  @override
  State<AddEditWasteItemPage> createState() => _AddEditWasteItemPageState();
}

class _AddEditWasteItemPageState extends State<AddEditWasteItemPage> {
  late TextEditingController _itemNameController;
  late TextEditingController _pointsController;
  late TextEditingController _instructionsController;

  String _selectedCategory = WasteCategories.categories.first;
  UnitType _selectedUnit = UnitType.kilogram;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _itemNameController = TextEditingController(
      text: widget.existingItem?.itemName ?? '',
    );
    _pointsController = TextEditingController(
      text: widget.existingItem?.amount.toString() ?? '',
    );
    _instructionsController = TextEditingController(
      text: widget.existingItem?.notes ?? '',
    );

    if (widget.existingItem != null) {
      _selectedCategory = widget.existingItem!.category;
      _selectedUnit = widget.existingItem!.unitType;
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _pointsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(BuildContext context) async {
    // Validation
    if (_itemNameController.text.isEmpty) {
      _showErrorSnackBar('Please enter an item name');
      return;
    }

    if (_itemNameController.text.length > 50) {
      _showErrorSnackBar('Item name must be 50 characters or less');
      return;
    }

    if (_pointsController.text.isEmpty) {
      _showErrorSnackBar('Please enter amount');
      return;
    }

    if (_instructionsController.text.isEmpty) {
      _showErrorSnackBar('Please enter notes');
      return;
    }

    try {
      final amount = num.parse(_pointsController.text);
      if (amount <= 0) {
        _showErrorSnackBar('Amount must be greater than 0');
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      final wasteItem = WasteItem(
        id: widget.existingItem?.id,
        itemName: _itemNameController.text,
        category: _selectedCategory,
        amount: amount,
        unitType: _selectedUnit,
        notes: _instructionsController.text,
        createdAt: widget.existingItem?.createdAt,
      );

      final provider = context.read<WasteItemProvider>();
      final ecoStatsProvider = context.read<EcoStatsProvider>();
      bool success;

      if (widget.isEditing && widget.existingItem != null) {
        success = await provider.updateWasteItem(
          widget.existingItem!.id!,
          wasteItem,
        );
      } else {
        success = await provider.createWasteItem(wasteItem);
      }

      if (success && !widget.isEditing) {
        if (!ecoStatsProvider.isInitialized) {
          await ecoStatsProvider.init();
        }
        await ecoStatsProvider.incrementItemsLogged();
      }

      if (!context.mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Waste item updated successfully'
                  : 'Waste item created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        final errorMsg = provider.errorMessage ?? 'Operation failed';
        _showErrorSnackBar(errorMsg);
      }
    } on FormatException {
      if (!context.mounted) return;
      _showErrorSnackBar('Please enter a valid number for amount');
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Waste Item' : 'Add New Waste Item',
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Name
              Text(
                'Item Name',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _itemNameController,
                maxLength: 50,
                decoration: InputDecoration(
                  hintText: 'e.g., Plastic Water Bottle',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: _itemNameController.text.isNotEmpty
                      ? Icon(Icons.check_circle, color: Colors.green[600])
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Waste Category
              Text(
                'Waste Category',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: WasteCategories.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Text(WasteCategories.getEmoji(category)),
                        const SizedBox(width: 8),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Amount and Unit Type
              Text(
                'Amount',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _pointsController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g., 2.5',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<UnitType>(
                      initialValue: _selectedUnit,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: UnitType.values.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(
                            unit == UnitType.kilogram ? 'kg' : 'unit',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedUnit = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes
              Text(
                'Notes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _instructionsController,
                maxLines: 5,
                minLines: 3,
                maxLength: 500,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submitForm(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.primaryColor,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          widget.isEditing ? 'Update Item' : 'Add Item',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
