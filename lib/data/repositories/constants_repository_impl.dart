import 'package:back_office/config/app_config.dart';
import 'package:back_office/data/repositories/constants_repository.dart';
import 'package:back_office/utils/utils.dart';

class ConstantsRepositoryImpl implements ConstantsRepository {
  @override
  FutureEither<Map<String, dynamic>> getConstants() async {
    return runTask(() async {
      final response = await AppConfig.dio.get<Map<String, dynamic>>('/constants');
      return response.data!['data'] as Map<String, dynamic>;
    });
  }
}
