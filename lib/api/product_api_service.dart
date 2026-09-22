import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ProductApiService {
  static const String baseUrl =
      'http://10.51.231.80:8080/api/v1';

  static Future<List<ProductModel>> getProductsByBusiness(
    int businessId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/products/business/$businessId',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data =
          jsonDecode(response.body);

      return data
          .map(
            (json) => ProductModel.fromJson(json),
          )
          .toList();
    }

    throw Exception(
      'Failed to load products: ${response.statusCode}',
    );
  }

  static Future<ProductModel> getProductById(
    int id,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/products/$id',
      ),
    );

    if (response.statusCode == 200) {
      return ProductModel.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to load product: ${response.statusCode}',
    );
  }

  static Future<List<ProductModel>> searchProducts(
    String name,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/products/search?name=${Uri.encodeComponent(name)}',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data =
          jsonDecode(response.body);

      return data
          .map(
            (json) => ProductModel.fromJson(json),
          )
          .toList();
    }

    throw Exception(
      'Failed to search products: ${response.statusCode}',
    );
  }
}