import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/operations_models.dart';

class OfflineScanDb {
  OfflineScanDb._();

  static final OfflineScanDb instance = OfflineScanDb._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'offline_scans.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE offline_scans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            payload TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  Future<void> saveScan(ScanRequestDTO scan) async {
    final db = await database;
    await db.insert(
      'offline_scans',
      {
        'payload': jsonEncode(scan.toJson()),
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<OfflineScanRecord>> getPendingScans() async {
    final db = await database;
    final rows = await db.query('offline_scans', orderBy: 'id ASC');

    return rows.map((row) {
      final payload = jsonDecode(row['payload'] as String);
      return OfflineScanRecord(
        id: row['id'] as int,
        scan: ScanRequestDTO(
          operationId: payload['operationId'],
          mobileScanId: payload['mobileScanId'],
          deviceId: payload['deviceId'],
          matricule: payload['matricule'],
          typeIso: payload['typeIso'],
          score: (payload['score'] as num?)?.toDouble(),
          offlineMode: payload['offlineMode'],
        ),
      );
    }).toList();
  }

  Future<int> countPendingScans() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM offline_scans',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> deleteScans(List<int> ids) async {
    if (ids.isEmpty) return;

    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');

    await db.delete(
      'offline_scans',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }
}

class OfflineScanRecord {
  final int id;
  final ScanRequestDTO scan;

  OfflineScanRecord({
    required this.id,
    required this.scan,
  });
}
