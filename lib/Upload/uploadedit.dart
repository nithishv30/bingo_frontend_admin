import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Api/product_api_service.dart';

class UploadEdit extends StatefulWidget {
  final String token;

  const UploadEdit({
    super.key,
    required this.token,
  });

  @override
  State<UploadEdit> createState() => _UploadEditState();
}

class _UploadEditState extends State<UploadEdit> {
  final barcodeController = TextEditingController();

  final mainCategoryController = TextEditingController();
  final subCategoryController = TextEditingController();
  final actualPriceController = TextEditingController();
  final currentPriceController = TextEditingController();
  final moreInfoController = TextEditingController();
  final nameController = TextEditingController();
  final reviewController = TextEditingController();
  final availabilityController = TextEditingController();
  final stockSizeController = TextEditingController();
  final descriptionController = TextEditingController();

  File? selectedImage;
  String? oldImagePath;
  int? productId;

  bool isSearching = false;
  bool isUpdating = false;

  @override
  void dispose() {
    barcodeController.dispose();
    mainCategoryController.dispose();
    subCategoryController.dispose();
    actualPriceController.dispose();
    currentPriceController.dispose();
    moreInfoController.dispose();
    nameController.dispose();
    reviewController.dispose();
    availabilityController.dispose();
    stockSizeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  String formatPrice(dynamic value) {
    if (value == null) return '';

    final number = double.tryParse(value.toString());
    if (number == null) return value.toString();

    if (number % 1 == 0) {
      return number.toInt().toString();
    }

    return number.toString();
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<void> searchProduct() async {
    final barcode = barcodeController.text.trim();

    if (barcode.isEmpty) {
      showMessage('Enter barcode');
      return;
    }

    try {
      setState(() => isSearching = true);

      final result = await ProductApiService.getProductByBarcode(
        barcode: barcode,
      );

      if (!mounted) return;

      setState(() {
        productId = result['id'];

        mainCategoryController.text = result['main_category'] ?? '';
        subCategoryController.text = result['sub_category'] ?? '';
        actualPriceController.text = formatPrice(result['actual_price']);
        currentPriceController.text = formatPrice(result['current_price']);
        moreInfoController.text = result['more_info'] ?? '';
        nameController.text = result['name'] ?? '';
        reviewController.text = result['review'] ?? '';
        availabilityController.text = result['availability'] ?? '';
        stockSizeController.text = result['stock_size'] ?? '';
        descriptionController.text = result['description'] ?? '';

        oldImagePath = result['image'];
        selectedImage = null;
      });
    } catch (e) {
      showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => isSearching = false);
      }
    }
  }

  bool validateForm() {
    if (productId == null) {
      showMessage('Search product first');
      return false;
    }

    if (mainCategoryController.text.trim().isEmpty) {
      showMessage('Main category is required');
      return false;
    }

    if (subCategoryController.text.trim().isEmpty) {
      showMessage('Sub category is required');
      return false;
    }

    if (actualPriceController.text.trim().isEmpty) {
      showMessage('Actual price is required');
      return false;
    }

    if (currentPriceController.text.trim().isEmpty) {
      showMessage('Current price is required');
      return false;
    }

    if (double.tryParse(actualPriceController.text.trim()) == null) {
      showMessage('Actual price must be number');
      return false;
    }

    if (double.tryParse(currentPriceController.text.trim()) == null) {
      showMessage('Current price must be number');
      return false;
    }

    if (nameController.text.trim().isEmpty) {
      showMessage('Product name is required');
      return false;
    }

    if (stockSizeController.text.trim().isEmpty) {
      showMessage('Stock size is required');
      return false;
    }

    return true;
  }

  Future<void> updateProductData() async {
    if (!validateForm()) return;

    try {
      setState(() => isUpdating = true);

      final result = await ProductApiService.updateProduct(
        token: widget.token,
        id: productId!,
        mainCategory: mainCategoryController.text.trim(),
        subCategory: subCategoryController.text.trim(),
        actualPrice: actualPriceController.text.trim(),
        currentPrice: currentPriceController.text.trim(),
        moreInfo: moreInfoController.text.trim(),
        name: nameController.text.trim(),
        imageFile: selectedImage,
        review: reviewController.text.trim(),
        availability: availabilityController.text.trim().isEmpty
            ? 'Yes'
            : availabilityController.text.trim(),
        stockSize: stockSizeController.text.trim(),
        description: descriptionController.text.trim(),
      );

      showMessage('Updated: ${result['name'] ?? 'Success'}');
    } catch (e) {
      showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => isUpdating = false);
      }
    }
  }

  Widget inputField(
      String label,
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String getImageUrl() {
    if (oldImagePath == null || oldImagePath!.isEmpty) return '';

    if (oldImagePath!.startsWith('http')) {
      return oldImagePath!;
    }

    return '${ProductApiService.baseUrl}$oldImagePath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f7f7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: barcodeController,
                decoration: InputDecoration(
                  labelText: 'Enter Barcode',
                  prefixIcon: const Icon(Icons.qr_code),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: isSearching ? null : searchProduct,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isSearching ? null : searchProduct,
                  child: isSearching
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Search'),
                ),
              ),

              const SizedBox(height: 20),

              if (productId != null) ...[
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                        : oldImagePath != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        getImageUrl(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text('Image not found'),
                          );
                        },
                      ),
                    )
                        : const Center(
                      child: Text('Select Image'),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                inputField('Main Category', mainCategoryController),
                inputField('Sub Category', subCategoryController),
                inputField(
                  'Actual Price',
                  actualPriceController,
                  keyboardType: TextInputType.number,
                ),
                inputField(
                  'Current Price',
                  currentPriceController,
                  keyboardType: TextInputType.number,
                ),
                inputField('More Info', moreInfoController),
                inputField('Product Name', nameController),
                inputField('Review', reviewController),
                inputField('Availability', availabilityController),
                inputField('Stock Size', stockSizeController),
                inputField(
                  'Description',
                  descriptionController,
                  maxLines: 3,
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isUpdating ? null : updateProductData,
                    child: isUpdating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Update'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}