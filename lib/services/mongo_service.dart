import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:logger/logger.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  factory MongoService() => _instance;
  MongoService._internal();

  final _logger = Logger();
  Db? _db;

  // ── CONNECTION SETTINGS ──────────────────────────────────────────────
  // Option A (no auth): 'mongodb://localhost:27017/pos_system_dev'
  // Option B (with auth): 'mongodb://USERNAME:PASSWORD@localhost:27017/pos_system_dev'
  // Change the connection string below to match your MongoDB setup.
  static const String _mongoUri = 'mongodb://localhost:27017/pos_system_dev';
  // ─────────────────────────────────────────────────────────────────────

  Db? get db => _db;

  bool get isConnected => kIsWeb ? true : (_db != null && _db!.isConnected);

  Future<void> connect() async {
    if (kIsWeb) {
      _logger.i('Running on Web: Using In-Memory Database Fallback');
      return;
    }
    if (isConnected) return;
    try {
      _db = await Db.create(_mongoUri);
      await _db!.open();
      _logger.i('Successfully connected to MongoDB (pos_system_dev)');
    } catch (e) {
      _logger.e('Failed to connect to MongoDB', error: e);
      _logger.e(
        'If you see "Command requires authentication", your MongoDB has auth enabled.\n'
        'Either:\n'
        '  (A) Disable auth in mongod.cfg (set authorization: disabled)\n'
        '  (B) Update _mongoUri above to include credentials:\n'
        '      mongodb://USERNAME:PASSWORD@localhost:27017/pos_system_dev',
      );
      rethrow;
    }
  }

  DbCollection getCollection(String collectionName) {
    if (kIsWeb) {
      throw StateError('Cannot get DbCollection on Web. Use web storage fallback.');
    }
    if (_db == null || !_db!.isConnected) {
      throw StateError('MongoDB is not connected. Call connect() first.');
    }
    return _db!.collection(collectionName);
  }

  Future<void> close() async {
    if (kIsWeb) return;
    try {
      await _db?.close();
      _db = null;
      _logger.i('MongoDB connection closed.');
    } catch (e) {
      _logger.e('Error closing MongoDB connection', error: e);
    }
  }
}




