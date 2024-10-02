import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'chart_data.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'finance.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE chart_data(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            symbol TEXT,
            name TEXT,
            price REAL,
            change REAL,
            image TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertChartData(ChartData data) async {
    final db = await database;
    await db.insert(
      'chart_data',
      {
        'symbol': data.symbol,
        'name': data.name,
        'price': data.price,
        'change': data.change,
        'image': data.image,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChartData>> fetchChartData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('chart_data');

    return List.generate(maps.length, (i) {
      return ChartData(
        symbol: maps[i]['symbol'],
        name: maps[i]['name'],
        price: maps[i]['price'],
        change: maps[i]['change'],
        stockHistory: [],
        image: maps[i]['image'],
      );
    });
  }
}
