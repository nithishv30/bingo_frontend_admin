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
  final moreInfoController = TextEditingController();
  final nameController = TextEditingController();
  final reviewController = TextEditingController();
  final availabilityController = TextEditingController();
  final stockSizeController = TextEditingController();
  final barcodeController = TextEditingController();
  final descriptionController = TextEditingController();

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

  @override
  void dispose() {
    actualPriceController.dispose();
    currentPriceController.dispose();
    moreInfoController.dispose();
    nameController.dispose();
    reviewController.dispose();
    availabilityController.dispose();
    stockSizeController.dispose();
    barcodeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> loadMainCategories() async {
    try {
      setState(() => categoryLoading = true);
      final data = await ProductApiService.getMainCategories();

      if (!mounted) return;

      setState(() {
        mainCategories = data;
      });
    } catch (e) {
      showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => categoryLoading = false);
      }
    }
  }

  Future<void> loadSubCategories(String mainCategory) async {
    try {
      final data = await ProductApiService.getSubCategories(mainCategory);

      if (!mounted) return;

      setState(() {
        subCategories = data;
        selectedSubCategory = null;
      });
    } catch (e) {
      showMessage(e.toString());
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

    controller.dispose();

    if (value != null && value.trim().isNotEmpty) {
      final category = value.trim();

      setState(() {
        if (!mainCategories.contains(category)) {
          mainCategories.add(category);
        }
        selectedMainCategory = category;
        selectedSubCategory = null;
        subCategories = [];
      });
    }
  }

  Future<void> addNewSubCategory() async {
    if (selectedMainCategory == null) {
      showMessage('Please select main category first');
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

    controller.dispose();

    if (value != null && value.trim().isNotEmpty) {
      final category = value.trim();

      setState(() {
        if (!subCategories.contains(category)) {
          subCategories.add(category);
        }
        selectedSubCategory = category;
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

  bool validateForm() {
    if (selectedMainCategory == null) {
      showMessage('Please select main category');
      return false;
    }

    if (selectedSubCategory == null) {
      showMessage('Please select sub category');
      return false;
    }

    if (actualPriceController.text.trim().isEmpty) {
      showMessage('Please enter actual price');
      return false;
    }

    if (currentPriceController.text.trim().isEmpty) {
      showMessage('Please enter current price');
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
      showMessage('Please enter product name');
      return false;
    }

    if (stockSizeController.text.trim().isEmpty) {
      showMessage('Please enter stock size');
      return false;
    }

    if (selectedImage == null) {
      showMessage('Please select product image');
      return false;
    }

    return true;
  }

  Future<void> submitProduct() async {
    if (!validateForm()) return;

    try {
      setState(() => isLoading = true);

      final result = await ProductApiService.addProduct(
        token: widget.token,
        mainCategory: selectedMainCategory!,
        subCategory: selectedSubCategory!,
        actualPrice: actualPriceController.text.trim(),
        currentPrice: currentPriceController.text.trim(),
        moreInfo: moreInfoController.text.trim(),
        name: nameController.text.trim(),
        imageFile: selectedImage!,
        review: reviewController.text.trim(),
        availability: availabilityController.text.trim().isEmpty
            ? 'Yes'
            : availabilityController.text.trim(),
        stockSize: stockSizeController.text.trim(),
        barcode: barcodeController.text.trim(),
        description: descriptionController.text.trim(),
      );

      clearForm();

      showMessage('Product added: ${result['name'] ?? 'Success'}');
    } catch (e) {
      showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void clearForm() {
    actualPriceController.clear();
    currentPriceController.clear();
    moreInfoController.clear();
    nameController.clear();
    reviewController.clear();
    availabilityController.clear();
    stockSizeController.clear();
    barcodeController.clear();
    descriptionController.clear();

    setState(() {
      selectedImage = null;
    });
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget inputField(
      String hint,
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
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 56,
            width: 56,
            child: ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.add, color: Colors.white),
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
          : SafeArea(
        child: SingleChildScrollView(
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
              inputField('Stock Size ex: 100kg / 5L / 500ml', stockSizeController),
              inputField('Barcode optional', barcodeController),
              inputField(
                'Description',
                descriptionController,
                maxLines: 3,
              ),

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
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
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
      ),
    );
  }
}