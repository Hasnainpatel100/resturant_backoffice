import 'base_mongo_datasource.dart';

class ManualStockEntryMongoDataSource extends BaseMongoDataSource {
  ManualStockEntryMongoDataSource() : super('manual_stock_entries');
}

class ManualStockOutMongoDataSource extends BaseMongoDataSource {
  ManualStockOutMongoDataSource() : super('manual_stock_outs');
}
