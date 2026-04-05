import 'package:flutter/material.dart';

class CountryBadge extends StatelessWidget {
  final String flag;
  final String countryName;
  final bool serviceIncluded;
  final VoidCallback onTap;

  const CountryBadge({
    super.key,
    required this.flag,
    required this.countryName,
    required this.serviceIncluded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  countryName,
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
                ),
                if (serviceIncluded)
                  Text(
                    'Service usually included',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ],
        ),
      ),
    );
  }
}
