import 'package:flutter/material.dart';
import 'package:frontend/features/products/presentation/screens/product_list_screen.dart';
import 'package:frontend/features/products/presentation/screens/add_product_screen.dart';
import 'package:frontend/features/categories/presentation/screens/category_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String products   = '/products';
  static const String addProduct = '/add-product';
  static const String categories = '/categories';

  static Map<String, WidgetBuilder> get routes => {
    products:   (_) => const ProductListScreen(),
    addProduct: (_) => const AddProductScreen(),
    categories: (_) => const CategoryScreen(),
  };
}
