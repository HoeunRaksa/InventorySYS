import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/config/app_design.dart';
import 'package:frontend/core/localization/locale_provider.dart';
import '../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleProvider>().locale.languageCode;
    
    // Choose product name based on current locale
    final displayName = (lang == 'en' && product.nameEn != null && product.nameEn!.isNotEmpty) 
        ? product.nameEn! 
        : product.name;
    
    // Choose category name based on current locale
    final displayCategory = (lang == 'en' && product.categoryNameEn != null && product.categoryNameEn!.isNotEmpty)
        ? product.categoryNameEn!
        : product.categoryName;

    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppStyles.cardRadius,
        boxShadow: AppStyles.softShadow,
      ),
      child: ClipRRect(
        borderRadius: AppStyles.cardRadius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    product.imageUrl != null
                        ? Image.network(
                            ApiClient.imageUrl(product.imageUrl!),
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                height: 220,
                                color: AppColors.primaryLight,
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            },
                            errorBuilder: (ctx, url, err) => Container(
                              height: 220,
                              color: AppColors.primaryLight,
                              child: const Icon(Icons.broken_image_outlined, color: AppColors.primary, size: 40),
                            ),
                          )
                        : Container(
                            height: 220,
                            width: double.infinity,
                            color: AppColors.primaryLight,
                            child: Icon(Icons.image_outlined, size: 48, color: AppColors.primary.withOpacity(0.3)),
                          ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
                          ],
                        ),
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    displayCategory.toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const SizedBox(width: 8),
                          Material(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            child: IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 24),
                              onPressed: onEdit,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            child: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 24),
                              onPressed: onDelete,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.qr_code_rounded, size: 16, color: AppColors.textLight),
                          const SizedBox(width: 6),
                          Text(
                            product.productCode,
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
