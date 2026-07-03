import 'package:back_office/data/models/inventory/inventory_category_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/utils/utils.dart';

abstract class CategoryRepository {
  FutureEither<ListResponse<InventoryCategoryModel>> getCategories(
    String brandId, {
    int page = 1,
    int limit = 50,
  });

  FutureEither<InventoryCategoryModel> getCategory(
    String brandId,
    String categoryId,
  );

  FutureEither<InventoryCategoryModel> createCategory(
    String brandId,
    Map<String, dynamic> data,
  );

  FutureEither<InventoryCategoryModel> updateCategory(
    String brandId,
    String categoryId,
    Map<String, dynamic> data,
  );

  FutureEither<void> deleteCategory(String brandId, String categoryId);
}
