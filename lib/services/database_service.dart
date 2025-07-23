import '../models/company_model.dart';
import '../models/localities_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DatabaseService {
  static const String baseUrl = 'http://localhost:8080/v1/auth/1/dashboard';
  // Simulate database call for localities
  // Future<List<String>> getLocalities() async {
  //   // Replace this with your actual database call
  //   await Future.delayed(const Duration(seconds: 1)); // Simulate loading
  //   // Return localities from your database
  //   return [
  //     'Marathahalli',
  //     'MG Layout',
  //     'Whitefield',
  //     'Koramangala',
  //     'Bellandur',
  //     'Electronic City',
  //     'Indiranagar',
  //     'HSR Layout',
  //   ];
  // }

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

  static Future<List<Locality>> fetchLocalities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/localities'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((json) => Locality.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load localities');
    }
  }

  // this method help to get all Locality Name from the database
  static Future<List<String>> fetchLocalityNames() async {
    final response = await http.get(
      Uri.parse('$baseUrl/localities'),
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
  static Future<List<String>> fetchjobCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/job-categories'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map<String>((json) => json['name'] as String).toList();
    } else {
      throw Exception('Failed to load locality names');
    }
  }

  
}
