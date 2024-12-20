import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://bubtcr.pythonanywhere.com/api';
  final String token;

  ApiService({required this.token});

  // Fetch Upcoming Exams
  Future<List<Map<String, dynamic>>> getUpcomingExams() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/upcoming-exams/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('Error fetching upcoming exams: $e');
      return [];
    }
  }

  // Fetch Profile data with this api - https://bubtcr.pythonanywhere.com/api/profile/
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load profile data with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      rethrow;
    }
  }

  // Fetch Announcements
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/announcements/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('Error fetching announcements: $e');
      return [];
    }
  }

  // Add Exam
  Future<bool> addExam({
    required String examName,
    required String courseName,
    required String courseCode,
    required DateTime date,
    required String topic,
    required String detail,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/upcoming-exams/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'exam_name': examName,
          'course_name': courseName,
          'course_code': courseCode,
          'date':
              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
          'topic': topic,
          'detail': detail,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error adding exam: $e');
      return false;
    }
  }

  // Fetch Exam Details
  Future<Map<String, dynamic>> getExamDetails(String examId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/upcoming-exams/update/$examId/'), // Correct endpoint
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load exam details with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching exam details: $e');
      rethrow;
    }
  }

  // Update Exam
  Future<bool> updateExam({
    required String examId,
    required String examName,
    required String courseName,
    required String courseCode,
    required DateTime date,
    required String topic,
    required String detail,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/upcoming-exams/update/$examId/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'exam_name': examName,
          'course_name': courseName,
          'course_code': courseCode,
          'date':
              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
          'topic': topic,
          'detail': detail,
        }),
      );

      if (response.statusCode == 200) {
        print('Exam updated successfully.');
        return true;
      } else {
        print(
            'Failed to update exam. Status Code: ${response.statusCode}, Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating exam: $e');
      return false;
    }
  }

  // Delete Exam
  Future<bool> deleteExam(String examId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/upcoming-exams/delete/$examId/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        print('Exam deleted successfully.');
        return true;
      } else {
        print(
            'Failed to delete exam. Status Code: ${response.statusCode}, Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting exam: $e');
      return false;
    }
  }

// Logout User
  Future<bool> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('token'); // Remove token from storage
        print('Logout successful.');
        return true;
      } else {
        print('Failed to logout. Status Code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }

// Add this method in your ApiService class
  Future<bool> addAnnouncement(String announcement) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/announcements/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'announcement': announcement,
        }),
      );

      if (response.statusCode == 201) {
        print('Announcement added successfully.');
        return true;
      } else {
        print('Failed to add announcement: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding announcement: $e');
      return false;
    }
  }

  // Fetch Departments (Public API)
  Future<List<dynamic>> getDepartments() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/departments/'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
      return [];
    } catch (e) {
      print('Error fetching departments: $e');
      return [];
    }
  }

  // Fetch Sections (Public API)
  Future<List<dynamic>> getSections() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sections/'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
      return [];
    } catch (e) {
      print('Error fetching sections: $e');
      return [];
    }
  }

  // Fetch Intakes (Public API)
  Future<List<dynamic>> getIntakes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/intekes/'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
      return [];
    } catch (e) {
      print('Error fetching intakes: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> registerFinalStep(
      Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register/v2/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        return {'status': true, 'message': 'Registration successful'};
      } else {
        return jsonDecode(response.body); // Return error message
      }
    } catch (e) {
      print('Error during final registration: $e');
      return {'status': false, 'message': 'Error occurred'};
    }
  }

  Future<Map<String, dynamic>> checkApproval() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/register/v1/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body); // Return JSON response
      } else {
        throw Exception('Failed to check account approval status.');
      }
    } catch (e) {
      print('Error checking account approval: $e');
      return {
        'status': false,
        'filled': false,
        'message': 'Error occurred while checking approval.',
      };
    }
  }

  Future<List<dynamic>> getPendings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pendings/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response as a List directly
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to fetch pending applications.');
      }
    } catch (e) {
      print('Error fetching pending applications: $e');
      return []; // Return an empty list on error
    }
  }

  Future<bool> approvePendingApplication(String uid) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pendings/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'uid': uid}),
      );

      if (response.statusCode == 200) {
        return true; // Approval successful
      } else {
        print('Error approving application: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error approving application: $e');
      return false;
    }
  }

  Future<bool> deletePendingApplication(String uid) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/pendings/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'uid': uid}),
      );

      if (response.statusCode == 200) {
        return true; // Deletion successful
      } else {
        print('Error deleting application: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting application: $e');
      return false;
    }
  }
}
