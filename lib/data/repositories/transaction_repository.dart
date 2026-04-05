import '../database/app_database.dart';
import '../models/transaction.dart';

class TransactionRepository {
  final AppDatabase _db;

  TransactionRepository({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  Future<int> insert(Transaction transaction) async {
    final db = await _db.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<Transaction>> getAll({int limit = 100, int offset = 0}) async {
    final db = await _db.database;
    final maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map(Transaction.fromMap).toList();
  }

  Future<List<Transaction>> getByCountry(String countryId) async {
    final db = await _db.database;
    final maps = await db.query(
      'transactions',
      where: 'country_id = ?',
      whereArgs: [countryId],
      orderBy: 'date DESC',
    );
    return maps.map(Transaction.fromMap).toList();
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    final db = await _db.database;
    return await db.delete('transactions');
  }

  Future<int> count() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM transactions');
    return result.first['count'] as int;
  }
}
