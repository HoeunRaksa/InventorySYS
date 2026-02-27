import 'package:frontend/features/categories/data/models/category_model.dart';
import 'package:frontend/features/categories/domain/repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository _repo;
  GetCategoriesUseCase(this._repo);
  Future<List<CategoryModel>> call({String? search}) => _repo.getAll(search: search);
}

class CreateCategoryUseCase {
  final CategoryRepository _repo;
  CreateCategoryUseCase(this._repo);
  Future<CategoryModel> call(String name, String? nameEn, String description) => _repo.create(name, nameEn, description);
}

class UpdateCategoryUseCase {
  final CategoryRepository _repo;
  UpdateCategoryUseCase(this._repo);
  Future<CategoryModel> call(int id, String name, String? nameEn, String description) => _repo.update(id, name, nameEn, description);
}

class DeleteCategoryUseCase {
  final CategoryRepository _repo;
  DeleteCategoryUseCase(this._repo);
  Future<void> call(int id) => _repo.delete(id);
}
