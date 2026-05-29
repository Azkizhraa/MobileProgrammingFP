import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/waste_categories.dart';
import '../../models/waste_item_model.dart';
import '../providers/waste_item_provider.dart';
import '../widgets/waste_item_card.dart';
import 'add_edit_waste_item_page.dart';

class WasteItemsPage extends StatefulWidget {
  const WasteItemsPage({Key? key}) : super(key: key);

  @override
  State<WasteItemsPage> createState() => _WasteItemsPageState();
}

class _WasteItemsPageState extends State<WasteItemsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waste Items'),
        elevation: 0,
      ),
      body: Consumer<WasteItemProvider>(
        builder: (context, provider, child) {
          return StreamBuilder<List<WasteItem>>(
            stream: provider.wasteItemsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Error loading waste items',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final items = snapshot.data ?? [];

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No waste items yet',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first waste item to get started',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return WasteItemCard(
                    item: item,
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditWasteItemPage(
                            existingItem: item,
                            isEditing: true,
                          ),
                        ),
                      );
                    },
                    onDelete: () {
                      _showDeleteConfirmation(context, item, provider);
                    },
                    onTap: () {
                      _showItemDetails(context, item);
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditWasteItemPage(
                isEditing: false,
              ),
            ),
          );
        },
        tooltip: 'Add Waste Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WasteItem item,
    WasteItemProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text(
          'Are you sure you want to delete "${item.itemName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (item.id != null) {
                final success = await provider.deleteWasteItem(item.id!);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.errorMessage ?? 'Failed to delete item',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(BuildContext context, WasteItem item) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Details
              Text(
                item.itemName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.category,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${item.amount} ${item.unitType == UnitType.kilogram ? 'kg' : 'unit'}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Notes:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.notes,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
