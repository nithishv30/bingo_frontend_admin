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
}