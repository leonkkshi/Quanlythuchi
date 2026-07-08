import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quanlythuchi.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        avatarUrl TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color_hex TEXT NOT NULL,
        user_id TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        category_id TEXT NOT NULL,
        type TEXT NOT NULL,
        user_id TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS budgets (
        id TEXT PRIMARY KEY,
        category_id TEXT NOT NULL,
        amount REAL NOT NULL,
        period TEXT NOT NULL,
        user_id TEXT NOT NULL
      )
    ''');

    // Seed default demo user
    await db.insert('users', {
      'id': 'u-001',
      'name': 'Nguyễn Văn Minh',
      'email': 'admin@example.com',
      'password': 'password123',
      'avatarUrl': 'https://api.dicebear.com/7.x/adventurer/png?seed=Minh',
    });

    // Seed default categories for demo user u-001
    await _seedDefaultCategories(db, 'u-001');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE categories (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          icon_code INTEGER NOT NULL,
          color_hex TEXT NOT NULL,
          user_id TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE transactions (
          id TEXT PRIMARY KEY,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          note TEXT,
          category_id TEXT NOT NULL,
          type TEXT NOT NULL,
          user_id TEXT NOT NULL,
          FOREIGN KEY (category_id) REFERENCES categories (id)
        )
      ''');

      await _seedDefaultCategories(db, 'u-001');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS budgets (
          id TEXT PRIMARY KEY,
          category_id TEXT NOT NULL,
          amount REAL NOT NULL,
          period TEXT NOT NULL,
          user_id TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> _seedDefaultCategories(Database db, String userId) async {
    final List<Map<String, dynamic>> defaultCategories = [
      // Expenses
      {
        'id': 'cat_expense_food_$userId',
        'name': 'Ăn uống',
        'type': 'expense',
        'icon_code': 0xe532, // restaurant
        'color_hex': '#FF9800',
        'user_id': userId,
      },
      {
        'id': 'cat_expense_daily_$userId',
        'name': 'Chi tiêu hàng ngày',
        'type': 'expense',
        'icon_code': 0xe547, // local_grocery_store
        'color_hex': '#4CAF50',
        'user_id': userId,
      },
      {
        'id': 'cat_expense_clothes_$userId',
        'name': 'Quần áo',
        'type': 'expense',
        'icon_code': 0xf581, // checkroom
        'color_hex': '#2196F3',
        'user_id': userId,
      },
      {
        'id': 'cat_expense_cosmetics_$userId',
        'name': 'Mỹ phẩm',
        'type': 'expense',
        'icon_code': 0xea8a, // spa
        'color_hex': '#E91E63',
        'user_id': userId,
      },
      {
        'id': 'cat_expense_social_$userId',
        'name': 'Phí giao lưu',
        'type': 'expense',
        'icon_code': 0xe540, // local_bar
        'color_hex': '#9C27B0',
        'user_id': userId,
      },
      {
        'id': 'cat_expense_health_$userId',
        'name': 'Y tế',
        'type': 'expense',
        'icon_code': 0xe548, // local_hospital
        'color_hex': '#00BCD4',
        'user_id': userId,
      },
      {
        'id': 'cat_expense_edu_$userId',
        'name': 'Giáo dục',
        'type': 'expense',
        'icon_code': 0xe80c, // school
        'color_hex': '#FF5722',
        'user_id': userId,
      },
      {
        'id': 'cat_expense_elec_$userId',
        'name': 'Tiền điện',
        'type': 'expense',
        'icon_code': 0xe90f, // lightbulb_outline
        'color_hex': '#FFEB3B',
        'user_id': userId,
      },
      {
        'id': 'cat_expense_transit_$userId',
        'name': 'Đi lại',
        'type': 'expense',
        'icon_code': 0xe531, // directions_car
        'color_hex': '#607D8B',
        'user_id': userId,
      },
      {
        'id': 'cat_expense_comm_$userId',
        'name': 'Phí liên lạc',
        'type': 'expense',
        'icon_code': 0xe2cd, // phone_android
        'color_hex': '#795548',
        'user_id': userId,
      },
      {
        'id': 'cat_expense_rent_$userId',
        'name': 'Tiền nhà',
        'type': 'expense',
        'icon_code': 0xe88a, // home
        'color_hex': '#3F51B5',
        'user_id': userId,
      },
      // Incomes
      {
        'id': 'cat_income_salary_$userId',
        'name': 'Lương',
        'type': 'income',
        'icon_code': 0xe227, // attach_money
        'color_hex': '#4CAF50',
        'user_id': userId,
      },
      {
        'id': 'cat_income_bonus_$userId',
        'name': 'Phụ thu',
        'type': 'income',
        'icon_code': 0xe8f1, // card_giftcard
        'color_hex': '#FFC107',
        'user_id': userId,
      },
      {
        'id': 'cat_income_invest_$userId',
        'name': 'Đầu tư',
        'type': 'income',
        'icon_code': 0xe6e1, // show_chart
        'color_hex': '#009688',
        'user_id': userId,
      },
      {
        'id': 'cat_income_other_$userId',
        'name': 'Khác',
        'type': 'income',
        'icon_code': 0xe5d2, // more_horiz
        'color_hex': '#9E9E9E',
        'user_id': userId,
      },
    ];

    final batch = db.batch();
    for (var cat in defaultCategories) {
      batch.insert('categories', cat, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  Future<void> seedDefaultCategoriesForUser(String userId) async {
    final db = await instance.database;
    await _seedDefaultCategories(db, userId);
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      columns: ['id', 'name', 'email', 'password', 'avatarUrl'],
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      columns: ['id', 'name', 'email', 'password', 'avatarUrl'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> updatePassword(String email, String newPassword) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );
  }

  Future<bool> checkUserExists(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      columns: ['email'],
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );
    return maps.isNotEmpty;
  }

  // --- CATEGORIES OPERATIONS ---
  Future<List<Map<String, dynamic>>> getCategoriesByUserId(String userId) async {
    final db = await instance.database;
    return await db.query(
      'categories',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await instance.database;
    return await db.insert(
      'categories',
      category,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteCategory(String id) async {
    final db = await instance.database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- TRANSACTIONS OPERATIONS ---
  Future<List<Map<String, dynamic>>> getTransactionsByUserId(String userId) async {
    final db = await instance.database;
    return await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  Future<int> insertTransaction(Map<String, dynamic> tx) async {
    final db = await instance.database;
    return await db.insert(
      'transactions',
      tx,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteTransaction(String id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateUserProfile(String id, String name, String avatarUrl) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'name': name, 'avatarUrl': avatarUrl},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
