import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/constants.dart';

class SplitControl extends StatelessWidget {
  final int splitCount;
  final ValueChanged<int> onChanged;

  const SplitControl({
    super.key,
    required this.splitCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 20,
                  color: theme.textTheme.bodyMedium?.color,
                ),
                const SizedBox(width: 10),
                Text('Split', style: theme.textTheme.titleMedium),
              ],
            ),
            Row(
              children: [
                _CircleButton(
                  icon: Icons.remove,
                  onTap: splitCount > AppConstants.minSplitCount
                      ? () {
                          HapticFeedback.lightImpact();
                          onChanged(splitCount - 1);
                        }
                      : null,
                  theme: theme,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '$splitCount',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                _CircleButton(
                  icon: Icons.add,
                  onTap: splitCount < AppConstants.maxSplitCount
                      ? () {
                          HapticFeedback.lightImpact();
                          onChanged(splitCount + 1);
                        }
                      : null,
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final ThemeData theme;

  const _CircleButton({
    required this.icon,
    this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isEnabled
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : theme.colorScheme.onSurface.withValues(alpha: 0.05),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
