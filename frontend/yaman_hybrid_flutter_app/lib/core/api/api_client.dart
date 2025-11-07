import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  Future<Map<String, dynamic>> get(String serviceUrl, String endpoint,
      {String? token}) async {
    final uri = Uri.parse('$serviceUrl/$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception(
          'Failed to load data from $endpoint: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> post(
      String serviceUrl, String endpoint, Map<String, dynamic> data,
      {String? token}) async {
    final uri = Uri.parse('$serviceUrl/$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      uri,
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Check if response body is empty before decoding
      if (response.bodyBytes.isEmpty) {
        return {}; // Return empty map for successful response with no body (e.g., 204 No Content)
      }
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      // Attempt to decode error message from body if available
      String errorBody = 'Unknown Error';
      try {
        errorBody = json.decode(utf8.decode(response.bodyBytes)).toString();
      } catch (_) {
        errorBody = utf8.decode(response.bodyBytes);
      }
      throw Exception(
          'Failed to post data to $endpoint: ${response.statusCode}. Details: $errorBody');
    }
  }

  // Add more methods for PUT, DELETE, etc. as needed
}
