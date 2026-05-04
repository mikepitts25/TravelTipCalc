import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../config/currencies.dart';
import '../../data/models/tipping_rule.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/tipping_repository.dart';
import '../../providers/exchange_rate_provider.dart';
import '../../providers/group_calculator_provider.dart';
import '../../providers/history_provider.dart';
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

  void _saveToHistory(BuildContext context) {
    final isPro = ref.read(proStatusProvider);
    if (!isPro) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip history is a Pro feature — upgrade in Settings'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final calcState = ref.read(tipCalculatorProvider);
    if (calcState.billAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a bill amount first')),
      );
      return;
    }

    final tx = TripTransaction(
      date: DateTime.now(),
      countryId: calcState.countryId,
      countryName: _countryName,
      countryFlag: _countryFlag,
      serviceType: calcState.serviceType,
      billAmount: calcState.billAmount,
      tipPercent: calcState.result.tipPercent,
      tipAmount: calcState.result.tipAmount,
      totalAmount: calcState.result.totalAmount,
      splitCount: calcState.splitCount,
      currencyCode: _currencyCode,
      currencySymbol: calcState.currencySymbol,
    );

    ref.read(historyProvider.notifier).save(tx);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Saved to trip history'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calcState = ref.watch(tipCalculatorProvider);
    final calcNotifier = ref.read(tipCalculatorProvider.notifier);
    final exchangeRate = ref.watch(exchangeRateProvider);
    final homeCurrency = ref.watch(homeCurrencyProvider);
    final theme = Theme.of(context);
    final isPro = ref.watch(proStatusProvider);

    return SafeArea(
      child: Column(
        children: [
          // Header: country badge + mode toggle + save button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    Icons.bookmark_add_outlined,
                    color: isPro
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  tooltip: isPro ? 'Save trip' : 'Pro: Save trip',
                  onPressed: () => _saveToHistory(context),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ServiceSelector(
              selected: calcState.serviceType,
              onSelected: _onServiceChanged,
            ),
          ),

          if (_currentRule != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Text(
                _currentRule!.note,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              child: _isGroupMode
                  ? const Column(
                      children: [
                        SizedBox(height: 8),
                        GroupModePanel(),
                        SizedBox(height: 80),
                      ],
                    )
                  : _SoloContent(
                      calcState: calcState,
                      calcNotifier: calcNotifier,
                      theme: theme,
                      exchangeRate: exchangeRate.hasRate &&
                              !exchangeRate.isSameCurrency
                          ? exchangeRate.rate
                          : null,
                      homeCurrencySymbol: getCurrencySymbol(homeCurrency),
                      homeCurrencyCode: homeCurrency,
                      localCurrencyCode: _currencyCode,
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
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _TipPresetRow(
            presets: AppConstants.quickTipPresets,
            selected: calcState.tipPercent,
            onSelected: (percent) {
              calcNotifier.setTipPercent(percent);
              ref.read(preferencesRepositoryProvider)?.setLastTip(
                    calcState.countryId,
                    calcState.serviceType.dbValue,
                    percent,
                  );
            },
            theme: theme,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _RoundingToggle(
            mode: calcState.roundingMode,
            onChanged: calcNotifier.setRoundingMode,
            theme: theme,
          ),
        ),
        const SizedBox(height: 8),
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
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SplitControl(
            splitCount: calcState.splitCount,
            onChanged: calcNotifier.setSplitCount,
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _TipPresetRow extends StatelessWidget {
  final List<double> presets;
  final double selected;
  final ValueChanged<double> onSelected;
  final ThemeData theme;

  const _TipPresetRow({
    required this.presets,
    required this.selected,
    required this.onSelected,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: presets.map((percent) {
        final isSelected = (percent - selected).abs() < 0.5;
        return GestureDetector(
          onTap: () => onSelected(percent),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: theme.colorScheme.primary)
                  : null,
            ),
            child: Text(
              '${percent.toInt()}%',
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
      }).toList(),
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
