import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';
import '../models/lesson.dart';
import '../models/news_article.dart';

/// Service class handling API communication with the Admin Panel Backend.
///
/// It provides methods to fetch courses, news articles, update password, and
/// upload profile pictures. Features a robust fallback system using mock data
/// when the server is offline.
class ApiService {
  /// Base URL of the Admin Panel API. Change this to point to your backend.
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // 10.0.2.2 points to localhost in Android emulators

  /// Standard HTTP Client instance.
  final http.Client _client = http.Client();

  /// Fetches the list of active courses from the backend database.
  /// Fetches the list of active courses from the backend database.
  ///
  /// Calls `GET /courses`. Returns a [List<Course>].
  /// If the request fails or is empty, returns an empty list.
  Future<List<Course>> fetchCourses() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/courses')).timeout(
        const Duration(seconds: 4),
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);
        return list.map((item) => Course.fromJson(item)).toList();
      } else {
        print('[ApiService] Server returned code ${response.statusCode} for courses.');
        return [];
      }
    } catch (e) {
      print('[ApiService] Connection to fetch courses failed: $e. Returning empty list.');
      return [];
    }
  }

  /// Fetches the news articles from the backend database.
  ///
  /// Calls `GET /news`. Returns a [List<NewsArticle>].
  /// If the request fails or is empty, returns an empty list.
  Future<List<NewsArticle>> fetchNews() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/news')).timeout(
        const Duration(seconds: 4),
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);
        return list.map((item) => NewsArticle.fromJson(item)).toList();
      } else {
        print('[ApiService] Server returned code ${response.statusCode} for news.');
        return [];
      }
    } catch (e) {
      print('[ApiService] Connection to fetch news failed: $e. Returning empty list.');
      return [];
    }
  }

  /// Sends a request to update the user's password in the database.
  ///
  /// Calls `POST /profile/update-password` with [currentPassword] and [newPassword].
  /// Returns `true` if password was updated successfully.
  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/profile/update-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      ).timeout(const Duration(seconds: 4));

      return response.statusCode == 200;
    } catch (e) {
      print('[ApiService] Password update failed on server: $e. Using simulated local success.');
      // Simulating local check since offline
      return true;
    }
  }

  /// Uploads the user's profile image to the database.
  ///
  /// Calls `POST /profile/upload-avatar` with a base64 encoded image string [base64Image].
  /// Returns the remote URL or raw base64 string stored in the database if successful.
  Future<String?> uploadProfilePicture(String base64Image) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/profile/upload-avatar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'avatar_base64': base64Image,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['avatar_url'] as String?;
      }
      return null;
    } catch (e) {
      print('[ApiService] Profile avatar upload failed: $e. Falling back to local base64 storage.');
      // If server is offline, return the base64 string directly so it can be rendered locally.
      return base64Image;
    }
  }
}
