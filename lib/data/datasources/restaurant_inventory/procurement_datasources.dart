import 'base_mongo_datasource.dart';

class PurchaseOrderMongoDataSource extends BaseMongoDataSource {
  PurchaseOrderMongoDataSource() : super('purchase_orders');
}

class GoodsReceiptMongoDataSource extends BaseMongoDataSource {
  GoodsReceiptMongoDataSource() : super('goods_receipts');
}

class SupplierInvoiceMongoDataSource extends BaseMongoDataSource {
  SupplierInvoiceMongoDataSource() : super('supplier_invoices');
}
