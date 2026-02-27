import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_dialogs.dart';
import 'package:frontend/core/widgets/app_text_field.dart';
import 'package:frontend/features/categories/presentation/providers/category_provider.dart';
import 'package:frontend/features/products/data/repositories/product_repository_impl.dart';
import 'package:frontend/features/products/data/sources/product_remote_source.dart';
import 'package:frontend/features/products/domain/usecases/product_usecases.dart';
import 'package:frontend/features/products/presentation/providers/product_provider.dart';
import 'package:frontend/features/products/presentation/widgets/product_image_picker.dart';
import 'package:frontend/core/localization/app_translations.dart';
import 'package:frontend/core/localization/locale_provider.dart';

import 'package:frontend/features/products/data/models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? product;
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _name = TextEditingController(); // Khmer
  final _nameEn = TextEditingController(); // English
  final _desc = TextEditingController();
  final _price = TextEditingController();
  int? _categoryId;
  XFile? _pickedImage;
  bool _loading = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final p = widget.product!;
      _code.text = p.productCode;
      _name.text = p.name;
      _nameEn.text = p.nameEn ?? '';
      _desc.text = p.description;
      _price.text = p.price.toString();
      _categoryId = p.categoryId;
    }
    Future.microtask(() {
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _nameEn.dispose();
    _desc.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      AppDialogs.snack(context, context.tr('select_category'), isError: true);
      return;
    }
    if (!_isEdit && _pickedImage == null) {
      AppDialogs.snack(context, context.tr('select_image'), isError: true);
      return;
    }

    setState(() => _loading = true);
    final provider = context.read<ProductProvider>();
    
    try {
      bool success;
      if (_isEdit) {
        success = await provider.updateProduct(
          id: widget.product!.id,
          productCode: _code.text.trim(),
          name: _name.text.trim(),
          nameEn: _nameEn.text.trim(),
          description: _desc.text.trim(),
          price: double.parse(_price.text.trim()),
          categoryId: _categoryId!,
          imagePath: _pickedImage?.path,
          imageName: _pickedImage?.name,
          existingImageUrl: widget.product!.imageUrl,
        );
      } else {
        final createUseCase = CreateProductWithImageUseCase(ProductRepositoryImpl(ProductRemoteSource()));
        await createUseCase(
          productCode: _code.text.trim(),
          name: _name.text.trim(),
          nameEn: _nameEn.text.trim(),
          description: _desc.text.trim(),
          price: double.parse(_price.text.trim()),
          categoryId: _categoryId!,
          imagePath: _pickedImage!.path,
          imageName: _pickedImage!.name,
        );
        success = true;
        provider.fetchProducts(refresh: true);
      }

      if (mounted && success) {
        AppDialogs.snack(context, context.tr('saved_successfully'));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) AppDialogs.snack(context, e.toString(), isError: true);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    final lang = context.watch<LocaleProvider>().locale.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Product' : context.tr('add_new'))),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProductImagePicker(
                    pickedImage: _pickedImage,
                    existingImageUrl: _isEdit ? widget.product!.imageUrl : null,
                    onPick: () async {
                      final img = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (img != null) setState(() => _pickedImage = img);
                    },
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _code,
                          label: context.tr('product_code'),
                          icon: Icons.qr_code,
                          validator: Validators.required,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _name,
                          label: '${context.tr('name')} (KM)',
                          icon: Icons.label_important_outline,
                          validator: Validators.required,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _nameEn,
                          label: '${context.tr('name')} (EN)',
                          icon: Icons.translate,
                          validator: Validators.required,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _desc,
                          label: context.tr('description'),
                          icon: Icons.notes,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _price,
                          label: '${context.tr('price')} (\$)',
                          icon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                          validator: Validators.number,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          value: _categoryId,
                          decoration: InputDecoration(
                            labelText: context.tr('category'),
                            prefixIcon: const Icon(Icons.category, size: 20),
                          ),
                          items: categories.map((c) {
                            final catName =
                                (lang == 'en' &&
                                    c.nameEn != null &&
                                    c.nameEn!.isNotEmpty)
                                ? c.nameEn!
                                : c.name;
                            return DropdownMenuItem(
                              value: c.id,
                              child: Text(
                                catName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _categoryId = v),
                          validator: (v) =>
                               v == null ? context.tr('select_category') : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    label: context.tr('save'),
                    onPressed: _submit,
                    isLoading: _loading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
