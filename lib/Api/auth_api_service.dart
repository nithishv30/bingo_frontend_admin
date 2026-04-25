import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApiService {
  static const String baseUrl = 'http://192.168.31.178:8080';

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> registerSendOtp({
    required String name,
    required String email,
    required String password,
    required String userMobileNumber,
    required String alternativeMobileNumber,
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String country,
    required String pinCode,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/register/send-otp');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'user_mobile_number': userMobileNumber,
        'alternative_mobile_number': alternativeMobileNumber,
        'address_line_1': addressLine1,
        'address_line_2': addressLine2,
        'city': city,
        'country': country,
        'pin_code': pinCode,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> registerVerifyOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/register/verify-otp');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    return jsonDecode(response.body);
  }
}