import 'package:back_office/data/models/restaurant_inventory/indent_model.dart';
import 'package:back_office/data/models/restaurant_inventory/stock_transfer_model.dart';
import 'package:back_office/data/datasources/restaurant_inventory/internal_movement_datasources.dart';

// ── INDENT REPOSITORY ────────────────────────────────────────────────────────
abstract class IndentRepository {
  Future<List<IndentModel>> getAllIndents();
  Future<IndentModel?> getIndentById(String id);
  Future<IndentModel> createIndent(IndentModel indent);
  Future<bool> updateIndent(String id, IndentModel indent);
  Future<bool> deleteIndent(String id);
}

class IndentRepositoryImpl implements IndentRepository {
  final IndentMongoDataSource _dataSource = IndentMongoDataSource();

  @override
  Future<List<IndentModel>> getAllIndents() async {
    final list = await _dataSource.getAll();
    return list.map((map) => IndentModel.fromMap(map)).toList();
  }

  @override
  Future<IndentModel?> getIndentById(String id) async {
    final map = await _dataSource.getById(id);
    if (map == null) return null;
    return IndentModel.fromMap(map);
  }

  @override
  Future<IndentModel> createIndent(IndentModel indent) async {
    final map = await _dataSource.create(indent.toMap()..remove('_id'));
    return IndentModel.fromMap(map);
  }

  @override
  Future<bool> updateIndent(String id, IndentModel indent) async {
    return await _dataSource.update(id, indent.toMap());
  }

  @override
  Future<bool> deleteIndent(String id) async {
    return await _dataSource.delete(id);
  }
}

// ── STOCK TRANSFER REPOSITORY ────────────────────────────────────────────────
abstract class StockTransferRepository {
  Future<List<StockTransferModel>> getAllTransfers();
  Future<StockTransferModel?> getTransferById(String id);
  Future<StockTransferModel> createTransfer(StockTransferModel transfer);
  Future<bool> updateTransfer(String id, StockTransferModel transfer);
  Future<bool> deleteTransfer(String id);
}

class StockTransferRepositoryImpl implements StockTransferRepository {
  final StockTransferMongoDataSource _dataSource = StockTransferMongoDataSource();

  @override
  Future<List<StockTransferModel>> getAllTransfers() async {
    final list = await _dataSource.getAll();
    return list.map((map) => StockTransferModel.fromMap(map)).toList();
  }

  @override
  Future<StockTransferModel?> getTransferById(String id) async {
    final map = await _dataSource.getById(id);
    if (map == null) return null;
    return StockTransferModel.fromMap(map);
  }

  @override
  Future<StockTransferModel> createTransfer(StockTransferModel transfer) async {
    final map = await _dataSource.create(transfer.toMap()..remove('_id'));
    return StockTransferModel.fromMap(map);
  }

  @override
  Future<bool> updateTransfer(String id, StockTransferModel transfer) async {
    return await _dataSource.update(id, transfer.toMap());
  }

  @override
  Future<bool> deleteTransfer(String id) async {
    return await _dataSource.delete(id);
  }
}
