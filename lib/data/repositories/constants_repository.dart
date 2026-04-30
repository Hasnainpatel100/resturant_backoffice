import 'package:back_office/utils/utils.dart';

abstract class ConstantsRepository {
  FutureEither<Map<String, dynamic>> getConstants();
}
