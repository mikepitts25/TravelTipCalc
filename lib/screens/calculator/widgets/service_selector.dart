import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/tipping_rule.dart';

class ServiceSelector extends StatelessWidget {
  final ServiceType selected;
  final ValueChanged<ServiceType> onSelected;

  const ServiceSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const _services = [
    ServiceType.restaurant,
    ServiceType.taxi,
    ServiceType.bar,
    ServiceType.barber,
    ServiceType.delivery,
    ServiceType.tourGuide,
    ServiceType.spa,
    ServiceType.hotelBellhop,
    ServiceType.hotelHousekeeping,
    ServiceType.valet,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showServicePicker(context),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              children: [
                Text(selected.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        selected.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showServicePicker(BuildContext context) {
    HapticFeedback.selectionClick();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        final sheetHeight = MediaQuery.sizeOf(context).height * 0.72;

        return SafeArea(
          child: SizedBox(
            height: sheetHeight,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    'Choose service',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _services.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 56,
                    ),
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      return _ServicePickerItem(
                        service: service,
                        isSelected: service == selected,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).pop();
                          onSelected(service);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ServicePickerItem extends StatelessWidget {
  final ServiceType service;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServicePickerItem({
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foregroundColor = isSelected
        ? theme.colorScheme.primary
        : theme.textTheme.bodyMedium?.color;

    return Material(
      color: isSelected
          ? theme.colorScheme.primary.withValues(alpha: 0.16)
          : theme.cardColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.55)
                  : theme.dividerColor.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Text(service.icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  service.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foregroundColor,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
