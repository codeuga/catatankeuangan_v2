import 'package:catatankeuangan/model/model_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  final String tableName = 'tbl_keuangan';
  final String columnId = 'id';
  final String columnTipe = 'tipe';
  final String columnKet = 'keterangan';
  final String columnJmlUang = 'jml_uang';
  final String columnTgl = 'tanggal';

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database?> get checkDB async {
    if (_database != null) {
      return _database;
    }
    _database = await _initDB();
    return _database;
  }

  Future<Database> _initDB() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'keuangan.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    var sql = "CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY, "
        "$columnTipe TEXT, "
        "$columnKet TEXT, "
        "$columnJmlUang TEXT,"
        "$columnTgl TEXT)";
    await db.execute(sql);
  }

  Future<int?> saveData(ModelDatabase modelDatabase) async {
    var dbClient = await checkDB;
    return await dbClient!.insert(tableName, modelDatabase.toMap());
  }

  Future<List?> getDataPemasukan() async {
    var dbClient = await checkDB;
    var result = await dbClient!.rawQuery(
        'SELECT * FROM $tableName WHERE $columnTipe = ?', ['pemasukan']);
    return result.toList();
  }

  Future<List?> getDataPengeluaran() async {
    var dbClient = await checkDB;
    var result = await dbClient!.rawQuery(
        'SELECT * FROM $tableName WHERE $columnTipe = ?', ['pengeluaran']);
    return result.toList();
  }

  Future<int> getJmlPemasukan() async {
    var dbClient = await checkDB;
    var queryResult = await dbClient!.rawQuery(
        'SELECT SUM(jml_uang) AS TOTAL from $tableName WHERE $columnTipe = ?',
        ['pemasukan']);

    int total = queryResult[0]['TOTAL'] != null
        ? int.parse(queryResult[0]['TOTAL'].toString())
        : 0;
    return total;
  }

  Future<int> getJmlPengeluaran() async {
    var dbClient = await checkDB;
    var queryResult = await dbClient!.rawQuery(
        'SELECT SUM(jml_uang) AS TOTAL from $tableName WHERE $columnTipe = ?',
        ['pengeluaran']);

    int total = queryResult[0]['TOTAL'] != null
        ? int.parse(queryResult[0]['TOTAL'].toString())
        : 0;
    return total;
  }

  Future<int?> updateDataPemasukan(ModelDatabase modelDatabase) async {
    var dbClient = await checkDB;
    return await dbClient!.update(tableName, modelDatabase.toMap(),
        where: '$columnId = ? and $columnTipe = ?',
        whereArgs: [modelDatabase.id, 'pemasukan']);
  }

  Future<int?> updateDataPengeluaran(ModelDatabase modelDatabase) async {
    var dbClient = await checkDB;
    return await dbClient!.update(tableName, modelDatabase.toMap(),
        where: '$columnId = ? and $columnTipe = ?',
        whereArgs: [modelDatabase.id, 'pengeluaran']);
  }

  Future<int?> cekDataPemasukan() async {
    var dbClient = await checkDB;
    return Sqflite.firstIntValue(await dbClient!.rawQuery(
        'SELECT COUNT(*) FROM $tableName WHERE $columnTipe = ?',
        ['pemasukan']));
  }

  Future<int?> cekDataPengeluaran() async {
    var dbClient = await checkDB;
    return Sqflite.firstIntValue(await dbClient!.rawQuery(
        'SELECT COUNT(*) FROM $tableName WHERE $columnTipe = ?',
        ['pengeluaran']));
  }

  Future<int?> deletePemasukan(int id) async {
    var dbClient = await checkDB;
    return await dbClient!.delete(tableName,
        where: '$columnId = ? and $columnTipe = ?',
        whereArgs: [id, 'pemasukan']);
  }

  Future<int?> deletePengeluaran(int id) async {
    var dbClient = await checkDB;
    return await dbClient!.delete(tableName,
        where: '$columnId = ? and $columnTipe = ?',
        whereArgs: [id, 'pengeluaran']);
  }
}
