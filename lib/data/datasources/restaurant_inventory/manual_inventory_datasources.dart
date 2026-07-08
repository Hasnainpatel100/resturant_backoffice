import 'base_hive_datasource.dart';

class ManualStockEntryMongoDataSource extends BaseHiveDataSource {
  ManualStockEntryMongoDataSource() : super('manual_stock_entries');
}

class ManualStockOutMongoDataSource extends BaseHiveDataSource {
  ManualStockOutMongoDataSource() : super('manual_stock_outs');
}
