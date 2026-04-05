import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static Database? _database;
  static const _dbName = 'travel_tip_calc.db';
  static const _dbVersion = 2;

  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE countries (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        flag TEXT NOT NULL,
        region TEXT NOT NULL,
        currency_code TEXT NOT NULL,
        currency_symbol TEXT NOT NULL,
        service_included INTEGER NOT NULL DEFAULT 0,
        etiquette_note TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tipping_rules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        country_id TEXT NOT NULL,
        service_type TEXT NOT NULL,
        min_percent REAL NOT NULL,
        max_percent REAL NOT NULL,
        suggested_percent REAL NOT NULL,
        note TEXT NOT NULL,
        FOREIGN KEY (country_id) REFERENCES countries (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        country_id TEXT NOT NULL,
        service_type TEXT NOT NULL,
        bill_amount REAL NOT NULL,
        tip_percent REAL NOT NULL,
        tip_amount REAL NOT NULL,
        total_amount REAL NOT NULL,
        split_count INTEGER NOT NULL DEFAULT 1,
        currency_code TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (country_id) REFERENCES countries (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE user_preferences (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await _createExchangeRatesTable(db);

    // Create indexes for fast lookups
    await db.execute(
      'CREATE INDEX idx_tipping_rules_country ON tipping_rules (country_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_date ON transactions (date DESC)',
    );

    // Seed tipping data from bundled JSON
    await _seedData(db);
  }

  static Future<void> _createExchangeRatesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS exchange_rates (
        base_currency TEXT NOT NULL,
        target_currency TEXT NOT NULL,
        rate REAL NOT NULL,
        fetched_at TEXT NOT NULL,
        PRIMARY KEY (base_currency, target_currency)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createExchangeRatesTable(db);
    }
  }

  Future<void> _seedData(Database db) async {
    final jsonString = await rootBundle.loadString('assets/data/tipping_data.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final countries = data['countries'] as List<dynamic>;

    final batch = db.batch();

    for (final countryData in countries) {
      final country = countryData as Map<String, dynamic>;

      batch.insert('countries', {
        'id': country['id'],
        'name': country['name'],
        'flag': country['flag'],
        'region': country['region'],
        'currency_code': country['currency_code'],
        'currency_symbol': country['currency_symbol'],
        'service_included': (country['service_included'] as bool) ? 1 : 0,
        'etiquette_note': country['etiquette_note'],
      });

      final rules = country['rules'] as List<dynamic>;
      for (final ruleData in rules) {
        final rule = ruleData as Map<String, dynamic>;
        batch.insert('tipping_rules', {
          'country_id': country['id'],
          'service_type': rule['service_type'],
          'min_percent': rule['min_percent'],
          'max_percent': rule['max_percent'],
          'suggested_percent': rule['suggested_percent'],
          'note': rule['note'],
        });
      }
    }

    await batch.commit(noResult: true);
  }
}
