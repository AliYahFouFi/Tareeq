import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_frontend/models/BusModel.dart';
import 'package:flutter_frontend/models/ReportModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        await db.execute('''
          CREATE TABLE buses (
            id INTEGER PRIMARY KEY,
            name TEXT
          )
        ''');

        // Use snake_case column names here:
        await db.execute('''
          CREATE TABLE reports (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bus_id INTEGER,
            issue_type TEXT,
            description TEXT,
            image_path TEXT
          )
        ''');

        for (int i = 1; i <= 5; i++) {
          await db.insert('buses', {'id': i, 'name': 'Bus $i'});
        }
      },
    );
  }

  static Future<List<Bus>> getBuses() async {
    final db = await database;
    final maps = await db.query('buses');
    return List.generate(maps.length, (i) => Bus.fromMap(maps[i]));
  }

  static Future<void> insertReport(Report report) async {
    final db = await database;
    await db.insert('reports', report.toMap());
  }

  static Future<List<Report>> getReports() async {
    final db = await database;
    final maps = await db.query('reports');
    return List.generate(maps.length, (i) => Report.fromMap(maps[i]));
  }

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
        'bus_id': report.busId,
        'issue_type': report.issueType,
        'description': report.description,
        'image_path': report.imagePath,
      },
      where: 'id = ?',
      whereArgs: [report.id],
    );
  }

  static Future<void> syncReportToLaravel(Report report) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/reports');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'bus_id': report.busId,
        'issue_type': report.issueType,
        'description': report.description,
        'image_path': report.imagePath,
      }),
    );

    if (response.statusCode == 201) {
      print("✅ Report synced: ${response.body}");
    } else {
      print("❌ Failed to sync: ${response.statusCode} => ${response.body}");
    }
  }
}
