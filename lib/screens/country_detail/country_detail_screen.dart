import 'package:flutter/material.dart';

import '../../data/models/country.dart';
import '../../data/models/tipping_rule.dart';
import '../../data/repositories/tipping_repository.dart';
import '../../utils/currency_formatter.dart';

class CountryDetailScreen extends StatefulWidget {
  final Country country;

  const CountryDetailScreen({super.key, required this.country});

  @override
  State<CountryDetailScreen> createState() => _CountryDetailScreenState();
}

class _CountryDetailScreenState extends State<CountryDetailScreen> {
  final _tippingRepo = TippingRepository();
  List<TippingRule> _rules = [];

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    final rules = await _tippingRepo.getRulesForCountry(widget.country.id);
    setState(() => _rules = rules);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final country = widget.country;

    return Scaffold(
      appBar: AppBar(
        title: Text('${country.flag} ${country.name}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Country header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    country.flag,
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    country.name,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${country.region} | ${country.currencyCode} (${country.currencySymbol})',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (country.serviceIncluded) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Service charge typically included',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Etiquette note
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tipping Etiquette',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    country.etiquetteNote,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tipping rules by service
          Text(
            'Tipping Guide by Service',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ..._rules.map((rule) => _RuleTile(rule: rule, theme: theme)),
        ],
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  final TippingRule rule;
  final ThemeData theme;

  const _RuleTile({required this.rule, required this.theme});

  @override
  Widget build(BuildContext context) {
    final rangeText = rule.minPercent == 0 && rule.maxPercent == 0
        ? 'Not percentage-based'
        : '${CurrencyFormatter.formatPercent(rule.minPercent)} - ${CurrencyFormatter.formatPercent(rule.maxPercent)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rule.serviceType.icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.serviceType.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Suggested: ',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        CurrencyFormatter.formatPercent(rule.suggestedPercent),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($rangeText)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rule.note,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
