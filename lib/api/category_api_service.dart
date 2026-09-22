import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/category_model.dart';

class CategoryApiService {
  static const String baseUrl =
      'http://10.51.231.80:8080/api/v1';

  static Future<List<CategoryModel>> getCategories() async {
    final url = '$baseUrl/categories';

    debugPrint('========== CATEGORY API ==========');
    debugPrint('URL: $url');
    debugPrint('Sending GET request...');

    try {
      final response = await http.get(
        Uri.parse(url),
      );

      debugPrint(
        'Status Code: ${response.statusCode}',
      );

      debugPrint(
        'Response Headers: ${response.headers}',
      );

      debugPrint(
        'Response Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            jsonDecode(response.body);

        debugPrint(
          'Categories Count: ${data.length}',
        );

        for (final category in data) {
          debugPrint(
            'Category: $category',
          );
        }

        final categories = data
            .map(
              (json) => CategoryModel.fromJson(json),
            )
            .toList();

        debugPrint(
          'Parsed Categories: ${categories.length}',
        );

        debugPrint(
          '=================================',
        );

        return categories;
      }

      debugPrint(
        'CATEGORY API ERROR: HTTP ${response.statusCode}',
      );

      debugPrint(
        '=================================',
      );

      throw Exception(
        'Failed to load categories: ${response.statusCode}',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'CATEGORY API EXCEPTION: $e',
      );

      debugPrint(
        'STACK TRACE: $stackTrace',
      );

      debugPrint(
        '=================================',
      );

      rethrow;
    }
  }
}