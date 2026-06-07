import 'package:flutter/material.dart';

class SystemSettingsCard extends StatelessWidget {
  final bool smartRemindersEnabled;
  final ValueChanged<bool> onSmartRemindersChanged;

  const SystemSettingsCard({
    super.key,
    required this.smartRemindersEnabled,
    required this.onSmartRemindersChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Smart Air Quality Reminders',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                smartRemindersEnabled ? 'Enabled' : 'Disabled',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: smartRemindersEnabled
                          ? Colors.green
                          : Colors.grey,
                    ),
              ),
            ],
          ),
          Switch(
            value: smartRemindersEnabled,
            onChanged: onSmartRemindersChanged,
            activeThumbColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
