import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/purchase_provider.dart';

class SettingsScreen extends ConsumerWidget {
  final VoidCallback onUpgradeTap;

  const SettingsScreen({super.key, required this.onUpgradeTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    final isPro = ref.watch(proStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Pro status card
          if (!isPro)
            Card(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: InkWell(
                onTap: onUpgradeTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.star,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upgrade to Pro',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Remove ads & unlock trip history export',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${AppConstants.proPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.verified, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Pro Member',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Appearance section
          Text('Appearance', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _ThemeTile(
                  title: 'Dark',
                  icon: Icons.dark_mode,
                  isSelected: themeMode == AppThemeMode.dark,
                  onTap: () =>
                      ref.read(themeProvider.notifier).setTheme(AppThemeMode.dark),
                  theme: theme,
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                _ThemeTile(
                  title: 'Light',
                  icon: Icons.light_mode,
                  isSelected: themeMode == AppThemeMode.light,
                  onTap: () => ref
                      .read(themeProvider.notifier)
                      .setTheme(AppThemeMode.light),
                  theme: theme,
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                _ThemeTile(
                  title: 'System',
                  icon: Icons.settings_brightness,
                  isSelected: themeMode == AppThemeMode.system,
                  onTap: () => ref
                      .read(themeProvider.notifier)
                      .setTheme(AppThemeMode.system),
                  theme: theme,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About section
          Text('About', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Version'),
                  trailing: Text(
                    AppConstants.appVersion,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Restore Purchases'),
                  onTap: () {
                    ref.read(purchaseProvider.notifier).restorePurchases();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Restoring purchases...')),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                ListTile(
                  leading: const Icon(Icons.star_outline),
                  title: const Text('Rate This App'),
                  onTap: () {
                    // TODO: Implement app store rating link
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ThemeTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon),
      title: Text(title),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
    );
  }
}
