import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'medicine.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medicines.db');
    return _database!;
  }
  //  Pag Initialize sang SQLite database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Force delete old DB (only for development, remove after testing)
    //await deleteDatabase(path);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

 // Pag Create sang tables
  Future _createDB(Database db, int version) async {
    // Create medicines table
    await db.execute('''
      CREATE TABLE medicines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dosage TEXT,
        usage TEXT,
        sideEffects TEXT,
        precautions TEXT,
        name_tagalog TEXT,
        dosage_tagalog TEXT,
        usage_tagalog TEXT,
        sideEffects_tagalog TEXT,
        precautions_tagalog TEXT
      )
    ''');

    // Create users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // default admin and user
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123',
      'role': 'admin'
    });

    await db.insert('users', {
      'username': 'user1',
      'password': 'user123',
      'role': 'user'
    });

   await db.execute('''
     CREATE TABLE schedules(
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       medicineName TEXT NOT NULL,
       dosage TEXT NOT NULL,
       frequency INTEGER NOT NULL,
       interval INTEGER NOT NULL,
       scheduleTimes TEXT NOT NULL
     )
   ''');

    final tables =
        await db.rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
    print('✅ Tables created: $tables');
  }

  // Add medicine
  Future<int> addMedicine(Medicine medicine) async {
    final db = await instance.database;
    return await db.insert('medicines', medicine.toMap());
  }

  // Get all medicines
  Future<List<Medicine>> getMedicines() async {
    final db = await instance.database;
    final result = await db.query('medicines');
    return result.map((map) => Medicine.fromMap(map)).toList();
  }

  // Update medicine
  Future<int> updateMedicine(Medicine medicine) async {
    final db = await instance.database;
    return db.update(
      'medicines',
      medicine.toMap(),
      where: 'id = ?',
      whereArgs: [medicine.id],
    );
  }

  // Delete medicine
  Future<int> deleteMedicine(int id) async {
    final db = await instance.database;
    return db.delete(
      'medicines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Add new user with role
  Future<int> addUser(String fullName, String username, String password, String role) async {
    final db = await instance.database;

    final existing = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (existing.isNotEmpty) {
      throw Exception('Username already exists');
    }

    return await db.insert('users', {
      'full_name': fullName,
      'username': username,
      'password': password,
      'role': role,
    });
  }

  // Login verification
  Future<Map<String, dynamic>?> loginUser(
      String username, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) return result.first;
    return null;
  }

  // Get medicine by name (case-insensitive) - Gin Gamit sa scanner sa pag scan sang med name
  Future<Map<String, dynamic>?> getMedicineByName(String name) async {
    final db = await instance.database;
    name = name.trim().replaceAll(RegExp(r'\s+'), '').replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    final result = await db.query(
      'medicines',
      where: 'REPLACE(REPLACE(name, " ", ""), ".", "") = ? COLLATE NOCASE',
      whereArgs: [name],
    );

    if (result.isNotEmpty) return result.first;
    return null;
  }

// saves a new medicine schedule into  SQLite database.
  Future<int> insertSchedule(Map<String, dynamic> schedule) async {
      final db = await instance.database;
      return await db.insert('schedules', schedule);
    }

//retrieves all saved schedules
    Future<List<Map<String, dynamic>>> getSchedules() async {
      final db = await instance.database;
      return await db.query('schedules', orderBy: 'id DESC');
    }

    // for delete schedule
   Future<int> deleteSchedule(int id) async {
     final db = await instance.database;
     return await db.delete(
       'schedules',
       where: 'id = ?',
       whereArgs: [id],
     );
   }


}
