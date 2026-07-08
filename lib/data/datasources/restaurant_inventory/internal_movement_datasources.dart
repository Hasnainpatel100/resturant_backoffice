import 'base_hive_datasource.dart';

class IndentMongoDataSource extends BaseHiveDataSource {
  IndentMongoDataSource() : super('indents');
}

class StockTransferMongoDataSource extends BaseHiveDataSource {
  StockTransferMongoDataSource() : super('stock_transfers');
}
