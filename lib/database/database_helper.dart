import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {

    if (_database != null) return _database!;

    _database = await _initDB('deposits.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {

    await db.execute('''
CREATE TABLE deposits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  bankName TEXT,
  accountNumber TEXT,
  depositType TEXT,
  amount REAL,
  startDate TEXT,
  maturityDate TEXT,
  UNIQUE(bankName, accountNumber, depositType)
)
''');
  }

  Future<int> insertDeposit(Map<String, dynamic> deposit) async {

    final db = await instance.database;

    return await db.insert(
      'deposits',
      deposit,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Map<String, dynamic>>> getDeposits() async {

    final db = await instance.database;

    return await db.query('deposits');
  }

  Future<int> deleteDeposit(int id) async {

    final db = await instance.database;

    return await db.delete(
      'deposits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}