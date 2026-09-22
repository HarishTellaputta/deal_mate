import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/business_model.dart';

class BusinessApiService {
  static const String baseUrl =
      'http://10.51.231.80:8080/api/v1';

  static const String serverBaseUrl =
      'http://10.51.231.80:8080';

  static Future<List<BusinessModel>> getBusinesses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/businesses'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((json) => BusinessModel.fromJson(json))
          .toList();
    }

    throw Exception(
      'Failed to load businesses: ${response.statusCode}',
    );
  }

  static Future<List<BusinessModel>> getBusinessesByCategory(
    int categoryId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/businesses/category/$categoryId',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((json) => BusinessModel.fromJson(json))
          .toList();
    }

    throw Exception(
      'Failed to load businesses by category: ${response.statusCode}',
    );
  }

  static Future<BusinessModel> getBusinessById(
    int id,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/businesses/$id'),
    );

    if (response.statusCode == 200) {
      return BusinessModel.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to load business: ${response.statusCode}',
    );
  }

  static Future<List<BusinessModel>> searchBusinesses(
    String name,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/businesses/search?name=${Uri.encodeComponent(name)}',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((json) => BusinessModel.fromJson(json))
          .toList();
    }

    throw Exception(
      'Failed to search businesses: ${response.statusCode}',
    );
  }

  static Future<BusinessModel> updateBusiness({
    required int businessId,
    required String token,
    required String name,
    required String mobile,
    String? whatsapp,
    required String location,
    String? address,
    String? description,
    String? imageUrl,
    required int categoryId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/businesses/$businessId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'mobile': mobile,
        'whatsapp': whatsapp,
        'location': location,
        'address': address,
        'description': description,
        'imageUrl': imageUrl,
        'categoryId': categoryId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return BusinessModel.fromJson(data);
    }

    throw Exception(
      data['message'] ?? 'Failed to update business',
    );
  }

  // ----------------------------------------------------------
  // BUSINESS IMAGE UPLOAD - WEB SAFE
  // ----------------------------------------------------------

  static Future<String> uploadBusinessImageBytes({
    required int businessId,
    required String token,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/businesses/upload-image?businessId=$businessId',
    );

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    request.headers['Authorization'] =
        'Bearer $token';

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: fileName,
      ),
    );

    final streamedResponse = await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        final imageUrl = data['imageUrl'];

        if (imageUrl != null &&
            imageUrl.toString().trim().isNotEmpty) {
          final value =
              imageUrl.toString().trim();

          if (value.startsWith('http://') ||
              value.startsWith('https://')) {
            return value;
          }

          return '$serverBaseUrl$value';
        }
      }

      if (data is String &&
          data.trim().isNotEmpty) {
        final value = data.trim();

        if (value.startsWith('http://') ||
            value.startsWith('https://')) {
          return value;
        }

        return '$serverBaseUrl$value';
      }

      throw Exception(
        'Image uploaded but image URL was not returned.',
      );
    }

    String message =
        'Failed to upload business image.';

    try {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic> &&
          data['message'] != null) {
        message = data['message'].toString();
      }
    } catch (_) {}

    throw Exception(message);
  }
}