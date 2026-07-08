import 'base_hive_datasource.dart';

class PurchaseOrderMongoDataSource extends BaseHiveDataSource {
  PurchaseOrderMongoDataSource() : super('purchase_orders');
}

class GoodsReceiptMongoDataSource extends BaseHiveDataSource {
  GoodsReceiptMongoDataSource() : super('goods_receipts');
}

class SupplierInvoiceMongoDataSource extends BaseHiveDataSource {
  SupplierInvoiceMongoDataSource() : super('supplier_invoices');
}
