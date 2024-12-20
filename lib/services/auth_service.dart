import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';

class AuthService {
  static const String baseUrl = 'https://bubtcr.pythonanywhere.com/api';

  /// Logs in the user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        // Successful login, store token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', jsonEncode(data['user']));

        return {
          'status': true,
          'token': data['token'],
          'user': data['user'],
          'message': 'Login successful'
        };
      } else if (response.statusCode == 400 &&
          data['detail'] == "Complete the last step of registration.") {
        // Incomplete registration case
        return {
          'status': false,
          'detail': 'incomplete_registration',
          'message': 'Complete the last step of registration.'
        };
      } else if (response.statusCode == 403 &&
          data['detail'] == "Your account is pending approval.") {
        // Account pending approval case
        return {
          'status': false,
          'detail': 'pending_approval',
          'message': 'Your account is pending approval.'
        };
      } else {
        // General error
        return {
          'status': false,
          'message': data['message'] ?? 'Invalid email or password'
        };
      }
    } catch (e) {
      return {'status': false, 'message': 'An error occurred: ${e.toString()}'};
    }
  }

  /// Registers a new user
  Future<Map<String, dynamic>> register({
    required String role,
    required String email,
    required String password1,
    required String password2,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'role': role,
          'email': email,
          'password1': password1,
          'password2': password2,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || data['status'] == true) {
        return {'status': true, 'message': 'User registered successfully!'};
      } else {
        // If errors are present, concatenate them into a single string
        String errorMessage = data['errors'] != null
            ? data['errors'].values.map((e) => e.join(', ')).join('\n')
            : 'Registration failed. Please try again.';

        return {'status': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'status': false, 'message': 'An error occurred: $e'};
    }
  }

  /// Logs out the user by clearing stored data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Checks if the user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  /// Fetches the stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Fetches user profile data
  Future<ApiResponse> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse(
          status: false,
          message: 'Unauthorized: No token found.',
        );
      }

      final response = await http.get(
        Uri.parse('$baseUrl/profile/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      return ApiResponse.fromJson(data);
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred while fetching profile: ${e.toString()}',
      );
    }
  }
}
