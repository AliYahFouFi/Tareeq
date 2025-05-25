import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_frontend/models/BusModel.dart';
import 'package:flutter_frontend/models/ReportModel.dart';

class BusDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bus.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create buses table
        await db.execute('''
          CREATE TABLE buses (
            id INTEGER PRIMARY KEY,
            name TEXT
          )
        ''');

        // Create reports table
        await db.execute('''
          CREATE TABLE reports (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            busId INTEGER,
            issueType TEXT,
            description TEXT,
            imagePath TEXT
          )
        ''');

        // Insert 5 default buses
        for (int i = 1; i <= 5; i++) {
          await db.insert('buses', {'id': i, 'name': 'Bus $i'});
        }
      },
    );
  }

  // Fetch all buses
  static Future<List<Bus>> getBuses() async {
    final db = await database;
    final maps = await db.query('buses');
    return List.generate(maps.length, (i) => Bus.fromMap(maps[i]));
  }

  // Insert a report
  static Future<void> insertReport(Report report) async {
    final db = await database;
    await db.insert('reports', report.toMap());
  }

  // Get all reports
  static Future<List<Report>> getReports() async {
    final db = await database;
    final maps = await db.query('reports');
    return List.generate(maps.length, (i) => Report.fromMap(maps[i]));
  }

  // Get a bus name by ID (optional helper)
  static Future<String> getBusNameById(int busId) async {
    final db = await database;
    final result = await db.query('buses', where: 'id = ?', whereArgs: [busId]);
    return result.isNotEmpty ? result.first['name'] as String : 'Unknown Bus';
  }

  static Future<int> updateReport(Report report) async {
    final db = await database;

    return await db.update(
      'reports',
      {
        'busId': report.busId,
        'issueType': report.issueType,
        'description': report.description,
        'imagePath': report.imagePath
      },
      where: 'id = ?',
      whereArgs: [report.id],
    );
  }
}
