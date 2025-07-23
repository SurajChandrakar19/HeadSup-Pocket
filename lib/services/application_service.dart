import 'dart:convert';
import 'package:http/http.dart' as http;

class ReachedCandidateService {
  static const String baseUrl = 'http://localhost:8080/v1/auth';

  static Future<List<Map<String, dynamic>>> fetchReachedCandidates(
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$userId/application/reached-candidates'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        // Convert List<dynamic> to List<Map<String, dynamic>>
        final List<Map<String, dynamic>> result = jsonList
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        return result;
      } else if (response.statusCode == 404) {
        throw Exception('Reached candidates not found for userId: $userId');
      } else {
        throw Exception(
          'Failed to load reached candidates. Status code: ${response.statusCode}',
        );
      }
    } catch (error) {
      // Optional: you can log the error or send it to an error tracking system
      throw Exception('Error fetching reached candidates: $error');
    }
  }

  
}
