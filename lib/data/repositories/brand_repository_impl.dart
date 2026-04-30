import 'package:back_office/config/app_config.dart';
import 'package:back_office/data/models/brand_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/repositories/brand_repository.dart';
import 'package:back_office/utils/utils.dart';

class BrandRepositoryImpl implements BrandRepository {
  @override
  FutureEither<BrandModel> getBrand(String brandId) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>('/api/brands/$brandId');
      final data = response.data!['data'] as Map<String, dynamic>;
      return BrandModel.fromJson(data);
    });
  }

  @override
  FutureEither<BrandModel> createBrand(Map<String, dynamic> data) async {
    return runTask(() async {
      final response = await AppConfig.dio.post<Map<String, dynamic>>('/api/brands', data: data);
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return BrandModel.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<BrandModel> updateBrand(String brandId, Map<String, dynamic> data) async {
    return runTask(() async {
      final response = await AppConfig.dio.put<Map<String, dynamic>>('/api/brands/$brandId', data: data);
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return BrandModel.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<void> deleteBrand(String brandId) async {
    return runTask(() async {
      await AppConfig.dio.delete<void>('/api/brands/$brandId');
    }, requiresNetwork: true);
  }

  @override
  FutureEither<ListResponse<BrandBasicModel>> getBrands({int page = 1, int limit = 20}) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/brands',
        queryParameters: {'page': page, 'limit': limit},
      );
      return ListResponse<BrandBasicModel>.fromJson(
        response.data!,
        (json) => BrandBasicModel.fromJson(json),
      );
    });
  }

  @override
  FutureEither<ListResponse<Map<String, dynamic>>> getPlanHistory(String brandId, {int page = 1, int limit = 20}) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/brands/$brandId/plan-history',
        queryParameters: {'page': page, 'limit': limit},
      );
      return ListResponse<Map<String, dynamic>>.fromJson(
        response.data!,
        (json) => json,
      );
    });
  }
}
