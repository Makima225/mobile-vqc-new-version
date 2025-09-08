import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mobile_vqc.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE templates (
        id INTEGER PRIMARY KEY,
        nom TEXT,
        activite_specifique INTEGER,
        fichier TEXT,
        type_template TEXT,
        schema TEXT,
        quantite INTEGER,
        quantitemod INTEGER,
        created_at TEXT,
        isSynced INTEGER
      );
    ''');
    await db.execute('''
      CREATE TABLE entetes (
        id INTEGER PRIMARY KEY,
        titre TEXT,
        activite_specifique INTEGER,
        template INTEGER,
        isSynced INTEGER
      );
    ''');
    await db.execute('''
      CREATE TABLE anomalies (
        id INTEGER PRIMARY KEY,
        fiche_controle INTEGER,
        description TEXT,
        photo TEXT,
        date_signalement TEXT,
        signale_par INTEGER,
        isPendingSync INTEGER
      );
    ''');
    await db.execute('''
      CREATE TABLE users (
        email TEXT PRIMARY KEY,
        name TEXT,
        surname TEXT,
        role TEXT,
        picture TEXT,
        token TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE sous_projets (
        id INTEGER PRIMARY KEY,
        titre TEXT,
        projet INTEGER
      );
    ''');
    await db.execute('''
      CREATE TABLE activite_specifiques (
        id INTEGER PRIMARY KEY,
        titre TEXT,
        activite_generale INTEGER
      );
    ''');
    await db.execute('''
      CREATE TABLE activite_generales (
        id INTEGER PRIMARY KEY,
        titre TEXT,
        sous_projet INTEGER,
        qualiticient TEXT
      );
    ''');
  }
}
