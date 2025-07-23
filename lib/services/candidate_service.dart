import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/candidate_model.dart';

class CandidateService {
  static const String baseUrl = 'http://localhost:8080/v1/auth';

  /// Insert reached candidate
  static Future<bool> markCandidateReached(
    String userId,
    int candidateId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/$userId/candidates/$candidateId/reached-candidates',
    );
    final response = await http.post(url);

    if (response.statusCode == 201) {
      return true; // inserted successfully
    } else {
      // optional: you could parse response.body for error message
      throw Exception('Failed to mark candidate as reached: ${response.body}');
    }
  }

  /// GET all candidates
  static Future<List<Map<String, dynamic>>> fetchCandidates(
    String userId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$userId/candidates/unreached'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonList);
    } else if (response.statusCode == 400) {
      return [];
    } else {
      throw Exception('Failed to load candidates');
    }
  }

  /// GET candidate by ID
  static Future<Candidate> fetchCandidateById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Candidate.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load candidate with id $id');
    }
  }

  /// POST a new candidate
  static Future<bool> addCandidate(Candidate candidate) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(_candidateToJson(candidate)),
    );
    return response.statusCode == 201;
  }

  /// POST update to Go For Interview
  static Future<bool> goForInterview(String clientId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$userId/candidates/$clientId/gfi'),
      );

      if (response.statusCode == 201) {
        // or check other status codes or parse response.body if needed
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Handle exception (e.g., network error)
      print('Error in goForInterview: $e');
      return false;
    }
  }

  /// PUT or PATCH to update candidate
  // static Future<bool> updateCandidate(int id, Candidate candidate) async {
  //   final response = await http.put(
  //     Uri.parse('$baseUrl/$id/update'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode(_candidateToJson(candidate)),
  //   );
  //   return response.statusCode == 200;
  // }

  // update One candidate at a time
  Future<bool> updateCandidate(
    Map<String, dynamic> candidate,
    String userId,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/$userId/candidates/${candidate['id']}');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(candidate),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update candidate: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception when updating candidate: $e');
      return false;
    }
  }

  /// DELETE a candidate
  static Future<bool> deleteCandidate(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id/delete'));
    return response.statusCode == 200;
  }

  /// Internal helper to convert model to JSON
  static Map<String, dynamic> _candidateToJson(Candidate c) {
    return {
      'id': c.id,
      'name': c.name,
      'role': c.role,
      'location': c.location,
      'qualification': c.qualification,
      'experience': c.experience,
      'age': c.age,
      'phone': c.phone,
      'rating': c.rating,
      'addedDate': c.addedDate,
      'notes': c.notes,
      'interviewTime': c.interviewTime,
    };
  }
}
