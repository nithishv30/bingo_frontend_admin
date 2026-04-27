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

  String formatPrice(dynamic value) {
    if (value == null) return '';

    final number = double.tryParse(value.toString());

    if (number == null) return value.toString();

    if (number % 1 == 0) {
      return number.toInt().toString();
    }

    return number.toString();
  }

  final barcodeController = TextEditingController();

  final mainCategoryController = TextEditingController();
  final subCategoryController = TextEditingController();
  final actualPriceController = TextEditingController();
  final currentPriceController = TextEditingController();
  final quantityController = TextEditingController();
  final nameController = TextEditingController();
  final reviewController = TextEditingController();
  final availabilityController = TextEditingController();
  final stockSizeController = TextEditingController();

  File? selectedImage;
  String? oldImagePath;
  int? productId;

  bool isSearching = false;
  bool isUpdating = false;

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
    if (barcodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter barcode')),
      );
      return;
    }

    try {
      setState(() {
        isSearching = true;
      });

      final result = await ProductApiService.getProductByBarcode(
        barcode: barcodeController.text.trim(),
      );

      setState(() {
        productId = result['id'];

        mainCategoryController.text = result['main_category'] ?? '';
        subCategoryController.text = result['sub_category'] ?? '';
        actualPriceController.text = formatPrice(result['actual_price']);
        currentPriceController.text = formatPrice(result['current_price']);
        quantityController.text = result['quantity'].toString();
        nameController.text = result['name'] ?? '';
        reviewController.text = result['review'] ?? '';
        availabilityController.text = result['availability'] ?? '';
        stockSizeController.text = result['stock_size'] ?? '';

        oldImagePath = result['image'];
        selectedImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }

  Future<void> updateProductData() async {
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Search product first')),
      );
      return;
    }

    try {
      setState(() {
        isUpdating = true;
      });

      final result = await ProductApiService.updateProduct(
        token: widget.token,
        id: productId!,
        mainCategory: mainCategoryController.text.trim(),
        subCategory: subCategoryController.text.trim(),
        actualPrice: actualPriceController.text.trim(),
        currentPrice: currentPriceController.text.trim(),
        quantity: quantityController.text.trim(),
        name: nameController.text.trim(),
        imageFile: selectedImage,
        review: reviewController.text.trim(),
        availability: availabilityController.text.trim(),
        stockSize: stockSizeController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated: ${result['name']}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  Widget inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
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
    return '${ProductApiService.baseUrl}$oldImagePath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f7f7),
      body: SingleChildScrollView(
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
              inputField('Actual Price', actualPriceController),
              inputField('Current Price', currentPriceController),
              inputField('Quantity', quantityController),
              inputField('Product Name', nameController),
              inputField('Review', reviewController),
              inputField('Availability', availabilityController),
              inputField('Stock Size', stockSizeController),

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
    );
  }
}