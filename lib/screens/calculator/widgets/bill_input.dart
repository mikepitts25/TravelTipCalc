import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom numpad for bill amount entry.
/// Avoids the system keyboard for a faster, more consistent experience.
class BillInput extends StatefulWidget {
  final String currencySymbol;
  final ValueChanged<double> onAmountChanged;

  const BillInput({
    super.key,
    required this.currencySymbol,
    required this.onAmountChanged,
  });

  @override
  State<BillInput> createState() => _BillInputState();
}

class _BillInputState extends State<BillInput> {
  String _input = '';

  double get _amount {
    if (_input.isEmpty) return 0;
    return double.tryParse(_input) ?? 0;
  }

  String get _displayAmount {
    if (_input.isEmpty) return '0.00';
    // Format as currency-like display
    final parts = _input.split('.');
    if (parts.length == 1) return '$_input.00';
    if (parts[1].length == 1) return '$_input' '0';
    return _input;
  }

  void _onKeyPress(String key) {
    HapticFeedback.lightImpact();

    setState(() {
      if (key == 'C') {
        _input = '';
      } else if (key == '⌫') {
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
        }
      } else if (key == '.') {
        if (!_input.contains('.')) {
          _input = _input.isEmpty ? '0.' : '$_input.';
        }
      } else {
        // Limit decimal places to 2
        if (_input.contains('.')) {
          final decimals = _input.split('.')[1];
          if (decimals.length >= 2) return;
        }
        // Limit total length
        if (_input.replaceAll('.', '').length >= 8) return;
        _input += key;
      }
    });

    widget.onAmountChanged(_amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Amount display
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.currencySymbol,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _displayAmount,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
        // Numpad
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              _buildRow(['1', '2', '3'], theme, isDark),
              const SizedBox(height: 8),
              _buildRow(['4', '5', '6'], theme, isDark),
              const SizedBox(height: 8),
              _buildRow(['7', '8', '9'], theme, isDark),
              const SizedBox(height: 8),
              _buildRow(['.', '0', '⌫'], theme, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(List<String> keys, ThemeData theme, bool isDark) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _NumpadKey(
              label: key,
              onTap: () => _onKeyPress(key),
              isDark: isDark,
              theme: theme,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NumpadKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final ThemeData theme;

  const _NumpadKey({
    required this.label,
    required this.onTap,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          child: label == '⌫'
              ? Icon(
                  Icons.backspace_outlined,
                  size: 22,
                  color: theme.textTheme.bodyLarge?.color,
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
        ),
      ),
    );
  }
}
