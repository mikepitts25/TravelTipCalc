import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/theme.dart';
import 'data/models/country.dart';
import 'providers/preferences_provider.dart';
import 'screens/calculator/calculator_screen.dart';
import 'screens/country_detail/country_detail_screen.dart';
import 'screens/country_picker/country_picker_screen.dart';
import 'screens/pro/pro_upgrade_screen.dart';
import 'screens/settings/settings_screen.dart';

class TravelTipCalcApp extends ConsumerWidget {
  const TravelTipCalcApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'TravelTipCalc',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _mapThemeMode(themeMode),
      home: const MainShell(),
    );
  }

  ThemeMode _mapThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// Main shell with bottom navigation.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final _calculatorKey = GlobalKey<CalculatorScreenState>();

  void _onCountrySelected(Country country) {
    // Go back to calculator and load the selected country
    setState(() => _currentIndex = 0);
    _calculatorKey.currentState?.loadCountry(country.id);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _openCountryDetail(Country country) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CountryDetailScreen(country: country),
      ),
    );
  }

  void _openCountryPicker() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CountryPickerScreen(
          onCountrySelected: (country) {
            Navigator.of(context).pop();
            _onCountrySelected(country);
          },
          onCountryInfoTap: _openCountryDetail,
        ),
      ),
    );
  }

  void _openProUpgrade() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProUpgradeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          CalculatorScreen(
            key: _calculatorKey,
            onCountryTap: _openCountryPicker,
          ),
          CountryPickerScreen(
            onCountrySelected: _onCountrySelected,
            onCountryInfoTap: _openCountryDetail,
          ),
          SettingsScreen(onUpgradeTap: _openProUpgrade),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate_outlined),
            activeIcon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
