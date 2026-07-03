import 'package:back_office/data/models/inventory/unit_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/utils/utils.dart';

abstract class UnitRepository {
  FutureEither<ListResponse<UnitModel>> getUnits(
    String brandId, {
    int page = 1,
    int limit = 50,
  });

  FutureEither<UnitModel> getUnit(String brandId, String unitId);

  FutureEither<UnitModel> createUnit(
    String brandId,
    Map<String, dynamic> data,
  );

  FutureEither<UnitModel> updateUnit(
    String brandId,
    String unitId,
    Map<String, dynamic> data,
  );

  FutureEither<void> deleteUnit(String brandId, String unitId);
}
