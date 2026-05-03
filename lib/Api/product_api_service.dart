import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ProductApiService {
  static const String baseUrl = 'http://172.16.131.129:8080';

  static Map<String, dynamic> _decodeJson(String body) {
    if (body.isEmpty) {
      throw Exception('Server returned empty response');
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> addProduct({
    required String token,
    required String mainCategory,
    required String subCategory,
    required String actualPrice,
    required String currentPrice,
    required String moreInfo,
    required String name,
    required File imageFile,
    required String review,
    required String availability,
    required String stockSize,
    String? barcode,
    required String description,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/products'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['main_category'] = mainCategory;
    request.fields['sub_category'] = subCategory;
    request.fields['actual_price'] = actualPrice;
    request.fields['current_price'] = currentPrice;
    request.fields['more_info'] = moreInfo;
    request.fields['name'] = name;
    request.fields['review'] = review;
    request.fields['availability'] = availability;
    request.fields['stock_size'] = stockSize;
    request.fields['description'] = description;

    if (barcode != null && barcode.trim().isNotEmpty) {
      request.fields['barcode'] = barcode.trim();
    }

    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final body = _decodeJson(response.body);

    if (response.statusCode == 200) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'Product upload failed');
    }
  }

  static Future<Map<String, dynamic>> getProductByBarcode({
    required String barcode,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/barcode/$barcode'),
    );

    final body = _decodeJson(response.body);

    if (response.statusCode == 200) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'Product not found');
    }
  }

  static Future<Map<String, dynamic>> updateProduct({
    required String token,
    required int id,
    required String mainCategory,
    required String subCategory,
    required String actualPrice,
    required String currentPrice,
    required String moreInfo,
    required String name,
    File? imageFile,
    required String review,
    required String availability,
    required String stockSize,
    required String description,
  }) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/api/products/$id'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['main_category'] = mainCategory;
    request.fields['sub_category'] = subCategory;
    request.fields['actual_price'] = actualPrice;
    request.fields['current_price'] = currentPrice;
    request.fields['more_info'] = moreInfo;
    request.fields['name'] = name;
    request.fields['review'] = review;
    request.fields['availability'] = availability;
    request.fields['stock_size'] = stockSize;
    request.fields['description'] = description;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final body = _decodeJson(response.body);

    if (response.statusCode == 200) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'Update failed');
    }
  }

  static Future<List<String>> getMainCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/main-categories'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e.toString()).toList();
    } else {
      throw Exception('Failed to load main categories');
    }
  }

  static Future<List<String>> getSubCategories(String mainCategory) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/sub-categories/$mainCategory'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e.toString()).toList();
    } else {
      throw Exception('Failed to load sub categories');
    }
  }
}