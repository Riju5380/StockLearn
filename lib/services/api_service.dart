import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/course.dart';
import '../models/news_article.dart';

/// Service class handling API communication with the Admin Panel Backend.
///
/// It provides methods to fetch courses, news articles, authenticate, update password, and
/// upload profile pictures. Features a robust fallback system using mock data
/// when the server is offline.
class ApiService {
  /// Base URL of the Admin Panel API.
  ///
  /// - Android Emulator: uses '10.0.2.2' to point to host machine localhost.
  /// - iOS Simulator / Web: uses 'localhost'.
  /// - Physical Device: Change the host IP below to your Mac's IP (e.g. '192.168.0.102').
  static String get baseUrl {
    // Set this to true if you are testing on a physical mobile device:
    const bool isPhysicalDevice = false; 
    const String computerIp = '192.168.0.198'; // Your Mac's local network IP

    if (isPhysicalDevice) {
      return 'http://$computerIp:8000/api';
    }

    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://localhost:8000/api';
  }

  /// Standard HTTP Client instance.
  final http.Client _client = http.Client();

  /// Generates the standard headers list, optionally appending the Sanctum Bearer token.
  Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Sends a registration request to the backend database.
  ///
  /// Calls `POST /auth/register`. Returns the response Map on success/failure.
  Future<Map<String, dynamic>?> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: _getHeaders(),
            body: json.encode({
              'username': username,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 4));

      return json.decode(response.body) as Map<String, dynamic>?;
    } catch (e) {
      print('[ApiService] Connection to register failed: $e');
      return null;
    }
  }

  /// Sends a login request to authenticate the user and obtain a Sanctum token.
  ///
  /// Calls `POST /auth/login`. Returns the response Map on success/failure.
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: _getHeaders(),
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 4));

      return json.decode(response.body) as Map<String, dynamic>?;
    } catch (e) {
      print('[ApiService] Connection to login failed: $e');
      return null;
    }
  }

  /// Logs out the user from the backend database by revoking the Sanctum token.
  ///
  /// Calls `POST /auth/logout`. Returns `true` on successful logout.
  Future<bool> logout(String token) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/auth/logout'),
            headers: _getHeaders(token: token),
          )
          .timeout(const Duration(seconds: 4));

      return response.statusCode == 200;
    } catch (e) {
      print('[ApiService] Logout failed on server: $e');
      return false;
    }
  }

  /// Sends a request to update the user's password in the database.
  ///
  /// Calls `POST /auth/change-password` with [currentPassword] and [newPassword].
  /// Returns `true` if password was updated successfully.
  Future<bool> changePassword(
    String token,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/auth/change-password'),
            headers: _getHeaders(token: token),
            body: json.encode({
              'current_password': currentPassword,
              'new_password': newPassword,
              'new_password_confirmation': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 4));

      return response.statusCode == 200;
    } catch (e) {
      print('[ApiService] Password update failed on server: $e');
      return false;
    }
  }

  /// Fetches the user profile details.
  ///
  /// Calls `GET /auth/profile`. Returns the response Map.
  Future<Map<String, dynamic>?> fetchProfile(String token) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/auth/profile'),
            headers: _getHeaders(token: token),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('[ApiService] Fetch profile failed: $e');
      return null;
    }
  }

  /// Fetches the list of active courses from the backend database.
  ///
  /// Calls `GET /courses`. Returns a [List<Course>].
  /// If the request fails or is empty, returns an empty list.
  Future<List<Course>> fetchCourses() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/courses'), headers: _getHeaders())
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<dynamic> list;
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          final dataNode = decoded['data'];
          if (dataNode is Map<String, dynamic> &&
              dataNode.containsKey('data')) {
            list = dataNode['data'] as List;
          } else if (dataNode is List) {
            list = dataNode;
          } else {
            list = [];
          }
        } else if (decoded is List) {
          list = decoded;
        } else {
          list = [];
        }
        return list.map((item) => Course.fromJson(item)).toList();
      } else {
        print(
          '[ApiService] Server returned code ${response.statusCode} for courses.',
        );
        return [];
      }
    } catch (e) {
      print(
        '[ApiService] Connection to fetch courses failed: $e. Returning empty list.',
      );
      return [];
    }
  }

  /// Fetches detailed information of a course including modules curriculum.
  ///
  /// Calls `GET /courses/{slug}`. Returns a [Course] or `null`.
  Future<Course?> fetchCourseDetails(String slug) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/courses/$slug'), headers: _getHeaders())
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          final dataNode = decoded['data'];
          if (dataNode is Map<String, dynamic>) {
            return Course.fromJson(dataNode);
          }
        }
      }
      return null;
    } catch (e) {
      print('[ApiService] Fetch course details failed: $e');
      return null;
    }
  }

  /// Fetches the news articles from the backend database.
  ///
  /// Calls `GET /news`. Returns a [List<NewsArticle>].
  /// If the request fails or is empty, returns an empty list.
  Future<List<NewsArticle>> fetchNews() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/news'), headers: _getHeaders())
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<dynamic> list;
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          final dataNode = decoded['data'];
          if (dataNode is Map<String, dynamic> &&
              dataNode.containsKey('data')) {
            list = dataNode['data'] as List;
          } else if (dataNode is List) {
            list = dataNode;
          } else {
            list = [];
          }
        } else if (decoded is List) {
          list = decoded;
        } else {
          list = [];
        }
        return list.map((item) => NewsArticle.fromJson(item)).toList();
      } else {
        print(
          '[ApiService] Server returned code ${response.statusCode} for news.',
        );
        return [];
      }
    } catch (e) {
      print(
        '[ApiService] Connection to fetch news failed: $e. Returning empty list.',
      );
      return [];
    }
  }

  /// Uploads the user's profile image to the database.
  ///
  /// Calls `POST /profile/upload-avatar` with a base64 encoded image string [base64Image].
  /// Returns the remote URL or raw base64 string stored in the database if successful.
  Future<String?> uploadProfilePicture(String base64Image) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/profile/upload-avatar'),
            headers: _getHeaders(),
            body: json.encode({'avatar_base64': base64Image}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['avatar_url'] as String?;
      }
      return null;
    } catch (e) {
      print(
        '[ApiService] Profile avatar upload failed: $e. Falling back to local base64 storage.',
      );
      // If server is offline, return the base64 string directly so it can be rendered locally.
      return base64Image;
    }
  }
}
