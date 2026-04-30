import 'package:back_office/data/models/user_profile_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/utils/utils.dart';

abstract class UserRepository {
  FutureEither<UserProfileModel> getUser(String userId);
  FutureEither<UserProfileModel> createUser(Map<String, dynamic> data);
  FutureEither<UserProfileModel> updateUser(String userId, Map<String, dynamic> data);
  FutureEither<UserProfileModel> updateUserBranch(String userId, String branchId);
  FutureEither<void> addDocument(String userId, Map<String, dynamic> data);
  FutureEither<void> deleteUser(String userId);
  FutureEither<ListResponse<UserData>> getUsersByBrand(String brandId, {int page = 1, int limit = 20});
}
