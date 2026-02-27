import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/utils/debouncer.dart';
import 'package:frontend/core/widgets/app_dialogs.dart';
import 'package:frontend/core/widgets/app_loader.dart';
import 'package:frontend/features/categories/data/models/category_model.dart';
import 'package:frontend/features/categories/presentation/providers/category_provider.dart';
import 'package:frontend/features/categories/presentation/widgets/category_tile.dart';
import 'package:frontend/core/widgets/app_text_field.dart';
import 'package:frontend/core/localization/app_translations.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _showCategoryForm([CategoryModel? category]) {
    final name = TextEditingController(text: category?.name ?? '');
    final nameEn = TextEditingController(text: category?.nameEn ?? '');
    final desc = TextEditingController(text: category?.description ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                category == null ? context.tr('new_category') : context.tr('edit_category'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: name,
                label: '${context.tr('name')} (KM)',
                icon: Icons.label_important_outline,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: nameEn,
                label: '${context.tr('name')} (EN)',
                icon: Icons.translate,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: desc,
                label: context.tr('description'),
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  if (name.text.isEmpty) return;
                  final prov = context.read<CategoryProvider>();
                  bool success;
                  if (category == null) {
                    success = await prov.createCategory(name.text, nameEn.text, desc.text);
                  } else {
                    success = await prov.updateCategory(category.id, name.text, nameEn.text, desc.text);
                  }
                  if (success && mounted) {
                    Navigator.pop(ctx);
                    AppDialogs.snack(context, context.tr('saved_successfully'));
                    prov.fetchCategories();
                  }
                },
                child: Text(context.tr('save')),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(int id, String name) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: context.tr('delete'),
      message: '${context.tr('confirm_delete')} "$name"',
    );
    if (confirmed && mounted) {
      final success = await context.read<CategoryProvider>().deleteCategory(id);
      if (success && mounted) {
        AppDialogs.snack(context, context.tr('deleted_successfully'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('categories')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppTextField(
              controller: _searchController,
              label: context.tr('search_categories'),
              icon: Icons.search,
              onChanged: (val) => _debouncer.run(() {
                context.read<CategoryProvider>().fetchCategories(search: val);
              }),
            ),
          ),
          Expanded(
            child: Consumer<CategoryProvider>(
              builder: (ctx, prov, _) {
                if (prov.isLoading && prov.categories.isEmpty) {
                  return const AppLoader();
                }
                if (prov.categories.isEmpty) {
                  return AppDialogs.emptyState(
                    title: context.tr('no_data'),
                    message: context.tr('add_category_msg'),
                    icon: Icons.category_outlined,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => prov.fetchCategories(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: prov.categories.length,
                    itemBuilder: (ctx, i) => CategoryTile(
                      category: prov.categories[i],
                      onEdit: () => _showCategoryForm(prov.categories[i]),
                      onDelete: () => _confirmDelete(prov.categories[i].id, prov.categories[i].name),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryForm(),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
