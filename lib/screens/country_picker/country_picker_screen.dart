import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/country.dart';
import '../../data/repositories/tipping_repository.dart';
import 'widgets/country_tile.dart';

class CountryPickerScreen extends ConsumerStatefulWidget {
  final ValueChanged<Country> onCountrySelected;
  final ValueChanged<Country>? onCountryInfoTap;

  const CountryPickerScreen({
    super.key,
    required this.onCountrySelected,
    this.onCountryInfoTap,
  });

  @override
  ConsumerState<CountryPickerScreen> createState() =>
      _CountryPickerScreenState();
}

class _CountryPickerScreenState extends ConsumerState<CountryPickerScreen> {
  final _tippingRepo = TippingRepository();
  final _searchController = TextEditingController();
  List<Country> _allCountries = [];
  List<Country> _filteredCountries = [];
  Map<String, List<Country>> _groupedByRegion = {};
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    final countries = await _tippingRepo.getAllCountries();
    setState(() {
      _allCountries = countries;
      _filteredCountries = countries;
      _groupByRegion(countries);
    });
  }

  void _groupByRegion(List<Country> countries) {
    _groupedByRegion = {};
    for (final country in countries) {
      _groupedByRegion.putIfAbsent(country.region, () => []).add(country);
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredCountries = _allCountries;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _filteredCountries = _allCountries
          .where((c) =>
              c.name.toLowerCase().contains(query.toLowerCase()) ||
              c.id.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Country'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search countries...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isSearching
          ? _buildFlatList(_filteredCountries)
          : _buildGroupedList(),
    );
  }

  Widget _buildFlatList(List<Country> countries) {
    if (countries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'No countries found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: countries.length,
      itemBuilder: (context, index) {
        final country = countries[index];
        return CountryTile(
          country: country,
          onTap: () => widget.onCountrySelected(country),
          onInfoTap: widget.onCountryInfoTap != null
              ? () => widget.onCountryInfoTap!(country)
              : null,
        );
      },
    );
  }

  Widget _buildGroupedList() {
    final regions = _groupedByRegion.keys.toList()..sort();

    return ListView.builder(
      itemCount: regions.length,
      itemBuilder: (context, index) {
        final region = regions[index];
        final countries = _groupedByRegion[region]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                region,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            ...countries.map(
              (country) => CountryTile(
                country: country,
                onTap: () => widget.onCountrySelected(country),
                onInfoTap: widget.onCountryInfoTap != null
                    ? () => widget.onCountryInfoTap!(country)
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}
