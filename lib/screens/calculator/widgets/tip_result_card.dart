import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../utils/currency_formatter.dart';

class TipResultCard extends StatelessWidget {
  final double tipAmount;
  final double totalAmount;
  final double perPersonTotal;
  final double perPersonTip;
  final double tipPercent;
  final int splitCount;
  final String currencySymbol;

  const TipResultCard({
    super.key,
    required this.tipAmount,
    required this.totalAmount,
    required this.perPersonTotal,
    required this.perPersonTip,
    required this.tipPercent,
    required this.splitCount,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showSplit = splitCount > 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Tip amount
            _ResultRow(
              label: 'Tip',
              value: CurrencyFormatter.formatCompact(tipAmount, currencySymbol),
              subtitle: CurrencyFormatter.formatPercent(tipPercent),
              theme: theme,
              isHighlighted: true,
            ),
            const SizedBox(height: 12),
            Divider(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 12),
            // Total
            _ResultRow(
              label: 'Total',
              value: CurrencyFormatter.formatCompact(
                totalAmount,
                currencySymbol,
              ),
              theme: theme,
            ),
            // Per person (if splitting)
            if (showSplit) ...[
              const SizedBox(height: 16),
              Divider(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 12),
              _ResultRow(
                label: 'Per Person',
                value: CurrencyFormatter.formatCompact(
                  perPersonTotal,
                  currencySymbol,
                ),
                subtitle:
                    '(${CurrencyFormatter.formatCompact(perPersonTip, currencySymbol)} tip)',
                theme: theme,
                isHighlighted: true,
              ),
            ],
          ],
        ),
      ),
    )
        .animate(key: ValueKey('$tipAmount-$splitCount'))
        .fadeIn(duration: 200.ms)
        .scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1, 1),
          duration: 200.ms,
        );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final ThemeData theme;
  final bool isHighlighted;

  const _ResultRow({
    required this.label,
    required this.value,
    this.subtitle,
    required this.theme,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: theme.colorScheme.primary.withValues(alpha: 0.8),
                ),
              ),
          ],
        ),
        Text(
          value,
          style: isHighlighted
              ? theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                )
              : theme.textTheme.titleLarge,
        ),
      ],
    );
  }
}
