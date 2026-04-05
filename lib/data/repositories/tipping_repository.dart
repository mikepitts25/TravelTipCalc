import '../database/app_database.dart';
import '../models/country.dart';
import '../models/tipping_rule.dart';

class TippingRepository {
  final AppDatabase _db;

  TippingRepository({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  Future<List<Country>> getAllCountries() async {
    final db = await _db.database;
    final maps = await db.query('countries', orderBy: 'name ASC');
    return maps.map(Country.fromMap).toList();
  }

  Future<List<Country>> searchCountries(String query) async {
    final db = await _db.database;
    final maps = await db.query(
      'countries',
      where: 'name LIKE ? OR id LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map(Country.fromMap).toList();
  }

  Future<List<Country>> getCountriesByRegion(String region) async {
    final db = await _db.database;
    final maps = await db.query(
      'countries',
      where: 'region = ?',
      whereArgs: [region],
      orderBy: 'name ASC',
    );
    return maps.map(Country.fromMap).toList();
  }

  Future<Country?> getCountryById(String id) async {
    final db = await _db.database;
    final maps = await db.query(
      'countries',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Country.fromMap(maps.first);
  }

  Future<List<TippingRule>> getRulesForCountry(String countryId) async {
    final db = await _db.database;
    final maps = await db.query(
      'tipping_rules',
      where: 'country_id = ?',
      whereArgs: [countryId],
    );
    return maps.map(TippingRule.fromMap).toList();
  }

  Future<TippingRule?> getRule(String countryId, ServiceType serviceType) async {
    final db = await _db.database;
    final maps = await db.query(
      'tipping_rules',
      where: 'country_id = ? AND service_type = ?',
      whereArgs: [countryId, serviceType.dbValue],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return TippingRule.fromMap(maps.first);
  }

  Future<List<String>> getAllRegions() async {
    final db = await _db.database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT region FROM countries ORDER BY region ASC',
    );
    return maps.map((m) => m['region'] as String).toList();
  }
}
