import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:back_office/services/mongo_service.dart';

class BaseMongoDataSource {
  final String collectionName;
  final MongoService _mongoService = MongoService();

  // In-memory static mock DB for Web
  static final Map<String, List<Map<String, dynamic>>> _webDb = {};

  BaseMongoDataSource(this.collectionName) {
    if (kIsWeb) {
      if (!_webDb.containsKey(collectionName)) {
        _webDb[collectionName] = [];
        _seedMockDataIfNeeded();
      }
    }
  }

  List<Map<String, dynamic>> get _webCollection => _webDb[collectionName]!;

  DbCollection get collection {
    if (kIsWeb) {
      throw StateError('Cannot access DbCollection on Web');
    }
    return _mongoService.getCollection(collectionName);
  }

  void _seedMockDataIfNeeded() {
    if (collectionName == 'branches' && _webDb['branches']!.isEmpty) {
      _webDb['branches']!.addAll([
        {
          '_id': ObjectId.fromHexString('5f67b5e408a2fc24bc6880bd'),
          'branch_code': 'BR-01',
          'name': {'en': 'Main Store Warehouse', 'ar': 'المستودع الرئيسي'},
          'isActive': true,
        },
        {
          '_id': ObjectId.fromHexString('5f67b5e408a2fc24bc6880be'),
          'branch_code': 'BR-02',
          'name': {'en': 'Kitchen Outlet A', 'ar': 'مطبخ أ'},
          'isActive': true,
        }
      ]);
    }

    if (collectionName == 'users' && _webDb['users']!.isEmpty) {
      _webDb['users']!.addAll([
        {
          '_id': ObjectId.fromHexString('5f67b5e408a2fc24bc6880bf'),
          'username': 'Chef John',
          'role': 'chef',
          'isActive': true,
        },
        {
          '_id': ObjectId.fromHexString('5f67b5e408a2fc24bc6880c0'),
          'username': 'Driver Sam',
          'role': 'driver',
          'isActive': true,
        }
      ]);
    }

    if (collectionName == 'units' && _webDb['units']!.isEmpty) {
      _webDb['units']!.addAll([
        {
          '_id': ObjectId.fromHexString('5f67b5e408a2fc24bc6880c3'),
          'unit_name': 'Kilograms',
          'short_name': 'kg',
          'isActive': true,
        },
        {
          '_id': ObjectId.fromHexString('5f67b5e408a2fc24bc6880c5'),
          'unit_name': 'Litres',
          'short_name': 'L',
          'isActive': true,
        }
      ]);
    }

    if (collectionName == 'raw_materials' && _webDb['raw_materials']!.isEmpty) {
      _webDb['raw_materials']!.addAll([
        {
          '_id': ObjectId.fromHexString('5f67b5e408a2fc24bc6880c1'),
          'material_code': 'RM-Milk',
          'material_name': 'Fresh Milk 1L',
          'base_unit_id': ObjectId.fromHexString('5f67b5e408a2fc24bc6880c5'),
          'tax_id': ObjectId.fromHexString('5f67b5e408a2fc24bc6880c4'),
          'purchase_rate': 2.50,
          'isActive': true,
        },
        {
          '_id': ObjectId.fromHexString('5f67b5e408a2fc24bc6880c2'),
          'material_code': 'RM-Flour',
          'material_name': 'Wheat Flour 1kg',
          'base_unit_id': ObjectId.fromHexString('5f67b5e408a2fc24bc6880c3'),
          'tax_id': ObjectId.fromHexString('5f67b5e408a2fc24bc6880c4'),
          'purchase_rate': 1.80,
          'isActive': true,
        }
      ]);
    }

    if (collectionName == 'raw_material_taxes' && _webDb['raw_material_taxes']!.isEmpty) {
      _webDb['raw_material_taxes']!.addAll([
        {
          '_id': ObjectId.fromHexString('5f67b5e408a2fc24bc6880c4'),
          'tax_name': 'Standard VAT',
          'tax_percent': 15.0,
          'isActive': true,
        }
      ]);
    }

    if (collectionName == 'vendors' && _webDb['vendors']!.isEmpty) {
      _webDb['vendors']!.addAll([
        {
          '_id': ObjectId.fromHexString('5f67b5e408a2fc24bc6880c6'),
          'vendor_name': 'Sysco Premium Foods',
          'contact_name': 'Alice Smith',
          'email': 'alice@sysco.com',
          'isActive': true,
        }
      ]);
    }

    if (collectionName == 'bill_types' && _webDb['bill_types']!.isEmpty) {
      _webDb['bill_types']!.addAll([
        {
          '_id': ObjectId.fromHexString('5f67b5e408a2fc24bc6880c7'),
          'name': 'Cash On Delivery',
          'isActive': true,
        }
      ]);
    }

    if (collectionName == 'stock_reasons' && _webDb['stock_reasons']!.isEmpty) {
      _webDb['stock_reasons']!.addAll([
        {
          '_id': ObjectId.fromHexString('5f67b5e408a2fc24bc6880c8'),
          'name': 'Spillage / Damage',
          'isActive': true,
        }
      ]);
    }
  }

  Future<List<Map<String, dynamic>>> getAll({SelectorBuilder? selector}) async {
    if (kIsWeb) {
      return List<Map<String, dynamic>>.from(_webCollection);
    }
    await _mongoService.connect();
    return await collection.find(selector).toList();
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    if (kIsWeb) {
      try {
        return _webCollection.firstWhere(
          (doc) => doc['id']?.toString() == id || doc['_id']?.toString() == id || (doc['_id'] is ObjectId && (doc['_id'] as ObjectId).toHexString() == id),
        );
      } catch (_) {
        return null;
      }
    }
    await _mongoService.connect();
    try {
      final objectId = ObjectId.fromHexString(id);
      return await collection.findOne(where.id(objectId));
    } catch (_) {
      return await collection.findOne(where.eq('id', id));
    }
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    if (kIsWeb) {
      if (!data.containsKey('_id') && !data.containsKey('id')) {
        data['_id'] = ObjectId();
      }
      _webCollection.add(data);
      return data;
    }
    await _mongoService.connect();
    if (!data.containsKey('_id') && !data.containsKey('id')) {
      data['_id'] = ObjectId();
    }
    await collection.insertOne(data);
    return data;
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    if (kIsWeb) {
      final idx = _webCollection.indexWhere(
        (doc) => doc['id']?.toString() == id || doc['_id']?.toString() == id || (doc['_id'] is ObjectId && (doc['_id'] as ObjectId).toHexString() == id),
      );
      if (idx != -1) {
        final merged = Map<String, dynamic>.from(_webCollection[idx])..addAll(data);
        _webCollection[idx] = merged;
        return true;
      }
      return false;
    }
    await _mongoService.connect();
    ObjectId? objectId;
    try {
      objectId = ObjectId.fromHexString(id);
    } catch (_) {}

    final selector = objectId != null ? where.id(objectId) : where.eq('id', id);
    final updateData = Map<String, dynamic>.from(data)..remove('_id');
    
    var modifier = modify;
    updateData.forEach((key, value) {
      modifier = modifier.set(key, value);
    });
    
    final result = await collection.updateOne(selector, modifier);
    return result.isSuccess;
  }

  Future<bool> delete(String id) async {
    if (kIsWeb) {
      final initialLen = _webCollection.length;
      _webCollection.removeWhere(
        (doc) => doc['id']?.toString() == id || doc['_id']?.toString() == id || (doc['_id'] is ObjectId && (doc['_id'] as ObjectId).toHexString() == id),
      );
      return _webCollection.length < initialLen;
    }
    await _mongoService.connect();
    ObjectId? objectId;
    try {
      objectId = ObjectId.fromHexString(id);
    } catch (_) {}

    final selector = objectId != null ? where.id(objectId) : where.eq('id', id);
    final result = await collection.deleteOne(selector);
    return result.isSuccess;
  }
}
