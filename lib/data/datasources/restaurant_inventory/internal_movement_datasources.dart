import 'base_mongo_datasource.dart';

class IndentMongoDataSource extends BaseMongoDataSource {
  IndentMongoDataSource() : super('indents');
}

class StockTransferMongoDataSource extends BaseMongoDataSource {
  StockTransferMongoDataSource() : super('stock_transfers');
}
