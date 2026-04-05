import 'package:flutter/material.dart';

import '../../../data/models/country.dart';

class CountryTile extends StatelessWidget {
  final Country country;
  final VoidCallback onTap;
  final VoidCallback? onInfoTap;

  const CountryTile({
    super.key,
    required this.country,
    required this.onTap,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: Text(
        country.flag,
        style: const TextStyle(fontSize: 28),
      ),
      title: Text(
        country.name,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Row(
        children: [
          Text(
            country.currencyCode,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          if (country.serviceIncluded) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Service included',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.info_outline,
          size: 20,
          color: theme.textTheme.bodyMedium?.color,
        ),
        onPressed: onInfoTap,
      ),
    );
  }
}
