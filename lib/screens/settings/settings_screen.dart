import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../config/currencies.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/purchase_provider.dart';

class SettingsScreen extends ConsumerWidget {
  final VoidCallback onUpgradeTap;

  const SettingsScreen({super.key, required this.onUpgradeTap});

  void _showCurrencyPicker(
    BuildContext context,
    WidgetRef ref,
    String currentCurrency,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CurrencyPickerSheet(
        currentCurrency: currentCurrency,
        onSelected: (code) {
          ref.read(homeCurrencyProvider.notifier).setCurrency(code);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    final isPro = ref.watch(proStatusProvider);
    final homeCurrency = ref.watch(homeCurrencyProvider);
    final currencyInfo = getCurrencyInfo(homeCurrency);

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

          // Home currency section
          Text('Home Currency', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text('Display Currency'),
              subtitle: Text(
                currencyInfo != null
                    ? '${currencyInfo.symbol} ${currencyInfo.name}'
                    : homeCurrency,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showCurrencyPicker(context, ref, homeCurrency),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              'Tip amounts will also show in this currency',
              style: theme.textTheme.bodySmall,
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

class _CurrencyPickerSheet extends StatefulWidget {
  final String currentCurrency;
  final ValueChanged<String> onSelected;

  const _CurrencyPickerSheet({
    required this.currentCurrency,
    required this.onSelected,
  });

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  String _query = '';

  List<CurrencyInfo> get _filtered {
    if (_query.isEmpty) return supportedCurrencies;
    final q = _query.toLowerCase();
    return supportedCurrencies.where((c) {
      return c.code.toLowerCase().contains(q) ||
          c.name.toLowerCase().contains(q) ||
          c.symbol.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Home Currency',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search currencies...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final currency = _filtered[index];
                  final isSelected = currency.code == widget.currentCurrency;
                  return ListTile(
                    leading: SizedBox(
                      width: 40,
                      child: Text(
                        currency.symbol,
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    title: Text(currency.name),
                    subtitle: Text(currency.code),
                    trailing: isSelected
                        ? Icon(Icons.check_circle,
                            color: theme.colorScheme.primary)
                        : null,
                    onTap: () => widget.onSelected(currency.code),
                  );
                },
              ),
            ),
          ],
        );
      },
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
