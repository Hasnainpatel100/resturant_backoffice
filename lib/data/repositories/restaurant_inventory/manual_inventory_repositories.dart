import 'package:back_office/data/models/restaurant_inventory/manual_stock_entry_model.dart';
import 'package:back_office/data/models/restaurant_inventory/manual_stock_out_model.dart';
import 'package:back_office/data/datasources/restaurant_inventory/manual_inventory_datasources.dart';

// ── 1. MANUAL STOCK ENTRY REPOSITORY ─────────────────────────────────────────
abstract class ManualStockEntryRepository {
  Future<List<ManualStockEntryModel>> getAllEntries();
  Future<ManualStockEntryModel?> getEntryById(String id);
  Future<ManualStockEntryModel> createEntry(ManualStockEntryModel entry);
  Future<bool> updateEntry(String id, ManualStockEntryModel entry);
  Future<bool> deleteEntry(String id);
}

class ManualStockEntryRepositoryImpl implements ManualStockEntryRepository {
  final ManualStockEntryMongoDataSource _dataSource = ManualStockEntryMongoDataSource();

  @override
  Future<List<ManualStockEntryModel>> getAllEntries() async {
    final list = await _dataSource.getAll();
    return list.map((map) => ManualStockEntryModel.fromMap(map)).toList();
  }

  @override
  Future<ManualStockEntryModel?> getEntryById(String id) async {
    final map = await _dataSource.getById(id);
    if (map == null) return null;
    return ManualStockEntryModel.fromMap(map);
  }

  @override
  Future<ManualStockEntryModel> createEntry(ManualStockEntryModel entry) async {
    final map = await _dataSource.create(entry.toMap()..remove('_id'));
    return ManualStockEntryModel.fromMap(map);
  }

  @override
  Future<bool> updateEntry(String id, ManualStockEntryModel entry) async {
    return await _dataSource.update(id, entry.toMap());
  }

  @override
  Future<bool> deleteEntry(String id) async {
    return await _dataSource.delete(id);
  }
}

// ── 2. MANUAL STOCK OUT REPOSITORY ──────────────────────────────────────────
abstract class ManualStockOutRepository {
  Future<List<ManualStockOutModel>> getAllOuts();
  Future<ManualStockOutModel?> getOutById(String id);
  Future<ManualStockOutModel> createOut(ManualStockOutModel out);
  Future<bool> updateOut(String id, ManualStockOutModel out);
  Future<bool> deleteOut(String id);
}

class ManualStockOutRepositoryImpl implements ManualStockOutRepository {
  final ManualStockOutMongoDataSource _dataSource = ManualStockOutMongoDataSource();

  @override
  Future<List<ManualStockOutModel>> getAllOuts() async {
    final list = await _dataSource.getAll();
    return list.map((map) => ManualStockOutModel.fromMap(map)).toList();
  }

  @override
  Future<ManualStockOutModel?> getOutById(String id) async {
    final map = await _dataSource.getById(id);
    if (map == null) return null;
    return ManualStockOutModel.fromMap(map);
  }

  @override
  Future<ManualStockOutModel> createOut(ManualStockOutModel out) async {
    final map = await _dataSource.create(out.toMap()..remove('_id'));
    return ManualStockOutModel.fromMap(map);
  }

  @override
  Future<bool> updateOut(String id, ManualStockOutModel out) async {
    return await _dataSource.update(id, out.toMap());
  }

  @override
  Future<bool> deleteOut(String id) async {
    return await _dataSource.delete(id);
  }
}
