import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job_model_create.dart';

class JobService {
  static const String baseUrl =
      'http://localhost:8080/v1/auth'; // Update to your serve

  static Future<List<Job>> fetchJobsByUserId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$userId/jobs'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        // return <List<Job>>.fromJson(jsonData);
        return jsonData.map((e) => Job.fromJson(e)).toList();
      } else {
        throw Exception('Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('JobService fetch error: $e');
      rethrow;
    }
  }

  static Future<void> createJob(Job job, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$userId/jobs'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(job.toJsonCreate()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create job');
    }
  }

  static Future<void> updateJob(Job job) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${job.userId}/jobs'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(job.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update job');
    }
  }

  static Future<void> deleteJob(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete job');
    }
  }

  // static Future<bool> createJob(JobModel job) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/create'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode(job.toJson()),
  //   );

  //   if (response.statusCode == 201) {
  //     return true;
  //   } else {
  //     print('Failed to post job: ${response.body}');
  //     return false;
  //   }
  // }
}
