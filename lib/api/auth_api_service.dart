import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/login_response.dart';

class AuthApiService {
  static const String baseUrl =
      'http://10.51.231.80:8080/api/v1';

  // ----------------------------------------------------------
  // LOGIN
  // ----------------------------------------------------------

  Future<LoginResponse> login({
    required String mobile,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'mobile': mobile,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return LoginResponse.fromJson(data);
    }

    throw Exception(
      data['message'] ?? 'Login failed',
    );
  }

  // ----------------------------------------------------------
  // BUSINESS REGISTRATION
  // ----------------------------------------------------------

  Future<LoginResponse> registerBusiness({
    required String ownerName,
    required String mobile,
    required String password,
    required String businessName,
    required String location,
    String? whatsapp,
    String? address,
    String? description,
    required int categoryId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/business-register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'ownerName': ownerName,
        'mobile': mobile,
        'password': password,
        'businessName': businessName,
        'location': location,
        'whatsapp': whatsapp,
        'address': address,
        'description': description,
        'categoryId': categoryId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return LoginResponse.fromJson(data);
    }

    throw Exception(
      data['message'] ?? 'Business registration failed',
    );
  }
}