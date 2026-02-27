import 'package:frontend/features/categories/data/models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getAll({String? search});
  Future<CategoryModel> create(String name, String? nameEn, String description);
  Future<CategoryModel> update(int id, String name, String? nameEn, String description);
  Future<void> delete(int id);
}
