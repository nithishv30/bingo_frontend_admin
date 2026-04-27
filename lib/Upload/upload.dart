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
  final actualPriceController = TextEditingController();
  final currentPriceController = TextEditingController();
  final quantityController = TextEditingController();
  final nameController = TextEditingController();
  final reviewController = TextEditingController();
  final availabilityController = TextEditingController();
  final stockSizeController = TextEditingController();
  final barcodeController = TextEditingController();

  List<String> mainCategories = [];
  List<String> subCategories = [];

  String? selectedMainCategory;
  String? selectedSubCategory;

  File? selectedImage;
  bool isLoading = false;
  bool categoryLoading = false;

  @override
  void initState() {
    super.initState();
    loadMainCategories();
  }

  Future<void> loadMainCategories() async {
    try {
      setState(() => categoryLoading = true);
      final data = await ProductApiService.getMainCategories();
      setState(() => mainCategories = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => categoryLoading = false);
    }
  }

  Future<void> loadSubCategories(String mainCategory) async {
    try {
      final data = await ProductApiService.getSubCategories(mainCategory);
      setState(() {
        subCategories = data;
        selectedSubCategory = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> addNewMainCategory() async {
    final controller = TextEditingController();

    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Main Category'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter main category',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  Navigator.pop(context, text);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (value != null && value.isNotEmpty) {
      setState(() {
        if (!mainCategories.contains(value)) {
          mainCategories.add(value);
        }
        selectedMainCategory = value;
        selectedSubCategory = null;
        subCategories = [];
      });
    }
  }

  Future<void> addNewSubCategory() async {
    if (selectedMainCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select main category first')),
      );
      return;
    }

    final controller = TextEditingController();

    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Sub Category'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter sub category',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  Navigator.pop(context, text);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (value != null && value.isNotEmpty) {
      setState(() {
        if (!subCategories.contains(value)) {
          subCategories.add(value);
        }
        selectedSubCategory = value;
      });
    }
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

  Future<void> submitProduct() async {
    if (selectedMainCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select main category')),
      );
      return;
    }

    if (selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select sub category')),
      );
      return;
    }

    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select product image')),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final result = await ProductApiService.addProduct(
        token: widget.token,
        mainCategory: selectedMainCategory!,
        subCategory: selectedSubCategory!,
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
      setState(() => isLoading = false);
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

  Widget dropdownWithAddButton({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required VoidCallback onAdd,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: categoryLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            dropdownWithAddButton(
              hint: 'Select Main Category',
              value: selectedMainCategory,
              items: mainCategories,
              onAdd: addNewMainCategory,
              onChanged: (value) {
                setState(() {
                  selectedMainCategory = value;
                  selectedSubCategory = null;
                  subCategories = [];
                });

                if (value != null) {
                  loadSubCategories(value);
                }
              },
            ),

            dropdownWithAddButton(
              hint: 'Select Sub Category',
              value: selectedSubCategory,
              items: subCategories,
              onAdd: addNewSubCategory,
              onChanged: (value) {
                setState(() {
                  selectedSubCategory = value;
                });
              },
            ),

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