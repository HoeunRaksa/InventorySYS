import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/utils/debouncer.dart';
import 'package:frontend/core/widgets/app_dialogs.dart';
import 'package:frontend/core/widgets/app_loader.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/categories/presentation/providers/category_provider.dart';
import 'package:frontend/features/products/presentation/providers/product_provider.dart';
import 'package:frontend/features/products/presentation/widgets/product_card.dart';
import 'package:frontend/features/products/presentation/widgets/product_filter_bar.dart';
import 'add_product_screen.dart';
import 'package:frontend/features/categories/presentation/screens/category_screen.dart';
import 'package:frontend/core/localization/app_translations.dart';
import 'package:frontend/core/widgets/language_toggle.dart';
import 'package:frontend/config/app_design.dart';
import 'package:frontend/core/utils/responsive.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);

  int? _selectedCategoryId;
  String _sortBy = 'id';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductProvider>().fetchProducts(refresh: true);
      context.read<CategoryProvider>().fetchCategories();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<ProductProvider>().fetchProducts(
              search: _searchController.text,
              sortBy: _sortBy,
              categoryId: _selectedCategoryId,
            );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    context.read<ProductProvider>().fetchProducts(
          refresh: true,
          search: _searchController.text,
          sortBy: _sortBy,
          categoryId: _selectedCategoryId,
        );
  }

  void _confirmDelete(int id) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: context.tr('delete'),
      message: context.tr('confirm_delete'),
    );
    if (confirmed && mounted) {
      await context.read<ProductProvider>().deleteProduct(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsProv = context.watch<ProductProvider>();
    final categoriesProv = context.watch<CategoryProvider>();

    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);
    
    int crossAxisCount = 1;
    double childAspectRatio = 0.85; // Default for mobile list-like cards

    if (isTablet) {
      crossAxisCount = 2;
      childAspectRatio = 0.9;
    } else if (Responsive.isDesktop(context)) {
      crossAxisCount = 4;
      childAspectRatio = 0.85;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140.0,
            backgroundColor: AppColors.background,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('app_title'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    'Live Inventory Manager',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            actions: [
              const LanguageToggle(),
              IconButton(
                icon: const Icon(Icons.category_outlined, color: AppColors.primary),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                onPressed: () => context.read<AuthProvider>().logout(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            sliver: SliverToBoxAdapter(
              child: ProductFilterBar(
                searchController: _searchController,
                selectedCategoryId: _selectedCategoryId,
                sortBy: _sortBy,
                categories: categoriesProv.categories,
                onSearch: (v) => _debouncer.run(_onFilterChanged),
                onCategoryChanged: (id) {
                  setState(() => _selectedCategoryId = id);
                  _onFilterChanged();
                },
                onSortChanged: (sort) {
                  setState(() => _sortBy = sort);
                  _onFilterChanged();
                },
              ),
            ),
          ),
          if (productsProv.isLoading && productsProv.products.isEmpty)
            const SliverFillRemaining(child: Center(child: AppLoader()))
          else if (productsProv.products.isEmpty)
            SliverFillRemaining(
              child: AppDialogs.emptyState(
                title: context.tr('no_data'),
                message: context.tr('search_hint'),
                icon: Icons.inventory_2_outlined,
                onReset: () {
                  _searchController.clear();
                  setState(() {
                    _selectedCategoryId = null;
                    _sortBy = 'id';
                  });
                  _onFilterChanged();
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(top: 10, bottom: 100),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    if (i == productsProv.products.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final p = productsProv.products[i];
                    return ProductCard(
                      product: p,
                      onDelete: () => _confirmDelete(p.id),
                      onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddProductScreen(product: p)),
                      ),
                      onTap: () {},
                    );
                  },
                  childCount: productsProv.products.length + (productsProv.hasMore ? 1 : 0),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())),
        backgroundColor: AppColors.primary,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        label: Text(context.tr('new_item'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        icon: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
