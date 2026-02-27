import 'package:flutter/material.dart';
import 'package:frontend/features/categories/data/models/category_model.dart';
import 'package:frontend/features/categories/data/repositories/category_repository_impl.dart';
import 'package:frontend/features/categories/data/sources/category_remote_source.dart';
import 'package:frontend/features/categories/domain/usecases/category_usecases.dart';

class CategoryProvider with ChangeNotifier {
  late final GetCategoriesUseCase    _getAll;
  late final CreateCategoryUseCase   _create;
  late final UpdateCategoryUseCase   _update;
  late final DeleteCategoryUseCase   _delete;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CategoryProvider() {
    final repo = CategoryRepositoryImpl(CategoryRemoteSource());
    _getAll = GetCategoriesUseCase(repo);
    _create = CreateCategoryUseCase(repo);
    _update = UpdateCategoryUseCase(repo);
    _delete = DeleteCategoryUseCase(repo);
  }

  Future<void> fetchCategories({String? search}) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      _categories = await _getAll(search: search);
    } catch (e) {
      _error = e.toString();
      debugPrint('CategoryProvider: $e');
    }
    _isLoading = false; notifyListeners();
  }

  Future<bool> createCategory(String name, String? nameEn, String description) async {
    try {
      final cat = await _create(name, nameEn, description);
      _categories = [cat, ..._categories];
      notifyListeners(); return true;
    } catch (e) { debugPrint('createCategory: $e'); return false; }
  }

  Future<bool> updateCategory(int id, String name, String? nameEn, String description) async {
    try {
      final updated = await _update(id, name, nameEn, description);
      _categories = _categories.map((c) => c.id == id ? updated : c).toList();
      notifyListeners(); return true;
    } catch (e) { debugPrint('updateCategory: $e'); return false; }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      await _delete(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners(); return true;
    } catch (e) { debugPrint('deleteCategory: $e'); return false; }
  }
}
