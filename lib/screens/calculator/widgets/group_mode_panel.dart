import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/constants.dart';
import '../../../config/currencies.dart';
import '../../../providers/exchange_rate_provider.dart';
import '../../../providers/group_calculator_provider.dart'
    show GroupCalculatorState, GroupPerson, groupCalculatorProvider;
import '../../../providers/preferences_provider.dart';
import '../../../utils/currency_formatter.dart';

class GroupModePanel extends ConsumerStatefulWidget {
  const GroupModePanel({super.key});

  @override
  ConsumerState<GroupModePanel> createState() => _GroupModePanelState();
}

class _GroupModePanelState extends ConsumerState<GroupModePanel> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(groupCalculatorProvider);
    final notifier = ref.read(groupCalculatorProvider.notifier);
    final exchangeRateState = ref.watch(exchangeRateProvider);
    final homeCurrency = ref.watch(homeCurrencyProvider);

    final rate = exchangeRateState.hasRate && !exchangeRateState.isSameCurrency
        ? exchangeRateState.rate
        : null;
    final homeSym = getCurrencySymbol(homeCurrency);
    final customSelected = _isCustomSelected(state.tipPercent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tip % presets row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('Tip:', style: theme.textTheme.bodyMedium),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _tipChip(
                          label: customSelected
                              ? '${_formatPercent(state.tipPercent)}%'
                              : 'Custom',
                          isSelected: customSelected,
                          onTap: customSelected
                              ? () => notifier.setTipPercent(0)
                              : () => _showCustomTipDialog(context),
                          theme: theme,
                        ),
                      ),
                      ...AppConstants.quickTipPresets.map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _tipChip(
                            label: '${p.toInt()}%',
                            isSelected: _matchesPercent(p, state.tipPercent),
                            onTap: () => notifier.toggleTipPercent(p),
                            theme: theme,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Person list
        ...state.persons.map(
          (person) => _PersonRow(
            key: Key(person.id),
            person: person,
            tipPercent: state.tipPercent,
            currencySymbol: state.currencySymbol,
            exchangeRate: rate,
            homeCurrencySymbol: homeSym,
            canDelete: state.persons.length > 1,
            onNameChanged: (name) => notifier.updatePersonName(person.id, name),
            onBillChanged: (amount) =>
                notifier.updatePersonBill(person.id, amount),
            onDelete: () => notifier.removePerson(person.id),
          ),
        ),

        // Add person button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextButton.icon(
            onPressed: () => notifier.addPerson(),
            icon: const Icon(Icons.person_add_outlined, size: 18),
            label: const Text('Add Person'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Grand total card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _GroupTotalsCard(
            state: state,
            exchangeRate: rate,
            homeCurrencySymbol: homeSym,
            homeCurrencyCode: homeCurrency,
            localCurrencyCode:
                state.countryId.isNotEmpty ? state.currencySymbol : null,
            isRefreshing: exchangeRateState.isLoading,
            onRefresh: () => ref.read(exchangeRateProvider.notifier).refresh(),
          ),
        ),
      ],
    );
  }

  bool _isCustomSelected(double percent) {
    return percent > 0 &&
        !AppConstants.quickTipPresets.any((p) => _matchesPercent(p, percent));
  }

  Future<void> _showCustomTipDialog(BuildContext context) async {
    final state = ref.read(groupCalculatorProvider);
    final initialText =
        state.tipPercent > 0 ? _formatPercent(state.tipPercent) : '';
    final percent = await showDialog<double>(
      context: context,
      builder: (context) => _CustomTipDialog(initialText: initialText),
    );

    if (percent == null) return;
    ref.read(groupCalculatorProvider.notifier).setTipPercent(percent);
  }

  Widget _tipChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border:
              isSelected ? Border.all(color: theme.colorScheme.primary) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? theme.colorScheme.primary : null,
          ),
        ),
      ),
    );
  }

  static double? _parsePercent(String value) {
    final percent = double.tryParse(value.trim());
    if (percent == null || percent < 0) return null;
    return percent;
  }

  static bool _matchesPercent(double a, double b) => (a - b).abs() < 0.001;

  static String _formatPercent(double percent) {
    return percent == percent.roundToDouble()
        ? percent.toInt().toString()
        : percent.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

class _PersonRow extends StatefulWidget {
  final GroupPerson person;
  final double tipPercent;
  final String currencySymbol;
  final double? exchangeRate;
  final String? homeCurrencySymbol;
  final bool canDelete;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<double> onBillChanged;
  final VoidCallback onDelete;

  const _PersonRow({
    super.key,
    required this.person,
    required this.tipPercent,
    required this.currencySymbol,
    this.exchangeRate,
    this.homeCurrencySymbol,
    required this.canDelete,
    required this.onNameChanged,
    required this.onBillChanged,
    required this.onDelete,
  });

  @override
  State<_PersonRow> createState() => _PersonRowState();
}

class _PersonRowState extends State<_PersonRow> {
  late final TextEditingController _nameController;
  late final TextEditingController _billController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.person.name);
    _billController = TextEditingController(
      text: widget.person.billAmount > 0
          ? widget.person.billAmount.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _billController.dispose();
    super.dispose();
  }

  String? _convert(double amount) {
    if (widget.exchangeRate == null || widget.homeCurrencySymbol == null) {
      return null;
    }
    final converted = amount * widget.exchangeRate!;
    return '≈ ${widget.homeCurrencySymbol}${converted.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tip = widget.person.tipAmount(widget.tipPercent);
    final total = widget.person.totalAmount(widget.tipPercent);
    final hasBill = widget.person.billAmount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Name',
                      ),
                      onChanged: widget.onNameChanged,
                    ),
                  ),
                  if (widget.canDelete)
                    GestureDetector(
                      onTap: widget.onDelete,
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    widget.currencySymbol,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _billController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: '0.00',
                        hintStyle: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.25),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onChanged: (v) {
                        final amount = double.tryParse(v) ?? 0;
                        widget.onBillChanged(amount);
                      },
                    ),
                  ),
                  if (hasBill)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+ ${CurrencyFormatter.formatCompact(tip, widget.currencySymbol)} tip',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          '= ${CurrencyFormatter.formatCompact(total, widget.currencySymbol)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_convert(total) != null)
                          Text(
                            _convert(total)!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupTotalsCard extends StatelessWidget {
  final GroupCalculatorState state;
  final double? exchangeRate;
  final String? homeCurrencySymbol;
  final String? homeCurrencyCode;
  final String? localCurrencyCode;
  final bool isRefreshing;
  final VoidCallback? onRefresh;

  const _GroupTotalsCard({
    required this.state,
    this.exchangeRate,
    this.homeCurrencySymbol,
    this.homeCurrencyCode,
    this.localCurrencyCode,
    this.isRefreshing = false,
    this.onRefresh,
  });

  String? _convert(double amount) {
    if (exchangeRate == null || homeCurrencySymbol == null) return null;
    final converted = amount * exchangeRate!;
    return '≈ $homeCurrencySymbol${converted.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sym = state.currencySymbol;
    final showConversion = exchangeRate != null && homeCurrencySymbol != null;

    return Card(
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Exchange rate badge
            if (showConversion && homeCurrencyCode != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 12, right: 4, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.currency_exchange,
                          size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${exchangeRate! < 1 ? exchangeRate!.toStringAsFixed(4) : exchangeRate!.toStringAsFixed(2)} $homeCurrencyCode per unit',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: isRefreshing
                            ? Padding(
                                padding: const EdgeInsets.all(6),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.refresh,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed: onRefresh,
                                tooltip: 'Refresh rate',
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            _TotalsRow(
              label: 'Combined Bill',
              value: CurrencyFormatter.formatCompact(state.totalBill, sym),
              converted: _convert(state.totalBill),
              theme: theme,
            ),
            const SizedBox(height: 6),
            _TotalsRow(
              label:
                  'Total Tips (${CurrencyFormatter.formatPercent(state.tipPercent)})',
              value: CurrencyFormatter.formatCompact(state.totalTip, sym),
              converted: _convert(state.totalTip),
              theme: theme,
              valueColor: theme.colorScheme.primary,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            _TotalsRow(
              label: 'Grand Total',
              value: CurrencyFormatter.formatCompact(state.grandTotal, sym),
              converted: _convert(state.grandTotal),
              theme: theme,
              labelStyle: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
              valueStyle: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTipDialog extends StatefulWidget {
  final String initialText;
  const _CustomTipDialog({required this.initialText});

  @override
  State<_CustomTipDialog> createState() => _CustomTipDialogState();
}

class _CustomTipDialogState extends State<_CustomTipDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static double? _parsePercent(String value) {
    final percent = double.tryParse(value.trim());
    if (percent == null || percent < 0) return null;
    return percent;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom tip'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        decoration: const InputDecoration(
          labelText: 'Tip percent',
          suffixText: '%',
        ),
        onSubmitted: (value) =>
            Navigator.of(context).pop(_parsePercent(value)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(_parsePercent(_controller.text)),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _TotalsRow extends StatelessWidget {
  final String label;
  final String value;
  final String? converted;
  final ThemeData theme;
  final Color? valueColor;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const _TotalsRow({
    required this.label,
    required this.value,
    this.converted,
    required this.theme,
    this.valueColor,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: labelStyle ?? theme.textTheme.bodyMedium),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: valueStyle ??
                  theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
            ),
            if (converted != null)
              Text(
                converted!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
