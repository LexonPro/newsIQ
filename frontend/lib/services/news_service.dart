import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NewsService {
  static const String defaultUrl = "http://10.221.231.192:8000";
  static String activeUrl = defaultUrl;
  static bool hasInitialized = false;

  /// Dynamically loads the saved backend URL, falling back to local host addresses
  /// if the preset server is unreachable.
  static Future<void> _initializeUrl() async {
    if (hasInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      activeUrl = prefs.getString("backend_url") ?? defaultUrl;
      hasInitialized = true;
    } catch (_) {
      activeUrl = defaultUrl;
    }
  }

  /// Sends a request with self-healing fallback if the main backend URL fails.
  static Future<http.Response> _safeGet(String path) async {
    await _initializeUrl();
    try {
      // Attempt connection with a short 3-second timeout
      final response = await http.get(Uri.parse("$activeUrl$path")).timeout(const Duration(seconds: 3));
      return response;
    } catch (e) {
      debugPrint("Connection to $activeUrl failed: $e. Attempting self-healing fallback...");
      
      // If we failed and are currently using the default hardcoded remote IP, attempt local fallbacks
      if (activeUrl == defaultUrl) {
        final List<String> fallbacks = [
          // Android Emulator loopback to host
          if (defaultTargetPlatform == TargetPlatform.android) "http://10.0.2.2:8000",
          // Localhost loopback
          "http://127.0.0.1:8000",
          "http://localhost:8000",
        ];

        for (final fallback in fallbacks) {
          try {
            debugPrint("Trying fallback backend: $fallback...");
            final response = await http.get(Uri.parse("$fallback$path")).timeout(const Duration(seconds: 2));
            
            // Connection succeeded! Update activeUrl and cache it for future launches
            activeUrl = fallback;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString("backend_url", fallback);
            debugPrint("Successfully switched backend URL to: $fallback");
            return response;
          } catch (_) {
            // Keep trying other fallbacks
          }
        }
      }
      // If fallbacks fail or we aren't using the default, rethrow the original exception
      rethrow;
    }
  }

  static Future<List<dynamic>> fetchNews({
    String category = "technology",
  }) async {
    final response = await _safeGet("/news/$category");
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> searchNews(
    String query,
  ) async {
    final response = await _safeGet("/search/$query");
    return jsonDecode(response.body);
  }
}