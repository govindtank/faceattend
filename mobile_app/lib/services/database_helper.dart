import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/employee_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'faceattend.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Employees table
        await db.execute('''
          CREATE TABLE employees (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            department TEXT,
            position TEXT,
            email TEXT,
            phone TEXT,
            face_template TEXT, -- JSON string of face embedding
            created_at TEXT NOT NULL,
            is_active INTEGER NOT NULL DEFAULT 1
          )
        ''');

        // Attendance records table
        await db.execute('''
          CREATE TABLE attendance_records (
            id TEXT PRIMARY KEY,
            employee_id TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            type TEXT NOT NULL,
            confidence REAL DEFAULT 0.0,
            location TEXT DEFAULT '',
            device_id TEXT DEFAULT '',
            FOREIGN KEY (employee_id) REFERENCES employees(id)
          )
        ''');

        // Sync queue for offline operations
        await db.execute('''
          CREATE TABLE sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            table_name TEXT NOT NULL,
            operation TEXT NOT NULL, -- INSERT, UPDATE, DELETE
            record_data TEXT NOT NULL, -- JSON string
            timestamp TEXT NOT NULL,
            attempted INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  // Employee operations
  Future<int> insertEmployee(Employee employee) async {
    final db = await database;
    return await db.insert('employees', employee.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Employee>> getEmployees({bool activeOnly = true}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: activeOnly ? 'is_active = 1' : null,
    );

    return List.generate(maps.length, (i) {
      final employee = Employee.fromJson(maps[i]);
      // Parse face template from JSON string
      if (employee.faceTemplate == null && maps[i]['face_template'] != null) {
        try {
          final templateJson = maps[i]['face_template'] as String;
          employee.faceTemplate = List<double>.from(
            jsonDecode(templateJson)
          );
        } catch (e) {
          employee.faceTemplate = null;
        }
      }
      return employee;
    });
  }

  Future<Employee?> getEmployeeById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    final employee = Employee.fromJson(maps.first);
    // Parse face template
    if (employee.faceTemplate == null && maps.first['face_template'] != null) {
      try {
        final templateJson = maps.first['face_template'] as String;
        employee.faceTemplate = List<double>.from(
          jsonDecode(templateJson)
        );
      } catch (e) {
        employee.faceTemplate = null;
      }
    }
    return employee;
  }

  Future<int> updateEmployee(Employee employee) async {
    final db = await database;
    return await db.update(
      'employees',
      employee.toJson(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  Future<int> deleteEmployee(String id) async {
    final db = await database;
    return await db.delete(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Attendance record operations
  Future<int> insertAttendanceRecord(AttendanceRecord record) async {
    final db = await database;
    return await db.insert('attendance_records', record.toJson());
  }

  Future<List<AttendanceRecord>> getAttendanceRecords({
    String? employeeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    String where = '';
    List<dynamic> whereArgs = [];
    
    if (employeeId != null) {
      where += 'employee_id = ?';
      whereArgs.add(employeeId);
    }
    
    if (startDate != null) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'timestamp >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'timestamp <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_records',
      where: where.isNotEmpty ? where : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) => AttendanceRecord.fromJson(maps[i]));
  }

  // Sync queue operations
  Future<int> addToSyncQueue(String tableName, String operation, Map<String, dynamic> recordData) async {
    final db = await database;
    return await db.insert('sync_queue', {
      'table_name': tableName,
      'operation': operation,
      'record_data': jsonEncode(recordData),
      'timestamp': DateTime.now().toIso8601String(),
      'attempted': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems(int limit) async {
    final db = await database;
    return await db.query(
      'sync_queue',
      where: 'attempted < 3', // Retry up to 3 times
      orderBy: 'timestamp ASC',
      limit: limit,
    );
  }

  Future<int> markSyncItemAsAttempted(int id) async {
    final db = await database;
    return await db.update(
      'sync_queue',
      {'attempted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSyncItem(int id) async {
    final db = await database;
    return await db.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}