import 'dart:convert';
import 'package:http/http.dart' as http;
import 'product_model.dart';

class ApiService {
  static const String baseUrl = 'http://172.16.131.129:8080';

  static Future<List<ProductModel>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/product-list'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  static String getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '$baseUrl$imagePath';
  }
}