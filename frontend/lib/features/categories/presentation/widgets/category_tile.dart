import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/categories/data/models/category_model.dart';
import 'package:frontend/core/localization/app_translations.dart';
import 'package:frontend/core/localization/locale_provider.dart';

class CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryTile({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleProvider>().locale.languageCode;
    final name = (lang == 'en' && category.nameEn != null && category.nameEn!.isNotEmpty) 
        ? category.nameEn! 
        : category.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.label_important_rounded, color: Colors.deepPurple, size: 20),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
        subtitle: Text(
          category.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(children: [const Icon(Icons.edit_outlined, size: 20), const SizedBox(width: 8), Text(context.tr('edit'))]),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(children: [const Icon(Icons.delete_outline, size: 20, color: Colors.red), const SizedBox(width: 8), Text(context.tr('delete'), style: const TextStyle(color: Colors.red))]),
            ),
          ],
        ),
      ),
    );
  }
}
