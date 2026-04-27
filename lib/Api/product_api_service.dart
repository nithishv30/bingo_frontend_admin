import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ProductApiService {
  static const String baseUrl = 'http://192.168.31.178:8080';

  static Future<Map<String, dynamic>> addProduct({
    required String token,
    required String mainCategory,
    required String subCategory,
    required String actualPrice,
    required String currentPrice,
    required String quantity,
    required String name,
    required File imageFile,
    required String review,
    required String availability,
    required String stockSize,
    String? barcode,
  }) async {
    final url = Uri.parse('$baseUrl/api/products');

    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['main_category'] = mainCategory;
    request.fields['sub_category'] = subCategory;
    request.fields['actual_price'] = actualPrice;
    request.fields['current_price'] = currentPrice;
    request.fields['quantity'] = quantity;
    request.fields['name'] = name;
    request.fields['review'] = review;
    request.fields['availability'] = availability;
    request.fields['stock_size'] = stockSize;

    if (barcode != null && barcode.trim().isNotEmpty) {
      request.fields['barcode'] = barcode.trim();
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'Product upload failed');
    }
  }
  static Future<Map<String, dynamic>> getProductByBarcode({
    required String barcode,
  }) async {
    final url = Uri.parse('$baseUrl/api/products/barcode/$barcode');
    print('GET URL: $url');

    final response = await http.get(url);

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    final body = jsonDecode(response.body);

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
    required String quantity,
    required String name,
    File? imageFile,
    required String review,
    required String availability,
    required String stockSize,
  }) async {
    final url = Uri.parse('$baseUrl/api/products/$id');
    final request = http.MultipartRequest('PUT', url);

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['main_category'] = mainCategory;
    request.fields['sub_category'] = subCategory;
    request.fields['actual_price'] = actualPrice;
    request.fields['current_price'] = currentPrice;
    request.fields['quantity'] = quantity;
    request.fields['name'] = name;
    request.fields['review'] = review;
    request.fields['availability'] = availability;
    request.fields['stock_size'] = stockSize;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'Update failed');
    }
  }
  static Future<List<String>> getMainCategories() async {
    final url = Uri.parse('$baseUrl/api/products/main-categories');

    final response = await http.get(url);
    final List data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data.map((e) => e.toString()).toList();
    } else {
      throw Exception('Failed to load main categories');
    }
  }

  static Future<List<String>> getSubCategories(String mainCategory) async {
    final url = Uri.parse(
      '$baseUrl/api/products/sub-categories/$mainCategory',
    );

    final response = await http.get(url);
    final List data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data.map((e) => e.toString()).toList();
    } else {
      throw Exception('Failed to load sub categories');
    }
  }
}