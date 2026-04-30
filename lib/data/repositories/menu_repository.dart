import 'package:back_office/data/models/menu_model.dart';
import 'package:back_office/data/models/api_response_model.dart';
import 'package:back_office/utils/utils.dart';

abstract class MenuRepository {
  // Categories
  FutureEither<ListResponse<CategoryModel>> createCategories(String brandId, List<Map<String, dynamic>> data);
  FutureEither<ListResponse<CategoryModel>> getCategories(String brandId, String branchId, {int page = 1, int limit = 20});
  FutureEither<CategoryModel> getCategory(String categoryId);
  FutureEither<CategoryModel> updateCategory(String categoryId, Map<String, dynamic> data);
  FutureEither<void> deleteCategory(String categoryId);

  // Menu Items
  FutureEither<ListResponse<MenuItemResponse>> createMenuItems(String brandId, List<Map<String, dynamic>> data);
  FutureEither<ListResponse<MenuItemResponse>> getMenuItems(String brandId, String branchId, {String? categoryId, int page = 1, int limit = 20});
  FutureEither<MenuItemResponse> getMenuItem(String itemId);
  FutureEither<MenuItemResponse> updateMenuItem(String itemId, Map<String, dynamic> data);
  FutureEither<MenuItemResponse> toggleAvailability(String itemId, Map<String, dynamic> data);
  FutureEither<void> deleteMenuItem(String itemId);
}