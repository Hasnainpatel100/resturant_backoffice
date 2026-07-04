import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:logger/logger.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  factory MongoService() => _instance;
  MongoService._internal();

  final _logger = Logger();
  Db? _db;

  Db? get db => _db;

  bool get isConnected => kIsWeb ? true : (_db != null && _db!.isConnected);

  Future<void> connect() async {
    if (kIsWeb) {
      _logger.i('Running on Web: Using In-Memory Database Fallback');
      return;
    }
    if (isConnected) return;
    try {
      // Connecting to local MongoDB on port 27017, database pos_system_dev
      _db = await Db.create('mongodb://localhost:27017/pos_system_dev');
      await _db!.open();
      _logger.i('Successfully connected to MongoDB (pos_system_dev)');
    } catch (e) {
      _logger.e('Failed to connect to MongoDB', error: e);
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
