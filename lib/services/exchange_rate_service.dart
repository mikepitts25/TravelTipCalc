import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/database/app_database.dart';

class ExchangeRateResult {
  final double rate;
  final DateTime fetchedAt;
  final bool fromCache;

  const ExchangeRateResult({
    required this.rate,
    required this.fetchedAt,
    this.fromCache = false,
  });
}

class ExchangeRateService {
  static const _baseUrl = 'https://api.frankfurter.app';
  static const _cacheMaxAge = Duration(hours: 6);

  /// Get exchange rate from [fromCurrency] to [toCurrency].
  /// Fetches from API if cache is stale, otherwise returns cached rate.
  /// Returns null if both API and cache fail.
  Future<ExchangeRateResult?> getRate(
    String fromCurrency,
    String toCurrency,
  ) async {
    if (fromCurrency == toCurrency) {
      return ExchangeRateResult(rate: 1.0, fetchedAt: DateTime.now());
    }

    // Check cache first
    final cached = await _getCachedRate(fromCurrency, toCurrency);
    if (cached != null) {
      final age = DateTime.now().difference(cached.fetchedAt);
      if (age < _cacheMaxAge) {
        return cached;
      }
    }

    // Fetch fresh rate from API
    try {
      final rate = await _fetchRate(fromCurrency, toCurrency);
      if (rate != null) {
        final now = DateTime.now();
        await _cacheRate(fromCurrency, toCurrency, rate, now);
        return ExchangeRateResult(rate: rate, fetchedAt: now);
      }
    } catch (_) {
      // API failed, fall through to cached
    }

    // Return stale cache if API failed
    return cached;
  }

  /// Fetch all rates for a base currency and cache them.
  Future<Map<String, double>?> getAllRates(String baseCurrency) async {
    try {
      final uri = Uri.parse('$_baseUrl/latest?from=$baseCurrency');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final rates = (data['rates'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, (value as num).toDouble()));

      // Cache all rates
      final now = DateTime.now();
      for (final entry in rates.entries) {
        await _cacheRate(baseCurrency, entry.key, entry.value, now);
      }

      return rates;
    } catch (_) {
      return null;
    }
  }

  Future<double?> _fetchRate(String from, String to) async {
    final uri = Uri.parse('$_baseUrl/latest?from=$from&to=$to');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return null;

    final data = json.decode(response.body) as Map<String, dynamic>;
    final rates = data['rates'] as Map<String, dynamic>;
    return (rates[to] as num?)?.toDouble();
  }

  Future<ExchangeRateResult?> _getCachedRate(String from, String to) async {
    try {
      final db = await AppDatabase.instance.database;
      final maps = await db.query(
        'exchange_rates',
        where: 'base_currency = ? AND target_currency = ?',
        whereArgs: [from, to],
        limit: 1,
      );
      if (maps.isEmpty) return null;

      final row = maps.first;
      return ExchangeRateResult(
        rate: row['rate'] as double,
        fetchedAt: DateTime.parse(row['fetched_at'] as String),
        fromCache: true,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheRate(
    String from,
    String to,
    double rate,
    DateTime fetchedAt,
  ) async {
    try {
      final db = await AppDatabase.instance.database;
      await db.insert(
        'exchange_rates',
        {
          'base_currency': from,
          'target_currency': to,
          'rate': rate,
          'fetched_at': fetchedAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Silently fail cache writes
    }
  }
}
