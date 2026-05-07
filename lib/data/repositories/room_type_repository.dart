import 'package:back_office/data/models/room_type_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/utils/utils.dart';

abstract class RoomTypeRepository {
  FutureEither<ListResponse<RoomTypeModel>> createRoomTypes(String brandId, List<Map<String, dynamic>> data);
  FutureEither<ListResponse<RoomTypeModel>> getRoomTypes(String brandId, String branchId, {int page = 1, int limit = 20});
  FutureEither<RoomTypeModel> getRoomType(String roomTypeId);
  FutureEither<RoomTypeModel> updateRoomType(String roomTypeId, Map<String, dynamic> data);
  FutureEither<void> deleteRoomType(String roomTypeId, {required String brandId, required String branchId});
}
