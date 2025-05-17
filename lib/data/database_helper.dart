import 'dart:async'; // Para operaciones asíncronas
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'; // Acceso a directorios del dispositivo
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  //Garantiza una única instancia de la clase en toda la app.

  // Nombre de la base de datos
  final String _databaseName = "geodesica_app.db";

  // Versión de la base de datos
  final int _databaseVersion = 1;

  // Nombres de tablas
  final String tableUsers = 'users';
  final String tableChats = 'chats';
  final String tableChatMessages = 'chat_messages';
  final String tableContabilidad = 'contabilidad';

  // Factory constructor
  factory DatabaseHelper() {
    return _instance;
  }

  // Constructor interno privado
  DatabaseHelper._internal();

  // Getter para la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  // Inicializar la base de datos
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Crear las tablas
  Future _onCreate(Database db, int version) async {
    // Tabla de Usuarios
    await db.execute('''
      CREATE TABLE $tableUsers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        birthDate TEXT,
        document TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabla de Chats (conversaciones)
    await db.execute('''
      CREATE TABLE $tableChats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES $tableUsers (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de Mensajes de Chat
    await db.execute('''
      CREATE TABLE $tableChatMessages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chat_id INTEGER NOT NULL,
        rol TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (chat_id) REFERENCES $tableChats (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de Contabilidad 
    await db.execute('''
      CREATE TABLE $tableContabilidad (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha TEXT NOT NULL,
        tipo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        monto REAL NOT NULL,
        categoria TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Insertar algunos datos de ejemplo en la tabla de contabilidad
    await _insertSampleContabilidadData(db);
  }

  Future _insertSampleContabilidadData(Database db) async {
    // Datos de ejemplo para la tabla de contabilidad
    List<Map<String, dynamic>> contabilidadData = [
      {
        'fecha': '2025-01-15',
        'tipo': 'Ingreso',
        'descripcion': 'Venta de productos',
        'monto': 5000.00,
        'categoria': 'Ventas',
      },
      {
        'fecha': '2025-01-20',
        'tipo': 'Gasto',
        'descripcion': 'Pago de alquiler',
        'monto': 1200.00,
        'categoria': 'Alquiler',
      },
      {
        'fecha': '2025-02-01',
        'tipo': 'Ingreso',
        'descripcion': 'Servicio de consultoría',
        'monto': 3500.00,
        'categoria': 'Servicios',
      },
      {
        'fecha': '2025-02-10',
        'tipo': 'Gasto',
        'descripcion': 'Compra de materiales',
        'monto': 850.00,
        'categoria': 'Inventario',
      },
      {
        'fecha': '2025-02-15',
        'tipo': 'Gasto',
        'descripcion': 'Pago de salarios',
        'monto': 7500.00,
        'categoria': 'Salarios',
      },
      {
        'fecha': '2025-03-01',
        'tipo': 'Ingreso',
        'descripcion': 'Venta de servicios',
        'monto': 6800.00,
        'categoria': 'Servicios',
      },
      {
        'fecha': '2025-03-10',
        'tipo': 'Gasto',
        'descripcion': 'Pago de impuestos',
        'monto': 1800.00,
        'categoria': 'Impuestos',
      },
      {
        'fecha': '2025-03-20',
        'tipo': 'Gasto',
        'descripcion': 'Servicios públicos',
        'monto': 450.00,
        'categoria': 'Servicios',
      },
      {
        'fecha': '2025-04-01',
        'tipo': 'Ingreso',
        'descripcion': 'Venta mayorista',
        'monto': 12000.00,
        'categoria': 'Ventas',
      },
      {
        'fecha': '2025-04-15',
        'tipo': 'Gasto',
        'descripcion': 'Mantenimiento de equipo',
        'monto': 980.00,
        'categoria': 'Mantenimiento',
      },
    ];

    for (var data in contabilidadData) {
      await db.insert(tableContabilidad, data);
    }
  }

  // CRUD para Usuarios
  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(tableUsers, row);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      tableUsers,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // CRUD para Chats
  Future<int> insertChat(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(tableChats, row);
  }

  Future<List<Map<String, dynamic>>> getChatsForUser(int userId) async {
    Database db = await database;
    return await db.query(
      tableChats,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  // CRUD para Mensajes de Chat
  Future<int> insertChatMessage(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(tableChatMessages, row);
  }

  Future<List<Map<String, dynamic>>> getMessagesForChat(int chatId) async {
    Database db = await database;
    return await db.query(
      tableChatMessages,
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'timestamp ASC',
    );
  }

  // Consultas para la tabla de Contabilidad
  Future<List<Map<String, dynamic>>> getAllContabilidadEntries() async {
    Database db = await database;
    return await db.query(tableContabilidad, orderBy: 'fecha DESC');
  }

  Future<List<Map<String, dynamic>>> searchContabilidad(String query) async {
    Database db = await database;
    return await db.query(
      tableContabilidad,
      where: 'descripcion LIKE ? OR categoria LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'fecha DESC',
    );
  }

  Future<double> getTotalIngresos() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(monto) AS total FROM $tableContabilidad WHERE tipo = ?',
      ['Ingreso'],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getTotalGastos() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(monto) AS total FROM $tableContabilidad WHERE tipo = ?',
      ['Gasto'],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<Map<String, double>> getGastosPorCategoria() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT categoria, SUM(monto) AS total FROM $tableContabilidad WHERE tipo = ? GROUP BY categoria',
      ['Gasto'],
    );

    Map<String, double> gastosPorCategoria = {};
    for (var row in result) {
      gastosPorCategoria[row['categoria'] as String] = row['total'] as double;
    }

    return gastosPorCategoria;
  }

  Future<List<Map<String, dynamic>>> getContabilidadByMonth(
    String month,
    String year,
  ) async {
    Database db = await database;
    return await db.query(
      tableContabilidad,
      where: "fecha LIKE ?",
      whereArgs: ['$year-$month%'],
      orderBy: 'fecha DESC',
    );
  }
}
