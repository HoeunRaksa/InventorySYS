import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/config/app_design.dart';
import 'package:frontend/core/network/api_client.dart';

class ProductImagePicker extends StatelessWidget {
  final XFile? pickedImage;
  final String? existingImageUrl;
  final VoidCallback onPick;

  const ProductImagePicker({
    super.key,
    required this.pickedImage,
    this.existingImageUrl,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppStyles.cardRadius,
          border: Border.all(
            color: pickedImage == null && existingImageUrl == null 
                ? AppColors.primary.withOpacity(0.2) 
                : Colors.transparent,
            width: 2,
            style: pickedImage == null && existingImageUrl == null 
                ? BorderStyle.solid 
                : BorderStyle.none,
          ),
          boxShadow: AppStyles.softShadow,
        ),
        child: ClipRRect(
          borderRadius: AppStyles.cardRadius,
          child: pickedImage != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(pickedImage!.path), fit: BoxFit.cover),
                    _buildOverlay('Tap to Change Selection'),
                  ],
                )
              : existingImageUrl != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          ApiClient.imageUrl(existingImageUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        ),
                        _buildOverlay('Tap to Change Image'),
                      ],
                    )
                  : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primaryLight.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 20)
              ],
            ),
            child: const Icon(Icons.add_a_photo_rounded, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tap to Upload Image',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'PNG, JPG up to 10MB',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay(String label) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.transparent,
                Colors.black.withOpacity(0.4),
              ],
            ),
          ),
        ),
        const Center(
          child: Icon(Icons.sync_rounded, color: Colors.white, size: 48),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
