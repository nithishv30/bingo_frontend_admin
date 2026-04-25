import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Api/product_api_service.dart';

class Upload extends StatefulWidget {
  final String token;

  const Upload({
    super.key,
    required this.token,
  });

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  final mainCategoryController = TextEditingController();
  final subCategoryController = TextEditingController();
  final actualPriceController = TextEditingController();
  final currentPriceController = TextEditingController();
  final quantityController = TextEditingController();
  final nameController = TextEditingController();
  final reviewController = TextEditingController();
  final availabilityController = TextEditingController();
  final stockSizeController = TextEditingController();
  final barcodeController = TextEditingController();

  File? selectedImage;
  bool isLoading = false;

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

  Future<void> submitProduct() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select product image')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final result = await ProductApiService.addProduct(
        token: widget.token,
        mainCategory: mainCategoryController.text.trim(),
        subCategory: subCategoryController.text.trim(),
        actualPrice: actualPriceController.text.trim(),
        currentPrice: currentPriceController.text.trim(),
        quantity: quantityController.text.trim(),
        name: nameController.text.trim(),
        imageFile: selectedImage!,
        review: reviewController.text.trim(),
        availability: availabilityController.text.trim(),
        stockSize: stockSizeController.text.trim(),
        barcode: barcodeController.text.trim(),
      );

      actualPriceController.clear();
      currentPriceController.clear();
      quantityController.clear();
      nameController.clear();
      reviewController.clear();
      availabilityController.clear();
      stockSizeController.clear();
      barcodeController.clear();

      setState(() {
        selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added: ${result['name']}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget inputField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            inputField('Main Category', mainCategoryController),
            inputField('Sub Category', subCategoryController),
            inputField('Actual Price', actualPriceController),
            inputField('Current Price', currentPriceController),
            inputField('Quantity', quantityController),
            inputField('Product Name', nameController),
            inputField('Review', reviewController),
            inputField('Availability', availabilityController),
            inputField('Stock Size', stockSizeController),
            inputField('Barcode optional', barcodeController),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: selectedImage == null
                    ? const Center(child: Text('Select Image'))
                    : Image.file(selectedImage!, fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitProduct,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Add Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}