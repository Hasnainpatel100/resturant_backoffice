import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class BaseHiveDataSource {
  final String collectionName;

  BaseHiveDataSource(this.collectionName);

  Future<Box> _getBox() async {
    final box = await Hive.openBox(collectionName);
    if (box.isEmpty) {
      await _seedMockDataIfNeeded(box);
    }
    return box;
  }

  Future<void> _seedMockDataIfNeeded(Box box) async {
    if (collectionName == 'branches') {
      await box.putAll({
        '5f67b5e408a2fc24bc6880bd': {
          '_id': '5f67b5e408a2fc24bc6880bd',
          'branch_code': 'BR-01',
          'name': {'en': 'Main Store Warehouse', 'ar': 'المستودع الرئيسي'},
          'isActive': true,
        },
        '5f67b5e408a2fc24bc6880be': {
          '_id': '5f67b5e408a2fc24bc6880be',
          'branch_code': 'BR-02',
          'name': {'en': 'Kitchen Outlet A', 'ar': 'مطبخ أ'},
          'isActive': true,
        }
      });
    }

    if (collectionName == 'users') {
      await box.putAll({
        '5f67b5e408a2fc24bc6880bf': {
          '_id': '5f67b5e408a2fc24bc6880bf',
          'username': 'Chef John',
          'role': 'chef',
          'isActive': true,
        },
        '5f67b5e408a2fc24bc6880c0': {
          '_id': '5f67b5e408a2fc24bc6880c0',
          'username': 'Driver Sam',
          'role': 'driver',
          'isActive': true,
        }
      });
    }

    if (collectionName == 'units') {
      await box.putAll({
        '5f67b5e408a2fc24bc6880c3': {
          '_id': '5f67b5e408a2fc24bc6880c3',
          'unit_name': 'Kilograms',
          'short_name': 'kg',
          'isActive': true,
        },
        '5f67b5e408a2fc24bc6880c5': {
          '_id': '5f67b5e408a2fc24bc6880c5',
          'unit_name': 'Litres',
          'short_name': 'L',
          'isActive': true,
        }
      });
    }

    if (collectionName == 'raw_materials') {
      await box.putAll({
        '5f67b5e408a2fc24bc6880c1': {
          '_id': '5f67b5e408a2fc24bc6880c1',
          'material_code': 'RM-Milk',
          'material_name': 'Fresh Milk 1L',
          'base_unit_id': '5f67b5e408a2fc24bc6880c5',
          'tax_id': '5f67b5e408a2fc24bc6880c4',
          'purchase_rate': 2.50,
          'isActive': true,
        },
        '5f67b5e408a2fc24bc6880c2': {
          '_id': '5f67b5e408a2fc24bc6880c2',
          'material_code': 'RM-Flour',
          'material_name': 'Wheat Flour 1kg',
          'base_unit_id': '5f67b5e408a2fc24bc6880c3',
          'tax_id': '5f67b5e408a2fc24bc6880c4',
          'purchase_rate': 1.80,
          'isActive': true,
        }
      });
    }

    if (collectionName == 'raw_material_taxes') {
      await box.putAll({
        '5f67b5e408a2fc24bc6880c4': {
          '_id': '5f67b5e408a2fc24bc6880c4',
          'tax_name': 'Standard VAT',
          'tax_percent': 15.0,
          'isActive': true,
        }
      });
    }

    if (collectionName == 'vendors') {
      await box.putAll({
        '5f67b5e408a2fc24bc6880c6': {
          '_id': '5f67b5e408a2fc24bc6880c6',
          'vendor_name': 'Sysco Premium Foods',
          'contact_name': 'Alice Smith',
          'email': 'alice@sysco.com',
          'isActive': true,
        }
      });
    }

    if (collectionName == 'bill_types') {
      await box.putAll({
        '5f67b5e408a2fc24bc6880c7': {
          '_id': '5f67b5e408a2fc24bc6880c7',
          'name': 'Cash On Delivery',
          'isActive': true,
        }
      });
    }

    if (collectionName == 'stock_reasons') {
      await box.putAll({
        '5f67b5e408a2fc24bc6880c8': {
          '_id': '5f67b5e408a2fc24bc6880c8',
          'name': 'Spillage / Damage',
          'isActive': true,
        }
      });
    }
  }

  Future<List<Map<String, dynamic>>> getAll({dynamic selector}) async {
    final box = await _getBox();
    return box.values.map((val) => Map<String, dynamic>.from(val)).toList();
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final box = await _getBox();
    final val = box.get(id);
    if (val == null) return null;
    return Map<String, dynamic>.from(val);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final box = await _getBox();

    String? key;
    if (data.containsKey('_id')) {
      final rawId = data['_id'];
      key = rawId is ObjectId ? rawId.toHexString() : rawId.toString();
    } else if (data.containsKey('id')) {
      key = data['id'].toString();
    }

    if (key == null || key.isEmpty) {
      final newObjectId = ObjectId();
      key = newObjectId.toHexString();
      data['_id'] = newObjectId;
    }

    final normalized = _normalizeMap(data);
    await box.put(key, normalized);
    return data;
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    final box = await _getBox();
    if (!box.containsKey(id)) {
      return false;
    }
    final existing = Map<String, dynamic>.from(box.get(id));
    existing.addAll(data);
    final normalized = _normalizeMap(existing);
    await box.put(id, normalized);
    return true;
  }

  Future<bool> delete(String id) async {
    final box = await _getBox();
    if (!box.containsKey(id)) {
      return false;
    }
    await box.delete(id);
    return true;
  }

  dynamic _normalizeMap(dynamic item) {
    if (item is Map) {
      return item.map((key, val) => MapEntry(key.toString(), _normalizeMap(val)));
    } else if (item is List) {
      return item.map(_normalizeMap).toList();
    } else if (item is ObjectId) {
      return item.toHexString();
    }
    return item;
  }
}
