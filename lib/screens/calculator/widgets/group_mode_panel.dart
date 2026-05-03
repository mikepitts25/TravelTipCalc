import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/constants.dart';
import '../../../providers/group_calculator_provider.dart' show GroupCalculatorState, GroupPerson, groupCalculatorProvider;
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
                    children: AppConstants.quickTipPresets.map((p) {
                      final isSelected =
                          (p - state.tipPercent).abs() < 0.5;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => notifier.setTipPercent(p),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                      .withValues(alpha: 0.2)
                                  : theme.cardColor,
                              borderRadius: BorderRadius.circular(10),
                              border: isSelected
                                  ? Border.all(
                                      color: theme.colorScheme.primary)
                                  : null,
                            ),
                            child: Text(
                              '${p.toInt()}%',
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
            canDelete: state.persons.length > 1,
            onNameChanged: (name) =>
                notifier.updatePersonName(person.id, name),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Grand total card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _GroupTotalsCard(state: state),
        ),
      ],
    );
  }
}

class _PersonRow extends StatefulWidget {
  final GroupPerson person;
  final double tipPercent;
  final String currencySymbol;
  final bool canDelete;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<double> onBillChanged;
  final VoidCallback onDelete;

  const _PersonRow({
    super.key,
    required this.person,
    required this.tipPercent,
    required this.currencySymbol,
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
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.4),
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
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _billController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
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
                  if (hasBill) ...[
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
                      ],
                    ),
                  ],
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

  const _GroupTotalsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sym = state.currencySymbol;

    return Card(
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _TotalsRow(
              label: 'Combined Bill',
              value: CurrencyFormatter.formatCompact(state.totalBill, sym),
              theme: theme,
            ),
            const SizedBox(height: 6),
            _TotalsRow(
              label:
                  'Total Tips (${CurrencyFormatter.formatPercent(state.tipPercent)})',
              value: CurrencyFormatter.formatCompact(state.totalTip, sym),
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

class _TotalsRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final Color? valueColor;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const _TotalsRow({
    required this.label,
    required this.value,
    required this.theme,
    this.valueColor,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle ?? theme.textTheme.bodyMedium),
        Text(
          value,
          style: valueStyle ??
              theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
        ),
      ],
    );
  }
}
