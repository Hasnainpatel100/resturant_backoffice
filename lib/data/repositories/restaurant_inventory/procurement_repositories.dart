import 'package:back_office/data/models/restaurant_inventory/purchase_order_model.dart';
import 'package:back_office/data/models/restaurant_inventory/goods_receipt_model.dart';
import 'package:back_office/data/models/restaurant_inventory/supplier_invoice_model.dart';
import 'package:back_office/data/datasources/restaurant_inventory/procurement_datasources.dart';

// ── 1. PURCHASE ORDER REPOSITORY ─────────────────────────────────────────────
abstract class PurchaseOrderRepository {
  Future<List<PurchaseOrderModel>> getAllPOs();
  Future<PurchaseOrderModel?> getPOById(String id);
  Future<PurchaseOrderModel> createPO(PurchaseOrderModel po);
  Future<bool> updatePO(String id, PurchaseOrderModel po);
  Future<bool> deletePO(String id);
}

class PurchaseOrderRepositoryImpl implements PurchaseOrderRepository {
  final PurchaseOrderMongoDataSource _dataSource = PurchaseOrderMongoDataSource();

  @override
  Future<List<PurchaseOrderModel>> getAllPOs() async {
    final list = await _dataSource.getAll();
    return list.map((map) => PurchaseOrderModel.fromMap(map)).toList();
  }

  @override
  Future<PurchaseOrderModel?> getPOById(String id) async {
    final map = await _dataSource.getById(id);
    if (map == null) return null;
    return PurchaseOrderModel.fromMap(map);
  }

  @override
  Future<PurchaseOrderModel> createPO(PurchaseOrderModel po) async {
    final map = await _dataSource.create(po.toMap()..remove('_id'));
    return PurchaseOrderModel.fromMap(map);
  }

  @override
  Future<bool> updatePO(String id, PurchaseOrderModel po) async {
    return await _dataSource.update(id, po.toMap());
  }

  @override
  Future<bool> deletePO(String id) async {
    return await _dataSource.delete(id);
  }
}

// ── 2. GOODS RECEIPT REPOSITORY ──────────────────────────────────────────────
abstract class GoodsReceiptRepository {
  Future<List<GoodsReceiptModel>> getAllGRNs();
  Future<GoodsReceiptModel?> getGRNById(String id);
  Future<GoodsReceiptModel> createGRN(GoodsReceiptModel grn);
  Future<bool> updateGRN(String id, GoodsReceiptModel grn);
  Future<bool> deleteGRN(String id);
}

class GoodsReceiptRepositoryImpl implements GoodsReceiptRepository {
  final GoodsReceiptMongoDataSource _dataSource = GoodsReceiptMongoDataSource();

  @override
  Future<List<GoodsReceiptModel>> getAllGRNs() async {
    final list = await _dataSource.getAll();
    return list.map((map) => GoodsReceiptModel.fromMap(map)).toList();
  }

  @override
  Future<GoodsReceiptModel?> getGRNById(String id) async {
    final map = await _dataSource.getById(id);
    if (map == null) return null;
    return GoodsReceiptModel.fromMap(map);
  }

  @override
  Future<GoodsReceiptModel> createGRN(GoodsReceiptModel grn) async {
    final map = await _dataSource.create(grn.toMap()..remove('_id'));
    return GoodsReceiptModel.fromMap(map);
  }

  @override
  Future<bool> updateGRN(String id, GoodsReceiptModel grn) async {
    return await _dataSource.update(id, grn.toMap());
  }

  @override
  Future<bool> deleteGRN(String id) async {
    return await _dataSource.delete(id);
  }
}

// ── 3. SUPPLIER INVOICE REPOSITORY ───────────────────────────────────────────
abstract class SupplierInvoiceRepository {
  Future<List<SupplierInvoiceModel>> getAllInvoices();
  Future<SupplierInvoiceModel?> getInvoiceById(String id);
  Future<SupplierInvoiceModel> createInvoice(SupplierInvoiceModel invoice);
  Future<bool> updateInvoice(String id, SupplierInvoiceModel invoice);
  Future<bool> deleteInvoice(String id);
}

class SupplierInvoiceRepositoryImpl implements SupplierInvoiceRepository {
  final SupplierInvoiceMongoDataSource _dataSource = SupplierInvoiceMongoDataSource();

  @override
  Future<List<SupplierInvoiceModel>> getAllInvoices() async {
    final list = await _dataSource.getAll();
    return list.map((map) => SupplierInvoiceModel.fromMap(map)).toList();
  }

  @override
  Future<SupplierInvoiceModel?> getInvoiceById(String id) async {
    final map = await _dataSource.getById(id);
    if (map == null) return null;
    return SupplierInvoiceModel.fromMap(map);
  }

  @override
  Future<SupplierInvoiceModel> createInvoice(SupplierInvoiceModel invoice) async {
    final map = await _dataSource.create(invoice.toMap()..remove('_id'));
    return SupplierInvoiceModel.fromMap(map);
  }

  @override
  Future<bool> updateInvoice(String id, SupplierInvoiceModel invoice) async {
    return await _dataSource.update(id, invoice.toMap());
  }

  @override
  Future<bool> deleteInvoice(String id) async {
    return await _dataSource.delete(id);
  }
}
