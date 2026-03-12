import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/business_card.dart';

class DatabaseHelper {
  // Singleton pattern to ensure only one instance of the database exists
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_capture.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Open/Create the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Define the table schema
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        company TEXT,
        scanDate TEXT
      )
    ''');
  }

  // --- CRUD OPERATIONS ---

  // Create: Insert a card
  Future<int> insertCard(BusinessCard card) async {
    final db = await instance.database;
    return await db.insert('cards', card.toMap());
  }

  // Read: Get all cards
  Future<List<BusinessCard>> getAllCards() async {
    final db = await instance.database;
    final result = await db.query('cards', orderBy: 'scanDate DESC');
    return result.map((json) => BusinessCard.fromMap(json)).toList();
  }

  // Delete: Remove a card by ID
  Future<int> deleteCard(int id) async {
    final db = await instance.database;
    return await db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }
}