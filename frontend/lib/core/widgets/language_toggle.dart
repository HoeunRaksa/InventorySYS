import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/localization/locale_provider.dart';
import 'package:frontend/features/categories/presentation/providers/category_provider.dart';
import 'package:frontend/features/products/presentation/providers/product_provider.dart';

class LanguageToggle extends StatelessWidget {
  final Color? color;
  const LanguageToggle({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final isKm = localeProvider.locale.languageCode == 'km';

    return TextButton(
      onPressed: () async {
        final newLocale = isKm ? const Locale('en') : const Locale('km');
        await localeProvider.setLocale(newLocale);
        
        if (context.mounted) {
          context.read<CategoryProvider>().fetchCategories();
          context.read<ProductProvider>().fetchProducts(refresh: true);
        }
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: (color ?? Colors.deepPurple).withOpacity(0.08),
      ),
      child: Text(
        isKm ? 'EN' : 'KM',
        style: TextStyle(
          color: color ?? Colors.deepPurple,
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
      ),
    );
  }
}
