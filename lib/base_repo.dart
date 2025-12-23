import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

abstract class BaseRepository<T> {
  final String tableName;

  BaseRepository(this.tableName);

  Future<Database> get _db async => DatabaseHelper().database;

  // Create: Insert a single item into the table
  Future<void> baseInsert(
    T item, {
    required Map<String, dynamic> Function(T) toMap,
  }) async {
    final db = await _db;
    await db.insert(
      tableName,
      toMap(item),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Create: Insert a list of items into the table
  Future<void> baseInsertAll(
    List<T> items, {
    required Map<String, dynamic> Function(T) toMap,
  }) async {
    final db = await _db;
    final batch = db.batch();

    for (var item in items) {
      batch.insert(
        tableName,
        toMap(item),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    try {
      await batch.commit(noResult: true); // Commit all operations in batch
    } catch (e) {
      print("Error inserting items into $tableName: $e");
      rethrow; // Optional: rethrow the error if you want it to propagate
    }
  }

  // Read: Get all items from the table
  Future<List<T>> baseGetAll({
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    final db = await _db;
    final List<Map<String, dynamic>> rows = await db.query(
      tableName,
      orderBy: 'id ASC',
    );
    return rows.map((e) => fromMap(e)).toList();
  }

  // Read: Get a single item by id
  Future<T?> baseGetById(
    int id, {
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    final db = await _db;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return fromMap(result.first);
    }
    return null; // If no item is found, return null
  }

  // Update: Update an existing item by id
  Future<int> baseUpdate(
    T item, {
    required Map<String, dynamic> Function(T) toMap,
    required int id,
  }) async {
    final db = await _db;
    return await db.update(
      tableName,
      toMap(item),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete: Delete an item by id
  Future<int> baseDelete(int id) async {
    final db = await _db;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Check if a record has children (rows with parent_id = id)
  Future<bool> hasChildren(int id) async {
    final db = await _db;
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM $tableName WHERE parent_id = ?',
        [id],
      ),
    );
    return (count ?? 0) > 0;
  }

  // Safe delete: only deletes if no children exist
  Future<bool> safeDelete(int id) async {
    if (await hasChildren(id)) {
      return false;
    }
    await baseDelete(id);
    return true;
  }

  // Check if the table is empty
  Future<bool> isEmpty() async => await _isTableEmpty(tableName);

  Future<bool> _isTableEmpty(String table) async {
    final database = await _db;
    final result = await database.rawQuery('SELECT 1 FROM $table LIMIT 1');
    return result.isEmpty;
  }
}
