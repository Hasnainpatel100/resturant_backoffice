import 'package:back_office/data/models/inventory/item_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/utils/utils.dart';

abstract class ItemRepository {
  FutureEither<ListResponse<ItemModel>> getItems(
    String brandId, {
    int page = 1,
    int limit = 50,
    String? search,
    String? categoryId,
  });

  FutureEither<ItemModel> getItem(String brandId, String itemId);

  FutureEither<ItemModel> createItem(
    String brandId,
    Map<String, dynamic> data,
  );

  FutureEither<ItemModel> updateItem(
    String brandId,
    String itemId,
    Map<String, dynamic> data,
  );

  FutureEither<void> deleteItem(String brandId, String itemId);
}
