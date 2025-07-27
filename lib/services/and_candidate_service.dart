import 'dart:io';

import '../models/company_model.dart';
import '../models/localities_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/company_id_name_model.dart';
import '../models/candidate_create_model.dart';
import 'package:http_parser/http_parser.dart';

class AddCandidateService {
  static const String baseUrl = 'http://localhost:8080/v1/auth';

  // this method help to get all Locality Name from the database
  static Future<List<String>> fetchLocalityNames(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$userId/add-candidate/get-localities'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map<String>((json) => json['name'] as String).toList();
    } else {
      throw Exception('Failed to load locality names');
    }
  }

  // this method help to get all Job Role Categories Name from the database
  static Future<List<String>> fetchjobCategories(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$userId/add-candidate/get-categories'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map<String>((json) => json['name'] as String).toList();
    } else {
      throw Exception('Failed to load locality names');
    }
  }

  // Simulate database call for companies
  Future<List<Company>> getCompanies() async {
    // Replace this with your actual database call
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading
    // Return companies from your database
    return [
      Company(
        id: '1',
        name: 'Tech Solutions Pvt Ltd',
        address: 'The Skyline • Seoul Plaza Rd',
      ),
      Company(
        id: '2',
        name: 'Innovation Hub Corp',
        address: 'Tech Park • Whitefield',
      ),
      Company(
        id: '3',
        name: 'Digital Dynamics Ltd',
        address: 'Business Hub • Koramangala',
      ),
    ];
  }

  static Future<List<CompanyIdName>> fetchJobIdAndCompanyNames(
    String userId,
  ) async {
    final url = Uri.parse('$baseUrl/$userId/add-candidate/get-companys');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((json) => CompanyIdName.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load job company names');
    }
  }

  // static Future<bool> createCandidate(
  //   CandidateCreateDTO candidate,
  //   String userId,
  //   File? _resumeFile,
  // ) async {
  //   final url = Uri.parse('$baseUrl/$userId/add-candidate');
  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode(candidate.toJson()),
  //   );
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     return true;
  //   } else {
  //     print('Failed to create candidate: ${response.body}');
  //     return false;
  //   }
  // }

  // static Future<bool> createCandidate(
  //   CandidateCreateDTO candidate,
  //   String userId,
  //   File? resumeFile,
  // ) async {
  //   final url = Uri.parse(
  //     '$baseUrl/$userId/dashboard/add-candidates',
  //   ); // Endpoint expects ?userid= in body, not URL
  //   final request = http.MultipartRequest('POST', url)
  //     ..fields['userid'] = userId
  //     ..fields['candidate'] = json.encode(candidate.toJson());
  //   if (resumeFile != null) {
  //     request.files.add(
  //       await http.MultipartFile.fromPath('resume', resumeFile.path),
  //     );
  //   }
  //   try {
  //     final streamedResponse = await request.send();
  //     final response = await http.Response.fromStream(streamedResponse);
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return true;
  //     } else {
  //       print('Failed to create candidate: ${response.body}');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Error uploading candidate: $e');
  //     return false;
  //   }
  // }

  static Future<bool> createCandidate(
    CandidateCreateDTO candidate,
    String userId,
    File? resumeFile,
  ) async {
    final url = Uri.parse('$baseUrl/$userId/dashboard/add-candidates');

    final request = http.MultipartRequest('POST', url)
      ..fields['userId'] = userId
      ..fields['candidate'] = json.encode(candidate.toJson());

    if (resumeFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'resume',
          resumeFile.path,
          contentType: MediaType(
            'application',
            'pdf',
          ), // or infer based on file
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed: ${response.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception: $e');
      return false;
    }
  }
}
