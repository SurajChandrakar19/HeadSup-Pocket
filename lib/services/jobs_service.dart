import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/job_model_create.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;

import 'package:flutter/foundation.dart' show kIsWeb;

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

  static Future<void> downloadJobsCSV(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId/jobs/export'));

    if (response.statusCode == 200) {
      if (kIsWeb) {
        // Web download logic
        downloadCsvInWeb(response.body, 'reached_candidates.csv');
      } else {
        // Mobile/Desktop logic
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/jobs.csv';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        print('CSV downloaded at $filePath');
      }
    } else {
      throw Exception(
        'Failed to download CSV. Status code: ${response.statusCode}',
      );
    }
  }

  static void downloadCsvInWeb(String csvData, String filename) {
    final bytes = utf8.encode(csvData);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", filename)
      ..click();
    html.Url.revokeObjectUrl(url);
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
