import 'base_mongo_datasource.dart';

class LocationMongoDataSource extends BaseMongoDataSource {
  LocationMongoDataSource() : super('locations');
}

class UnitMongoDataSource extends BaseMongoDataSource {
  UnitMongoDataSource() : super('units');
}

class RawMaterialGroupMongoDataSource extends BaseMongoDataSource {
  RawMaterialGroupMongoDataSource() : super('raw_material_groups');
}

class RawMaterialTaxMongoDataSource extends BaseMongoDataSource {
  RawMaterialTaxMongoDataSource() : super('raw_material_taxes');
}

class RawMaterialMongoDataSource extends BaseMongoDataSource {
  RawMaterialMongoDataSource() : super('raw_materials');
}

class VendorMongoDataSource extends BaseMongoDataSource {
  VendorMongoDataSource() : super('vendors');
}

class BillTypeMongoDataSource extends BaseMongoDataSource {
  BillTypeMongoDataSource() : super('bill_types');
}

class StockReasonMongoDataSource extends BaseMongoDataSource {
  StockReasonMongoDataSource() : super('stock_reasons');
}

class BranchMongoDataSource extends BaseMongoDataSource {
  BranchMongoDataSource() : super('branches');
}

class UserMongoDataSource extends BaseMongoDataSource {
  UserMongoDataSource() : super('users');
}
