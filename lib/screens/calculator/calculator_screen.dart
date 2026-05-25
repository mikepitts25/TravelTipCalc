import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../config/currencies.dart';
import '../../data/models/tipping_rule.dart';
import '../../data/repositories/tipping_repository.dart';
import '../../providers/exchange_rate_provider.dart';
import '../../providers/group_calculator_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/tip_calculator_provider.dart';
import '../../utils/rounding.dart';
import 'widgets/bill_input.dart';
import 'widgets/country_badge.dart';
import 'widgets/group_mode_panel.dart';
import 'widgets/service_selector.dart';
import 'widgets/split_control.dart';
import 'widgets/tip_result_card.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  final VoidCallback onCountryTap;

  const CalculatorScreen({super.key, required this.onCountryTap});

  @override
  ConsumerState<CalculatorScreen> createState() => CalculatorScreenState();
}

// ignore: library_private_types_in_public_api
class CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  final _tippingRepo = TippingRepository();
  final _scrollController = ScrollController();
  String _countryFlag = '\u{1F30D}';
  String _countryName = 'Select Country';
  String _currencyCode = 'USD';
  bool _serviceIncluded = false;
  TippingRule? _currentRule;
  bool _isGroupMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectOrLoadCountry();
      ref.listenManual(homeCurrencyProvider, (previous, next) {
        if (previous != next && _currencyCode.isNotEmpty) {
          ref
              .read(exchangeRateProvider.notifier)
              .fetchRate(_currencyCode, next);
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _detectOrLoadCountry() async {
    try {
      final prefs = ref.read(preferencesRepositoryProvider);
      final lastCountry = prefs?.lastCountry;

      if (lastCountry != null) {
        await _loadCountry(lastCountry);
      } else {
        try {
          await ref.read(locationProvider.notifier).detectLocation();
          final locationState = ref.read(locationProvider);
          if (locationState.countryCode != null) {
            await _loadCountry(locationState.countryCode!);
            return;
          }
        } catch (_) {}
        await _loadCountry(AppConstants.defaultCountry);
      }
    } catch (_) {
      await _loadCountry(AppConstants.defaultCountry);
    }
  }

  Future<void> _loadCountry(String countryId) async {
    final country = await _tippingRepo.getCountryById(countryId);
    if (country == null) return;

    final calcNotifier = ref.read(tipCalculatorProvider.notifier);
    final calcState = ref.read(tipCalculatorProvider);

    calcNotifier.setCountry(country.id, country.currencySymbol);
    ref.read(groupCalculatorProvider.notifier).setCountryAndCurrency(
          country.id,
          country.currencySymbol,
        );

    if (!mounted) return;
    setState(() {
      _countryFlag = country.flag;
      _countryName = country.name;
      _currencyCode = country.currencyCode;
      _serviceIncluded = country.serviceIncluded;
    });

    // Fetch exchange rate from local currency to user's home currency
    final homeCurrency = ref.read(homeCurrencyProvider);
    ref
        .read(exchangeRateProvider.notifier)
        .fetchRate(country.currencyCode, homeCurrency);

    await _loadRule(country.id, calcState.serviceType);
    ref.read(preferencesRepositoryProvider)?.setLastCountry(country.id);
  }

  Future<void> _loadRule(String countryId, ServiceType serviceType) async {
    final rule = await _tippingRepo.getRule(countryId, serviceType);
    if (rule != null && mounted) {
      setState(() => _currentRule = rule);

      final prefs = ref.read(preferencesRepositoryProvider);
      final savedTip = prefs?.getLastTip(countryId, serviceType.dbValue);
      final tipPct = savedTip ?? rule.suggestedPercent;

      ref.read(tipCalculatorProvider.notifier).setTipPercent(tipPct);
      ref.read(groupCalculatorProvider.notifier).setTipPercent(tipPct);
    }
  }

  void _onServiceChanged(ServiceType type) {
    final calcNotifier = ref.read(tipCalculatorProvider.notifier);
    final calcState = ref.read(tipCalculatorProvider);
    calcNotifier.setServiceType(type);
    _loadRule(calcState.countryId, type);
  }

  void loadCountry(String countryId) {
    _loadCountry(countryId);
  }

  @override
  Widget build(BuildContext context) {
    final calcState = ref.watch(tipCalculatorProvider);
    final calcNotifier = ref.read(tipCalculatorProvider.notifier);
    final exchangeRate = ref.watch(exchangeRateProvider);
    final homeCurrency = ref.watch(homeCurrencyProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          // Header: country badge + mode toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: CountryBadge(
                    flag: _countryFlag,
                    countryName: _countryName,
                    serviceIncluded: _serviceIncluded,
                    onTap: widget.onCountryTap,
                  ),
                ),
                const SizedBox(width: 8),
                _ModeToggle(
                  isGroupMode: _isGroupMode,
                  onToggle: (v) => setState(() => _isGroupMode = v),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: ServiceSelector(
              selected: calcState.serviceType,
              onSelected: _onServiceChanged,
            ),
          ),

          if (_currentRule != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
              child: Text(
                _currentRule!.note,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                primary: false,
                child: _isGroupMode
                    ? const Column(
                        children: [
                          SizedBox(height: 8),
                          GroupModePanel(),
                          SizedBox(height: 24),
                        ],
                      )
                    : _SoloContent(
                        calcState: calcState,
                        calcNotifier: calcNotifier,
                        theme: theme,
                        exchangeRate:
                            exchangeRate.hasRate && !exchangeRate.isSameCurrency
                                ? exchangeRate.rate
                                : null,
                        homeCurrencySymbol: getCurrencySymbol(homeCurrency),
                        homeCurrencyCode: homeCurrency,
                        localCurrencyCode: _currencyCode,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool isGroupMode;
  final ValueChanged<bool> onToggle;

  const _ModeToggle({required this.isGroupMode, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onToggle(!isGroupMode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isGroupMode
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : theme.colorScheme.onSurface.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: isGroupMode
              ? Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isGroupMode ? Icons.group : Icons.person_outline,
              size: 15,
              color: isGroupMode
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Text(
              isGroupMode ? 'Group' : 'Solo',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isGroupMode
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoloContent extends ConsumerWidget {
  final TipCalculatorState calcState;
  final TipCalculatorNotifier calcNotifier;
  final ThemeData theme;
  final double? exchangeRate;
  final String? homeCurrencySymbol;
  final String? homeCurrencyCode;
  final String? localCurrencyCode;

  const _SoloContent({
    required this.calcState,
    required this.calcNotifier,
    required this.theme,
    this.exchangeRate,
    this.homeCurrencySymbol,
    this.homeCurrencyCode,
    this.localCurrencyCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        BillInput(
          currencySymbol: calcState.currencySymbol,
          onAmountChanged: calcNotifier.setBillAmount,
          exchangeRate: exchangeRate,
          homeCurrencySymbol: homeCurrencySymbol,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _TipPresetRow(
            presets: AppConstants.quickTipPresets,
            selected: calcState.tipPercent,
            onSelected: (percent) {
              final selectedPercent = calcNotifier.toggleTipPercent(percent);
              ref.read(preferencesRepositoryProvider)?.setLastTip(
                    calcState.countryId,
                    calcState.serviceType.dbValue,
                    selectedPercent,
                  );
            },
            onCustomSelected: (percent) {
              calcNotifier.setTipPercent(percent);
              ref.read(preferencesRepositoryProvider)?.setLastTip(
                    calcState.countryId,
                    calcState.serviceType.dbValue,
                    percent,
                  );
            },
            onClear: () {
              calcNotifier.setTipPercent(0);
              ref.read(preferencesRepositoryProvider)?.setLastTip(
                    calcState.countryId,
                    calcState.serviceType.dbValue,
                    0,
                  );
            },
            theme: theme,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _RoundingToggle(
            mode: calcState.roundingMode,
            onChanged: calcNotifier.setRoundingMode,
            theme: theme,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TipResultCard(
            tipAmount: calcState.result.tipAmount,
            totalAmount: calcState.result.totalAmount,
            perPersonTotal: calcState.result.perPersonTotal,
            perPersonTip: calcState.result.perPersonTip,
            tipPercent: calcState.result.tipPercent,
            splitCount: calcState.splitCount,
            currencySymbol: calcState.currencySymbol,
            exchangeRate: exchangeRate,
            homeCurrencySymbol: homeCurrencySymbol,
            homeCurrencyCode: homeCurrencyCode,
            localCurrencyCode: localCurrencyCode,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SplitControl(
            splitCount: calcState.splitCount,
            onChanged: calcNotifier.setSplitCount,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _TipPresetRow extends StatelessWidget {
  final List<double> presets;
  final double selected;
  final ValueChanged<double> onSelected;
  final ValueChanged<double> onCustomSelected;
  final VoidCallback onClear;
  final ThemeData theme;

  const _TipPresetRow({
    required this.presets,
    required this.selected,
    required this.onSelected,
    required this.onCustomSelected,
    required this.onClear,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final customSelected =
        selected > 0 && !presets.any((p) => _matchesPercent(p, selected));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _TipPresetChip(
            label: customSelected ? '${_formatPercent(selected)}%' : 'Custom',
            isSelected: customSelected,
            onTap:
                customSelected ? onClear : () => _showCustomTipDialog(context),
            theme: theme,
          ),
          const SizedBox(width: 8),
          ...presets.map((percent) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _TipPresetChip(
                label: '${percent.toInt()}%',
                isSelected: _matchesPercent(percent, selected),
                onTap: () => onSelected(percent),
                theme: theme,
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _showCustomTipDialog(BuildContext context) async {
    final percent = await showDialog<double>(
      context: context,
      builder: (context) => _CustomTipDialog(
        initialValue: selected > 0 ? _formatPercent(selected) : '',
      ),
    );

    if (percent == null) return;
    onCustomSelected(percent);
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

class _CustomTipDialog extends StatefulWidget {
  final String initialValue;

  const _CustomTipDialog({required this.initialValue});

  @override
  State<_CustomTipDialog> createState() => _CustomTipDialogState();
}

class _CustomTipDialogState extends State<_CustomTipDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            Navigator.of(context).pop(_TipPresetRow._parsePercent(value)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context)
              .pop(_TipPresetRow._parsePercent(_controller.text)),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _TipPresetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _TipPresetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border:
              isSelected ? Border.all(color: theme.colorScheme.primary) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}

class _RoundingToggle extends StatelessWidget {
  final RoundingMode mode;
  final ValueChanged<RoundingMode> onChanged;
  final ThemeData theme;

  const _RoundingToggle({
    required this.mode,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.blur_circular_outlined,
          size: 16,
          color: theme.textTheme.bodyMedium?.color,
        ),
        const SizedBox(width: 6),
        Text('Round:', style: theme.textTheme.bodyMedium),
        const SizedBox(width: 8),
        _roundChip('Off', RoundingMode.none),
        const SizedBox(width: 6),
        _roundChip('Tip ↑', RoundingMode.roundTipUp),
        const SizedBox(width: 6),
        _roundChip('Total ↑', RoundingMode.roundTotalUp),
      ],
    );
  }

  Widget _roundChip(String label, RoundingMode chipMode) {
    final isSelected = mode == chipMode;
    return GestureDetector(
      onTap: () => onChanged(chipMode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}
