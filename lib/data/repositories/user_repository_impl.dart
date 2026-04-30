import 'package:back_office/config/app_config.dart';
import 'package:back_office/data/models/user_profile_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/data/repositories/user_repository.dart';
import 'package:back_office/utils/utils.dart';

class UserRepositoryImpl implements UserRepository {
  @override
  FutureEither<UserProfileModel> getUser(String userId) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>('/api/users/$userId');
      final data = response.data!['data'] as Map<String, dynamic>;
      return UserProfileModel.fromJson(data);
    });
  }

  @override
  FutureEither<UserProfileModel> createUser(Map<String, dynamic> data) async {
    return runTask(() async {
      final response = await AppConfig.dio.post<Map<String, dynamic>>('/api/users/create', data: data);
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return UserProfileModel.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<UserProfileModel> updateUser(String userId, Map<String, dynamic> data) async {
    return runTask(() async {
      final response = await AppConfig.dio.put<Map<String, dynamic>>('/api/users/$userId', data: data);
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return UserProfileModel.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<UserProfileModel> updateUserBranch(String userId, String branchId) async {
    return runTask(() async {
      final response = await AppConfig.dio.put<Map<String, dynamic>>(
        '/api/users/$userId/branch/$branchId',
      );
      final responseData = response.data!['data'] as Map<String, dynamic>;
      return UserProfileModel.fromJson(responseData);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<void> addDocument(String userId, Map<String, dynamic> data) async {
    return runTask(() async {
      await AppConfig.dio.post<void>('/api/users/add-document', data: data);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<void> deleteUser(String userId) async {
    return runTask(() async {
      await AppConfig.dio.delete<void>('/api/users/$userId');
    }, requiresNetwork: true);
  }

  @override
  FutureEither<ListResponse<UserData>> getUsersByBrand(String brandId, {int page = 1, int limit = 20}) async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>(
        '/api/users',
        queryParameters: {'brandId': brandId, 'page': page, 'limit': limit},
      );
      return ListResponse<UserData>.fromJson(
        response.data!,
        (json) => UserData.fromJson(json),
      );
    });
  }
}
