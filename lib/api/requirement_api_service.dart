import 'dart:convert';

import 'package:http/http.dart' as http;

class RequirementApiService {
  static const String baseUrl =
      'http://10.51.231.80:8080/api/v1';

  static Future<void> submitRequirement({
    required String product,
    required String budget,
    required String location,
    required String purchaseTime,
    required String name,
    required String mobile,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/requirements'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'product': product,
        'budget': budget,
        'location': location,
        'purchaseTime': purchaseTime,
        'name': name,
        'mobile': mobile,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        'Failed to submit requirement: ${response.statusCode}',
      );
    }
  }
}