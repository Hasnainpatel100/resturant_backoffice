import 'package:back_office/data/models/brand_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/utils/utils.dart';

abstract class BrandRepository {
  FutureEither<BrandModel> getBrand(String brandId);
  FutureEither<BrandModel> createBrand(Map<String, dynamic> data);
  FutureEither<BrandModel> updateBrand(String brandId, Map<String, dynamic> data);
  FutureEither<void> deleteBrand(String brandId);
  FutureEither<ListResponse<BrandBasicModel>> getBrands({int page = 1, int limit = 20});
  FutureEither<ListResponse<Map<String, dynamic>>> getPlanHistory(String brandId, {int page = 1, int limit = 20});
}
