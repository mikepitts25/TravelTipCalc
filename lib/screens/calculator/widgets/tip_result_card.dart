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

  // Conversion fields (null = no conversion shown)
  final double? exchangeRate;
  final String? homeCurrencySymbol;
  final String? homeCurrencyCode;
  final String? localCurrencyCode;

  const TipResultCard({
    super.key,
    required this.tipAmount,
    required this.totalAmount,
    required this.perPersonTotal,
    required this.perPersonTip,
    required this.tipPercent,
    required this.splitCount,
    required this.currencySymbol,
    this.exchangeRate,
    this.homeCurrencySymbol,
    this.homeCurrencyCode,
    this.localCurrencyCode,
  });

  bool get _showConversion =>
      exchangeRate != null &&
      homeCurrencySymbol != null &&
      localCurrencyCode != homeCurrencyCode;

  String _converted(double amount) {
    final converted = amount * exchangeRate!;
    return CurrencyFormatter.formatCompact(converted, homeCurrencySymbol!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showSplit = splitCount > 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Exchange rate badge
            if (_showConversion)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.currency_exchange,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '1 $localCurrencyCode = ${exchangeRate!.toStringAsFixed(exchangeRate! < 1 ? 4 : 2)} $homeCurrencyCode',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Tip amount
            _ResultRow(
              label: 'Tip',
              value:
                  CurrencyFormatter.formatCompact(tipAmount, currencySymbol),
              subtitle: CurrencyFormatter.formatPercent(tipPercent),
              convertedValue: _showConversion ? _converted(tipAmount) : null,
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
              convertedValue:
                  _showConversion ? _converted(totalAmount) : null,
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
                convertedValue:
                    _showConversion ? _converted(perPersonTotal) : null,
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
  final String? convertedValue;
  final ThemeData theme;
  final bool isHighlighted;

  const _ResultRow({
    required this.label,
    required this.value,
    this.subtitle,
    this.convertedValue,
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: isHighlighted
                  ? theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    )
                  : theme.textTheme.titleLarge,
            ),
            if (convertedValue != null)
              Text(
                '\u2248 $convertedValue',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
