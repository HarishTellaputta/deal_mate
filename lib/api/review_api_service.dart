import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/review_model.dart';

class ReviewApiService {
  static const String baseUrl =
      'http://10.51.231.80:8080/api/v1';

  static Future<List<ReviewModel>> getReviewsByBusiness(
    int businessId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/reviews/business/$businessId',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data =
          jsonDecode(response.body);

      return data
          .map(
            (json) => ReviewModel.fromJson(json),
          )
          .toList();
    }

    throw Exception(
      'Failed to load reviews: ${response.statusCode}',
    );
  }

  static Future<Map<String, dynamic>>
      getReviewSummary(
    int businessId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/reviews/business/$businessId/summary',
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load review summary: ${response.statusCode}',
    );
  }

  static Future<ReviewModel> createReview({
    required String name,
    required String mobile,
    required int rating,
    String? comment,
    required int businessId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reviews'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'mobile': mobile,
        'rating': rating,
        'comment': comment,
        'businessId': businessId,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return ReviewModel.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to submit review: ${response.statusCode}',
    );
  }
}