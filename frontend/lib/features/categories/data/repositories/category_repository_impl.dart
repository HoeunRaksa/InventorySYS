import 'package:frontend/features/categories/data/models/category_model.dart';
import 'package:frontend/features/categories/data/sources/category_remote_source.dart';
import 'package:frontend/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteSource _source;
  CategoryRepositoryImpl(this._source);

  @override Future<List<CategoryModel>> getAll({String? search}) => _source.getAll(search: search);
  @override Future<CategoryModel> create(String name, String? nameEn, String description) => _source.create(name, nameEn, description);
  @override Future<CategoryModel> update(int id, String name, String? nameEn, String description) => _source.update(id, name, nameEn, description);
  @override Future<void> delete(int id) => _source.delete(id);
}
