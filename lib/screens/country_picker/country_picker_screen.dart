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
  final Set<String> _expandedRegionGroups = {};
  final Set<String> _expandedSubregions = {};
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

  List<_RegionGroup> _regionGroups() {
    const groups = [
      _RegionGroup(
        name: 'Europe',
        subregions: [
          'Western Europe',
          'Eastern Europe',
          'Northern Europe',
          'Southern Europe',
        ],
      ),
      _RegionGroup(
        name: 'North America',
        subregions: [
          'North America',
          'Central America & Caribbean',
        ],
      ),
      _RegionGroup(
        name: 'South America',
        subregions: ['South America'],
      ),
      _RegionGroup(
        name: 'Asia',
        subregions: [
          'East Asia',
          'Southeast Asia',
          'South Asia',
          'Russia & Central Asia',
        ],
      ),
      _RegionGroup(
        name: 'Middle East & North Africa',
        subregions: [
          'Middle East',
          'North Africa',
        ],
      ),
      _RegionGroup(
        name: 'Africa',
        subregions: [
          'East Africa',
          'West Africa',
          'Central Africa',
          'Southern Africa',
        ],
      ),
      _RegionGroup(
        name: 'Oceania',
        subregions: ['Oceania'],
      ),
    ];

    return groups
        .where((group) => group.subregions.any(_groupedByRegion.containsKey))
        .toList();
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
    final groups = _regionGroups();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final countryCount = group.countryCount(_groupedByRegion);
        final isExpanded = _expandedRegionGroups.contains(group.name);
        final theme = Theme.of(context);

        return Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: PageStorageKey<String>('country-region-group-${group.name}'),
            initiallyExpanded: isExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                if (expanded) {
                  _expandedRegionGroups.add(group.name);
                } else {
                  _expandedRegionGroups.remove(group.name);
                }
              });
            },
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.only(bottom: 8),
            iconColor: theme.colorScheme.primary,
            collapsedIconColor: theme.textTheme.bodyMedium?.color,
            title: Text(
              group.name,
              style: theme.textTheme.labelLarge,
            ),
            subtitle: Text(
              '$countryCount countries',
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
            children: group.subregions.length == 1
                ? _buildCountryTiles(group.subregions.first)
                : [
                    for (final subregion in group.subregions)
                      if (_groupedByRegion.containsKey(subregion))
                        _buildSubregionTile(subregion),
                  ],
          ),
        );
      },
    );
  }

  Widget _buildSubregionTile(String subregion) {
    final countries = _groupedByRegion[subregion]!;
    final isExpanded = _expandedSubregions.contains(subregion);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: ExpansionTile(
        key: PageStorageKey<String>('country-subregion-$subregion'),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            if (expanded) {
              _expandedSubregions.add(subregion);
            } else {
              _expandedSubregions.remove(subregion);
            }
          });
        },
        tilePadding: const EdgeInsets.only(left: 16, right: 16),
        childrenPadding: const EdgeInsets.only(bottom: 6),
        iconColor: theme.colorScheme.primary,
        collapsedIconColor: theme.textTheme.bodyMedium?.color,
        title: Text(
          subregion,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          '${countries.length} countries',
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
        children: _buildCountryTiles(subregion),
      ),
    );
  }

  List<Widget> _buildCountryTiles(String region) {
    final countries = _groupedByRegion[region] ?? const <Country>[];
    return [
      for (final country in countries)
        CountryTile(
          country: country,
          onTap: () => widget.onCountrySelected(country),
          onInfoTap: widget.onCountryInfoTap != null
              ? () => widget.onCountryInfoTap!(country)
              : null,
        ),
    ];
  }
}

class _RegionGroup {
  final String name;
  final List<String> subregions;

  const _RegionGroup({
    required this.name,
    required this.subregions,
  });

  int countryCount(Map<String, List<Country>> countriesByRegion) {
    return subregions.fold<int>(
      0,
      (total, subregion) => total + (countriesByRegion[subregion]?.length ?? 0),
    );
  }
}
