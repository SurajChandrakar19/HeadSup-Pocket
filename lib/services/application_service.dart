import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;

class ReachedCandidateService {
  static const String baseUrl = 'http://localhost:8080/v1/auth';

  static Future<List<Map<String, dynamic>>> fetchReachedCandidates(
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$userId/applications/reached-candidates'),
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

  static Future<void> downloadReachedCandidatesCSV(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$userId/applications/export'),
    );

    if (response.statusCode == 200) {
      if (kIsWeb) {
        // Web download logic
        downloadCsvInWeb(response.body, 'reached_candidates.csv');
      } else {
        // Mobile/Desktop logic
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/reached_candidates.csv';
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
}

class CandidateTrack {
  static const String baseUrl = 'http://localhost:8080/v1/auth';

  static Future<bool> updateStatus(
    String candidateId,
    String newStatus,
    String userId,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$userId/applications/update-status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'candidateId': int.parse(candidateId),
          'userId': int.parse(userId),
          'status': newStatus.toUpperCase(),
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        // Optionally log error
        return false;
      }
    } catch (e) {
      // Handle exception (e.g., network issues)
      rethrow;
    }
  }
}
