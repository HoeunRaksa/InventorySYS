import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/localization/app_translations.dart';
import 'package:frontend/core/localization/locale_provider.dart';
import 'package:frontend/config/app_design.dart';
import 'package:frontend/core/utils/responsive.dart';
import 'package:frontend/features/categories/data/models/category_model.dart';

class ProductFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final int? selectedCategoryId;
  final String sortBy;
  final List<CategoryModel> categories;
  final ValueChanged<String> onSearch;
  final ValueChanged<int?> onCategoryChanged;
  final ValueChanged<String> onSortChanged;

  const ProductFilterBar({
    super.key,
    required this.searchController,
    required this.selectedCategoryId,
    required this.sortBy,
    required this.categories,
    required this.onSearch,
    required this.onCategoryChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleProvider>().locale.languageCode;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppStyles.inputRadius,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearch,
                    decoration: InputDecoration(
                      hintText: context.tr('search_hint'),
                      hintStyle: const TextStyle(color: AppColors.textLight),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showSortOptions(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppStyles.inputRadius,
                  ),
                  child: const Icon(Icons.tune_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (Responsive.isDesktop(context))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _CategoryChip(
                  label: context.tr('all'),
                  selected: selectedCategoryId == null,
                  onTap: () => onCategoryChanged(null),
                ),
                ...categories.map((cat) {
                  final catName = (lang == 'en' && cat.nameEn != null && cat.nameEn!.isNotEmpty) ? cat.nameEn! : cat.name;
                  return _CategoryChip(
                    label: catName,
                    selected: selectedCategoryId == cat.id,
                    onTap: () => onCategoryChanged(cat.id),
                  );
                }).toList(),
              ],
            ),
          )
        else
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length + 1,
              itemBuilder: (ctx, i) {
                if (i == 0) {
                  return _CategoryChip(
                    label: context.tr('all'),
                    selected: selectedCategoryId == null,
                    onTap: () => onCategoryChanged(null),
                  );
                }
                final cat = categories[i - 1];
                final catName = (lang == 'en' && cat.nameEn != null && cat.nameEn!.isNotEmpty) ? cat.nameEn! : cat.name;
                return _CategoryChip(
                  label: catName,
                  selected: selectedCategoryId == cat.id,
                  onTap: () => onCategoryChanged(cat.id),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('sort_by'), style: AppStyles.title),
            const SizedBox(height: 20),
            _SortTile(label: context.tr('newest'), value: 'id', groupValue: sortBy, onChanged: onSortChanged),
            _SortTile(label: context.tr('price_l_h'), value: 'price_asc', groupValue: sortBy, onChanged: onSortChanged),
            _SortTile(label: context.tr('price_h_l'), value: 'price_desc', groupValue: sortBy, onChanged: onSortChanged),
            _SortTile(label: context.tr('name_a_z'), value: 'name_asc', groupValue: sortBy, onChanged: onSortChanged),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textPrimary,
          fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
        ),
        backgroundColor: Colors.white,
        side: BorderSide(color: selected ? AppColors.primary : Colors.black12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

class _SortTile extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _SortTile({required this.label, required this.value, required this.groupValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return ListTile(
      onTap: () {
        onChanged(value);
        Navigator.pop(context);
      },
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          selected ? Icons.check_rounded : Icons.sort_rounded,
          color: selected ? AppColors.primary : AppColors.textLight,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
          color: selected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
    );
  }
}
