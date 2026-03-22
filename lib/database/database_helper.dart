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

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<double> getTotalPrincipal() async {
    final db = await instance.database;

    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM deposits",
    );

    if (result.first['total'] == null) {
      return 0;
    }

    return result.first['total'] as double;
  }

  Future<List<Map<String, dynamic>>> getTotalByBank() async {
    final db = await instance.database;

    return await db.rawQuery(
      "SELECT bankName, SUM(amount) as total FROM deposits GROUP BY bankName",
    );
  }

  Future<List<Map<String, dynamic>>> getTotalByUser() async {
    final db = await instance.database;

    return await db.rawQuery(
      "SELECT depositor, SUM(amount) as total FROM deposits GROUP BY depositor",
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE deposits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bankName TEXT,
        depositor TEXT,
        depositType TEXT,
        amount REAL,
        interestRate TEXT,
        yearlyInterest REAL,
        startDate TEXT,
        maturityDate TEXT,
        UNIQUE(bankName, depositor, amount)
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

    return await db.delete('deposits', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalByType(String type) async {
    final db = await instance.database;

    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM deposits WHERE depositType = ?",
      [type],
    );

    if (result.first['total'] == null) {
      return 0;
    }

    return result.first['total'] as double;
  }

  Future<bool> isDuplicateDeposit(
    String name,
    String bankName,
    double amount,
  ) async {
    final db = await instance.database;

    final result = await db.query(
      'deposits',
      where: 'depositor = ? AND bankName = ? AND amount = ?',
      whereArgs: [name, bankName, amount],
    );

    return result.isNotEmpty;
  }
}
