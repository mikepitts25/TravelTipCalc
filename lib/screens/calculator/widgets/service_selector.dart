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

  // Show only the most common service types in the compact selector
  static const _primaryServices = [
    ServiceType.restaurant,
    ServiceType.taxi,
    ServiceType.bar,
    ServiceType.barber,
    ServiceType.delivery,
    ServiceType.tourGuide,
    ServiceType.spa,
    ServiceType.hotelBellhop,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _primaryServices.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final service = _primaryServices[index];
          final isSelected = service == selected;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(service);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.2)
                    : theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(service.icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    service.displayName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
