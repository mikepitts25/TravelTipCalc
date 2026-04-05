import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../data/models/tipping_rule.dart';
import '../../data/repositories/tipping_repository.dart';
import '../../providers/location_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/tip_calculator_provider.dart';
import '../../utils/rounding.dart';
import 'widgets/bill_input.dart';
import 'widgets/country_badge.dart';
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
  String _countryFlag = '🌍';
  String _countryName = 'Select Country';
  bool _serviceIncluded = false;
  TippingRule? _currentRule;

  @override
  void initState() {
    super.initState();
    // Try to detect location on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectOrLoadCountry();
    });
  }

  Future<void> _detectOrLoadCountry() async {
    try {
      final prefs = ref.read(preferencesRepositoryProvider);
      final lastCountry = prefs?.lastCountry;

      if (lastCountry != null) {
        await _loadCountry(lastCountry);
      } else {
        // Try GPS detection (may fail on simulator)
        try {
          await ref.read(locationProvider.notifier).detectLocation();
          final locationState = ref.read(locationProvider);
          if (locationState.countryCode != null) {
            await _loadCountry(locationState.countryCode!);
            return;
          }
        } catch (_) {
          // Location detection failed, fall through to default
        }
        await _loadCountry(AppConstants.defaultCountry);
      }
    } catch (_) {
      // Database might not be ready yet, load default
      await _loadCountry(AppConstants.defaultCountry);
    }
  }

  Future<void> _loadCountry(String countryId) async {
    final country = await _tippingRepo.getCountryById(countryId);
    if (country == null) return;

    final calcNotifier = ref.read(tipCalculatorProvider.notifier);
    final calcState = ref.read(tipCalculatorProvider);

    calcNotifier.setCountry(country.id, country.currencySymbol);

    if (!mounted) return;
    setState(() {
      _countryFlag = country.flag;
      _countryName = country.name;
      _serviceIncluded = country.serviceIncluded;
    });

    // Load tipping rule for current service type
    await _loadRule(country.id, calcState.serviceType);

    // Save as last country
    ref.read(preferencesRepositoryProvider)?.setLastCountry(country.id);
  }

  Future<void> _loadRule(String countryId, ServiceType serviceType) async {
    final rule = await _tippingRepo.getRule(countryId, serviceType);
    if (rule != null && mounted) {
      setState(() => _currentRule = rule);

      // Check if user has a saved tip % for this combo
      final prefs = ref.read(preferencesRepositoryProvider);
      final savedTip = prefs?.getLastTip(countryId, serviceType.dbValue);

      final calcNotifier = ref.read(tipCalculatorProvider.notifier);
      calcNotifier.setTipPercent(savedTip ?? rule.suggestedPercent);
    }
  }

  void _onServiceChanged(ServiceType type) {
    final calcNotifier = ref.read(tipCalculatorProvider.notifier);
    final calcState = ref.read(tipCalculatorProvider);
    calcNotifier.setServiceType(type);
    _loadRule(calcState.countryId, type);
  }

  /// Called externally when a country is selected from the picker.
  void loadCountry(String countryId) {
    _loadCountry(countryId);
  }

  @override
  Widget build(BuildContext context) {
    final calcState = ref.watch(tipCalculatorProvider);
    final calcNotifier = ref.read(tipCalculatorProvider.notifier);
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Country badge
                  CountryBadge(
                    flag: _countryFlag,
                    countryName: _countryName,
                    serviceIncluded: _serviceIncluded,
                    onTap: widget.onCountryTap,
                  ),
                  const SizedBox(height: 8),
                  // Service type selector
                  ServiceSelector(
                    selected: calcState.serviceType,
                    onSelected: _onServiceChanged,
                  ),
                  const SizedBox(height: 4),
                  // Tipping note for current rule
                  if (_currentRule != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 4,
                      ),
                      child: Text(
                        _currentRule!.note,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  // Bill input numpad
                  BillInput(
                    currencySymbol: calcState.currencySymbol,
                    onAmountChanged: (amount) {
                      calcNotifier.setBillAmount(amount);
                    },
                  ),
                  const SizedBox(height: 12),
                  // Quick tip % presets
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _TipPresetRow(
                      presets: AppConstants.quickTipPresets,
                      selected: calcState.tipPercent,
                      onSelected: (percent) {
                        calcNotifier.setTipPercent(percent);
                        // Save preference
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
                  // Rounding toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _RoundingToggle(
                      mode: calcState.roundingMode,
                      onChanged: calcNotifier.setRoundingMode,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Results card
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
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Split control
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SplitControl(
                      splitCount: calcState.splitCount,
                      onChanged: calcNotifier.setSplitCount,
                    ),
                  ),
                  const SizedBox(height: 80), // Space for bottom nav + ad
                ],
              ),
            ),
          ),
          // Banner ad placeholder - enable once AdMob is configured
          // See lib/providers/ad_provider.dart for setup instructions
        ],
      ),
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
